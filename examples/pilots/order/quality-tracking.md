# Order Pilot — Quality Tracking (L1 + L2)

## Purpose

Track AI workflow discipline, not prove software correctness.
Order has no CI, no test suite, no automated verification.

## L1 — Commit message + diff review checklist

For every AI-assisted change in Order:

- [ ] Scope clearly stated before work began
- [ ] Files changed match write preview
- [ ] No files outside approved scope modified
- [ ] No production / deploy / DB / config risk introduced
- [ ] No secrets or credentials exposed in diff
- [ ] Commit message follows convention

## L2 — Session debrief log

At session end, record in Notion or Linear comment
(not in any repo):

- date
- task_scope
- files_changed
- write_preview_done (yes/no)
- validation_available (no — Order has no CI/tests)
- manual_verification_result
- issues_found
- follow_up

## Explicitly deferred

- L3: deploy verification gate
- L4: governance compliance metrics
- Quality score / dashboard
- Automated debrief hook
- CI-like pass/fail claims
- Langfuse / external telemetry
