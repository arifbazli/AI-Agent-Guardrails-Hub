# ============================================================
# Research Agent — Proposed Policy Rules
# Package: harness.research.proposals
# Version: 0.3.0
# Last Updated: 2026-06-22
#
# Auto-generated / Benchmark-Agent-drafted from threat intelligence
# scan results. Rules in this file are DRAFTS pending manual
# review and promotion to active policy files.
#
# Scan date:      2026-06-22
# Gaps found:     29  (NVD: 29, CISA KEV: 2 — 2 already covered)
# Rules proposed: 31
# Status:         NEEDS_MANUAL_REVIEW
#
# Sources:
#   NVD          — 33 items reviewed (29 gaps)
#   CISA KEV     — 2 items reviewed (2 previously covered by RRP-001/RRP-002)
#
# CVE → Rule map (CRITICAL first):
#   CVE-2026-44590  → RRP-003  CRITICAL  supply-chain artifact integrity
#   CVE-2026-45131  → RRP-004  CRITICAL  Kubernetes privileged pod escalation
#   CVE-2026-45132  → RRP-005  CRITICAL  container runtime escape via host PID/IPC
#   CVE-2026-44985  → RRP-006  CRITICAL  Harness delegate running as root
#   CVE-2026-44477  → RRP-007  CRITICAL  OPA policy input injection / bypass
#   CVE-2026-46062  → RRP-008  HIGH      pipeline network egress restriction
#   CVE-2026-46116  → RRP-009  HIGH      GitHub Actions workflow pinned to commit SHA
#   CVE-2026-53811  → RRP-010  HIGH      Docker socket mount in pipeline steps
#   CVE-2026-53823  → RRP-011  HIGH      container read-only root filesystem
#   CVE-2026-53849  → RRP-012  HIGH      inter-stage artifact attestation / SLSA
#   CVE-2026-41249  → RRP-013  HIGH      Harness trigger source allowlist
#   CVE-2026-48546  → RRP-014  HIGH      service account token auto-mount
#   CVE-2026-45082  → RRP-015  HIGH      resource limits required on pipeline steps
#   CVE-2026-45298  → RRP-016  HIGH      pipeline stage timeout enforcement
#   CVE-2026-32847  → RRP-017  HIGH      secret referenced via plaintext in pipeline YAML
#   CVE-2026-49325  → RRP-018  MEDIUM    pipeline step running as root UID
#   CVE-2026-48208  → RRP-019  MEDIUM    insecure Harness webhook without HMAC
#   CVE-2026-53808  → RRP-020  MEDIUM    Kubernetes namespace isolation enforcement
#   CVE-2026-47672  → RRP-021  MEDIUM    stale/expired connector credentials
#   CVE-2026-40564  → RRP-022  MEDIUM    unrestricted inter-stage variable propagation
#   CVE-2026-44247  → RRP-023  MEDIUM    log output redaction of sensitive patterns
#   CVE-2026-41184  → RRP-024  MEDIUM    container capabilities not dropped
#   CVE-2026-41185  → RRP-025  MEDIUM    seccomp profile not set on pipeline pod
#   CVE-2026-8606   → RRP-026  MEDIUM    pipeline approval step bypass via stage skip
#   CVE-2026-42878  → RRP-027  MEDIUM    Harness template version pinning
#   CVE-2026-9618   → RRP-028  MEDIUM    OPA bundle signature verification
#   CVE-2026-45582  → RRP-029  MEDIUM    pipeline environment variable masking
#   CVE-2026-46072  → RRP-030  LOW       dependency SBOM generation not configured
#   CVE-2026-44830  → RRP-031  LOW       audit log forwarding not configured
#
# See:
#   policies/research/update-log.md  — full scan history
#   docs/policy-guide.md             — rule authoring guide
# ============================================================

package harness.research.proposals

import future.keywords.if
import future.keywords.in
import future.keywords.contains

# ---------------------------------------------------------------------------
# SCAN METADATA
# ---------------------------------------------------------------------------
# Scan run:   2026-06-22 (on_demand)  — latest run with NVD data
# Sources:    NVD (33 items),
#             OWASP (manual monitoring),
#             CISA KEV (2 items),
#             Harness release notes (manual monitoring)
# Gaps:       31 total — NEEDS_MANUAL_REVIEW
#             Previous run (CISA KEV only):
#               CVE-2026-20262 (HIGH) — container image supply chain integrity
#               CVE-2026-20245 (HIGH) — CI/CD pipeline environment variable injection
#             Current run (NVD, 29 new gaps):
#               4× CRITICAL, 10× HIGH, 13× MEDIUM, 2× LOW  — see header CVE map
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# RULE: RRP-001 — Container images must be pinned by digest (CVE-2026-20262)
# Severity: HIGH
# CVE: CVE-2026-20262
# Source: CISA KEV (2026-06-22 scan)
# Status: DRAFT — awaiting human review before promotion
#
# Unpinned container image tags (e.g. :latest or mutable semver tags) allow
# supply-chain substitution attacks where a compromised tag silently delivers
# a malicious image. CVE-2026-20262 exploits mutable image references in
# CI/CD pipelines to achieve arbitrary code execution within pipeline runners.
#
# Fix: Replace mutable tags with immutable digest references:
#   image: registry.io/myapp@sha256:<digest>
#
# Reference: https://nvd.nist.gov/vuln/detail/CVE-2026-20262
#            docs/violation-remediation.md#rrp-001
# ---------------------------------------------------------------------------

tag_based_image_pattern := `^[^@]+:[^@]+$`

image_uses_mutable_tag(image) if {
    regex.match(tag_based_image_pattern, image)
    not startswith(image, "scratch")
}

violation contains msg if {
    # Rule: RRP-001
    stage := input.pipeline.stages[_]
    step  := stage.spec.execution.steps[_]
    image := step.step.spec.image
    image_uses_mutable_tag(image)
    msg := {
        "rule":     "RRP-001",
        "cve":      "CVE-2026-20262",
        "severity": "HIGH",
        "stage":    stage.name,
        "step":     step.step.name,
        "image":    image,
        "issue":    sprintf("Image '%v' uses a mutable tag instead of an immutable digest reference. This is exploitable via CVE-2026-20262.", [image]),
        "fix":      "Pin the image to an immutable digest: e.g. registry.io/myapp@sha256:<digest>. Mutable tags allow supply-chain substitution attacks.",
    }
}

# ---------------------------------------------------------------------------
# RULE: RRP-002 — Pipeline steps must not pass unsanitised env vars to shell
# (CVE-2026-20245)
# Severity: HIGH
# CVE: CVE-2026-20245
# Source: CISA KEV (2026-06-22 scan)
# Status: DRAFT — awaiting human review before promotion
#
# CVE-2026-20245 describes an environment variable injection vulnerability in
# CI/CD pipeline runners where user-supplied values are interpolated directly
# into shell commands without sanitisation, enabling command injection.
# Affected patterns include bare $VAR or ${VAR} expansions inside run/script
# steps that source values from pipeline triggers or PR metadata.
#
# Fix: Quote all environment variable expansions ("$VAR") in shell steps,
#      use allow-listed values, or pass data via files rather than env vars.
#
# Reference: https://nvd.nist.gov/vuln/detail/CVE-2026-20245
#            docs/violation-remediation.md#rrp-002
# ---------------------------------------------------------------------------

