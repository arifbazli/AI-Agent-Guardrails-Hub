#!/usr/bin/env python3
"""
Research Agent — Policy Intelligence Scanner
=============================================
Fetches threat intelligence from NVD and CISA KEV, performs a gap analysis
against existing OPA guardrail rules, and updates the research log.

Usage
-----
python3 scripts/research_agent.py [--test-connections] [--dry-run] [--max-cves N] [--force-scan]

Environment variables
---------------------
NIST_API_KEY   – optional NVD API key (increases rate-limit)
GITHUB_TOKEN   – required when opening a PR for gap results
GITHUB_OUTPUT  – set automatically in GitHub Actions
LOOKBACK_DAYS  – number of days to look back for CVEs (default: 30)
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from datetime import datetime, timedelta, timezone
from pathlib import Path


# ---------------------------------------------------------------------------
# HTTP helper — fetch with retry / exponential backoff
# ---------------------------------------------------------------------------

_RETRY_STATUS_CODES = {429, 500, 502, 503, 504}
_MAX_FETCH_ATTEMPTS = 3
_INITIAL_BACKOFF    = 5   # seconds


def _fetch_with_retry(
    url: str,
    headers: dict[str, str] | None = None,
    timeout: int = 30,
) -> bytes:
    """Fetch *url* and return the raw response body.

    Retries up to ``_MAX_FETCH_ATTEMPTS`` times with exponential backoff on
    transient HTTP errors (429, 5xx) and network-level exceptions.  On a 429
    the ``Retry-After`` response header is honoured when present (both
    delta-seconds and HTTP-date formats are supported).

    Raises the last exception when all attempts are exhausted.
    """
    headers = headers or {}
    last_exc: Exception | None = None
    delay = _INITIAL_BACKOFF

    for attempt in range(1, _MAX_FETCH_ATTEMPTS + 1):
        try:
            req = urllib.request.Request(url, headers=headers)
            with urllib.request.urlopen(req, timeout=timeout) as resp:
                return resp.read()
        except urllib.error.HTTPError as exc:
            last_exc = exc
            if exc.code not in _RETRY_STATUS_CODES or attempt == _MAX_FETCH_ATTEMPTS:
                raise
            # Honour Retry-After when the server sends it (common on 429).
            # The header may be delta-seconds ("120") or an HTTP-date string.
            retry_after = exc.headers.get("Retry-After") if exc.headers else None
            if retry_after:
                try:
                    delay = max(delay, int(retry_after))
                except ValueError:
                    # HTTP-date format — parse and compute remaining seconds.
                    from email.utils import parsedate_to_datetime  # stdlib
                    try:
                        retry_dt = parsedate_to_datetime(retry_after)
                        seconds_until = int(
                            (retry_dt - datetime.now(timezone.utc)).total_seconds()
                        )
                        if seconds_until > 0:
                            delay = max(delay, seconds_until)
                    except Exception:  # noqa: BLE001
                        pass  # fall back to current exponential delay
            print(
                f"WARNING: HTTP {exc.code} on attempt {attempt}/{_MAX_FETCH_ATTEMPTS} "
                f"— retrying in {delay}s",
                file=sys.stderr,
            )
            time.sleep(delay)
            delay *= 2
        except (OSError, urllib.error.URLError) as exc:
            last_exc = exc
            if attempt == _MAX_FETCH_ATTEMPTS:
                raise
            print(
                f"WARNING: network error on attempt {attempt}/{_MAX_FETCH_ATTEMPTS} "
                f"({exc}) — retrying in {delay}s",
                file=sys.stderr,
            )
            time.sleep(delay)
            delay *= 2

    # Defensive guard: in practice every loop iteration that does not return
    # assigns to last_exc before reaching here, but this keeps type-checkers
    # satisfied and makes the intent explicit.
    if last_exc is None:
        raise RuntimeError(f"All {_MAX_FETCH_ATTEMPTS} fetch attempts failed for {url}")
    raise last_exc


# ---------------------------------------------------------------------------
# Connection test
# ---------------------------------------------------------------------------

def test_connections() -> dict[str, dict]:
    """Test all external API connections before running the full scan.

    Returns a dict mapping source name → ``{"status": "connected"|"failed", ...}``.
    Prints a one-line status line for each source.
    """
    results: dict[str, dict] = {}

    # Test NVD API
    try:
        data  = json.loads(_fetch_with_retry(
            "https://services.nvd.nist.gov/rest/json/cves/2.0?resultsPerPage=1",
            headers={"User-Agent": "agent-guardrails/1.0"},
        ))
        count = data.get("totalResults", 0)
        results["nvd"] = {"status": "connected", "total_cves": count}
        print(f"✅ NVD API: {count} CVEs available")
    except Exception as exc:  # noqa: BLE001
        results["nvd"] = {"status": "failed", "error": str(exc)}
        print(f"❌ NVD API: {exc}")

    # Test CISA KEV
    try:
        data  = json.loads(_fetch_with_retry(
            "https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json",
            headers={"User-Agent": "agent-guardrails/1.0"},
        ))
        vulns = data.get("vulnerabilities", [])
        results["cisa"] = {"status": "connected", "total_vulns": len(vulns)}
        print(f"✅ CISA KEV: {len(vulns)} vulnerabilities")
    except Exception as exc:  # noqa: BLE001
        results["cisa"] = {"status": "failed", "error": str(exc)}
        print(f"❌ CISA KEV: {exc}")

    # Write failing sources to GITHUB_OUTPUT so the workflow classifier can
    # read them without parsing stdout.
    github_output = os.environ.get("GITHUB_OUTPUT")
    if github_output:
        failing = [name for name, r in results.items() if r["status"] != "connected"]
        with open(github_output, "a") as fh:
            fh.write(f"failing_sources={','.join(failing)}\n")

    return results


# ---------------------------------------------------------------------------
# NVD fetch
# ---------------------------------------------------------------------------

def fetch_nvd(max_cves: int = 100) -> list[dict]:
    """Fetch recent CVEs from NVD relevant to CI/CD and container tooling."""
    keywords = [
        "Harness", "OPA", "Open Policy Agent", "GitHub Actions",
        "Docker", "Kubernetes", "CI/CD", "supply chain", "secrets",
    ]

    lookback_days = _lookback_window()
    end_date   = datetime.now(timezone.utc)
    start_date = end_date - timedelta(days=lookback_days)
    start_str  = start_date.strftime("%Y-%m-%dT%H:%M:%S.000")
    end_str    = end_date.strftime("%Y-%m-%dT%H:%M:%S.000")

    per_keyword = max(1, max_cves // len(keywords))
    results: list[dict] = []

    for kw in keywords:
        url = (
            f"https://services.nvd.nist.gov/rest/json/cves/2.0"
            f"?keywordSearch={urllib.parse.quote(kw)}"
            f"&pubStartDate={start_str}&pubEndDate={end_str}"
            f"&resultsPerPage={per_keyword}"
        )
        try:
            headers: dict[str, str] = {"User-Agent": "ResearchAgent/1.0"}
            api_key = os.environ.get("NIST_API_KEY") or os.environ.get("NVD_API_KEY")
            if api_key:
                headers["apiKey"] = api_key
            data  = json.loads(_fetch_with_retry(url, headers=headers))
            vulns = data.get("vulnerabilities", [])
            for v in vulns:
                cve       = v.get("cve", {})
                cve_id    = cve.get("id", "UNKNOWN")
                desc_list = cve.get("descriptions", [])
                desc      = next(
                    (d["value"] for d in desc_list if d.get("lang") == "en"),
                    "No description",
                )
                metrics  = cve.get("metrics", {})
                severity = "LOW"
                for cvss_key in ["cvssMetricV31", "cvssMetricV30", "cvssMetricV2"]:
                    m_list = metrics.get(cvss_key, [])
                    if m_list:
                        severity = m_list[0].get("cvssData", {}).get("baseSeverity", "LOW")
                        break
                results.append({
                    "source":      "NVD",
                    "id":          cve_id,
                    "keyword":     kw,
                    "severity":    severity,
                    "description": desc[:200],
                })
        except Exception as exc:  # noqa: BLE001
            print(
                f"WARNING: NVD fetch failed for keyword '{kw}': {exc}",
                file=sys.stderr,
            )

    print(f"NVD items fetched: {len(results)}")
    return results


# ---------------------------------------------------------------------------
# CISA KEV fetch
# ---------------------------------------------------------------------------

def fetch_cisa() -> list[dict]:
    """Fetch recently-added CISA Known Exploited Vulnerabilities relevant to CI/CD."""
    lookback_days = _lookback_window()
    cutoff = datetime.now(timezone.utc) - timedelta(days=lookback_days)
    url    = (
        "https://www.cisa.gov/sites/default/files/feeds/"
        "known_exploited_vulnerabilities.json"
    )
    ci_cd_keywords = [
        "docker", "kubernetes", "github", "jenkins", "gitlab",
        "harness", "container", "pipeline", "registry", "ci",
    ]

    results: list[dict] = []
    try:
        data = json.loads(_fetch_with_retry(url, headers={"User-Agent": "ResearchAgent/1.0"}))
        for v in data.get("vulnerabilities", []):
            added_str = v.get("dateAdded", "")
            try:
                added = datetime.strptime(added_str, "%Y-%m-%d").replace(
                    tzinfo=timezone.utc
                )
            except ValueError:
                continue
            if added < cutoff:
                continue
            product = (v.get("product", "") + " " + v.get("vendorProject", "")).lower()
            if any(kw in product for kw in ci_cd_keywords):
                results.append({
                    "source":      "CISA-KEV",
                    "id":          v.get("cveID", "UNKNOWN"),
                    "product":     v.get("product", ""),
                    "severity":    "HIGH",
                    "description": v.get("shortDescription", "")[:200],
                    "due_date":    v.get("dueDate", ""),
                })
    except Exception as exc:  # noqa: BLE001
        print(f"WARNING: CISA KEV fetch failed: {exc}", file=sys.stderr)

    print(f"CISA KEV items fetched: {len(results)}")
    return results


# ---------------------------------------------------------------------------
# Gap analysis
# ---------------------------------------------------------------------------

def _load_previously_reported_gap_ids() -> set[str]:
    """CVE/KEV IDs already logged as a gap in a previous run.

    Without this, an unresolved gap gets treated as "new" and re-escalated
    (fresh Issue) every single week it remains open — confirmed in practice:
    CVE-2026-63808, CVE-2026-64102, and ~20 others recurred, unresolved,
    across all six research-agent Issues filed to date.
    """
    log_path = Path("policies/research/update-log.md")
    if not log_path.exists():
        return set()
    content = log_path.read_text()
    return set(re.findall(r"\|\s*GAP-\d+\s*\|\s*(\S+)\s*\|", content))


def gap_analysis(items: list[dict], previously_reported: set[str] | None = None) -> dict:
    """Compare threat items against existing OPA rules and identify gaps.

    De-dupes items matched by more than one search keyword within this run
    (the same CVE fetched under, say, both "Docker" and "supply chain"
    previously produced two separate GAP-* rows for one real threat).
    Gaps already reported in a previous run are split out as `recurring`
    rather than counted as `gaps`, so an unresolved item doesn't keep
    re-triggering a fresh escalation Issue every week it stays open.
    """
    previously_reported = previously_reported or set()
    existing_rules: dict[str, dict] = {}
    for root, _dirs, files in os.walk("policies"):
        for fname in files:
            if not fname.endswith(".rego") or fname.endswith("_test.rego"):
                continue
            fpath = os.path.join(root, fname)
            with open(fpath) as rf:
                content = rf.read()
            # Actual rule headers in this repo use "# RULE:" (all caps, see
            # e.g. pipeline-guardrails.rego) — this was previously matching
            # the literal, differently-cased "# Rule:" and finding zero rule
            # IDs in any real policy file, making existing_rules always empty
            # and every fetched CVE/KEV item register as a gap regardless of
            # actual coverage.
            for m in re.finditer(r"#\s*RULE:\s*(\S+)", content, re.IGNORECASE):
                rule_id = m.group(1)
                existing_rules[rule_id] = {
                    "file":             fpath,
                    "content_fragment": content[max(0, m.start() - 50): m.end() + 300],
                }

    print(f"Existing rules loaded: {len(existing_rules)}")
    print(f"Threat items to evaluate: {len(items)}")

    gaps: list[dict]      = []
    recurring: list[dict] = []
    covered: list[dict]   = []
    seen_ids: set[str] = set()
    for item in items:
        item_id = item["id"]
        if item_id in seen_ids:
            continue
        seen_ids.add(item_id)

        product_hint = item.get("keyword", item.get("product", "")).lower()
        matched      = False
        for rule_id, rule_info in existing_rules.items():
            combined = (rule_info["content_fragment"] + rule_info["file"]).lower()
            if item_id.lower() in combined or (product_hint and product_hint in combined):
                covered.append({"item": item_id, "rule": rule_id})
                matched = True
                break
        if matched:
            continue
        if item_id in previously_reported:
            recurring.append(item)
        else:
            gaps.append(item)

    print(f"Covered: {len(covered)}, New gaps: {len(gaps)}, Recurring unresolved: {len(recurring)}")
    return {"gaps": gaps, "recurring": recurring, "covered": covered}


# ---------------------------------------------------------------------------
# Update research log
# ---------------------------------------------------------------------------

def _gap_rows(items: list[dict], prefix: str) -> str:
    rows = ""
    for i, g in enumerate(items, 1):
        desc = g.get("description", "").replace("|", "/").replace("\n", " ").strip() or "(no description)"
        rows += (
            f"| {prefix}-{i:03d} | {g['id']} | {g.get('severity', 'MEDIUM')} "
            f"| TBD | NEEDS_MANUAL_REVIEW | {desc} |\n"
        )
    return rows


def update_log(
    gaps: list[dict],
    recurring: list[dict],
    covered: list[dict],
    nvd_count: int,
    cisa_count: int,
    trigger: str,
) -> None:
    """Append a new run entry to policies/research/update-log.md and write
    the current-run summary to policies/research/current-scan-summary.md.

    The cumulative log (update-log.md) preserves the full audit trail.
    The current-scan-summary.md file contains only the latest run entry so
    that the workflow can build an accurate issue body without risk of matching
    a stale "Gaps found:" value from a previous run.
    """
    now = datetime.now(timezone.utc).strftime("%Y-%m-%d")

    gap_rows = _gap_rows(gaps, "GAP")
    if not gap_rows:
        gap_rows = "_No new gaps found in this run._\n"

    recurring_section = ""
    if recurring:
        recurring_section = (
            f"\n### Recurring unresolved gaps (first reported in an earlier run): {len(recurring)}\n"
            f"| Gap ID | Source | Severity | Assigned Rule | Status | Description |\n"
            f"|---|---|---|---|---|---|\n"
            f"{_gap_rows(recurring, 'REC')}\n"
        )

    entry = (
        f"\n## Run: {now} — Trigger: {trigger}\n\n"
        f"### Sources scanned\n"
        f"- NVD: {nvd_count} items reviewed\n"
        f"- OWASP: manual monitoring (automated fetch not yet implemented)\n"
        f"- CISA KEV: {cisa_count} items reviewed\n"
        f"- Harness release notes: manual monitoring (automated fetch not yet implemented)\n\n"
        f"### Gaps found (new this run): {len(gaps)}\n"
        f"| Gap ID | Source | Severity | Assigned Rule | Status | Description |\n"
        f"|---|---|---|---|---|---|\n"
        f"{gap_rows}\n"
        f"{recurring_section}"
        f"### Rules updated: 0\n"
        f"No automated rule drafting performed in this run — gaps flagged for manual review.\n\n"
        f"### No-action items: {len(covered)}\n"
        f"{len(covered)} threats fully covered by existing rules. No changes required.\n\n"
        f"---\n"
    )

    # Append to cumulative audit log.
    log_path = Path("policies/research/update-log.md")
    with open(log_path, "a") as fh:
        fh.write(entry)
    print("Update log written successfully.")

    # Overwrite current-run summary so the workflow always reads the latest
    # entry only (no risk of matching a stale "Gaps found:" from prior runs).
    summary_path = Path("policies/research/current-scan-summary.md")
    with open(summary_path, "w") as fh:
        fh.write(entry.lstrip("\n"))
    print("Current-scan summary written successfully.")


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _lookback_window() -> int:
    """Return the lookback window in days.

    Uses the LOOKBACK_DAYS environment variable (default: 30).
    """
    return int(os.environ.get("LOOKBACK_DAYS", "30"))


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main() -> int:
    parser = argparse.ArgumentParser(
        description="Research Agent — Policy Intelligence Scanner"
    )
    parser.add_argument(
        "--test-connections",
        action="store_true",
        help="Test API connections and exit",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Scan but do not open a PR or commit changes",
    )
    parser.add_argument(
        "--max-cves",
        type=int,
        default=100,
        help="Maximum CVEs to fetch per scan (default: 100)",
    )
    parser.add_argument(
        "--force-scan",
        action="store_true",
        help="Force full scan regardless of baseline state",
    )
    args = parser.parse_args()

    # --test-connections: probe APIs and exit immediately
    if args.test_connections:
        results = test_connections()
        all_ok  = all(v["status"] == "connected" for v in results.values())
        return 0 if all_ok else 1

    # --force-scan: ensure a 30-day lookback when no LOOKBACK_DAYS is set
    if args.force_scan and "LOOKBACK_DAYS" not in os.environ:
        os.environ["LOOKBACK_DAYS"] = "30"

    # Full scan
    nvd_items  = fetch_nvd(max_cves=args.max_cves)
    cisa_items = fetch_cisa()
    all_items  = nvd_items + cisa_items

    analysis  = gap_analysis(all_items, previously_reported=_load_previously_reported_gap_ids())
    gaps      = analysis["gaps"]
    recurring = analysis["recurring"]
    covered   = analysis["covered"]

    trigger = os.environ.get("RESEARCH_TRIGGER", "on_demand")

    if not args.dry_run:
        update_log(
            gaps      = gaps,
            recurring = recurring,
            covered   = covered,
            nvd_count = len(nvd_items),
            cisa_count= len(cisa_items),
            trigger   = trigger,
        )

    # Export counts for GitHub Actions downstream steps. gaps_count is
    # NEW gaps only — recurring (already-reported, still-open) items don't
    # re-trigger the "open an Issue" step in research-agent.yml.
    github_output = os.environ.get("GITHUB_OUTPUT")
    if github_output:
        with open(github_output, "a") as fh:
            fh.write(f"gaps_count={len(gaps)}\n")
            fh.write(f"recurring_count={len(recurring)}\n")
            fh.write(f"covered_count={len(covered)}\n")

    print(f"\nScan complete — new gaps: {len(gaps)}, recurring: {len(recurring)}, covered: {len(covered)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
