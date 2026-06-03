---
title: Repo Adoption Assessment Capability Bundle
version: v0.1
status: design_draft
authority: advisory_only
created: 2026-06-03
---

# Repo Adoption Assessment Capability Bundle v0.1

Status: design draft. Authority: advisory only.

## Non-authority statement

This document is a design draft. It is explicitly **not**:

- capability approval
- registry promotion
- downstream adoption
- migration approval
- hook installation or `.claude/settings.json` change
- external skill installation
- approval to copy, vendor, or install NVIDIA/cuOpt skills (or any external skill pack)

Nothing in this document selects, registers, promotes, installs, or adopts anything. Every component described here is a *design intention* whose existence does not make it usable. Per the capability substrate, a capability is selectable only when it is an artifact, registered, `approved`, adopted by a downstream adapter, and allowed by the local boundary. This bundle is none of those yet.

See:

- `docs/architecture/capability-substrate.v0.1.md` — what AIWF Core is.
- `docs/sops/aiwf-change-lifecycle.v0.1.md` — how AIWF Core changes move safely (this bundle is named there as an intended follow-up use).
- `aiwf/kernel/kernel.v0.1.yaml` — kernel rules K1–K7 that bound this design.

## Purpose

The repo-adoption-assessment bundle is a design for a set of **advisory** components that assess whether a given repository can safely **draft, adopt, or upgrade** AIWF Core — without taking any action on that repository.

Goals:

- Assess adoption/upgrade feasibility from source facts, not from memory or prior summaries.
- Preserve downstream autonomy: the local repo boundary always wins; the bundle never silently takes ownership of existing hooks, skills, settings, or rules.
- Produce **advisory evidence and recommendations**, never actions. Every output is a labeled finding plus a recommended *next safe step*, gated on human decision.

This bundle does not adopt, migrate, upgrade, install, or approve. It only describes the current state and proposes the smallest safe next step for a human to decide on.

## Component model

The bundle is composed of seven components. Each is advisory-only and produces labeled findings.

| Component | Role |
| --- | --- |
| `repo-intake` | Gather verifiable source facts about the target repo (identity, structure, existing AIWF traces, governance files). |
| `runtime-inventory` | Identify existing execution surfaces: hooks, skills, settings, CI/deploy entry points. Classify each by owner, mode, risk, disposition. |
| `repo-governance-map` | Classify the repo's existing local rules, detect duplicated/conflicting rules and missing boundaries. |
| `adoption-assessment` | Given intake + inventory + governance map, recommend the next safe adoption disposition. |
| `upgrade-assessment` | Compare the repo's adapter pin / `source_ref` against newer AIWF Core capabilities; report safe upgrades, candidate-only items, deprecations, breaking changes. |
| `migration-plan` | After assessment, propose reversible, human-gated migration steps only. Never executes. |
| `external-skill-source-lifecycle` | Handle vendor/community skill packs (e.g. NVIDIA cuOpt) as *sources*, never as capabilities. |

These components reuse the abstractions already defined in the capability substrate (runtime inventory, repo governance map, adoption assessment, upgrade assessment, external skill-source management). This bundle composes them into a single assessment flow; it does not redefine or replace them.

## Data flow

```text
repo-intake
   └─ gathers source facts (repo identity, files, existing AIWF residue, governance docs)
runtime-inventory
   └─ identifies hooks/skills/settings/CI/deploy execution surfaces, classified
repo-governance-map
   └─ classifies local rules; flags duplicated, conflicting, and missing boundaries
adoption-assessment
   └─ consumes the three above → recommends the next safe step (disposition)
upgrade-assessment
   └─ compares adapter pin / source_ref against newer AIWF Core → reports upgrade surface
migration-plan
   └─ proposes reversible steps ONLY after assessment, ONLY with human approval
external-skill-source-lifecycle
   └─ runs in parallel; treats vendor/community packs as sources, not capabilities
```

Flow rules:

- Each downstream component consumes upstream **findings**, not upstream actions.
- No component may advance the repo's state. `migration-plan` proposes; it never applies.
- `upgrade-assessment` reports proposals; it never auto-upgrades (consistent with the adapter upgrade policy: `auto_upgrade: false`, `upgrade_assessment_required: true`, `human_approval_required: true`).
- `external-skill-source-lifecycle` outputs source packets and candidate concepts only; it never yields a selectable capability.

## Required output labels

Every component output must label each claim with one of:

- `fact` — source-backed (T0: repo source, tool output, official docs/changelog).
- `inference` — reasoned conclusion derived from labeled facts.
- `assumption` — unverified working premise.
- `unknown` — missing, partial, stale, or unclear evidence.
- `blocker` — a blocking unknown or constraint that prevents a confident recommendation.
- `human_decision_required` — a point where only a human may decide (adopt, migrate, upgrade, install, promote, merge, deploy).

Inference and unknown must never be presented as fact across summaries or handoffs (kernel K4). Blocking unknowns force a conditional or withheld recommendation.

## Assessment dispositions

`adoption-assessment` must recommend exactly one disposition as the *next safe step*:

