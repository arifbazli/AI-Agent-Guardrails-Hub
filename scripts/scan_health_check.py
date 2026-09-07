#!/usr/bin/env python3
"""
Scan Health Check — Research Agent Self-Healing Automation
===========================================================
Classifies each Research Agent scan outcome into one of five categories,
auto-assigns Copilot with category-specific investigation instructions, and
enforces a dedupe/escalation guard so Copilot is never invoked more than
MAX_AUTO_RETRIES times in a row for the same recurring failure.

Categories
----------
  clean             – all sources reachable, gap count consistent
  api_unreachable   – one or more NVD/CISA sources failed after retries
  stats_mismatch    – job-summary gaps_count differs from issue body text
  session_cancelled – workflow was cancelled mid-execution
  unknown_anomaly   – anything else with unexpected output shape

Usage (called from GitHub Actions workflow)
-------------------------------------------
All inputs are read from environment variables set by the workflow:

  GITHUB_REPOSITORY   – "owner/repo"
  GITHUB_TOKEN        – standard Actions token (read issues, add labels/comments)
  COPILOT_PAT         – PAT with repo scope used to post the @copilot mention comment
  SCAN_CATEGORY       – preliminary category from bash classifier ("clean",
                        "api_unreachable", "session_cancelled", "unknown_anomaly",
                        or "" for the script to determine)
  FAILING_SOURCES     – comma-separated source names that failed (e.g. "nvd,cisa")
  GAPS_COUNT          – integer string from gap_analysis step output
  ISSUE_NUMBER        – number of the research issue created this run (may be empty
                        if no issue was created because gaps_count == 0)
  RUN_URL             – full URL to the workflow run for linking in instructions
"""

from __future__ import annotations

import json
import os
import re
import sys
import urllib.error
import urllib.parse
import urllib.request

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

MAX_AUTO_RETRIES = 2  # escalate after this many consecutive same-category failures

CATEGORY_LABELS: dict[str, str] = {
    "clean":             "scan-category-clean",
    "api_unreachable":   "scan-category-api-unreachable",
    "stats_mismatch":    "scan-category-stats-mismatch",
    "session_cancelled": "scan-category-session-cancelled",
    "unknown_anomaly":   "scan-category-unknown-anomaly",
}

CATEGORY_TITLES: dict[str, str] = {
    "api_unreachable":   "🔴 Research Agent — API Unreachable",
    "stats_mismatch":    "⚠️ Research Agent — Stats Mismatch",
    "session_cancelled": "🚫 Research Agent — Session Cancelled",
    "unknown_anomaly":   "❓ Research Agent — Unknown Anomaly",
}