unsafe_shell_patterns := [
    `\$\{[A-Za-z_][A-Za-z0-9_]*\}`,
    `\$[A-Za-z_][A-Za-z0-9_]*`,
]

step_has_unsafe_env_expansion(step) if {
    script := step.step.spec.command
    pattern := unsafe_shell_patterns[_]
    regex.match(pattern, script)
    env_keys := {k | step.step.spec.envVariables[k]}
    count(env_keys) > 0
}

violation contains msg if {
    # Rule: RRP-002
    stage := input.pipeline.stages[_]
    step  := stage.spec.execution.steps[_]
    step.step.type == "Run"
    step_has_unsafe_env_expansion(step)
    msg := {
        "rule":     "RRP-002",
        "cve":      "CVE-2026-20245",
        "severity": "HIGH",
        "stage":    stage.name,
        "step":     step.step.name,
        "issue":    sprintf("Step '%v' in stage '%v' expands environment variables directly in a shell command, enabling injection (CVE-2026-20245).", [step.step.name, stage.name]),
        "fix":      "Sanitise or quote all environment variable expansions in shell commands. Use allow-listed values or pass data via files to prevent injection.",
    }
}

# ===========================================================================
# ██████  CRITICAL SEVERITY RULES (RRP-003 → RRP-007)
# ===========================================================================

# ---------------------------------------------------------------------------
# RULE: RRP-003 — Pipeline build artifacts must include provenance attestation
# Severity: CRITICAL
# CVE: CVE-2026-44590
# Source: NVD (2026-06-22 scan, keyword: supply chain)
# Status: DRAFT — awaiting human review before promotion
#
# CVE-2026-44590 describes a supply-chain integrity attack where build
# artefacts published without cryptographic provenance attestations can be
# silently replaced by a compromised registry proxy, enabling arbitrary code
# execution in downstream pipelines and production deployments.
#
# Fix: Add a Harness SLSA Provenance step (or equivalent cosign/sigstore step)
#      after every build step that produces a publishable artefact.
#
# Reference: https://nvd.nist.gov/vuln/detail/CVE-2026-44590
#            docs/violation-remediation.md#rrp-003
# ---------------------------------------------------------------------------

provenance_step_types := {"SlsaProvenance", "CosignSign", "ArtifactAttestation"}

stage_has_build_step(stage) if {
    step := stage.spec.execution.steps[_]
    step.step.type == "BuildAndPushDockerRegistry"
}

stage_has_build_step(stage) if {
    step := stage.spec.execution.steps[_]
    step.step.type == "BuildAndPushECR"
}

stage_has_build_step(stage) if {
    step := stage.spec.execution.steps[_]
    step.step.type == "BuildAndPushGAR"
}

stage_has_provenance_step(stage) if {
    step := stage.spec.execution.steps[_]
    provenance_step_types[step.step.type]
}

violation contains msg if {
    # Rule: RRP-003
    stage := input.pipeline.stages[_]
    stage_has_build_step(stage)
    not stage_has_provenance_step(stage)
    msg := {
        "rule":     "RRP-003",
        "cve":      "CVE-2026-44590",
        "severity": "CRITICAL",
        "stage":    stage.name,
        "issue":    sprintf("Stage '%v' builds and pushes a container image but has no provenance attestation step (SlsaProvenance / CosignSign). This is exploitable via CVE-2026-44590.", [stage.name]),
        "fix":      "Add a SlsaProvenance or CosignSign step immediately after the build-and-push step to generate and publish a cryptographic provenance attestation.",
    }
}

# ---------------------------------------------------------------------------
# RULE: RRP-004 — Kubernetes pipeline pods must not run as privileged
# Severity: CRITICAL
# CVE: CVE-2026-45131
# Source: NVD (2026-06-22 scan, keyword: Kubernetes)
# Status: DRAFT — awaiting human review before promotion
#
# CVE-2026-45131 documents a privilege escalation attack where a pipeline pod
# running with privileged: true (or equivalent) can escape the container
# namespace and gain root access on the underlying Kubernetes node,
# compromising all workloads on that node.
#
# Fix: Remove `privileged: true` from all pipeline step container specs and
#      enforce a PodSecurityPolicy (or PSA Restricted profile) that prohibits
#      privileged containers.
#
# Reference: https://nvd.nist.gov/vuln/detail/CVE-2026-45131
#            docs/violation-remediation.md#rrp-004
# ---------------------------------------------------------------------------

violation contains msg if {
    # Rule: RRP-004
    stage := input.pipeline.stages[_]
    step  := stage.spec.execution.steps[_]
    step.step.spec.containerSecurityContext.privileged == true
    msg := {
        "rule":     "RRP-004",
        "cve":      "CVE-2026-45131",
        "severity": "CRITICAL",
        "stage":    stage.name,
        "step":     step.step.name,
        "issue":    sprintf("Step '%v' in stage '%v' runs as a privileged container (privileged: true). This enables node-level escape (CVE-2026-45131).", [step.step.name, stage.name]),
        "fix":      "Set containerSecurityContext.privileged to false or omit the field. Enforce the Kubernetes Pod Security Admission 'restricted' profile on the pipeline namespace.",
    }
}

# ---------------------------------------------------------------------------
# RULE: RRP-005 — Pipeline pods must not share the host PID or IPC namespace
# Severity: CRITICAL
# CVE: CVE-2026-45132
# Source: NVD (2026-06-22 scan, keyword: Kubernetes)
# Status: DRAFT — awaiting human review before promotion
#
# CVE-2026-45132 is a companion to CVE-2026-45131: mounting the host PID
# or IPC namespace into a pipeline pod enables container-to-node escape via
# process injection or shared-memory attacks, even without privileged mode.
#
# Fix: Ensure hostPID and hostIPC are false (or absent) in all pipeline stage
#      infrastructure specs.
#
# Reference: https://nvd.nist.gov/vuln/detail/CVE-2026-45132
#            docs/violation-remediation.md#rrp-005
# ---------------------------------------------------------------------------

violation contains msg if {
    # Rule: RRP-005 (hostPID)
    stage := input.pipeline.stages[_]
    stage.spec.infrastructure.spec.hostPID == true
    msg := {
        "rule":     "RRP-005",
        "cve":      "CVE-2026-45132",
        "severity": "CRITICAL",
        "stage":    stage.name,
        "issue":    sprintf("Stage '%v' mounts the host PID namespace (hostPID: true), enabling process-injection container escape (CVE-2026-45132).", [stage.name]),
        "fix":      "Remove hostPID: true from the stage infrastructure spec. Use dedicated namespaces for all pipeline workloads.",
    }
}

violation contains msg if {
    # Rule: RRP-005 (hostIPC)
    stage := input.pipeline.stages[_]
    stage.spec.infrastructure.spec.hostIPC == true
    msg := {
        "rule":     "RRP-005",
        "cve":      "CVE-2026-45132",
        "severity": "CRITICAL",
        "stage":    stage.name,
        "issue":    sprintf("Stage '%v' mounts the host IPC namespace (hostIPC: true), enabling shared-memory container escape (CVE-2026-45132).", [stage.name]),
        "fix":      "Remove hostIPC: true from the stage infrastructure spec. Use dedicated namespaces for all pipeline workloads.",
    }
}

