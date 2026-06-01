# Dogfood Evidence Recorder

`record-dogfood-run.sh` generates machine-readable dogfood evidence records so runs do not need to be filled in manually.

## Command

```bash
bash scripts/record-dogfood-run.sh repo-validation-check --task "docs: add schema examples"
```

## What it records

The recorder automatically captures:

- current branch
- current commit
- local validation pass/fail/skip counts
- successful GitHub Actions run id
- CI validation pass/fail/skip counts
- PR metadata if the current branch has a PR
- direct-push / branch-without-PR tracking mode if no PR exists

## Tracking modes

```yaml
tracking_modes:
  github_pr:
    meaning: current branch has a GitHub PR
  direct_push:
    meaning: current branch is master/main and no PR is attached
  branch_no_pr:
    meaning: current branch is not master/main and no PR exists
```

PR tracking is optional. The recorder records PR fields when a PR exists, but it does not create a PR.

## Requirements

- clean working tree
- `git`
- GitHub CLI `gh`
- authenticated `gh`
- `python3`
- successful GitHub Actions run for the current commit

## Output

Records are written to:

```text
docs/development/dogfood-runs/<skill-id>-run-NNN.yaml
```

Example:

```text
docs/development/dogfood-runs/repo-validation-check-run-002.yaml
```

## Boundary

The recorder may:

- run local validation
- read git state
- read GitHub PR / Actions state through `gh`
- write a dogfood evidence YAML file

The recorder must not:

- promote skills
- edit registry status
- edit release manifests
- approve or merge PRs
- install hooks
- modify settings
- call Claude, Codex, Slack, Linear, or Notion
- auto-fix files

## Flow

```bash
# after a small repo change has been pushed and CI has passed
bash scripts/record-dogfood-run.sh repo-validation-check --task "short task summary"

git add docs/development/dogfood-runs/*.yaml
git commit -m "chore: record dogfood evidence"
git push
```

CI then validates the evidence through the Dogfood Evidence Gate.