# Investigation templates — format() keys must match what _build_instructions() passes.
CATEGORY_TEMPLATES: dict[str, str] = {
    "api_unreachable": """\
## 🔴 Research Agent — API Unreachable

**Failing sources detected:** `{failing_sources}`
**Workflow run:** {run_url}

### What happened
The Research Agent scan failed because the following external threat-intelligence
source(s) could not be reached after automatic retry-with-backoff: **{failing_sources}**.
This is not a transient network blip — it survived all retry attempts.

### Investigation steps
1. Verify that **{failing_sources}** are currently operational:
   - NVD: https://nvd.nist.gov/ (check their status page)
   - CISA KEV: https://www.cisa.gov/known-exploited-vulnerabilities-catalog
2. Check whether the `NIST_API_KEY` secret is still valid and not expired
   (repository **Settings → Secrets and variables → Actions**).
3. Open the run linked above, expand the **"Test API connections"** step, and
   look for HTTP status codes (429 = rate-limited, 5xx = server error,
   connection error = DNS/network issue).
4. If credentials are stale, rotate them and re-run the workflow via
   **Actions → Research Agent → Run workflow**.

### Fix criteria
Re-run the Research Agent scan and confirm all sources show ✅ in the
connection-test step with no retry needed.
""",

    "stats_mismatch": """\
## ⚠️ Research Agent — Stats Mismatch

**Workflow `gaps_count` output:** {gaps_count}
**Issue body "Gaps found:" value:** {body_count}
**Affected issue:** #{issue_number}
**Workflow run:** {run_url}

### What happened
The gap count emitted by the scan step (`{gaps_count}`) does not match the
first "Gaps found" occurrence found in the research issue body (`{body_count}`).

### Investigation steps
1. Open the issue body for #{issue_number} and confirm which heading the
   mismatch regex matched — it should be the current run's
   `### Gaps found (new this run): N` line from
   `policies/research/current-scan-summary.md`, not a stale entry.
2. Confirm `research-agent.yml`'s "Create research summary issue" step is
   still reading `current-scan-summary.md` (current run only) rather than
   falling back to a `tail` of the cumulative `update-log.md`.
3. Check `gap_analysis()` / `update_log()` in `scripts/research_agent.py` for
   any recent change to how `gaps`/`recurring`/`covered` counts are computed
   or rendered — this category means the two numbers disagree even though
   they should describe the same run.

### Fix criteria
Re-run the workflow; confirm the research issue body's "Gaps found" line
matches the `gaps_count` job-summary output.
""",

    "session_cancelled": """\
## 🚫 Research Agent — Session Cancelled

**Workflow run:** {run_url}

### What happened
The Research Agent scan workflow was cancelled before completing. No research
issue or branch was created for this run, so the weekly gap analysis is
incomplete.

### Investigation steps
1. Open the run linked above and check which step was active at cancellation.
2. Check for a simultaneous competing run — the concurrency group
   `research-agent-scan` queues runs (cancel-in-progress: false), so a
   cancellation here was explicit (manual or API-triggered).
3. Verify the scan is not hitting the 6-hour GitHub Actions job limit; if
   `fetch_nvd()` hangs on a slow keyword, add a shorter per-request timeout.
4. Confirm no repository admin cancelled the run inadvertently.

### Fix criteria
Re-run the Research Agent scan (`Actions → Research Agent → Run workflow`) and
confirm it reaches the "Output summary" step with a `success` conclusion.
""",

    "unknown_anomaly": """\
## ❓ Research Agent — Unknown Anomaly

**Workflow run:** {run_url}
**Details:** {details}

### What happened
The Research Agent scan produced output that doesn't match the expected shape.
The `gaps_count` or `covered_count` step outputs may be missing, the scan may
have exited non-zero, or the update log may not have been written.

### Investigation steps
1. Open the run linked above and expand each step's logs.
2. Look for Python tracebacks in the **"Run research scan"** step.
3. Verify `scripts/research_agent.py` writes all three output keys to `GITHUB_OUTPUT`:
   - `gaps_count=<integer>`
   - `recurring_count=<integer>`
   - `covered_count=<integer>`
4. Confirm `policies/research/update-log.md` was updated (check branch diff).
5. Ensure `policies/research/` directory exists in the repository.

### Fix criteria
Re-run the scan and confirm both expected outputs are present, the update log
is written, and the workflow reaches "Output summary" with a `success` conclusion.
""",
}

# ---------------------------------------------------------------------------
# GitHub API helpers
# ---------------------------------------------------------------------------


def _api(
    path: str,
    method: str = "GET",
    payload: dict | None = None,
    token: str | None = None,
) -> dict | list:
    """Make a GitHub REST API call and return parsed JSON."""
    base = "https://api.github.com"
    url = path if path.startswith("http") else f"{base}{path}"
    headers = {
        "Accept": "application/vnd.github.v3+json",
        "User-Agent": "scan-health-check/1.0",
    }
    if token:
        headers["Authorization"] = "Bearer " + token
    body = json.dumps(payload).encode() if payload is not None else None
    req = urllib.request.Request(url, data=body, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            return json.loads(resp.read())
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"HTTP {exc.code} from {url}: {detail}") from exc


# ---------------------------------------------------------------------------
# Issue helpers
# ---------------------------------------------------------------------------


def get_issue(owner: str, repo: str, number: int, token: str) -> dict:
    return _api(f"/repos/{owner}/{repo}/issues/{number}", token=token)  # type: ignore[return-value]


def add_label(owner: str, repo: str, number: int, label: str, token: str) -> None:
    try:
        _api(
            f"/repos/{owner}/{repo}/issues/{number}/labels",
            method="POST",
            payload={"labels": [label]},
            token=token,
        )
    except (RuntimeError, OSError, urllib.error.URLError) as exc:
        print(f"WARNING: could not add label '{label}': {exc}", file=sys.stderr)


def add_comment(owner: str, repo: str, number: int, body: str, token: str) -> dict:
    return _api(  # type: ignore[return-value]
        f"/repos/{owner}/{repo}/issues/{number}/comments",
        method="POST",
        payload={"body": body},
        token=token,
    )