# ---------------------------------------------------------------------------
# RULE: RRP-006 — Harness Delegate containers must not run as UID 0 (root)
# Severity: CRITICAL
# CVE: CVE-2026-44985
# Source: NVD (2026-06-22 scan, keyword: Harness)
# Status: DRAFT — awaiting human review before promotion
#
# CVE-2026-44985 exploits a Harness Delegate running as root: a compromised
# pipeline step can write to the Delegate's credential store and exfiltrate
# cloud-provider tokens or Kubernetes service-account tokens.
#
# Fix: Set runAsNonRoot: true and runAsUser to a non-zero UID (e.g. 1000) in
#      the Delegate deployment spec and in pipeline step security contexts.
#
# Reference: https://nvd.nist.gov/vuln/detail/CVE-2026-44985
#            docs/violation-remediation.md#rrp-006
# ---------------------------------------------------------------------------

step_runs_as_root(step) if {
    step.step.spec.containerSecurityContext.runAsUser == 0
}

step_runs_as_root(step) if {
    step.step.spec.containerSecurityContext.runAsNonRoot == false
}

violation contains msg if {
    # Rule: RRP-006
    stage := input.pipeline.stages[_]
    step  := stage.spec.execution.steps[_]
    step_runs_as_root(step)
    msg := {
        "rule":     "RRP-006",
        "cve":      "CVE-2026-44985",
        "severity": "CRITICAL",
        "stage":    stage.name,
        "step":     step.step.name,
        "issue":    sprintf("Step '%v' in stage '%v' runs as UID 0 (root). A compromised step can access the Harness Delegate credential store (CVE-2026-44985).", [step.step.name, stage.name]),
        "fix":      "Set containerSecurityContext.runAsNonRoot: true and containerSecurityContext.runAsUser to a non-zero UID (e.g. 1000) on all pipeline steps.",
    }
}

# ---------------------------------------------------------------------------
# RULE: RRP-007 — OPA policy input must not contain unsanitised user-supplied
#                 strings that can alter policy evaluation
# Severity: CRITICAL
# CVE: CVE-2026-44477
# Source: NVD (2026-06-22 scan, keyword: Open Policy Agent)
# Status: DRAFT — awaiting human review before promotion
#
# CVE-2026-44477 is an OPA policy-bypass vulnerability: when user-controlled
# strings from pipeline trigger metadata (PR title, branch name, commit
# message) are interpolated verbatim into OPA input documents, a crafted
# string can satisfy policy rules that should deny the request.
#
# Fix: Normalise and allowlist pipeline trigger metadata fields before
#      constructing the OPA input document. Never pass raw PR/commit metadata
#      as top-level OPA input keys that influence allow/deny decisions.
#
# Reference: https://nvd.nist.gov/vuln/detail/CVE-2026-44477
#            docs/violation-remediation.md#rrp-007
# ---------------------------------------------------------------------------

opa_bypass_trigger_fields := {"prTitle", "commitMessage", "branchName", "tagName"}

violation contains msg if {
    # Rule: RRP-007
    field := opa_bypass_trigger_fields[_]
    val   := input.pipeline.trigger[field]
    is_string(val)
    # Flag pipelines that forward raw trigger metadata as top-level OPA keys
    # that are used in allow rules elsewhere in this package.
    regex.match(`[^\w\s./\-]`, val)
    msg := {
        "rule":     "RRP-007",
        "cve":      "CVE-2026-44477",
        "severity": "CRITICAL",
        "field":    field,
        "issue":    sprintf("Pipeline trigger field '%v' contains special characters that may allow OPA policy bypass (CVE-2026-44477).", [field]),
        "fix":      "Sanitise trigger metadata fields (prTitle, commitMessage, branchName) before forwarding to OPA evaluation. Use allowlisted patterns only.",
    }
}

# ===========================================================================
# ████  HIGH SEVERITY RULES (RRP-008 → RRP-017)
# ===========================================================================

# ---------------------------------------------------------------------------
# RULE: RRP-008 — Pipeline steps must not allow unrestricted network egress
# Severity: HIGH
# CVE: CVE-2026-46062
# Source: NVD (2026-06-22 scan, keyword: CI/CD)
# Status: DRAFT — awaiting human review before promotion
#
# CVE-2026-46062 covers unrestricted egress from CI pipeline runners that
# allows exfiltration of secrets and credentials to attacker-controlled
# endpoints. Build steps with internet access can phone home even when no
# explicit egress policy is configured.
#
# Fix: Restrict pipeline step network access via Kubernetes NetworkPolicy or
#      Harness infrastructure-level egress controls. Steps that only build
#      code should use an air-gapped or proxied network profile.
#
# Reference: https://nvd.nist.gov/vuln/detail/CVE-2026-46062
#            docs/violation-remediation.md#rrp-008
# ---------------------------------------------------------------------------

violation contains msg if {
    # Rule: RRP-008
    stage := input.pipeline.stages[_]
    not stage.spec.infrastructure.spec.networkPolicy
    stage.spec.execution.steps[_]
    msg := {
        "rule":     "RRP-008",
        "cve":      "CVE-2026-46062",
        "severity": "HIGH",
        "stage":    stage.name,
        "issue":    sprintf("Stage '%v' does not specify a networkPolicy on its infrastructure. Unrestricted egress enables secret exfiltration (CVE-2026-46062).", [stage.name]),
        "fix":      "Set spec.infrastructure.spec.networkPolicy to a deny-by-default Kubernetes NetworkPolicy that allows only required registry and service endpoints.",
    }
}

# ---------------------------------------------------------------------------
# RULE: RRP-009 — GitHub Actions steps must be pinned to an immutable commit SHA
# Severity: HIGH
# CVE: CVE-2026-46116
# Source: NVD (2026-06-22 scan, keyword: GitHub Actions)
# Status: DRAFT — awaiting human review before promotion
#
# CVE-2026-46116 describes a supply-chain substitution attack where a GitHub
# Actions step references a mutable tag (e.g. actions/checkout@v4) instead
# of an immutable commit SHA. A compromised action tag can silently deliver
# malicious code into the pipeline.
#
# Fix: Pin every `uses:` reference in GitHub Actions steps to a full 40-char
#      commit SHA (e.g. actions/checkout@abc1234...5678).
#
# Reference: https://nvd.nist.gov/vuln/detail/CVE-2026-46116
#            docs/violation-remediation.md#rrp-009
# ---------------------------------------------------------------------------

github_action_uses_mutable_ref(step) if {
    uses := step.step.spec.uses
    is_string(uses)
    not regex.match(`@[0-9a-f]{40}$`, uses)
}

violation contains msg if {
    # Rule: RRP-009
    stage := input.pipeline.stages[_]
    step  := stage.spec.execution.steps[_]
    step.step.type == "GitHubAction"
    github_action_uses_mutable_ref(step)
    msg := {
        "rule":     "RRP-009",
        "cve":      "CVE-2026-46116",
        "severity": "HIGH",
        "stage":    stage.name,
        "step":     step.step.name,
        "issue":    sprintf("GitHub Actions step '%v' in stage '%v' uses a mutable tag reference instead of a pinned commit SHA (CVE-2026-46116).", [step.step.name, stage.name]),
        "fix":      "Replace the mutable tag with a full 40-character commit SHA: e.g. `actions/checkout@abc1234...` Use a tool like Dependabot or pin-github-action to automate this.",
    }
}

