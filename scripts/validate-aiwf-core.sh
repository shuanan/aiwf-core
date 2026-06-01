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
require_file "aiwf/releases/aiwf.v0.1.0.yaml"
require_file "docs/architecture/architecture.v0.1.md"
require_file "docs/architecture/kernel.v0.1.md"
require_file "docs/extraction/extraction_decision.md"
require_file "docs/quickstart.md"
require_file "docs/development/validation.md"
require_file "docs/development/v0.1-foundation-checklist.md"
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

for cap in capabilities:
    cap_id = cap.get("id", "<missing-id>")
    location = cap.get("location")
    if location and not Path(location).exists():
        errors.append(f"capability {cap_id} location does not exist: {location}")
    if cap.get("status") == "approved":
        boundary = cap.get("authority_boundary") or {}
        if not boundary.get("can"):
            errors.append(f"approved capability {cap_id} missing authority_boundary.can")
        if not boundary.get("cannot"):
            errors.append(f"approved capability {cap_id} missing authority_boundary.cannot")

for cap in release.get("components", {}).get("capabilities", []):
    cap_id = cap.get("id")
    if cap_id not in capability_ids:
        errors.append(f"release component not found in registry: {cap_id}")

kernel_rule_ids = {key for key in kernel.keys() if key.startswith("K")}

if example_adapter.get("status") != "draft":
    errors.append("example adapter status must be draft")

adapter_hooks = (
    example_adapter
    .get("adopted", {})
    .get("capabilities", {})
    .get("hooks", [])
)
if adapter_hooks != []:
    errors.append("example adapter hooks must be empty")

worker_policy = example_adapter.get("worker_policy", {})
if worker_policy.get("default_mode") != "notify_only":
    errors.append("example adapter worker_policy.default_mode must be notify_only")
if worker_policy.get("auto_paid_worker") is not False:
    errors.append("example adapter worker_policy.auto_paid_worker must be false")

for required_forbidden_path in [".env*", "secrets/**", "credentials/**"]:
    forbidden_paths = example_adapter.get("local_boundary", {}).get("forbidden_paths", [])
    if required_forbidden_path not in forbidden_paths:
        errors.append(f"example adapter forbidden_paths missing {required_forbidden_path}")

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
        errors.append(f"example adapter adopted capability not found in registry: {cap_id}")

adapter_kernel_rules = (
    example_adapter
    .get("adopted", {})
    .get("kernel", {})
    .get("rules", [])
)
for rule_id in adapter_kernel_rules:
    if rule_id not in kernel_rule_ids:
        errors.append(f"example adapter kernel rule not found in kernel: {rule_id}")

if errors:
    for error in errors:
        print(f"INTERNAL_REFERENCE_FAIL {error}", file=sys.stderr)
    raise SystemExit(1)

print("INTERNAL_REFERENCES OK")
print("EXAMPLE_ADAPTER OK")
PY
  pass "internal registry/release references are consistent"
  pass "example adapter structure is safe draft"
else
  skip "PyYAML not installed; internal reference checks not run"
  skip "PyYAML not installed; example adapter checks not run"
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