def ensure_label(
    owner: str, repo: str, name: str, color: str, description: str, token: str
) -> None:
    """Create label if it doesn't already exist (422 = already exists → ok)."""
    try:
        _api(
            f"/repos/{owner}/{repo}/labels",
            method="POST",
            payload={"name": name, "color": color, "description": description},
            token=token,
        )
    except RuntimeError as exc:
        if "422" not in str(exc):
            print(f"WARNING: could not create label '{name}': {exc}", file=sys.stderr)
    except (OSError, urllib.error.URLError) as exc:
        print(f"WARNING: could not create label '{name}': {exc}", file=sys.stderr)


def list_recent_scan_issues(
    owner: str, repo: str, category_label: str, token: str, per_page: int = 5
) -> list[dict]:
    """Return still-open scan issues carrying category_label.

    Scoped to state=open (not all-time) so a category that was resolved and
    closed months ago doesn't count toward the *next*, unrelated escalation
    streak — "consecutive failures" should mean consecutive *unresolved* ones.
    """
    path = (
        f"/repos/{owner}/{repo}/issues"
        f"?labels={urllib.parse.quote(category_label)}"
        f"&state=open&per_page={per_page}&sort=created&direction=desc"
    )
    result = _api(path, token=token)
    return result if isinstance(result, list) else []


def create_failure_issue(
    owner: str,
    repo: str,
    category: str,
    body: str,
    token: str,
) -> int:
    """
    Create a failure-tracking issue for a non-clean scan category.

    Returns the new issue number.  Raises RuntimeError on API failure.
    """
    import datetime  # local import — only needed here

    date_str = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
    title_prefix = CATEGORY_TITLES.get(category, "❓ Research Agent — Scan Failure")
    title = f"{title_prefix} — {date_str}"

    cat_label = CATEGORY_LABELS.get(category, "")
    labels = ["automated"]
    if cat_label:
        labels.append(cat_label)

    payload: dict = {"title": title, "body": body, "labels": labels}
    result = _api(
        f"/repos/{owner}/{repo}/issues",
        method="POST",
        payload=payload,
        token=token,
    )
    issue_number = result["number"]  # type: ignore[index]
    print(f"✅ Failure-tracking issue #{issue_number} created (category: {category})")
    return int(issue_number)


# ---------------------------------------------------------------------------
# Copilot assignment
# ---------------------------------------------------------------------------


# ---------------------------------------------------------------------------
# Classification helpers
# ---------------------------------------------------------------------------


def detect_stats_mismatch(issue_body: str, gaps_count: str) -> tuple[bool, int | None]:
    """
    Parse the first '### Gaps found ...: N' heading from the issue body and
    compare with the workflow's gaps_count output.

    The issue body is built from current-scan-summary.md (current run only)
    when present, falling back to a tail of update-log.md otherwise — see
    research-agent.yml. A mismatch here means the two counts disagree even
    within what should be the same run's data.

    Returns (is_mismatch, body_count_or_None).
    """
    if not issue_body or not gaps_count:
        return False, None
    # research_agent.py's heading is "### Gaps found (new this run): N" —
    # [^:]* tolerates that parenthetical (or its absence in older log data)
    # without requiring an exact literal match.
    m = re.search(r"###\s+Gaps found[^:]*:\s*(\d+)", issue_body)
    if not m:
        return False, None
    body_count = int(m.group(1))
    try:
        wf_count = int(gaps_count)
    except (TypeError, ValueError):
        return False, body_count
    return wf_count != body_count, body_count


# ---------------------------------------------------------------------------
# Dedupe / escalation guard
# ---------------------------------------------------------------------------


def check_dedupe_escalation(
    owner: str,
    repo: str,
    category: str,
    current_issue_number: int,
    token: str,
) -> tuple[bool, bool]:
    """
    Returns (skip_assignment, should_escalate).

    skip_assignment  – True when the current issue already has 'copilot-assigned'.
    should_escalate  – True when there are >= MAX_AUTO_RETRIES *other* recent
                       issues carrying the same category label (meaning this
                       would be the (MAX_AUTO_RETRIES+1)th consecutive failure).
    """
    # 1. Check if current issue is already processed.
    issue = get_issue(owner, repo, current_issue_number, token)
    current_labels = {lb["name"] for lb in issue.get("labels", [])}
    if "copilot-assigned" in current_labels:
        print(
            f"Issue #{current_issue_number} already has 'copilot-assigned' — skipping.",
            file=sys.stderr,
        )
        return True, False

    # 2. Count recent issues with the same category label (excluding current).
    cat_label = CATEGORY_LABELS.get(category, "")
    if not cat_label:
        return False, False

    try:
        recent = list_recent_scan_issues(
            owner, repo, cat_label, token, per_page=MAX_AUTO_RETRIES + 3
        )
    except (RuntimeError, OSError, urllib.error.URLError) as exc:
        print(f"WARNING: could not fetch recent issues: {exc}", file=sys.stderr)
        return False, False

    same_cat_others = [i for i in recent if i["number"] != current_issue_number]
    if len(same_cat_others) >= MAX_AUTO_RETRIES:
        return False, True

    return False, False