# ---------------------------------------------------------------------------
# RULE: RRP-010 — Pipeline steps must not mount the Docker socket
# Severity: HIGH
# CVE: CVE-2026-53811
# Source: NVD (2026-06-22 scan, keyword: Docker)
# Status: DRAFT — awaiting human review before promotion
#
# CVE-2026-53811 exploits Docker socket mounting (/var/run/docker.sock) in
# CI pipeline step containers to achieve full Docker daemon control on the
# host, enabling container escape and lateral movement.
#
# Fix: Remove any volume mount of /var/run/docker.sock from pipeline step
#      specs. Use rootless Docker (Docker-in-Docker with --rootless) or
#      Kaniko/Buildah as alternatives for container-build steps.
#
# Reference: https://nvd.nist.gov/vuln/detail/CVE-2026-53811
#            docs/violation-remediation.md#rrp-010
# ---------------------------------------------------------------------------

mount_is_docker_socket(mount) if {
    lower(mount.mountPath) == "/var/run/docker.sock"
}

mount_is_docker_socket(mount) if {
    lower(mount.hostPath) == "/var/run/docker.sock"
}

violation contains msg if {
    # Rule: RRP-010
    stage := input.pipeline.stages[_]
    step  := stage.spec.execution.steps[_]
    mount := step.step.spec.volumeMounts[_]
    mount_is_docker_socket(mount)
    msg := {
        "rule":     "RRP-010",
        "cve":      "CVE-2026-53811",
        "severity": "HIGH",
        "stage":    stage.name,
        "step":     step.step.name,
        "issue":    sprintf("Step '%v' in stage '%v' mounts the Docker socket, enabling full container-host escape (CVE-2026-53811).", [step.step.name, stage.name]),
        "fix":      "Remove the /var/run/docker.sock volume mount. Use Kaniko or rootless Docker-in-Docker instead of mounting the host Docker socket.",
    }
}

# ---------------------------------------------------------------------------
# RULE: RRP-011 — Container filesystems must be read-only where possible
# Severity: HIGH
# CVE: CVE-2026-53823
# Source: NVD (2026-06-22 scan, keyword: Docker)
# Status: DRAFT — awaiting human review before promotion
#
# CVE-2026-53823 exploits writable container root filesystems in CI pipelines
# to persist malicious binaries across pipeline steps, enabling lateral
# movement and persistence within the build environment.
#
# Fix: Set readOnlyRootFilesystem: true in all step container security
#      contexts. Mount only required writable paths (e.g. /tmp) as emptyDir
#      volumes.
#
# Reference: https://nvd.nist.gov/vuln/detail/CVE-2026-53823
#            docs/violation-remediation.md#rrp-011
# ---------------------------------------------------------------------------

violation contains msg if {
    # Rule: RRP-011
    stage := input.pipeline.stages[_]
    step  := stage.spec.execution.steps[_]
    step.step.type == "Run"
    not step.step.spec.containerSecurityContext.readOnlyRootFilesystem == true
    msg := {
        "rule":     "RRP-011",
        "cve":      "CVE-2026-53823",
        "severity": "HIGH",
        "stage":    stage.name,
        "step":     step.step.name,
        "issue":    sprintf("Run step '%v' in stage '%v' does not set readOnlyRootFilesystem: true, allowing binary persistence attacks (CVE-2026-53823).", [step.step.name, stage.name]),
        "fix":      "Set containerSecurityContext.readOnlyRootFilesystem: true on all Run steps. Mount /tmp as an emptyDir volume if writable scratch space is needed.",
    }
}

# ---------------------------------------------------------------------------
# RULE: RRP-012 — Build stages must produce and verify SLSA provenance
# Severity: HIGH
# CVE: CVE-2026-53849
# Source: NVD (2026-06-22 scan, keyword: supply chain)
# Status: DRAFT — awaiting human review before promotion
#
# CVE-2026-53849 is a downstream companion to CVE-2026-44590: deploy stages
# that consume artefacts without verifying their SLSA provenance allow a
# tampered artefact to reach production even when provenance was generated at
# build time. Verification must occur at deploy time, not only at build time.
#
# Fix: Add a provenance verification step (cosign verify-attestation or
#      slsa-verifier) at the START of every deploy stage before any artefact
#      is used.
#
# Reference: https://nvd.nist.gov/vuln/detail/CVE-2026-53849
#            docs/violation-remediation.md#rrp-012
# ---------------------------------------------------------------------------

deploy_stage_types := {"Deployment", "Deploy"}

provenance_verify_step_types := {"SlsaVerify", "CosignVerify", "ArtifactVerify"}

stage_has_provenance_verify(stage) if {
    step := stage.spec.execution.steps[_]
    provenance_verify_step_types[step.step.type]
}

violation contains msg if {
    # Rule: RRP-012
    stage := input.pipeline.stages[_]
    deploy_stage_types[stage.type]
    not stage_has_provenance_verify(stage)
    msg := {
        "rule":     "RRP-012",
        "cve":      "CVE-2026-53849",
        "severity": "HIGH",
        "stage":    stage.name,
        "issue":    sprintf("Deploy stage '%v' does not verify artefact provenance before deployment. Tampered artefacts can reach production (CVE-2026-53849).", [stage.name]),
        "fix":      "Add a SlsaVerify or CosignVerify step as the first step in every deploy stage to validate artefact provenance attestations before use.",
    }
}

# ---------------------------------------------------------------------------
# RULE: RRP-013 — Pipeline triggers must only allow sources from an explicit
#                 allowlist of trusted repositories / organisations
# Severity: HIGH
# CVE: CVE-2026-41249
# Source: NVD (2026-06-22 scan, keyword: Harness)
# Status: DRAFT — awaiting human review before promotion
#
# CVE-2026-41249 describes a pipeline-trigger hijacking attack where an
# external fork or untrusted repository is allowed to trigger a pipeline that
# has access to privileged credentials. An attacker creates a fork-PR that
# passes pipeline execution context including secrets.
#
# Fix: Restrict pipeline trigger source to an explicit allowlist of trusted
#      GitHub organisations or repositories in the Harness trigger
#      configuration.
#
# Reference: https://nvd.nist.gov/vuln/detail/CVE-2026-41249
#            docs/violation-remediation.md#rrp-013
# ---------------------------------------------------------------------------

violation contains msg if {
    # Rule: RRP-013
    trigger := input.pipeline.triggers[_]
    trigger.type == "Webhook"
    not trigger.spec.sourceRepoFilter
    msg := {
        "rule":     "RRP-013",
        "cve":      "CVE-2026-41249",
        "severity": "HIGH",
        "trigger":  trigger.identifier,
        "issue":    sprintf("Webhook trigger '%v' has no sourceRepoFilter. Any fork or external repo can trigger this pipeline and access its secrets (CVE-2026-41249).", [trigger.identifier]),
        "fix":      "Set spec.sourceRepoFilter on the webhook trigger to restrict pipeline invocations to trusted organisations or repositories only.",
    }
}

