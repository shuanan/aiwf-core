# SOP Enforcement Audit

Status: advisory, read-only audit. Non-authoritative.

This note describes how `docs/sops/aiwf-change-lifecycle.v0.1.md` is enforced. It
does **not** enforce anything itself. The source of truth for enforcement is
`scripts/validate-aiwf-core.sh` (run in CI by `.github/workflows/validate.yml`);
if the validator changes, re-derive this note from it. This file holds no live
state values (no commit SHAs, statuses, counts, or run ids).

## Enforcement summary

| SOP rule | Enforcement |
| --- | --- |
| Registry approved-only authority boundary | script (validator) |
| Selectable only when approved | schema + script (adapter-adoption check) |
| Adapter adoption boundary (approved + registered only) | script (validator) |
| Dogfood evidence gate | CI (validator) |
| No default hooks / no `.claude/settings.json` | script (validator) |
| Declaration integrity (artifact/registry/adapter) | script (validator) |
| Validation runs before merge | CI (signal only) |
| No direct master push | human / branch protection |
| Write preview before persistent writes | human-only (kernel K5) |
| Branch + draft PR | manual / process |
| Human-only merge | human-only (kernel K1) |
| Promotion (candidate → approved) | human-only (gate refuses to promote) |
| Sync-anchor mirror subordination | documented only (governs external mirrors) |

## Human-only by design (not gaps)

These are intentionally **not** script-enforced and must stay that way. Automating
them would create a self-approval surface, which kernel K1 forbids:

- no direct master push (enforced, if at all, by GitHub branch protection — human-configured, out of repo)
- write preview + explicit human approval before persistent writes (K5)
- branch + draft PR workflow discipline
- human-only merge
- promotion / selectability / adapter-adoption decisions

The dogfood evidence gate deliberately only **counts** valid runs and refuses to
promote; promotion remains a human decision.

## Optional future lightweight checks (not done here)

Recorded for consideration only; this audit changes nothing:

- Validate full `capability_required_fields` (per the registry schema) for every
  capability, not just `can`/`cannot` for `approved` entries.
- Add the governing SOP and `docs/development/sync-anchor.md` to the validator's
  required-file list so they cannot be deleted silently.

## Non-claims

This file is a description only. It is **not** promotion, selectability approval,
adapter adoption, runtime/settings change, or merge/deploy authority.
