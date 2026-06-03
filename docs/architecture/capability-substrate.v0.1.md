# AIWF Capability Substrate v0.1

Status: architecture concept. Not repo adoption, not capability approval, not downstream migration.

## Purpose

AIWF Core is a versioned AI capability substrate for AI-assisted software development.

Downstream repositories remain autonomous. Each repo owns its local boundaries, existing hooks, existing skills, settings, production rules, and adoption decisions. AIWF Core provides reusable kernel rules, capability definitions, lifecycle rules, assessment patterns, and upgrade guidance.

AIWF Core may assess and propose. It must not self-approve adoption, install hooks, edit settings, merge, deploy, or silently migrate a repo.

## Ownership model

### AIWF Core owns

- Kernel rules
- Capability registry
- Candidate / approved lifecycle
- Reusable skills, templates, schemas, hooks, and SOP definitions
- Source intake and review model
- Upgrade assessment logic

### Downstream repo owns

- `aiwf.adapter.yaml`
- Local safety rules
- Existing hooks / skills / settings
- Production boundaries
- Adoption, migration, and upgrade timing
- Final approval

## Core principle

Registry is the capability source. Adapter is the repo-owned adoption contract.

An AIWF capability is usable in a repo only when:

1. It exists as an artifact.
2. It is registered.
3. Its registry status is `approved`.
4. The downstream adapter adopts it.
5. The repo-local boundary allows it.

Candidate, reviewed, pilot-only, deprecated, or external-source items are not selectable.

## Required abstractions

### Repo governance map

A repo governance map describes existing repo rules before adoption.

It separates:

- Domain safety rules
- AI workflow rules
- Legacy AIWF residue
- Duplicated rules
- Conflicting rules
- Missing boundaries

### Runtime inventory

A runtime inventory describes existing hooks, skills, settings, and other execution surfaces.

Every existing hook or skill must be classified before migration:

- `keep_local`
- `reference_only`
- `audit_before_migration`
- `migrate_candidate`
- `remove_candidate`

AIWF must not silently take ownership of existing hooks or skills.

### Adoption assessment

An adoption assessment decides whether the next safe step is:

- `no_adoption`
- `cleanup_first`
- `adapter_draft_possible`
- `already_adopted_needs_review`
- `stop`

The assessment is advisory only and is not an adoption decision.

### Upgrade assessment

An upgrade assessment compares a repo's current adapter pin with newer AIWF Core capabilities.

It may report:

- safe upgrades
- new approved capabilities
- candidate-only items
- deprecated capabilities
- breaking changes
- do-not-upgrade warnings

It must not apply upgrades automatically.

## Existing hooks and skills

If a downstream repo already has hooks or skills, AIWF Core first acts as an auditor, not an owner.

Required flow:

1. Inventory existing runtime surfaces.
2. Identify owner: `local_repo`, `legacy_aiwf`, `third_party`, `aiwf_core`, or `unknown`.
3. Identify mode: `log_only`, `warn`, `block`, or `unknown`.
4. Identify risk: can block, can write, can read secrets, can call external services.
5. Recommend disposition.
6. Require human approval before migration.

Local repo safety hooks win. AIWF Core must not weaken them.

Hook/settings changes are high-risk writes and require explicit preview and approval.

## External skill-source management

External skill packs are sources, not capabilities.

Examples include:

- NVIDIA cuOpt skills
- Vendor-provided workflow skills
- Community skill repositories
- Prompt packs
- Third-party hook bundles

External skill handling lifecycle:

1. `raw_source` — captured only, not usable.
2. `source_packet` — records URL, author/org, source type, captured_at, source_as_of, license/terms if known, and risk surface.
3. `concept_extraction` — separates facts, source claims, inferences, unknowns, and possible AIWF components.
4. `candidate_component` — may become an AIWF candidate, still not selectable.
5. `reviewed` — advisory review only; checks source trace, duplication, authority boundary, license, supply-chain risk, tool permissions, and prompt-injection risk.
6. `pilot_only` — single repo, single task type, reversible, with evidence.
7. `human_adoption_decision` — required before release.
8. `approved` — only after release and registry update.

NVIDIA/cuOpt skills or similar external sources must not be copied, installed, or treated as approved AIWF capabilities merely because they exist or appear useful.

## Adapter and upgrade model

Downstream repos should pin AIWF Core by source reference.

Example:

```yaml
source:
  aiwf_repo: shuanan/aiwf-core
  source_ref: aiwf@v0.1.0

upgrade_policy:
  auto_upgrade: false
  upgrade_assessment_required: true
  human_approval_required: true
```

AIWF Core can evolve. Repos receive proposals, not silent updates.

## Non-goals

AIWF Core is not:

- a production runner
- a Kanban app
- an auto-merge system
- an approval authority
- a hook installer
- a downstream repo owner

## Next implementation candidates

- repo-intake skill
- repo-governance-map schema
- runtime-inventory schema
- adoption-assessment schema
- upgrade-assessment schema
- adoption-migration-plan template
