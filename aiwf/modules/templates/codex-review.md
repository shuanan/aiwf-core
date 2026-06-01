# Codex Review Template

Use only when worker profile allows Codex.

Role: advisory reviewer only.

Prompt:

```text
Review this diff against the TaskEnvelope.

Return:
- blocking risks
- missing tests
- unclear assumptions
- security or data risks
- not checked

Do not approve.
Do not merge.
Do not mark done.
```
