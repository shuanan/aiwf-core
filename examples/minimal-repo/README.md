# Minimal Downstream Adapter Example

This directory shows a minimal downstream repo adoption draft for AIWF Core.

It is an example only. It does not adopt AIWF Core into any real repository.

## Files

```text
examples/minimal-repo/aiwf.adapter.yaml
```

## What this example demonstrates

- Adapter-first adoption.
- Thin kernel adoption.
- Small capability subset.
- Local repo boundaries.
- Write preview requirement.
- Notify/manual default worker mode.
- No hooks.
- No settings changes.
- No worker auto-run.
- No paid worker execution.

## Important boundary

The example adapter uses:

```yaml
status: draft
```

That means it is not active adoption.

A downstream repo may treat an adapter as active only after human review and explicit approval.

## Suggested adoption flow

1. Copy `aiwf.adapter.yaml` into a target repo.
2. Keep `status: draft`.
3. Adjust `target_repo`.
4. Adjust `allowed_paths`, `protected_paths`, and `forbidden_paths`.
5. Adjust adopted capabilities.
6. Run local validation if available.
7. Review the adapter manually.
8. Only then change status to `approved`.

## Not included

This example does not include:

- Claude Code hooks.
- `.claude/settings.json`.
- GitHub Actions changes.
- Slack or Linear automation.
- Codex execution.
- Claude `-p` execution.
- Auto-merge or deployment.
