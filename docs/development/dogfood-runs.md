# Repo Validation Check Dogfood Runs

Status: active evidence log for the `repo-validation-check` candidate skill.

Core boundary:

```text
Skill checks before handoff; CI verifies after push.
```

This document records observed runs. It is evidence for deciding whether the candidate skill is useful, not approval for promotion.

## Runs

```yaml
dogfood_run:
  date: 2026-06-01
  task: add repo validation check skill candidate
  commit: 5572efc
  local_validation:
    passed: 35
    failed: 0
    skipped: 0
  changed_files:
    - aiwf/modules/skills/repo-validation-check/SKILL.md
    - aiwf/registry/aiwf.capabilities.yaml
    - docs/development/validation.md
  ci:
    run_id: 26734865697
    result: success
  usefulness:
    reduced_missed_steps: yes
    clarified_ci_boundary: yes
    caused_false_authority: no
  notes:
    - Local validation was run before commit and push.
    - CI was checked after push before reporting final success.
    - The skill remained candidate and was not adopted by an adapter or release manifest.
```

```yaml
dogfood_run:
  date: 2026-06-01
  task: add repo validation skill dogfood protocol
  commit: c0037e0
  local_validation:
    passed: null
    failed: null
    skipped: null
  changed_files:
    - docs/development/repo-validation-check-dogfood.md
  ci:
    run_id: 26737493684
    result: success
  usefulness:
    reduced_missed_steps: unknown
    clarified_ci_boundary: yes
    caused_false_authority: no
  notes:
    - CI was verified after push.
    - Local validation was not separately recorded for this docs-only change.
    - Keep this as partial evidence only; it does not satisfy the local-validation promotion criterion.
```

## Current Assessment

The candidate skill is useful as a preflight reminder and CI-boundary reminder.

It is not ready for promotion yet. At least one more fully recorded run should show local validation before handoff and CI verification after push.