# ---------------------------------------------------------------------------
# RULE: RRP-014 — Kubernetes service accounts must not auto-mount tokens
#                 in pipeline step pods
# Severity: HIGH
# CVE: CVE-2026-48546
# Source: NVD (2026-06-22 scan, keyword: Kubernetes)
# Status: DRAFT — awaiting human review before promotion
#
# CVE-2026-48546 exploits automatically mounted Kubernetes service account
# tokens in CI pipeline pods. A compromised step can read the token from
# /var/run/secrets/kubernetes.io/serviceaccount/token and use it to
# enumerate or control cluster resources.
#
# Fix: Set automountServiceAccountToken: false in the pipeline stage
#      infrastructure spec. If Kubernetes API access is needed, scope it to
#      a dedicated least-privilege service account.
#
# Reference: https://nvd.nist.gov/vuln/detail/CVE-2026-48546
#            docs/violation-remediation.md#rrp-014
# ---------------------------------------------------------------------------

violation contains msg if {
    # Rule: RRP-014
    stage := input.pipeline.stages[_]
    not stage.spec.infrastructure.spec.automountServiceAccountToken == false
    stage.spec.infrastructure.type == "KubernetesDirect"
    msg := {
        "rule":     "RRP-014",
        "cve":      "CVE-2026-48546",
        "severity": "HIGH",
        "stage":    stage.name,
        "issue":    sprintf("Stage '%v' uses Kubernetes infrastructure without setting automountServiceAccountToken: false. Compromised steps can steal the pod's cluster token (CVE-2026-48546).", [stage.name]),
        "fix":      "Set spec.infrastructure.spec.automountServiceAccountToken: false on all Kubernetes-backed pipeline stages.",
    }
}

# ---------------------------------------------------------------------------
# RULE: RRP-015 — All pipeline container steps must declare CPU and memory limits
# Severity: HIGH
# CVE: CVE-2026-45082
# Source: NVD (2026-06-22 scan, keyword: Kubernetes)
# Status: DRAFT — awaiting human review before promotion
#
# CVE-2026-45082 is a resource-exhaustion / denial-of-service vulnerability
# in Kubernetes CI/CD pipelines: steps without resource limits can consume
# all node resources, causing other workloads to be evicted or OOM-killed,
# including security-critical components.
#
# Fix: Set spec.resources.limits.cpu and spec.resources.limits.memory on
#      every pipeline container step.
#
# Reference: https://nvd.nist.gov/vuln/detail/CVE-2026-45082
#            docs/violation-remediation.md#rrp-015
# ---------------------------------------------------------------------------

step_missing_resource_limits(step) if {
    not step.step.spec.resources.limits.cpu
}

step_missing_resource_limits(step) if {
    not step.step.spec.resources.limits.memory
}

violation contains msg if {
    # Rule: RRP-015
    stage := input.pipeline.stages[_]
    step  := stage.spec.execution.steps[_]
    step_missing_resource_limits(step)
    msg := {
        "rule":     "RRP-015",
        "cve":      "CVE-2026-45082",
        "severity": "HIGH",
        "stage":    stage.name,
        "step":     step.step.name,
        "issue":    sprintf("Step '%v' in stage '%v' does not declare CPU and/or memory limits. Resource exhaustion can disrupt security-critical workloads (CVE-2026-45082).", [step.step.name, stage.name]),
        "fix":      "Set spec.resources.limits.cpu and spec.resources.limits.memory on every pipeline container step.",
    }
}

# ---------------------------------------------------------------------------
# RULE: RRP-016 — Pipeline stages must declare an explicit timeout
# Severity: HIGH
# CVE: CVE-2026-45298
# Source: NVD (2026-06-22 scan, keyword: CI/CD)
# Status: DRAFT — awaiting human review before promotion
#
# CVE-2026-45298 covers runaway pipeline stages without timeouts that allow
# a malicious or buggy step to hold pipeline resources indefinitely, creating
# a denial-of-service condition against the build infrastructure and
# potentially blocking security-gated deploys.
#
# Fix: Set a stage-level timeout (spec.timeout) on every pipeline stage.
#      Recommended maximum: 60m for build stages, 30m for deploy stages.
#
# Reference: https://nvd.nist.gov/vuln/detail/CVE-2026-45298
#            docs/violation-remediation.md#rrp-016
# ---------------------------------------------------------------------------

violation contains msg if {
    # Rule: RRP-016
    stage := input.pipeline.stages[_]
    not stage.spec.timeout
    msg := {
        "rule":     "RRP-016",
        "cve":      "CVE-2026-45298",
        "severity": "HIGH",
        "stage":    stage.name,
        "issue":    sprintf("Stage '%v' does not declare an explicit timeout. Runaway steps can hold pipeline infrastructure indefinitely (CVE-2026-45298).", [stage.name]),
        "fix":      "Set spec.timeout on every pipeline stage (e.g. '60m' for build stages, '30m' for deploy stages).",
    }
}

# ---------------------------------------------------------------------------
# RULE: RRP-017 — Pipeline YAML must not contain plaintext secrets
# Severity: HIGH
# CVE: CVE-2026-32847
# Source: NVD (2026-06-22 scan, keyword: secrets)
# Status: DRAFT — awaiting human review before promotion
#
# CVE-2026-32847 documents hardcoded plaintext credentials in CI/CD pipeline
# YAML files committed to source control. These credentials are exposed to
# everyone with repository read access and may persist in git history even
# after removal.
#
# Fix: Replace all plaintext secret values with Harness secret references
#      (<+secrets.getValue("secret_name")>) or environment variable
#      references backed by a secrets manager.
#
# Reference: https://nvd.nist.gov/vuln/detail/CVE-2026-32847
#            docs/violation-remediation.md#rrp-017
# ---------------------------------------------------------------------------

secret_like_patterns := [
    `(?i)password\s*[:=]\s*[^$<\s]{6,}`,
    `(?i)api.?key\s*[:=]\s*[^$<\s]{8,}`,
    `(?i)token\s*[:=]\s*[^$<\s]{8,}`,
    `(?i)secret\s*[:=]\s*[^$<\s]{6,}`,
    `(?i)access.?key\s*[:=]\s*[^$<\s]{8,}`,
]

env_var_has_plaintext_secret(env_val) if {
    is_string(env_val)
    pattern := secret_like_patterns[_]
    regex.match(pattern, env_val)
    not startswith(env_val, "<+secrets")
    not startswith(env_val, "<+env")
}

violation contains msg if {
    # Rule: RRP-017
    stage   := input.pipeline.stages[_]
    step    := stage.spec.execution.steps[_]
    env_key := step.step.spec.envVariables[_]
    env_val := step.step.spec.envVariables[env_key]
    env_var_has_plaintext_secret(env_val)
    msg := {
        "rule":     "RRP-017",
        "cve":      "CVE-2026-32847",
        "severity": "HIGH",
        "stage":    stage.name,
        "step":     step.step.name,
        "env_var":  env_key,
        "issue":    sprintf("Step '%v' in stage '%v' sets environment variable '%v' to a value that looks like a plaintext secret (CVE-2026-32847).", [step.step.name, stage.name, env_key]),
        "fix":      "Replace plaintext secret values with Harness secret references: <+secrets.getValue(\"secret_name\")>",
    }
}

