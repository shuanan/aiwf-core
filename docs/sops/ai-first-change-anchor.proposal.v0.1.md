# AI-FIRST Change Anchor — PROPOSAL v0.1

> **Status: PROPOSED — NOT ADOPTED. Governance-medium.**
>
> This is a thin crosswalk proposal, not an approved SOP, **not** a kernel rule,
> **not** a registry capability, and **not** validator-enforced. It is not
> adoption, merge, release, or deploy approval.
>
> It does **not** replace or weaken kernel invariants **K1–K7** or any canonical
> AIWF SOP. On any conflict, kernel rules + adopted SOPs + local repo boundaries
> (**K6**) win. This document only *maps* an external "AI-FIRST" compact anchor
> onto existing aiwf-core capabilities — it does not redefine them.
>
> Adoption requires **explicit human approval** via the AIWF Change Lifecycle SOP
> (`docs/sops/aiwf-change-lifecycle.v0.1.md`). Until then this file is advisory
> only and supersedes nothing.

## 1. Purpose

Provide a thin glue/crosswalk between the AI-FIRST compact anchor and the
governance surface that already exists in aiwf-core. The intent is to make the
anchor usable *without* introducing a competing monolithic workflow: every phase
points at an existing capability, kernel rule, or SOP. Where the anchor adds a
genuinely new scaffold (scale classifier, flags, light/heavy routing,
load-bearing facts, architecture-before-slice, reviewer independence,
macro-before-micro verification), this proposal states it as **advisory** and
defers any enforceable form to a later human-approved lifecycle decision.

This document maps; it does not redefine. Where this proposal and an adopted
artifact appear to differ, the adopted artifact and the kernel govern.

## 2. Phase crosswalk — Understand → Evidence → Synthesis → Execution → Verification (UESEV)

Each phase is satisfied by existing aiwf-core capabilities, not by new machinery:

| Phase | Existing aiwf-core capability | Kernel anchor |
|---|---|---|
| **Understand** | `task-assessment` skill (`aiwf/modules/skills/task-assessment/SKILL.md`) — classify scope/type, surface blocking unknowns, decide proceed/split/research/stop | K3 task boundary |
| **Evidence** | `source-check`, `repo-intake`, `hallucination-check` skills — verify claims against current source; label fact/inference/assumption/unknown | K2 source boundary, K4 epistemic boundary |
| **Synthesis** | `write-preview` and `task-envelope` templates — structure the proposed change and its bounded handoff | K5 write boundary |
| **Execution** | `aiwf-change-lifecycle` SOP local-executor lane — apply only the approved preview, run validation, commit/branch/draft-PR | K1 no self-approval, K5, K6 |
| **Verification** | `repo-validation-check` skill + lifecycle "Done criteria" — validation is evidence, not approval | K1, K4 |

The anchor reuses these; it does not create a new pipeline that bypasses them.

## 3. Scale classifier (advisory; extends, does not replace)

A size axis layered *on top of* `task-assessment` `scope_mode` (it does not
replace `scope_mode` or the lifecycle change tiers):

- **single-page** — a localized change confined to one surface/page/component.
- **feature-module** — a change spanning a module or multiple coupled surfaces.

## 4. Flags (advisory)

Risk flags that promote a change toward the heavy path regardless of scale:

- **cross-repo** — touches or depends on more than one repository.
- **DB** — touches a data store, schema, or migration.
- **auth-export** — touches an authentication, permission, or export boundary.
- **runtime** — touches runtime configuration, hooks, settings, or deploy surface.

## 5. Light path vs Heavy path (advisory)

- **Light path** — `single-page` **and** no flags:
  confirm scope → inspect the nearby pattern → write-preview the change → verify.
- **Heavy path** — `feature-module` **or** any flag set:
  inventory the source → reconcile coverage → **verify load-bearing facts before
  Synthesis** → then proceed through preview/execution/verification.

Routing is advisory input to `task-assessment`; it never grants approval (K1, K5).

## 6. Load-bearing facts (confirm before Synthesis)

On the heavy path, confirm these against current source before any synthesis or
write preview. Unconfirmed items are blocking unknowns, not assumptions (K2/K4):

- **host/nav repo** — which repo and navigation surface owns the change.
- **data source** — where the data actually comes from.
- **writer** — what writes the data / who owns the write path.
- **DB boundary** — the data-store boundary being crossed, if any.
- **permission/export boundary** — the auth/permission/export boundary, if any.

## 7. Architecture before slice (advisory)

- Slice into implementation work **only after** the architecture is fixed.
- An **architecture change requires re-gating** — return to Understand/architecture
  approval before resuming slices.
- **DB / auth / runtime** changes use **small slices**.
- For feature-module or high-risk work, a **human-approved architecture** precedes
  the first implementation slice. This is advisory here; Major-tier changes remain
  human-approved per `docs/architecture/minimum-framework-spec.md` and the lifecycle
  SOP. This proposal does not itself approve any architecture or slice.

## 8. Reviewer independence taxonomy (advisory)

Restates and refines K1 ("no actor checks itself"): AI review is **advisory only**
and never self-approval. Reviewer independence is classified along these
dimensions — independence is stronger as more dimensions differ between the
author actor and the reviewer actor:

- **vendor**
- **model**
- **instance**
- **context**
- **tool**
- **write-authority**

This taxonomy describes independence; it does not grant review authority or
approval power.

## 9. Verification order — macro before micro (advisory)

Verify in this order; a passing micro check never substitutes for a missing macro
check:

1. **Macro** — spec coverage, architecture, and repo / data / write / permission
   boundary.
2. **Micro** — diff, file, and route checks.

**Done means verified.** If verification could not be completed, state the limits
explicitly rather than claiming done (K4). Validation is evidence, not approval
(K1); a human decides.

## 10. Authority note

Authority: **advisory_only**. This proposal supersedes nothing. It is proposed and
not adopted, not kernel, not a registry capability, and not validator-enforced.
Adoption requires explicit human approval via the AIWF Change Lifecycle SOP.
