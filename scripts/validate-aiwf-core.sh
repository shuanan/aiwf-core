#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

PASS=0
FAIL=0
SKIP=0

pass() {
  printf 'PASS %s\n' "$1"
  PASS=$((PASS + 1))
}

fail() {
  printf 'FAIL %s\n' "$1" >&2
  FAIL=$((FAIL + 1))
}

skip() {
  printf 'SKIP %s\n' "$1"
  SKIP=$((SKIP + 1))
}

require_file() {
  local path="$1"
  if [[ -f "$path" ]]; then
    pass "required file exists: $path"
  else
    fail "missing required file: $path"
  fi
}

forbid_path() {
  local path="$1"
  if [[ -e "$path" ]]; then
    fail "forbidden path exists: $path"
  else
    pass "forbidden path absent: $path"
  fi
}

require_file "README.md"
require_file "CHANGELOG.md"
require_file "aiwf/kernel/kernel.v0.1.yaml"
require_file "aiwf/registry/aiwf.capabilities.yaml"
require_file "aiwf/registry/aiwf.capabilities.schema.yaml"
require_file "aiwf/adapters/aiwf.adapter.schema.yaml"
require_file "aiwf/adapters/templates/aiwf.adapter.yaml"
require_file "aiwf/workers/aiwf.worker-profiles.schema.yaml"
require_file "aiwf/workers/templates/worker-profiles.yaml"
require_file "aiwf/control-plane/aiwf.control-plane.schema.yaml"
require_file "aiwf/control-plane/templates/linear-slack-notion-langfuse.yaml"
require_file "aiwf/lifecycle/release_manifest.schema.yaml"
require_file "aiwf/lifecycle/upgrade_plan.schema.yaml"
require_file "aiwf/lifecycle/dogfood_run.schema.yaml"
require_file "aiwf/releases/aiwf.v0.1.0.yaml"
require_file "docs/architecture/architecture.v0.1.md"
require_file "docs/architecture/kernel.v0.1.md"
require_file "docs/extraction/extraction_decision.md"
require_file "docs/quickstart.md"
require_file "docs/development/validation.md"
require_file "docs/development/v0.1-foundation-checklist.md"
require_file "docs/development/declaration-integrity-gate.md"
require_file "examples/README.md"
require_file "examples/minimal-repo/README.md"
require_file "examples/minimal-repo/aiwf.adapter.yaml"

forbid_path ".claude/settings.json"
forbid_path "archives"
forbid_path ".env"
forbid_path "secrets"
forbid_path "credentials"

if find . -path './.git' -prune -o -path './.claude/hooks/*' -print | grep -q .; then
  fail "runtime hooks exist under .claude/hooks"
else
  pass "no runtime hooks installed by default"
fi

PYTHON_YAML_AVAILABLE=0
if python3 - <<'PY'
try:
    import yaml  # type: ignore
except Exception:
    raise SystemExit(42)
PY
then
  PYTHON_YAML_AVAILABLE=1
else
  PYTHON_YAML_AVAILABLE=0
fi

if find . -path './.git' -prune -o -name '*.yaml' -print | grep -q .; then
  if [[ "$PYTHON_YAML_AVAILABLE" -eq 1 ]]; then
    python3 - <<'PY'
from pathlib import Path
import sys
import yaml  # type: ignore

bad = []
for path in sorted(Path(".").rglob("*.yaml")):
    if ".git" in path.parts:
        continue
    try:
        with path.open("r", encoding="utf-8") as handle:
            yaml.safe_load(handle)
    except Exception as exc:
        bad.append((str(path), str(exc)))

if bad:
    for path, error in bad:
        print(f"YAML_PARSE_FAIL {path}: {error}", file=sys.stderr)
    raise SystemExit(1)

print("YAML OK")
PY
    pass "YAML files parse with PyYAML"
  else
    skip "PyYAML not installed; YAML parse check not run"
  fi
else
  fail "no YAML files found"
fi

if [[ "$PYTHON_YAML_AVAILABLE" -eq 1 ]]; then
  python3 - <<'PY'
from pathlib import Path
import sys
import yaml  # type: ignore

def remediation(message: str) -> str:
    return (
        f"{message}\n"
        "  remediation_options:\n"
        "    A_register: add or update registry entry if this is intended as an approved capability\n"
        "    B_remove: remove adoption from adapter if this repo should not adopt it\n"
        "    C_candidate: keep artifact as candidate/reference but do not adopt it\n"
        "  rule: validator detects mismatch; human decides intent"
    )

registry_path = Path("aiwf/registry/aiwf.capabilities.yaml")
release_path = Path("aiwf/releases/aiwf.v0.1.0.yaml")
kernel_path = Path("aiwf/kernel/kernel.v0.1.yaml")
example_adapter_path = Path("examples/minimal-repo/aiwf.adapter.yaml")