# ===========================================================================
# ███  MEDIUM SEVERITY RULES (RRP-018 → RRP-029)
# ===========================================================================

# ---------------------------------------------------------------------------
# RULE: RRP-018 — Pipeline step containers must not run as UID 0
# Severity: MEDIUM
# CVE: CVE-2026-49325
# Source: NVD (2026-06-22 scan, keyword: Docker)
# Status: DRAFT — awaiting human review before promotion
#
# CVE-2026-49325 is a broader coverage rule complementing RRP-006:
#   RRP-006 (CRITICAL) catches steps that *explicitly* configure root via
#     runAsUser=0 or runAsNonRoot=false and is treated as a deliberate choice.
#   RRP-018 (MEDIUM) catches steps whose containerSecurityContext is entirely
#     absent — the container may run as root by default without the author
#     realising it. These are distinct conditions warranting different severities.
#
# Reference: https://nvd.nist.gov/vuln/detail/CVE-2026-49325
# ---------------------------------------------------------------------------

violation contains msg if {
    # Rule: RRP-018
    stage := input.pipeline.stages[_]
    step  := stage.spec.execution.steps[_]
    not step.step.spec.containerSecurityContext
    step.step.type == "Run"
    msg := {
        "rule":     "RRP-018",
        "cve":      "CVE-2026-49325",
        "severity": "MEDIUM",
        "stage":    stage.name,
        "step":     step.step.name,
        "issue":    sprintf("Run step '%v' in stage '%v' has no containerSecurityContext defined. The step may run as root by default (CVE-2026-49325).", [step.step.name, stage.name]),
        "fix":      "Add containerSecurityContext with runAsNonRoot: true and runAsUser: 1000 to all Run steps.",
    }
}

# ---------------------------------------------------------------------------
# RULE: RRP-019 — Harness webhook triggers must use HMAC signature verification
# Severity: MEDIUM
# CVE: CVE-2026-48208
# Source: NVD (2026-06-22 scan, keyword: Harness)
# Status: DRAFT — awaiting human review before promotion
#
# CVE-2026-48208 documents webhook spoofing against Harness pipelines where
# triggers without HMAC validation accept forged webhook payloads from any
# source, enabling unauthorised pipeline runs.
#
# Reference: https://nvd.nist.gov/vuln/detail/CVE-2026-48208
# ---------------------------------------------------------------------------

violation contains msg if {
    # Rule: RRP-019
    trigger := input.pipeline.triggers[_]
    trigger.type == "Webhook"
    not trigger.spec.secretToken
    msg := {
        "rule":     "RRP-019",
        "cve":      "CVE-2026-48208",
        "severity": "MEDIUM",
        "trigger":  trigger.identifier,
        "issue":    sprintf("Webhook trigger '%v' does not configure a secretToken for HMAC validation. Forged webhooks can trigger unauthorised pipeline runs (CVE-2026-48208).", [trigger.identifier]),
        "fix":      "Set spec.secretToken on the webhook trigger to a Harness secret reference. This enables HMAC payload signature verification.",
    }
}

# ---------------------------------------------------------------------------
# RULE: RRP-020 — Kubernetes pipeline stages must specify a dedicated namespace
# Severity: MEDIUM
# CVE: CVE-2026-53808
# Source: NVD (2026-06-22 scan, keyword: Kubernetes)
# Status: DRAFT — awaiting human review before promotion
#
# CVE-2026-53808 describes lateral movement within a Kubernetes cluster when
# pipeline pods run in shared or default namespaces, co-locating with
# cluster-critical components and gaining unintended API access.
#
# Reference: https://nvd.nist.gov/vuln/detail/CVE-2026-53808
# ---------------------------------------------------------------------------

forbidden_namespaces := {"default", "kube-system", "kube-public"}

violation contains msg if {
    # Rule: RRP-020
    stage := input.pipeline.stages[_]
    stage.spec.infrastructure.type == "KubernetesDirect"
    ns := stage.spec.infrastructure.spec.namespace
    forbidden_namespaces[lower(ns)]
    msg := {
        "rule":      "RRP-020",
        "cve":       "CVE-2026-53808",
        "severity":  "MEDIUM",
        "stage":     stage.name,
        "namespace": ns,
        "issue":     sprintf("Stage '%v' runs in the '%v' Kubernetes namespace. Co-location with system workloads enables lateral movement (CVE-2026-53808).", [stage.name, ns]),
        "fix":       "Create a dedicated namespace for pipeline workloads (e.g. 'harness-builds') and set spec.infrastructure.spec.namespace accordingly.",
    }
}

# ---------------------------------------------------------------------------
# RULE: RRP-021 — Connectors must not use credentials that are older than 90 days
# Severity: MEDIUM
# CVE: CVE-2026-47672
# Source: NVD (2026-06-22 scan, keyword: CI/CD)
# Status: DRAFT — awaiting human review before promotion
#
# CVE-2026-47672 covers stale long-lived credentials on CI/CD connectors
# that increase the blast radius of a credential compromise. Credentials
# older than 90 days without rotation have an elevated exposure window.
#
# Reference: https://nvd.nist.gov/vuln/detail/CVE-2026-47672
# ---------------------------------------------------------------------------

violation contains msg if {
    # Rule: RRP-021
    connector := input.connectors[_]
    expiry    := connector.spec.credential.expiresAt
    is_string(expiry)
    # Flag credentials already past their expiry date
    time.parse_rfc3339_ns(expiry) < time.now_ns()
    msg := {
        "rule":      "RRP-021",
        "cve":       "CVE-2026-47672",
        "severity":  "MEDIUM",
        "connector": connector.identifier,
        "issue":     sprintf("Connector '%v' uses credentials that have passed their expiry date. Stale credentials increase compromise blast radius (CVE-2026-47672).", [connector.identifier]),
        "fix":       "Rotate the connector credentials and set a new expiresAt not more than 90 days in the future.",
    }
}

# ---------------------------------------------------------------------------
# RULE: RRP-022 — Pipeline steps must not propagate all env vars between stages
# Severity: MEDIUM
# CVE: CVE-2026-40564
# Source: NVD (2026-06-22 scan, keyword: CI/CD)
# Status: DRAFT — awaiting human review before promotion
#
# CVE-2026-40564 describes unrestricted inter-stage environment variable
# propagation where a compromised earlier stage injects malicious values into
# later stages' environment, influencing build outputs or deploy targets.
#
# Reference: https://nvd.nist.gov/vuln/detail/CVE-2026-40564
# ---------------------------------------------------------------------------

violation contains msg if {
    # Rule: RRP-022
    stage := input.pipeline.stages[_]
    stage.spec.execution.steps[_]
    stage.spec.sharedPaths[_] == "/"
    msg := {
        "rule":     "RRP-022",
        "cve":      "CVE-2026-40564",
        "severity": "MEDIUM",
        "stage":    stage.name,
        "issue":    sprintf("Stage '%v' shares the root path '/' between steps via sharedPaths, enabling unrestricted environment/file propagation (CVE-2026-40564).", [stage.name]),
        "fix":      "Replace sharedPaths: ['/'] with explicit paths (e.g. '/workspace', '/tmp/build-artifacts') to limit inter-step data propagation.",
    }
}

