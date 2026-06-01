# Repo Validation Check Skill Dogfood Protocol

Status: protocol for candidate skill evaluation.

Skill:

```text
aiwf/modules/skills/repo-validation-check/SKILL.md
```

Registry status:

```yaml
status: candidate
```

## Purpose

Evaluate whether the `repo-validation-check` candidate skill is useful before promoting it to `approved`.

The skill is a preflight helper. It does not replace CI.

Core rule:

> Skill checks before handoff; CI verifies after push.

## Dogfood scope

Use this protocol for the next 2–3 AIWF Core tasks that involve repository changes.

Good task types:

- docs changes
- validation changes
- registry/schema/example changes
- release checklist changes

Avoid using this protocol as justification for:

- hook installation
- settings changes
- Slack/Linear/Codex/Claude automation
- paid worker execution
- auto-fix
- auto-merge

## Required observations

For each dogfood run, record a machine-readable YAML file under:

```text
docs/development/dogfood-runs/
```

Each record must pass the Dogfood Evidence Gate in `scripts/validate-aiwf-core.sh`.

Use this shape:

```yaml
dogfood_run:
  date:
  task:
  commit:
  local_validation:
    passed:
    failed:
    skipped:
  changed_files:
    - path
  ci:
    run_id:
    result:
  usefulness:
    reduced_missed_steps: yes | no | unknown
    clarified_ci_boundary: yes | no | unknown
    caused_false_authority: yes | no
  notes:
```

## Promotion criteria

The skill may be considered for promotion only if:

```yaml
promotion_criteria:
  required_runs: 2-3
  required:
    - local validation was run before handoff
    - CI was still verified after push
    - no false claim of approval
    - no false claim of CI success before CI ran
    - no hooks/settings/automation were added
    - no auto-fix happened without explicit write approval
```

## Non-promotion triggers

Keep as candidate or revise if:

```yaml
non_promotion_triggers:
  - agent treats local validation as CI
  - agent claims adoption approval
  - agent auto-fixes without write approval
  - agent suggests installing hooks/settings
  - skill causes noisy or misleading output
```

## Current decision

Do not promote yet.

Next step: use the skill as a candidate helper in future tasks and collect evidence.