registry = yaml.safe_load(registry_path.read_text(encoding="utf-8"))
release = yaml.safe_load(release_path.read_text(encoding="utf-8"))
kernel = yaml.safe_load(kernel_path.read_text(encoding="utf-8"))
example_adapter = yaml.safe_load(example_adapter_path.read_text(encoding="utf-8"))

errors = []

capabilities = registry.get("capabilities", [])
capability_ids = {cap.get("id") for cap in capabilities}
capability_status = {cap.get("id"): cap.get("status") for cap in capabilities}

for cap in capabilities:
    cap_id = cap.get("id", "<missing-id>")
    location = cap.get("location")
    if location and not Path(location).exists():
        errors.append(
            "DECLARATION_MISMATCH registry_points_to_missing_artifact "
            f"capability={cap_id} location={location}\n"
            "  remediation_options:\n"
            "    A_create: create the referenced artifact if registry entry is intended\n"
            "    B_fix: update registry location if path is wrong\n"
            "    C_remove: remove/deprecate registry entry if artifact should not exist"
        )
    if cap.get("status") == "approved":
        boundary = cap.get("authority_boundary") or {}
        if not boundary.get("can"):
            errors.append(f"DECLARATION_MISMATCH approved_capability_missing_can capability={cap_id}")
        if not boundary.get("cannot"):
            errors.append(f"DECLARATION_MISMATCH approved_capability_missing_cannot capability={cap_id}")

for cap in release.get("components", {}).get("capabilities", []):
    cap_id = cap.get("id")
    if cap_id not in capability_ids:
        errors.append(
            "DECLARATION_MISMATCH release_mentions_unregistered_capability "
            f"capability={cap_id}\n"
            "  remediation_options:\n"
            "    A_register: add registry entry before release references it\n"
            "    B_remove: remove capability from release manifest\n"
            "    C_defer: keep artifact as candidate outside release"
        )

kernel_rule_ids = {key for key in kernel.keys() if key.startswith("K")}

if example_adapter.get("status") != "draft":
    errors.append(
        "DECLARATION_MISMATCH example_adapter_not_draft\n"
        "  remediation_options:\n"
        "    A_set_draft: keep example non-adopted\n"
        "    B_escalate: create a real adoption decision outside examples"
    )

adapter_hooks = (
    example_adapter
    .get("adopted", {})
    .get("capabilities", {})
    .get("hooks", [])
)
if adapter_hooks != []:
    errors.append(
        "DECLARATION_MISMATCH example_adapter_adopts_hooks\n"
        "  remediation_options:\n"
        "    A_remove: keep example hook-free\n"
        "    B_create_hook_example: create separate hook-specific example with explicit risk notes"
    )

worker_policy = example_adapter.get("worker_policy", {})
if worker_policy.get("default_mode") != "notify_only":
    errors.append("DECLARATION_MISMATCH example_adapter_default_mode_not_notify_only")
if worker_policy.get("auto_paid_worker") is not False:
    errors.append("DECLARATION_MISMATCH example_adapter_auto_paid_worker_not_false")

for required_forbidden_path in [".env*", "secrets/**", "credentials/**"]:
    forbidden_paths = example_adapter.get("local_boundary", {}).get("forbidden_paths", [])
    if required_forbidden_path not in forbidden_paths:
        errors.append(f"DECLARATION_MISMATCH example_adapter_forbidden_paths_missing path={required_forbidden_path}")

adapter_skill_ids = [
    item.get("id")
    for item in (
        example_adapter
        .get("adopted", {})
        .get("capabilities", {})
        .get("skills", [])
    )
]
adapter_template_ids = [
    item.get("id")
    for item in (
        example_adapter
        .get("adopted", {})
        .get("capabilities", {})
        .get("templates", [])
    )
]
for cap_id in adapter_skill_ids + adapter_template_ids:
    if cap_id not in capability_ids:
        errors.append(
            remediation(
                "DECLARATION_MISMATCH adapter_adopts_unregistered_capability "
                f"capability={cap_id}"
            )
        )
    elif capability_status.get(cap_id) != "approved":
        errors.append(
            "DECLARATION_MISMATCH adapter_adopts_non_approved_capability "
            f"capability={cap_id} status={capability_status.get(cap_id)}\n"
            "  remediation_options:\n"
            "    A_promote: run lifecycle before adoption\n"
            "    B_remove: remove capability from adapter\n"
            "    C_pin: explicitly document temporary exception, if policy allows"
        )

adapter_kernel_rules = (
    example_adapter
    .get("adopted", {})
    .get("kernel", {})
    .get("rules", [])
)
for rule_id in adapter_kernel_rules:
    if rule_id not in kernel_rule_ids:
        errors.append(
            "DECLARATION_MISMATCH adapter_adopts_unknown_kernel_rule "
            f"rule={rule_id}\n"
            "  remediation_options:\n"
            "    A_fix: correct rule ID in adapter\n"
            "    B_add: add kernel rule only through explicit architecture decision\n"
            "    C_remove: remove rule adoption"
        )

