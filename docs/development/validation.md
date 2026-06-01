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
- Git working tree status is reported.

## What it does not check

- It does not approve AIWF adoption.
- It does not validate downstream repo adapters.
- It does not install hooks.
- It does not call Claude, Codex, Slack, Linear, Notion, or Langfuse.
- It does not prove that any prompt, skill, or schema is correct.

## Optional dependency

YAML parse validation uses Python `PyYAML` when available.

Install locally only if desired:

```bash
python3 -m pip install pyyaml
```

If PyYAML is not installed, the script skips the YAML parse check and reports it as `SKIP`.

## Expected use

Run before committing structural changes:

```bash
bash scripts/validate-aiwf-core.sh
```

For the initial repository, the script should pass with no failures.
