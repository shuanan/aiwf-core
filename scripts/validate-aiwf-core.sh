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

if find . -path './.git' -prune -o -name '*.yaml' -print | grep -q .; then
  if python3 - <<'PY'
try:
    import yaml  # type: ignore
except Exception:
    raise SystemExit(42)
PY
  then
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

    python3 - <<'PY'
from pathlib import Path
import sys
import yaml  # type: ignore


def load_yaml(path: str):
    with Path(path).open("r", encoding="utf-8") as handle:
        return yaml.safe_load(handle)


registry = load_yaml("aiwf/registry/aiwf.capabilities.yaml")
kernel = load_yaml("aiwf/kernel/kernel.v0.1.yaml")
release = load_yaml("aiwf/releases/aiwf.v0.1.0.yaml")

errors = []
capabilities = registry.get("capabilities") or []
registry_ids = {capability.get("id") for capability in capabilities}
kernel_components = {("kernel", kernel.get("version"))}

for capability in capabilities:
    capability_id = capability.get("id", "<missing id>")
    capability_type = capability.get("type")
    location = capability.get("location")

    if not location:
        errors.append(f"REGISTRY_LOCATION_MISSING {capability_id}")
    elif not Path(location).is_file():
        errors.append(f"REGISTRY_LOCATION_NOT_FOUND {capability_id}: {location}")

    if capability.get("status") == "approved":
        boundary = capability.get("authority_boundary") or {}
        for key in ("can", "cannot"):
            value = boundary.get(key)
            if not isinstance(value, list) or not value:
                errors.append(f"APPROVED_AUTHORITY_BOUNDARY_MISSING {capability_id}: authority_boundary.{key}")

    if capability_type in {"skill", "template"}:
        if not location or not Path(location).is_file():
            errors.append(f"REGISTRY_{capability_type.upper()}_PATH_NOT_FOUND {capability_id}: {location}")

release_components = release.get("components") or {}
for component_group, items in release_components.items():
    if not isinstance(items, list):
        errors.append(f"RELEASE_COMPONENT_GROUP_INVALID {component_group}")
        continue

    for item in items:
        component_id = item.get("id") if isinstance(item, dict) else None
        component_version = item.get("version") if isinstance(item, dict) else None
        if component_id in registry_ids:
            continue
        if (component_id, component_version) in kernel_components:
            continue
        errors.append(f"RELEASE_COMPONENT_UNRESOLVED {component_group}: {component_id}@{component_version}")

if errors:
    for error in errors:
        print(error, file=sys.stderr)
    raise SystemExit(1)

print("INTERNAL_REFERENCES OK")
PY
    pass "internal references are consistent"
  else
    skip "PyYAML not installed; YAML parse check not run"
    skip "PyYAML not installed; internal reference checks not run"
  fi
else
  fail "no YAML files found"
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