if errors:
    for error in errors:
        print(error, file=sys.stderr)
    raise SystemExit(1)

print("INTERNAL_REFERENCES OK")
print("EXAMPLE_ADAPTER OK")
print("DECLARATION_INTEGRITY OK")
PY
  pass "internal registry/release references are consistent"
  pass "example adapter structure is safe draft"
  pass "declaration integrity mismatches include remediation guidance"
else
  skip "PyYAML not installed; internal reference checks not run"
  skip "PyYAML not installed; example adapter checks not run"
  skip "PyYAML not installed; declaration integrity checks not run"
fi

if [[ "$PYTHON_YAML_AVAILABLE" -eq 1 ]]; then
  python3 - <<'PY'
from collections import Counter
from pathlib import Path
import sys
import yaml  # type: ignore

schema_path = Path("aiwf/lifecycle/dogfood_run.schema.yaml")
records_dir = Path("docs/development/dogfood-runs")

schema = yaml.safe_load(schema_path.read_text(encoding="utf-8"))
record_paths = sorted(records_dir.glob("*.yaml"))
errors = []
valid_runs = Counter()


def require_mapping(value, label):
    if not isinstance(value, dict):
        errors.append(f"DOGFOOD_EVIDENCE_FAIL {label} must be a mapping")
        return {}
    return value


def require_fields(mapping, fields, label):
    for field in fields:
        if field not in mapping or mapping[field] in (None, ""):
            errors.append(f"DOGFOOD_EVIDENCE_FAIL {label} missing required field: {field}")


def expect(value, expected, label):
    if value != expected:
        errors.append(f"DOGFOOD_EVIDENCE_FAIL {label} expected {expected!r}, got {value!r}")


if not record_paths:
    errors.append("DOGFOOD_EVIDENCE_FAIL no dogfood run records found")

for path in record_paths:
    record = require_mapping(yaml.safe_load(path.read_text(encoding="utf-8")), str(path))
    require_fields(record, schema.get("required_fields", []), str(path))

    skill_id = record.get("skill_id")
    local_validation = require_mapping(record.get("local_validation"), f"{path}: local_validation")
    ci = require_mapping(record.get("ci"), f"{path}: ci")
    boundary = require_mapping(record.get("boundary"), f"{path}: boundary")
    human_observation = require_mapping(record.get("human_observation"), f"{path}: human_observation")

    require_fields(local_validation, schema.get("local_validation_required_fields", []), f"{path}: local_validation")
    require_fields(ci, schema.get("ci_required_fields", []), f"{path}: ci")
    require_fields(boundary, schema.get("boundary_required_fields", []), f"{path}: boundary")
    require_fields(human_observation, schema.get("human_observation_required_fields", []), f"{path}: human_observation")

    expect(local_validation.get("ran_before_commit"), True, f"{path}: local_validation.ran_before_commit")
    expect(local_validation.get("failed"), 0, f"{path}: local_validation.failed")
    expect(local_validation.get("skipped"), 0, f"{path}: local_validation.skipped")
    expect(ci.get("verified_after_push"), True, f"{path}: ci.verified_after_push")
    expect(ci.get("result"), "success", f"{path}: ci.result")
    expect(ci.get("failed"), 0, f"{path}: ci.failed")
    expect(ci.get("skipped"), 0, f"{path}: ci.skipped")

    for field in schema.get("boundary_required_fields", []):
        expect(boundary.get(field), True, f"{path}: boundary.{field}")

    caused_false_authority = human_observation.get("caused_false_authority")
    if caused_false_authority not in ("no", False):
        errors.append(
            "DOGFOOD_EVIDENCE_FAIL "
            f"{path}: human_observation.caused_false_authority expected 'no', got {caused_false_authority!r}"
        )

    if not errors:
        valid_runs[skill_id] += 1

if errors:
    for error in errors:
        print(error, file=sys.stderr)
    print(
        "DOGFOOD_EVIDENCE_FAIL evidence gate cannot promote skills; human decision required",
        file=sys.stderr,
    )
    raise SystemExit(1)

for skill_id, count in sorted(valid_runs.items()):
    print(f"DOGFOOD_EVIDENCE OK {skill_id} valid_runs={count}")
PY
  pass "dogfood evidence records are complete"
else
  skip "PyYAML not installed; dogfood evidence checks not run"
fi

if git status --short | grep -q .; then
  pass "working tree has expected local changes during validation run"
else
  pass "working tree clean"
fi

printf '\nvalidate-aiwf-core: %s passed, %s failed, %s skipped\n' "$PASS" "$FAIL" "$SKIP"

if [[ "$FAIL" -ne 0 ]]; then
  exit 1
fi