- `no_adoption` — repo should not adopt now.
- `cleanup_first` — local residue/conflicts must be resolved before any adapter draft.
- `adapter_draft_possible` — a draft adapter could be drafted (still requires human approval to draft/adopt).
- `already_adopted_needs_review` — repo shows existing AIWF adoption that needs human review.
- `upgrade_assessment_needed` — repo is adopted; the relevant next step is an upgrade assessment.
- `migration_plan_possible` — a reversible migration plan can be proposed (not executed).
- `stop` — source, authority, scope, or safety prevents a recommendation.

A disposition is advisory. It is never an adoption, migration, or upgrade decision.

## Runtime inventory classification

Each discovered execution surface (hook, skill, settings entry, CI/deploy hook) is classified along four axes.

**Owner:**

- `local_repo`
- `legacy_aiwf`
- `third_party`
- `aiwf_core`
- `unknown`

**Mode:**

- `none`
- `log_only`
- `warn`
- `block`
- `write`
- `external_call`
- `unknown`

**Risk flags** (each true/false/unknown):

- `can_block`
- `can_write`
- `can_read_secrets`
- `can_call_external_services`
- `changes_agent_behavior`
- `affects_ci`
- `affects_deploy`

**Disposition:**

- `keep_local`
- `reference_only`
- `audit_before_migration`
- `migrate_candidate`
- `remove_candidate`
- `human_review_required`

AIWF Core acts as an **auditor, not an owner**, of existing surfaces. Local repo safety hooks win and must not be weakened. Hook/settings changes are high-risk writes and always require explicit preview + human approval — this bundle only *classifies and recommends*, it never installs or edits them.

## Repo governance map categories

`repo-governance-map` classifies existing local rules into:

- domain safety rules
- AI workflow rules
- production/deploy rules
- secrets/privacy rules
- branch/PR/CI rules
- legacy AIWF residue
- duplicated rules
- conflicting rules
- missing boundaries

Conflicting rules and missing boundaries are surfaced as findings (often `blocker` or `human_decision_required`); the bundle does not resolve them on its own.

## External skill-source lifecycle

External skill packs are **sources, not capabilities**. The lifecycle stages (aligned with the capability substrate's external-source model):

1. `raw_source` — captured only; not usable.
2. `source_packet` — records URL, author/org, source type, captured_at, source_as_of, license/terms if known, and risk surface.
3. `concept_extraction` — separates facts, source claims, inferences, unknowns, and possible AIWF components.
4. `candidate_component` — may become an AIWF candidate; still **not selectable**.
5. `reviewed` — advisory review only (source trace, duplication, authority boundary, license, supply-chain risk, tool permissions, prompt-injection risk).
6. `pilot_only` — single repo, single task type, reversible, with evidence.
7. `human_adoption_decision` — required before release.
8. `approved_after_release_registry_update` — only after release and registry update.

No stage before `approved_after_release_registry_update` yields a usable capability.

## NVIDIA/cuOpt-specific constraints

NVIDIA/cuOpt skills are treated as an **external source only**, the same as any other vendor pack:

- Record URL / source / org / `source_as_of` / license / terms / known risk surface in a `source_packet`.
- Do **not** run `npx skills add` (or any installer).
- Do **not** copy repo skills into AIWF.
- Do **not** mark as `approved` or `candidate` without passing the separate external-skill-source lifecycle.
- Do **not** let vendor "verified"/"official" wording become AIWF approval. Vendor verification is a source claim, not an AIWF control-plane decision.

## Boundaries

- Local repo boundary wins (kernel K6). Generic AIWF guidance never overrides repo-local rules.
- `candidate`, `reviewed`, `pilot_only`, and external-source items are **not selectable**.
- Migration requires human approval. The bundle proposes reversible steps only.
- Upgrade requires human approval. The bundle proposes; it never applies.
- Hooks and settings are high-risk writes; this bundle never installs or edits them.
- Downstream repos are **untouched** by this PR and by the bundle's assessment activity (assessment reads/observes; it does not write to the target repo without a separate, human-approved write flow).
- This bundle holds no control-plane authority. Data-plane outputs (inventories, maps, assessments, plans, packets) never grant approval, promotion, adoption, merge, or deployment.

## Open questions

- Exact schema filenames for runtime-inventory / governance-map / adoption-assessment / upgrade-assessment.
- Registry representation for a candidate *bundle* (vs. individual candidate components).
- Dogfood evidence requirements before any component could be considered for candidate registration.
- Whether external source packets live under `docs/`, `aiwf/modules/`, or `examples/`.
- What minimum downstream pilot evidence is required before candidate registration.

## Next PR split recommendation

This design should be implemented as separate, small, human-gated PRs — not as one large change:

- **PR A** — schemas for `runtime-inventory`, `repo-governance-map`, `adoption-assessment`, `upgrade-assessment`.
- **PR B** — `repo-intake` skill skeleton as **candidate only**.
- **PR C** — external-source `source_packet` template.
- **PR D** — dogfood evidence examples.
- **PR E** — registry candidate entries, **only after human review**.

Each of these is its own write preview + draft PR under the change-lifecycle SOP. None is authorized by this document.