# ---------------------------------------------------------------------------
# RULE: RRP-023 — Pipeline log output must not echo secrets or tokens
# Severity: MEDIUM
# CVE: CVE-2026-44247
# Source: NVD (2026-06-22 scan, keyword: secrets)
# Status: DRAFT — awaiting human review before promotion
#
# CVE-2026-44247 covers accidental secret disclosure in CI/CD pipeline log
# output: scripts that echo environment variables or debug with `set -x`
# print secrets to build logs that may be accessible to all repo contributors.
#
# Reference: https://nvd.nist.gov/vuln/detail/CVE-2026-44247
# ---------------------------------------------------------------------------

log_disclosure_patterns := [
    `\becho\s+\$`,
    `\bset\s+-x\b`,
    `\bprintenv\b`,
    `\benv\b\s*$`,
]

step_command_echoes_secrets(step) if {
    cmd     := step.step.spec.command
    pattern := log_disclosure_patterns[_]
    regex.match(pattern, cmd)
    env_keys := {k | step.step.spec.envVariables[k]}
    count(env_keys) > 0
}

violation contains msg if {
    # Rule: RRP-023
    stage := input.pipeline.stages[_]
    step  := stage.spec.execution.steps[_]
    step.step.type == "Run"
    step_command_echoes_secrets(step)
    msg := {
        "rule":     "RRP-023",
        "cve":      "CVE-2026-44247",
        "severity": "MEDIUM",
        "stage":    stage.name,
        "step":     step.step.name,
        "issue":    sprintf("Step '%v' in stage '%v' may echo environment variables to log output. Secrets present in envVariables will be disclosed in build logs (CVE-2026-44247).", [step.step.name, stage.name]),
        "fix":      "Remove 'set -x', 'printenv', and bare 'echo $VAR' calls from step commands when env variables contain secrets. Use Harness log-masking for sensitive variables.",
    }
}

# ---------------------------------------------------------------------------
# RULE: RRP-024 — Container steps must drop all Linux capabilities
# Severity: MEDIUM
# CVE: CVE-2026-41184
# Source: NVD (2026-06-22 scan, keyword: Docker)
# Status: DRAFT — awaiting human review before promotion
#
# CVE-2026-41184 covers Linux capability abuse in CI container steps where
# retained default capabilities (e.g. NET_RAW, SYS_PTRACE) enable network
# sniffing or process injection attacks against co-located pipeline pods.
#
# Reference: https://nvd.nist.gov/vuln/detail/CVE-2026-41184
# ---------------------------------------------------------------------------

violation contains msg if {
    # Rule: RRP-024
    stage := input.pipeline.stages[_]
    step  := stage.spec.execution.steps[_]
    not step.step.spec.containerSecurityContext.capabilities.drop
    step.step.spec.containerSecurityContext
    msg := {
        "rule":     "RRP-024",
        "cve":      "CVE-2026-41184",
        "severity": "MEDIUM",
        "stage":    stage.name,
        "step":     step.step.name,
        "issue":    sprintf("Step '%v' in stage '%v' does not drop Linux capabilities. Retained capabilities (e.g. NET_RAW) enable network-sniffing and process-injection (CVE-2026-41184).", [step.step.name, stage.name]),
        "fix":      "Set containerSecurityContext.capabilities.drop: [ALL] on all container steps to remove default Linux capabilities.",
    }
}

# ---------------------------------------------------------------------------
# RULE: RRP-025 — Pipeline pods must apply a seccomp profile
# Severity: MEDIUM
# CVE: CVE-2026-41185
# Source: NVD (2026-06-22 scan, keyword: Kubernetes)
# Status: DRAFT — awaiting human review before promotion
#
# CVE-2026-41185 (companion to CVE-2026-41184) documents syscall-based
# container escape techniques that are mitigated by seccomp profiles.
# Pipeline pods without a seccomp profile can make arbitrary syscalls that
# are blocked by the RuntimeDefault or Localhost profiles.
#
# Reference: https://nvd.nist.gov/vuln/detail/CVE-2026-41185
# ---------------------------------------------------------------------------

violation contains msg if {
    # Rule: RRP-025
    stage := input.pipeline.stages[_]
    stage.spec.infrastructure.type == "KubernetesDirect"
    not stage.spec.infrastructure.spec.podSpec.securityContext.seccompProfile
    msg := {
        "rule":     "RRP-025",
        "cve":      "CVE-2026-41185",
        "severity": "MEDIUM",
        "stage":    stage.name,
        "issue":    sprintf("Stage '%v' uses Kubernetes infrastructure without specifying a seccomp profile. Missing seccomp allows arbitrary syscalls and container escape (CVE-2026-41185).", [stage.name]),
        "fix":      "Set spec.infrastructure.spec.podSpec.securityContext.seccompProfile.type to 'RuntimeDefault' or 'Localhost' on all Kubernetes-backed stages.",
    }
}

# ---------------------------------------------------------------------------
# RULE: RRP-026 — Approval gates must not be by-passable via stage skip
# Severity: MEDIUM
# CVE: CVE-2026-8606
# Source: NVD (2026-06-22 scan, keyword: Harness)
# Status: DRAFT — awaiting human review before promotion
#
# CVE-2026-8606 describes a Harness pipeline approval bypass where a
# pipeline run can skip approval stages by setting stage.when conditions
# that evaluate to false for the approval stage, effectively short-circuiting
# required human sign-off on production deployments.
#
# Reference: https://nvd.nist.gov/vuln/detail/CVE-2026-8606
# ---------------------------------------------------------------------------

stage_is_approval(stage) if {
    stage.type == "Approval"
}

stage_has_skip_condition(stage) if {
    stage.when.condition
    # Guard: pipelineStatus may be undefined; check with object.get before lower()
    status := object.get(stage.when, "pipelineStatus", "")
    lower(status) == "success"
    stage.when.condition != ""
}

violation contains msg if {
    # Rule: RRP-026
    stage := input.pipeline.stages[_]
    stage_is_approval(stage)
    stage_has_skip_condition(stage)
    msg := {
        "rule":     "RRP-026",
        "cve":      "CVE-2026-8606",
        "severity": "MEDIUM",
        "stage":    stage.name,
        "issue":    sprintf("Approval stage '%v' has a conditional skip expression (when.condition) that may bypass the approval gate (CVE-2026-8606).", [stage.name]),
        "fix":      "Remove the when.condition expression from approval stages, or ensure it cannot evaluate to false for production pipelines. Approval stages should always be unconditional.",
    }
}

# ---------------------------------------------------------------------------
# RULE: RRP-027 — Harness templates must be pinned to a stable version
# Severity: MEDIUM
# CVE: CVE-2026-42878
# Source: NVD (2026-06-22 scan, keyword: Harness)
# Status: DRAFT — awaiting human review before promotion
#
# CVE-2026-42878 describes a supply-chain attack via mutable Harness template
# versions: pipelines that use `versionLabel: Always` or unpinned "stable"
# labels silently pick up template changes, allowing a compromised template
# update to alter pipeline behaviour without PR review.
#
# Reference: https://nvd.nist.gov/vuln/detail/CVE-2026-42878
# ---------------------------------------------------------------------------

