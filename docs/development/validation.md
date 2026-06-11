# AIWF Core Validation

This document describes the validation checks for the standalone `aiwf-core` repository.

## Purpose

The validation script is a lightweight repository health check. It verifies that the AIWF Core scaffold remains small, portable, internally consistent, and free of default runtime automation.

It does not prove semantic correctness, adoption readiness, or downstream safety.

## Script

```bash
scripts/validate-aiwf-core.sh
```

## What it checks

- Required core files exist.
- Forbidden default runtime surfaces are absent.
- `.claude/settings.json` is not present.
- Runtime hooks are not installed by default.
- YAML files parse (PyYAML required; validator hard-fails without it).
- Capability registry `location` paths exist.
- Approved capabilities have `authority_boundary.can` and `authority_boundary.cannot`.
- Release manifest capability IDs exist in the registry.
- The minimal example adapter remains a safe draft:
  - `status: draft`
  - hooks are empty
  - `worker_policy.default_mode: notify_only`
  - `worker_policy.auto_paid_worker: false`
  - forbidden paths include `.env*`, `secrets/**`, and `credentials/**`
  - adopted capability IDs exist in the registry
  - adopted kernel rules exist in the kernel
- Declaration mismatches include remediation guidance instead of silently choosing intent.
- Git working tree status is reported.

## Declaration Integrity Gate

The validator checks declaration integrity across three surfaces:

- Artifact: a file exists.
- Registry: the library exposes a selectable capability.
- Adapter: a repo or example claims adoption.

Valid adoption requires all of these to align:

- Artifact exists.
- Registry entry exists.
- Registry status is `approved`.
- Adapter adopts it.

When the validator finds a mismatch, it must report the mismatch and remediation options. It must not silently register, remove, promote, downgrade, or adopt anything.

See `docs/development/declaration-integrity-gate.md`.

## Skill vs CI boundary

`repo-validation-check` may help an agent run local validation before handoff.

It is not a replacement for CI.

- Skill checks before handoff.
- CI verifies after push.
- Local validation is useful preflight evidence.
- GitHub Actions remains the final repository receipt.
- A skill must not claim CI passed before CI actually runs.

## Dogfood Evidence Gate

Dogfood run records live under:

```text
docs/development/dogfood-runs/*.yaml
```

CI validates that records are complete, have zero failed/skipped checks, preserve boundary flags, and record CI verification after push.

The gate may count valid runs per candidate skill.

The gate must not promote a skill. Promotion remains a human decision.

## What it does not check

- It does not approve AIWF adoption.
- It does not validate real downstream repo adapters.
- It does not install hooks.
- It does not call Claude, Codex, Slack, Linear, Notion, or Langfuse.
- It does not prove that any prompt, skill, or schema is correct.

## Required dependency (PyYAML)

The core YAML gates (parse, internal reference, example-adapter, declaration
integrity, dogfood evidence) require Python `PyYAML`. Install it before running the validator:

```bash
python3 -m pip install pyyaml
```

If PyYAML is not installed the validator hard-fails (exit 1) rather than skipping the
core gates. For a quick local run of the non-YAML checks only, set
`AIWF_ALLOW_NO_PYYAML=1` to bypass — this is ignored when `CI=true`, so CI always
enforces PyYAML.

## Expected use

Run before committing structural changes:

```bash
bash scripts/validate-aiwf-core.sh
```

CI installs PyYAML, so CI should run the full validation set with no skipped checks.