# ---------------------------------------------------------------------------
# Instruction builder
# ---------------------------------------------------------------------------


def _build_instructions(
    category: str,
    *,
    failing_sources: str,
    gaps_count: str,
    body_count: int | None,
    issue_number: int,
    run_url: str,
    details: str,
) -> str:
    template = CATEGORY_TEMPLATES.get(category, CATEGORY_TEMPLATES["unknown_anomaly"])
    return template.format(
        failing_sources=failing_sources or "unknown source(s)",
        gaps_count=gaps_count or "unknown",
        body_count=body_count if body_count is not None else "unknown",
        issue_number=issue_number,
        run_url=run_url or "N/A",
        details=details or f"category={category}",
    )


# ---------------------------------------------------------------------------
# Label bootstrap
# ---------------------------------------------------------------------------

NEW_LABELS: dict[str, tuple[str, str]] = {
    "scan-category-clean":             ("0e8a16", "Research scan completed cleanly"),
    "scan-category-api-unreachable":   ("e4e669", "Research scan: API source unreachable"),
    "scan-category-stats-mismatch":    ("fbca04", "Research scan: gap count inconsistency"),
    "scan-category-session-cancelled": ("d93f0b", "Research scan: run was cancelled"),
    "scan-category-unknown-anomaly":   ("b60205", "Research scan: unexpected output shape"),
    "copilot-assigned":                ("0075ca", "Copilot coding agent assigned to this issue"),
    "needs-human-escalation":          ("cc317c", "Auto-retry limit exceeded — human review needed"),
}


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------


