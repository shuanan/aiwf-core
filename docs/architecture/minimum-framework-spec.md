# AIWF Core Minimum Framework Spec v0.1

## Status

Proposed.

This document is a design/specification document only. It does not approve adoption, promotion, release, automation, or enforcement.

## Purpose

Define the minimum structure required for aiwf-core to function as a lightweight, versioned AI workflow governance package for downstream repositories.

This is not a summary framework. It defines the smallest governance surface that must exist before downstream repositories can reason about adoption, boundaries, validation evidence, and versioned AIWF Core components.

## What aiwf-core is

- A repo-based governance package.
- A source-of-truth structure for AI-assisted development workflow rules.
- A versioned set of kernel rules, capabilities, adapter contracts, release manifests, and validation expectations.
- A human-in-the-loop governance framework.

## What aiwf-core is not

- Not a runtime platform.
- Not an automation control plane.
- Not a hook installer.
- Not a dashboard.
- Not a CI decision-maker.
- Not an auto-approval system.
- Not a replacement for human approval.

## Current Maturity Target

Current target: M1 - Minimal Usable Governance Package.

M2 - Evidence-backed Lifecycle is the next target, not the current state.

Do not imply that aiwf-core has already reached M2 merely because this document exists.

## Authority Hierarchy

AIWF Core depends on a small authority hierarchy:

1. Kernel invariants cannot be weakened.
2. Local repo boundaries may be stricter than kernel rules, but cannot override or weaken core safety/governance invariants.
3. Capabilities operate only inside both kernel constraints and local repo boundaries.

`local_boundary_wins` means local repositories may add stricter execution constraints. It does not mean downstream repositories may bypass no-self-approval, write boundaries, source boundaries, or human approval requirements.

## Framework Layers

### 1. Kernel

Purpose: define non-negotiable AIWF governance invariants.

Minimum properties:

- rule id
- rule meaning
- cannot-override semantics

Examples:

- no self-approval
- source boundary
- task boundary
- write boundary
- local repo boundary wins, only as stricter local constraint

### 2. Capability Registry

Purpose: define which AIWF capabilities exist, which are approved, and what each can or cannot do.

Minimum properties:

- id
- type
- status
- version
- trigger
- location
- authority_boundary
- risk

Rule:

Approved means currently usable, not permanently trusted.

### 3. Downstream Adapter Contract

Purpose: define how downstream repositories declare AIWF adoption intent.

Minimum properties:

- target_repo
- status
- enforcement
- adopted kernel rules
- adopted capabilities
- local_boundary
- forbidden_actions
- write_gate

Adapter physical form:

- Default file: `aiwf.adapter.yaml`
- Default location: downstream repo root unless documented otherwise
- Initial status: `draft`
- Initial enforcement: `none`

Rules:

- Draft adapter is not adoption.
- Enforcement none means the adapter is not actively enforcing anything.
- Adapter must not weaken kernel invariants.
- Local boundaries may be stricter than aiwf-core defaults.

### 4. Release / Versioning

Purpose: define what a specific aiwf-core version contains.

Minimum properties:

- version
- release_ref
- components
- changelog
- migration_notes

Rule:

The release manifest defines the versioned surface that downstream repos can pin to.

### 5. Human-Driven Validation Checklist

Purpose: define what reviewers should verify before claiming a change is safe.

For v0.1, this is primarily human-driven. Do not imply machine enforcement unless it already exists.

Reviewer checks:

- Required files exist.
- Registry entries point to existing artifacts.
- Downstream adapter adopts only approved capabilities.
- Release manifest clearly describes versioned components.
- Lifecycle status changes have explicit human approval.
- Local boundaries are stricter than, not weaker than, kernel invariants.
- Validation output is evidence, not approval.

Rule:

Validator detects. Human decides.

### 6. Lifecycle Roadmap

Purpose: define how capabilities mature over time.

States:

- candidate
- approved
- deprecated
- archived

Transition rules:

candidate -> approved requires:

- evidence
- validation where available
- explicit human approval

approved -> deprecated requires:

- documented reason
- known issue or replacement
- explicit human approval

deprecated -> archived requires:

- removal from active release surface where applicable
- migration note if replacement exists
- explicit human approval

Rule:

CI may warn. CI must not auto-promote or auto-demote.

### 7. Change Tiers

Use three tiers for v0.1.

#### Patch

Examples:

- documentation clarification
- typo fixes
- non-semantic examples

Requires:

- clear scope
- validation if relevant

#### Minor

Examples:

- registry metadata update
- capability documentation update
- adapter template clarification
- release note update

Requires:

- diff review
- validator green if available
- no lifecycle status change unless explicitly approved

#### Major

Examples:

- kernel rule change
- lifecycle status transition
- schema contract change
- release surface change
- automation, CI, hook, or enforcement behavior

Requires:

- explicit human approval
- evidence
- reversibility or rollback note

## Bootstrap Protocol

A downstream repo starts with a draft adapter:

1. Copy or create `aiwf.adapter.yaml`.
2. Fill target repo identity.
3. Pin aiwf-core source reference.
4. Adopt kernel rules.
5. Adopt only approved capabilities.
6. Declare local boundaries and forbidden actions.
7. Keep `status: draft`.
8. Keep `enforcement: none`.
9. Human reviewer verifies local boundaries.
10. Only after explicit approval may the downstream repo advance adoption state.

## Maturity Roadmap

### M0 - Skeleton

Repo structure exists. Kernel, registry, adapter, release, and docs have initial forms.

### M1 - Minimal Usable Governance Package

Current target.

Downstream repo can create a draft adapter. Registry distinguishes approved and candidate capabilities. Basic validation and human review can catch declaration mismatch.

### M2 - Evidence-backed Lifecycle

Next target.

Candidate-to-approved has criteria. Approved capabilities have health blocks. Dogfood evidence can be counted. CI is treated as final receipt after it actually runs.

### M3 - Release Discipline

Release manifest and registry state are consistent. Migration notes exist. Deprecated and archived lifecycle behavior is defined.

### M4 - Change / Review Discipline

Change tiers, PR template, ADR trigger, and reviewer checklist exist.

### M5 - Optional Automation

Scheduled health checks, auto issues, scorecards, dashboards, Slack/Linear/Notion integration.

M5 is explicitly deferred.

## Explicitly Deferred

Do not treat these as part of v0.1 minimum framework:

- schema expansion
- validator expansion
- CI receipt automation
- scheduled health checks
- auto issue creation
- dashboards
- Slack / Linear / Notion integration
- hook installation
- OPA / policy engine
- automatic promotion
- automatic demotion
- automatic archival

## Hard Rules

- Kernel invariants cannot be weakened.
- Local repo boundaries may be stricter, but cannot weaken kernel invariants.
- Adapter draft is not adoption.
- Validator detects; human decides.
- Local validation is preflight evidence.
- CI is final receipt only after CI actually runs.
- Lifecycle changes require explicit human approval.
- Release manifest defines the versioned surface.
- Documentation must not claim maturity that the repo has not reached.

## Non-goals for this document

This document does not:

- approve any lifecycle change
- promote any capability
- change any release manifest
- define machine-enforced schema
- add validation behavior
- add CI behavior
- install hooks
- create automation