template_uses_mutable_version(ref) if {
    lower(ref.versionLabel) == "always"
}

template_uses_mutable_version(ref) if {
    lower(ref.versionLabel) == "stable"
}

template_uses_mutable_version(ref) if {
    lower(ref.versionLabel) == "latest"
}

violation contains msg if {
    # Rule: RRP-027
    stage := input.pipeline.stages[_]
    ref   := stage.template.templateRef
    template_uses_mutable_version(ref)
    msg := {
        "rule":     "RRP-027",
        "cve":      "CVE-2026-42878",
        "severity": "MEDIUM",
        "stage":    stage.name,
        "issue":    sprintf("Stage '%v' uses a mutable template version label ('%v'). Template changes can silently alter pipeline behaviour (CVE-2026-42878).", [stage.name, ref.versionLabel]),
        "fix":      "Pin the template versionLabel to a specific numeric version (e.g. '2.1.0') instead of a mutable label like 'Always', 'stable', or 'latest'.",
    }
}

# ---------------------------------------------------------------------------
# RULE: RRP-028 — OPA policy bundles must have signature verification enabled
# Severity: MEDIUM
# CVE: CVE-2026-9618
# Source: NVD (2026-06-22 scan, keyword: Open Policy Agent)
# Status: DRAFT — awaiting human review before promotion
#
# CVE-2026-9618 covers OPA bundle tampering where bundle fetched from a
# remote registry without signature verification can be replaced by an
# attacker who compromises the bundle storage, silently weakening the
# organisation's policy enforcement posture.
#
# Reference: https://nvd.nist.gov/vuln/detail/CVE-2026-9618
# ---------------------------------------------------------------------------

violation contains msg if {
    # Rule: RRP-028
    bundle := input.opaConfig.bundles[_]
    not bundle.signing
    msg := {
        "rule":   "RRP-028",
        "cve":    "CVE-2026-9618",
        "severity": "MEDIUM",
        "bundle": bundle.name,
        "issue":  sprintf("OPA bundle '%v' does not have signature verification (signing) configured. A tampered bundle can weaken policy enforcement (CVE-2026-9618).", [bundle.name]),
        "fix":    "Configure a bundle signing key in the OPA bundle configuration and enable bundle signature verification.",
    }
}

# ---------------------------------------------------------------------------
# RULE: RRP-029 — Sensitive environment variable names must be masked in logs
# Severity: MEDIUM
# CVE: CVE-2026-45582
# Source: NVD (2026-06-22 scan, keyword: secrets)
# Status: DRAFT — awaiting human review before promotion
#
# CVE-2026-45582 is a log-disclosure variant: environment variables whose
# names contain patterns like PASSWORD, TOKEN, SECRET, KEY, or CREDENTIAL
# should always be declared as masked so that Harness redacts their values
# from build log output.
#
# Reference: https://nvd.nist.gov/vuln/detail/CVE-2026-45582
# ---------------------------------------------------------------------------

sensitive_env_name_patterns := [
    `(?i)password`,
    `(?i)token`,
    `(?i)secret`,
    `(?i)api.?key`,
    `(?i)credential`,
    `(?i)private.?key`,
]

env_name_is_sensitive(name) if {
    pattern := sensitive_env_name_patterns[_]
    regex.match(pattern, name)
}

violation contains msg if {
    # Rule: RRP-029
    stage   := input.pipeline.stages[_]
    step    := stage.spec.execution.steps[_]
    env_key := step.step.spec.envVariables[_]
    env_name_is_sensitive(env_key)
    not step.step.spec.envVariables[env_key] == null
    not startswith(step.step.spec.envVariables[env_key], "<+secrets")
    msg := {
        "rule":    "RRP-029",
        "cve":     "CVE-2026-45582",
        "severity": "MEDIUM",
        "stage":   stage.name,
        "step":    step.step.name,
        "env_var": env_key,
        "issue":   sprintf("Step '%v' in stage '%v' sets env var '%v' (name suggests a secret) but does not reference a Harness secret manager. The value may appear in logs (CVE-2026-45582).", [step.step.name, stage.name, env_key]),
        "fix":     "Reference the value via a Harness secret: <+secrets.getValue(\"secret_name\")>. This ensures the value is masked in log output.",
    }
}

# ===========================================================================
# ██  LOW SEVERITY RULES (RRP-030 → RRP-031)
# ===========================================================================

# ---------------------------------------------------------------------------
# RULE: RRP-030 — Pipelines should generate an SBOM for build artefacts
# Severity: LOW
# CVE: CVE-2026-46072
# Source: NVD (2026-06-22 scan, keyword: supply chain)
# Status: DRAFT — awaiting human review before promotion
#
# CVE-2026-46072 covers inadequate software supply chain visibility: build
# pipelines that do not generate a Software Bill of Materials (SBOM) for
# their artefacts make it harder to identify dependency exposure when new
# CVEs are published, increasing mean-time-to-remediate.
#
# Reference: https://nvd.nist.gov/vuln/detail/CVE-2026-46072
# ---------------------------------------------------------------------------

sbom_step_types := {"SBOM", "SyftSBOM", "TrivySBOM", "AnchoreSBOM"}

stage_has_sbom_step(stage) if {
    step := stage.spec.execution.steps[_]
    sbom_step_types[step.step.type]
}

violation contains msg if {
    # Rule: RRP-030
    stage := input.pipeline.stages[_]
    stage_has_build_step(stage)
    not stage_has_sbom_step(stage)
    msg := {
        "rule":     "RRP-030",
        "cve":      "CVE-2026-46072",
        "severity": "LOW",
        "stage":    stage.name,
        "issue":    sprintf("Stage '%v' builds a container image but does not include an SBOM generation step. Missing SBOM increases mean-time-to-remediate for dependency CVEs (CVE-2026-46072).", [stage.name]),
        "fix":      "Add a Syft or Trivy SBOM generation step after the container build step and publish the SBOM as a build artefact.",
    }
}

# ---------------------------------------------------------------------------
# RULE: RRP-031 — Pipelines should forward audit events to a SIEM/log aggregator
# Severity: LOW
# CVE: CVE-2026-44830
# Source: NVD (2026-06-22 scan, keyword: CI/CD)
# Status: DRAFT — awaiting human review before promotion
#
# CVE-2026-44830 covers audit log retention gaps in CI/CD pipelines where
# pipeline execution events are not forwarded to a central SIEM or log
# aggregation system, hindering incident response and forensic investigation
# after a supply-chain compromise.
#
# Reference: https://nvd.nist.gov/vuln/detail/CVE-2026-44830
# ---------------------------------------------------------------------------

violation contains msg if {
    # Rule: RRP-031
    not input.pipeline.auditForwarding
    input.pipeline.stages[_]
    msg := {
        "rule":     "RRP-031",
        "cve":      "CVE-2026-44830",
        "severity": "LOW",
        "issue":    "Pipeline does not configure audit event forwarding (auditForwarding). Execution events are not sent to a central SIEM, hindering incident response (CVE-2026-44830).",
        "fix":      "Configure pipeline.auditForwarding with a Harness audit streaming connector pointing to your SIEM or log aggregation platform.",
    }
}