def main() -> int:  # noqa: C901
    repo_env = os.environ.get("GITHUB_REPOSITORY", "")
    if not repo_env or "/" not in repo_env:
        print("ERROR: GITHUB_REPOSITORY must be set (owner/repo)", file=sys.stderr)
        return 1

    owner, repo = repo_env.split("/", 1)
    github_token = os.environ.get("GITHUB_TOKEN", "")
    copilot_pat = os.environ.get("COPILOT_PAT", "")

    # Prefer COPILOT_PAT for assignment; fall back to GITHUB_TOKEN for reads.
    assign_token = copilot_pat or github_token
    read_token = github_token or copilot_pat

    if not read_token:
        print("ERROR: neither GITHUB_TOKEN nor COPILOT_PAT is set", file=sys.stderr)
        return 1

    # Inputs from workflow
    category = os.environ.get("SCAN_CATEGORY", "").strip() or "clean"
    failing_sources = os.environ.get("FAILING_SOURCES", "").strip()
    gaps_count = os.environ.get("GAPS_COUNT", "").strip()
    issue_number_str = os.environ.get("ISSUE_NUMBER", "").strip()
    run_url = os.environ.get("RUN_URL", "").strip()

    print(f"Health check — category hint: {category}")

    # Ensure all new labels exist in the repo.
    for label_name, (color, desc) in NEW_LABELS.items():
        ensure_label(owner, repo, label_name, color, desc, token=read_token)

    # Fast-path: preliminary classification says clean and no issue was created.
    if category == "clean" and not issue_number_str:
        print("✅ Scan outcome: clean, no issue created — nothing to do.")
        return 0

    # Resolve issue number.
    issue_number: int | None = None
    if issue_number_str:
        try:
            issue_number = int(issue_number_str)
        except ValueError:
            print(
                f"WARNING: ISSUE_NUMBER='{issue_number_str}' is not an integer.",
                file=sys.stderr,
            )

    # If we have an issue number and the category is still provisionally "clean",
    # check for stats_mismatch by reading the issue body.
    body_count: int | None = None
    if issue_number and category == "clean":
        try:
            issue = get_issue(owner, repo, issue_number, read_token)
            is_mismatch, body_count = detect_stats_mismatch(
                issue.get("body", ""), gaps_count
            )
            if is_mismatch:
                category = "stats_mismatch"
                print(
                    f"Stats mismatch detected: "
                    f"workflow gaps_count={gaps_count}, "
                    f"issue body first 'Gaps found:'={body_count}"
                )
            else:
                print(f"✅ Scan outcome: clean — gaps_count consistent ({gaps_count}).")
                add_label(
                    owner, repo, issue_number,
                    CATEGORY_LABELS["clean"], read_token,
                )
                return 0
        except (RuntimeError, OSError, urllib.error.URLError) as exc:
            print(f"WARNING: could not read issue #{issue_number}: {exc}", file=sys.stderr)
            category = "unknown_anomaly"

    # If still clean with no issue, nothing to do.
    if category == "clean":
        print("✅ Scan outcome: clean — nothing to do.")
        return 0

    print(f"Non-clean outcome: category={category}")

    # Without an issue number we cannot assign Copilot — create one now.
    if not issue_number:
        print(
            f"No issue number available for category '{category}'; "
            "creating a failure-tracking issue.",
            file=sys.stderr,
        )
        # Build a minimal body using the category template so the issue already
        # contains investigation steps when Copilot picks it up.
        placeholder_body = _build_instructions(
            category,
            failing_sources=failing_sources,
            gaps_count=gaps_count,
            body_count=None,
            issue_number=0,
            run_url=run_url,
            details=f"category={category}, failing_sources={failing_sources!r}",
        )
        try:
            issue_number = create_failure_issue(
                owner, repo, category, placeholder_body, token=read_token
            )
        except (RuntimeError, OSError, urllib.error.URLError) as exc:
            print(f"ERROR: could not create failure-tracking issue: {exc}", file=sys.stderr)
            return 1

    # Add category label to the issue.
    cat_label = CATEGORY_LABELS.get(category, "")
    if cat_label:
        add_label(owner, repo, issue_number, cat_label, read_token)

    # Dedupe / escalation guard.
    skip, escalate = check_dedupe_escalation(
        owner, repo, category, issue_number, token=read_token
    )

    if skip:
        print(
            f"Issue #{issue_number} already has 'copilot-assigned' — no duplicate assignment."
        )
        return 0

    if escalate:
        print(
            f"⚠️  Escalating issue #{issue_number}: "
            f"{MAX_AUTO_RETRIES}+ prior consecutive '{category}' failures detected."
        )
        add_label(owner, repo, issue_number, "needs-human-escalation", read_token)
        try:
            add_comment(
                owner,
                repo,
                issue_number,
                (
                    f"🚨 **Auto-escalation triggered** — this is at least the "
                    f"{MAX_AUTO_RETRIES + 1}th consecutive `{category}` scan failure.\n\n"
                    f"Automatic Copilot assignment has been **suspended** to avoid an "
                    f"infinite fix-loop. A human needs to investigate and resolve the "
                    f"underlying cause before automated retries resume.\n\n"
                    f"**Run:** {run_url or 'N/A'}"
                ),
                token=read_token,
            )
        except (RuntimeError, OSError, urllib.error.URLError) as exc:
            print(f"WARNING: could not post escalation comment: {exc}", file=sys.stderr)
        return 0

    # Build category-specific Copilot instructions.
    instructions = _build_instructions(
        category,
        failing_sources=failing_sources,
        gaps_count=gaps_count,
        body_count=body_count,
        issue_number=issue_number,
        run_url=run_url,
        details=f"category={category}, failing_sources={failing_sources!r}",
    )

    # Post a @copilot mention comment so the Copilot coding agent picks up the task.
    comment_body = (
        f"@copilot Please investigate this Research Agent scan failure.\n\n"
        f"**Failure category:** `{category}`\n\n"
        + instructions
    )
    try:
        add_comment(owner, repo, issue_number, comment_body, token=assign_token)
        print(
            f"✅ Copilot trigger comment posted on issue #{issue_number} "
            f"(category: {category})"
        )
    except (RuntimeError, OSError, urllib.error.URLError) as exc:
        print(f"ERROR: could not post Copilot trigger comment: {exc}", file=sys.stderr)
        return 1

    add_label(owner, repo, issue_number, "copilot-assigned", read_token)
    return 0


if __name__ == "__main__":
    sys.exit(main())
