#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  scripts/record-dogfood-run.sh <skill-id> --task "<task summary>"

Example:
  scripts/record-dogfood-run.sh repo-validation-check --task "docs: add schema examples"

Purpose:
  Generate a machine-readable dogfood evidence YAML record.

What it does:
  - requires a clean working tree
  - runs scripts/validate-aiwf-core.sh
  - captures local validation pass/fail/skip counts
  - detects current commit and branch
  - detects GitHub PR if one exists for the branch
  - detects successful GitHub Actions run for the current commit
  - writes docs/development/dogfood-runs/<skill-id>-run-NNN.yaml

What it does not do:
  - promote skills
  - edit registry status
  - edit release manifests
  - approve or merge PRs
  - install hooks
  - modify settings
  - call Claude/Codex/Slack/Linear/Notion
EOF
}

SKILL_ID=""
TASK=""

if [[ $# -lt 1 ]]; then
  usage
  exit 2
fi

SKILL_ID="$1"
shift

while [[ $# -gt 0 ]]; do
  case "$1" in
    --task)
      if [[ $# -lt 2 ]]; then
        echo "ERROR --task requires a value" >&2
        exit 2
      fi
      TASK="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR unknown argument: $1" >&2
      usage
      exit 2
      ;;
  esac
done

if [[ -z "$SKILL_ID" ]]; then
  echo "ERROR skill id is required" >&2
  exit 2
fi

if [[ -z "$TASK" ]]; then
  echo "ERROR --task is required" >&2
  exit 2
fi

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$ROOT" ]]; then
  echo "ERROR not inside a git repository" >&2
  exit 1
fi
cd "$ROOT"

if [[ ! -x scripts/validate-aiwf-core.sh && ! -f scripts/validate-aiwf-core.sh ]]; then
  echo "ERROR scripts/validate-aiwf-core.sh not found" >&2
  exit 1
fi

if [[ -n "$(git status --short)" ]]; then
  echo "ERROR working tree must be clean before recording dogfood evidence" >&2
  git status --short >&2
  exit 1
fi

BRANCH="$(git rev-parse --abbrev-ref HEAD)"
COMMIT="$(git rev-parse HEAD)"
SHORT_COMMIT="$(git rev-parse --short HEAD)"
DATE="$(date +%F)"

VALIDATION_LOG="$(mktemp)"
trap 'rm -f "$VALIDATION_LOG" "$GH_RUNS_JSON" "$PR_JSON"' EXIT

if ! bash scripts/validate-aiwf-core.sh | tee "$VALIDATION_LOG"; then
  echo "ERROR local validation failed; dogfood evidence not recorded" >&2
  exit 1
fi

SUMMARY_LINE="$(grep -E 'validate-aiwf-core: [0-9]+ passed, [0-9]+ failed, [0-9]+ skipped' "$VALIDATION_LOG" | tail -n 1 || true)"
if [[ -z "$SUMMARY_LINE" ]]; then
  echo "ERROR could not parse validation summary" >&2
  exit 1
fi

read -r LOCAL_PASSED LOCAL_FAILED LOCAL_SKIPPED < <(
  python3 - "$SUMMARY_LINE" <<'PY'
import re
import sys

line = sys.argv[1]
match = re.search(r'validate-aiwf-core:\s+(\d+)\s+passed,\s+(\d+)\s+failed,\s+(\d+)\s+skipped', line)
if not match:
    raise SystemExit(1)
print(match.group(1), match.group(2), match.group(3))
PY
)

if [[ "$LOCAL_FAILED" != "0" || "$LOCAL_SKIPPED" != "0" ]]; then
  echo "ERROR local validation must have 0 failed and 0 skipped" >&2
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "ERROR GitHub CLI 'gh' is required to record CI evidence" >&2
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "ERROR GitHub CLI is not authenticated" >&2
  exit 1
fi

GH_RUNS_JSON="$(mktemp)"
if ! gh run list --commit "$COMMIT" --limit 20 --json databaseId,status,conclusion,headSha,workflowName,event,url,createdAt > "$GH_RUNS_JSON"; then
  echo "ERROR failed to query GitHub Actions runs for commit $SHORT_COMMIT" >&2
  exit 1
fi

read -r CI_RUN_ID CI_RESULT CI_URL < <(
  python3 - "$GH_RUNS_JSON" "$COMMIT" <<'PY'
import json
import sys

path, commit = sys.argv[1], sys.argv[2]
runs = json.load(open(path, encoding="utf-8"))
for run in runs:
    if run.get("headSha") == commit and run.get("status") == "completed" and run.get("conclusion") == "success":
        print(run.get("databaseId"), run.get("conclusion"), run.get("url") or "")
        raise SystemExit(0)
raise SystemExit(1)
PY
) || {
  echo "ERROR no successful completed GitHub Actions run found for commit $SHORT_COMMIT" >&2
  echo "Hint: push first, wait for CI to pass, then rerun this recorder." >&2
  exit 1
}

CI_LOG="$(mktemp)"
trap 'rm -f "$VALIDATION_LOG" "$GH_RUNS_JSON" "$PR_JSON" "$CI_LOG"' EXIT

if ! gh run view "$CI_RUN_ID" --log > "$CI_LOG"; then
  echo "ERROR failed to fetch CI log for run $CI_RUN_ID" >&2
  exit 1
fi

CI_SUMMARY_LINE="$(grep -E 'validate-aiwf-core: [0-9]+ passed, [0-9]+ failed, [0-9]+ skipped' "$CI_LOG" | tail -n 1 || true)"
if [[ -z "$CI_SUMMARY_LINE" ]]; then
  echo "ERROR could not parse CI validation summary from run $CI_RUN_ID" >&2
  exit 1
fi

read -r CI_PASSED CI_FAILED CI_SKIPPED < <(
  python3 - "$CI_SUMMARY_LINE" <<'PY'
import re
import sys

line = sys.argv[1]
match = re.search(r'validate-aiwf-core:\s+(\d+)\s+passed,\s+(\d+)\s+failed,\s+(\d+)\s+skipped', line)
if not match:
    raise SystemExit(1)
print(match.group(1), match.group(2), match.group(3))
PY
)

if [[ "$CI_FAILED" != "0" || "$CI_SKIPPED" != "0" ]]; then
  echo "ERROR CI validation must have 0 failed and 0 skipped" >&2
  exit 1
fi

TRACKING_MODE="branch_no_pr"
PR_NUMBER=""
PR_URL=""
PR_HEAD_BRANCH=""
PR_BASE_BRANCH=""
PR_STATE=""

PR_JSON="$(mktemp)"
if gh pr view --json number,url,headRefName,baseRefName,state > "$PR_JSON" 2>/dev/null; then
  TRACKING_MODE="github_pr"
  read -r PR_NUMBER PR_URL PR_HEAD_BRANCH PR_BASE_BRANCH PR_STATE < <(
    python3 - "$PR_JSON" <<'PY'
import json
import sys

data = json.load(open(sys.argv[1], encoding="utf-8"))
print(
    data.get("number", ""),
    data.get("url", ""),
    data.get("headRefName", ""),
    data.get("baseRefName", ""),
    data.get("state", ""),
)
PY
  )
else
  if [[ "$BRANCH" == "master" || "$BRANCH" == "main" ]]; then
    TRACKING_MODE="direct_push"
  fi
fi

RUN_DIR="docs/development/dogfood-runs"
mkdir -p "$RUN_DIR"

NEXT_NUM="$(
  python3 - "$RUN_DIR" "$SKILL_ID" <<'PY'
from pathlib import Path
import re
import sys

run_dir = Path(sys.argv[1])
skill_id = sys.argv[2]
pattern = re.compile(re.escape(skill_id) + r"-run-(\d{3})\.yaml$")
nums = []
for path in run_dir.glob(f"{skill_id}-run-*.yaml"):
    match = pattern.match(path.name)
    if match:
        nums.append(int(match.group(1)))
print(f"{(max(nums) if nums else 0) + 1:03d}")
PY
)"
OUTPUT_PATH="$RUN_DIR/${SKILL_ID}-run-${NEXT_NUM}.yaml"

if [[ -e "$OUTPUT_PATH" ]]; then
  echo "ERROR output already exists: $OUTPUT_PATH" >&2
  exit 1
fi

cat > "$OUTPUT_PATH" <<EOF
skill_id: ${SKILL_ID}
run_id: "${NEXT_NUM}"
date: ${DATE}
commit: ${COMMIT}
task: ${TASK}

local_validation:
  ran_before_commit: true
  passed: ${LOCAL_PASSED}
  failed: ${LOCAL_FAILED}
  skipped: ${LOCAL_SKIPPED}

ci:
  verified_after_push: true
  run_id: ${CI_RUN_ID}
  result: ${CI_RESULT}
  passed: ${CI_PASSED}
  failed: ${CI_FAILED}
  skipped: ${CI_SKIPPED}
  url: ${CI_URL}

source_control:
  tracking_mode: ${TRACKING_MODE}
  branch: ${BRANCH}
  commit: ${COMMIT}
EOF

if [[ "$TRACKING_MODE" == "github_pr" ]]; then
  cat >> "$OUTPUT_PATH" <<EOF
  pr:
    number: ${PR_NUMBER}
    url: ${PR_URL}
    head_branch: ${PR_HEAD_BRANCH}
    base_branch: ${PR_BASE_BRANCH}
    state: ${PR_STATE}
EOF
else
  cat >> "$OUTPUT_PATH" <<EOF
  pr:
    number:
    url:
    head_branch:
    base_branch:
    state:
EOF
fi

cat >> "$OUTPUT_PATH" <<'EOF'

boundary:
  no_false_ci_claim: true
  no_adoption_approval_claim: true
  no_hooks_or_settings: true
  no_external_services: true
  no_auto_fix: true
  no_auto_merge: true

human_observation:
  reduced_missed_steps: unknown
  clarified_ci_boundary: yes
  caused_false_authority: no

notes:
  - Generated by scripts/record-dogfood-run.sh.
  - This record is evidence only and does not promote the skill.
EOF

echo "Created dogfood evidence: $OUTPUT_PATH"
echo
bash scripts/validate-aiwf-core.sh
echo
echo "Next:"
echo "  git add $OUTPUT_PATH"
echo "  git commit -m \"chore: record dogfood evidence\""
echo "  git push"
