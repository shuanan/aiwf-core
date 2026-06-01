# AIWF Core Validation

This document describes the minimal validation checks for the standalone `aiwf-core` repository.

## Purpose

The validation script is a lightweight repository health check. It verifies that the initial AIWF Core scaffold remains small, portable, and free of default runtime automation.

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
- YAML files parse when PyYAML is available.
- Registry capability `location` paths exist.
- Approved registry capabilities define non-empty `authority_boundary.can` and `authority_boundary.cannot` lists.
- Release manifest components resolve to either a registry capability or the kernel component.
- Registry skill and template paths exist.
- Git working tree status is reported.

## What it does not check

- It does not approve AIWF adoption.
- It does not validate downstream repo adapters.
- It does not call Claude, Codex, Slack, Linear, Notion, or Langfuse.
- It does not install hooks, edit settings, or auto-run repository automation.
- It does not rewrite schemas.
- It does not prove that any prompt, skill, or schema is correct.

## Optional dependency

YAML parse validation and internal reference checks use Python `PyYAML` when available.

Install locally only if desired:

```bash
python3 -m pip install pyyaml
```

If PyYAML is not installed, the script skips the YAML parse and internal reference checks and reports them as `SKIP`.

## Expected use

Run before committing structural changes:

```bash
bash scripts/validate-aiwf-core.sh
```

For the initial repository, the script should pass with no failures.
