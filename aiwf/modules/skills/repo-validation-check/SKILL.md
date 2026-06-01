---
name: repo-validation-check
description: Candidate skill for running and interpreting AIWF Core repository validation before handoff.
disable-model-invocation: true
allowed-tools: Read Bash
---

# repo-validation-check

## Purpose

Help an agent run local validation before handoff, interpret the output, stop on failures, report pass/fail/skip counts, and remember that CI remains the final receipt after push.

## Must

- Run `bash scripts/validate-aiwf-core.sh` when available.
- Report the exact validation summary.
- Report changed files with `git status --short`.
- Distinguish local validation from CI validation.
- Say CI is still required after push.

## Must not

- Claim adoption approved.
- Claim CI passed before CI actually ran.
- Install hooks.
- Modify settings.
- Call Claude, Codex, Slack, Linear, Notion, or Langfuse.
- Auto-fix without explicit write approval.
- Mark Done or merge.
