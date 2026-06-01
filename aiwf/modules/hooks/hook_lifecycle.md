# Hook Lifecycle v0.1

```yaml
H0_candidate:
  installed: false
  effect: none

H1_log_only:
  installed: true
  blocks: false

H2_warn:
  installed: true
  blocks: false

H3_block:
  installed: true
  blocks: true
  requires: explicit_human_approval
```

Hook generator skills may propose hooks, fixtures, install previews, and rollback plans.

They must not install hooks or edit `.claude/settings.json`.
