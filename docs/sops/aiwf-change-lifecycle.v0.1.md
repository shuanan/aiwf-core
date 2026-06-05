# AIWF Change Lifecycle SOP v0.1

Status: proposed SOP. Not adoption approval, not merge approval, not release approval.

## Purpose

This SOP standardizes how aiwf-core changes move from idea to branch, draft PR, review, ready-for-review, and merge decision.

It exists to reduce repeated human/AI coordination, preserve no-self-approval, and keep aiwf-core changes small, reviewable, reversible, and source-verified.

This SOP applies to aiwf-core changes. Downstream repos may adopt their own local variant through an adapter, but downstream local boundaries always win.

## Non-goals

This SOP does not:

- grant approval to write, merge, release, deploy, or adopt
- replace human review
- approve candidate capabilities
- install hooks
- edit `.claude/settings.json`
- modify downstream repos
- allow AI to merge its own work
- make PR creation equivalent to adoption

## Core principles

- Source beats memory, handoff, and prior summaries.
- No actor checks itself.
- AI reviews are advisory only.
- Writes require preview.
- Persistent state changes require explicit human approval.
- Master/main is not pushed directly by default.
- Draft PR is the default for architecture, governance, registry, kernel, schema, lifecycle, release, hook, or settings changes.
- Merge is human-only.

## Roles

### Human owner

Can approve:

- persistent writes
- PR ready-for-review transition
- merge
- release
- adoption
- capability promotion
- hook/settings installation
- downstream repo migration

### Planning assistant

May:

- shape scope
- identify risks
- produce write preview
- produce executor prompt
- review reports
- recommend next action

Must not:

- approve its own plan
- claim merge/adoption/release approval
- hide uncertainty
- bypass source verification

### Local executor

May:

- inspect repo state
- create branch
- edit files within approved scope
- run validation
- commit locally
- push branch
- open draft PR
- report evidence

Must stop when:

- repo/branch/remote mismatches target
- working tree is dirty
- source contradicts the plan
- target scope is incomplete
- write preview is invalidated
- unexpected files would change
- validation reveals blocking failure

## Lifecycle states

```yaml
states:
  proposed:
    meaning: idea or requested change only; no write preview yet

  previewed:
    meaning: write preview exists with target, operation, risk, reversibility, and no-touch list

  executing_local:
    meaning: approved local executor is applying the preview

  local_committed:
    meaning: local commit exists; not yet pushed

  draft_pr:
    meaning: branch pushed and PR opened as draft

  review_packet_ready:
    meaning: changed files, CI, scope, risks, and findings have been reported

  ready_for_review:
    meaning: PR is no longer draft after explicit human instruction

  merge_pending:
    meaning: PR is ready but merge decision is still pending

  merged:
    meaning: human-approved merge completed

  blocked:
    meaning: workflow stopped due to source, scope, authority, safety, validation, or tool mismatch

  abandoned:
    meaning: intentionally stopped and not expected to continue
```

## Proposal artifact lifecycle overlay

Merged proposal docs are tracked artifacts, not adopted rules.

```yaml
proposal_doc_states:
  proposed:
    meaning: merged or unmerged proposal exists; advisory only

  pilot_requested:
    meaning: human explicitly instructs this session/lane to apply the proposal as pilot guidance

  pilot_in_progress:
    meaning: proposal is being session-applied inside an approved envelope

  evidence_captured:
    meaning: pilot produced source-backed evidence

  evaluation_pending:
    meaning: human has not decided adopt / revise / park / reject

  adopted:
    meaning: explicit human adoption decision plus required registry/kernel/SOP/release changes, if any

  revised:
    meaning: proposal needs a new version before further use

  parked:
    meaning: retained for reference, not active guidance

  rejected:
    meaning: should not be used as guidance
```

Rules:

* Merged proposal does not mean adoption.
* Proposed docs may be piloted only by explicit human instruction.
* Pilot use is session-applied guidance, not repo adoption.
* Pilot use does not update kernel, registry, schema, release, hooks, settings, or downstream adapters.
* Pilot evidence must be captured before evaluation.
* Evidence leads to adopt, revise, park, reject, or continue pilot.
* Adoption requires explicit human approval and the normal lifecycle path.

## Default workflow

### 0. Intake

Classify the request before writing.

```yaml
intake:
  task_class: review | shape | docs_only | registry_change | kernel_change | schema_change | runtime_change | downstream_change | unknown
  risk: low | medium | high
  expected_files: []
  blocking_unknowns: []
  next_smallest_safe_action:
```

If source, target, authority, or risk is unclear, do read-only verification first.

### 1. Write preview

Every persistent write requires preview.

```yaml
write_preview:
  target:
    - path
  operation:
    - CREATE | EDIT | DELETE | MOVE
  risk:
  reversibility:
  no_touch:
    - registry
    - kernel
    - adapter_schema
    - release_manifest
    - hooks_settings
    - downstream_repos
  approval_needed:
```

Preview is not approval. Human approval must be explicit.

For AI/AIWF artifact persistence decisions — including whether an artifact belongs
in tracked files, local-only paths, `.git/info/exclude`, or exceptional
`skip-worktree` handling — consult `docs/sops/ai-artifact-persistence-policy.v0.1.md`
before preparing the write.

### 2. Preflight

Before local execution, run:

```bash
pwd
git status --short
git branch --show-current
git rev-parse HEAD
git remote -v
```

Stop if:

* target repo is wrong
* branch is wrong
* working tree is dirty
* remote does not match expected repo
* branch is not the expected base branch
* source inspection contradicts the plan

### 3. Source verification

Read relevant source before writing.

Examples:

* target file, if editing or deleting
* related README or evidence files, if deleting a referenced artifact
* registry, if changing capabilities
* schema, if changing adapter format
* workflow file, if validation behavior changes

If source contradicts plan, stop before write.

### 4. Local write

Apply only the approved preview.

Rules:

* Do not widen scope without a new preview.
* Do not repair unrelated issues.
* Do not modify branch/PR metadata unless requested.
* Do not alter runtime settings unless explicitly approved.

### 5. Local validation

Run relevant validation.

For aiwf-core structural changes:

```bash
bash scripts/validate-aiwf-core.sh
git status --short
git diff --check
```

If validation is skipped or incomplete, report why.

### 6. Commit

Commit only intended files.

Commit message should describe the actual change, not an invalidated rationale.

Examples:

* `docs: define AIWF capability substrate`
* `docs: add AIWF change lifecycle SOP`
* `chore: archive order pilot evidence set`

### 7. Branch and draft PR

Default behavior:

* do not push master/main directly
* push feature branch
* open draft PR

Architecture, governance, registry, kernel, schema, lifecycle, release, hook, settings, and downstream-adoption changes should start as draft PR.

### 8. Review packet

Before marking ready, produce:

```yaml
pr_review:
  pr:
  draft:
  base:
  head:
  commits:
  changed_files:
  out_of_scope_changes_detected:
  ci:
  focus_checks:
  findings:
    blocking: []
    non_blocking: []
  verdict: ready_to_mark_review | needs_revision | blocked
```

Review must check:

* changed files match preview
* no out-of-scope changes
* CI status
* no self-approval wording
* no automatic adoption/upgrade/install/merge/deploy implication
* local boundary remains stronger than generic AIWF guidance
* candidate capabilities are not treated as selectable

### 9. Ready for review

Only mark PR ready when human explicitly says to do so.

Allowed when:

* review packet has no blocking findings
* CI is green, or exception is explicitly accepted
* head commit is known
* no unauthorized files changed

### 10. Merge decision

Merge requires explicit human approval.

Before merge, verify:

```yaml
merge_precheck:
  pr:
  expected_head_sha:
  ci:
  blocking_findings:
  human_merge_go:
```

AI must not merge merely because:

* CI is green
* review packet says ready
* PR is ready for review
* previous AI review approved
* change is docs-only

## Blocker handling

### Source contradicts plan

Stop before write.

Example:

```yaml
plan_claim: Order pilot draft is stale
source_finding: git log shows it was added yesterday
result: stale rationale invalidated
action: stop and ask for revised decision
```

### Target scope incomplete

Stop before partial deletion.

Example:

```yaml
planned_delete:
  - examples/pilots/order/aiwf.adapter.draft.yaml
source_finding:
  - README.md references the draft
  - quality-tracking.md is part of the evidence set
action: do not delete only the YAML
```

### Tool or connector mismatch

Stop external write.

Example:

```yaml
requested_repo: shuanan/aiwf-core
tool_returned_repo: shuanan/MarketBriefing
action:
  - do not write through connector
  - switch to local executor
  - label connector-derived state as unverified
```

### Duplicate request

If the requested action is already done:

```yaml
action:
  - verify current state
  - no-op
  - report unchanged state
```

### Process anomaly / lifecycle gap

Repeated correction is evidence, not noise.

Stop local answering and surface a workflow gap when:

* the same correction repeats
* the human becomes a relay for executor prompts
* micro-approval loops multiply inside one intended task
* a merged proposal has no next lifecycle state
* a tool or candidate is discussed without pilot evidence
* local micro-fixes are replacing workflow diagnosis

Output:

```yaml
process_anomaly:
  trigger:
  evidence:
  affected_lifecycle:
  local_fix_to_pause:
  recommended_smallest_sop_patch:
  human_decision_required:
```

## PR policy

```yaml
pr_policy:
  direct_master_push:
    default: forbidden

  draft_pr_required_for:
    - architecture docs
    - governance docs
    - registry changes
    - kernel changes
    - adapter schema changes
    - lifecycle changes
    - release changes
    - hook/settings changes
    - downstream adoption changes

  ready_for_review_requires:
    - changed files match preview
    - CI observed
    - no blocking findings
    - human go

  merge_requires:
    - explicit human merge go
    - expected head sha
    - CI green or accepted exception
```

## Bounded-run approval (experiment)

This is an **experiment** to reduce repeated approve / go / review loops for
low-risk, docs-only aiwf-core lanes. It changes approval **granularity**, not
safety **boundaries**.

One approved envelope can cover multiple small steps, so a human does not have to
re-approve each branch, edit, validation, and draft-PR step individually. It is
meant to reduce process tax. It does **not** let AI self-approve any hard stop:
merge, release, promotion, selectability, adoption, and runtime/hook/settings
changes remain explicit human decisions. It is experimental, off by default, and
can be reverted at any time.

It is **not** a kernel rule, **not** a registry capability, **not** validator
enforcement, and **not** auto-merge permission.

```yaml
bounded_run_approval:
  status: experimental
  default: off
  enabled_by: explicit human envelope approval
  allowed_for:
    - docs-only cleanup
    - non-authoritative audit docs
    - stale-doc cleanup
    - wording/consistency fixes
  executor_may:
    - create branch
    - edit within approved file/path envelope
    - run validation
    - open draft PR
    - verify CI
    - mark ready for review if all envelope conditions hold
  executor_must_stop_on:
    - files outside envelope
    - validation failure
    - CI red
    - registry status change
    - promotion/selectability/adoption
    - release declaration ambiguity
    - runtime/hooks/settings changes
    - downstream repo writes
  still_requires_explicit_human_go:
    - merge
    - release tag
    - promotion
    - selectability
    - adapter adoption
    - runtime configuration
```

This experiment changes approval granularity, not safety boundaries. One approved
envelope can cover multiple small steps, but the executor must stop and return to
the human the moment any `executor_must_stop_on` condition appears, and the
`still_requires_explicit_human_go` decisions are never self-approved.

### Envelope-level approval clarification

Approval is for a bounded envelope, not every micro-step.

An approved envelope may cover low-risk internal steps such as read-only inspection,
bounded edits, validation, draft PR creation, and review packet preparation when
the preview names target, operation, risk, reversibility, no-touch boundaries,
stop conditions, and done criteria.

This changes approval granularity, not safety boundaries.

The executor must stop on:

* scope or architecture change
* files outside envelope
* dirty or mismatched repo state
* source contradiction
* repeated correction indicating workflow confusion
* proposal/tool has no next lifecycle state
* registry/kernel/schema/runtime/hooks/settings/downstream change
* adoption, promotion, release, merge, deploy, or selectability decision

## Executor report format

Local executor should report:

```yaml
executor_report:
  status:
  repo:
  branch:
  head:
  working_tree:
  files_changed:
  validation:
  ci:
  boundaries_observed:
    registry:
    kernel:
    adapter_schema:
    release_manifest:
    hooks_settings:
    downstream_repos:
  source_contradictions:
  deviations_from_plan:
  next_smallest_safe_action:
```

For proposal or pilot lanes, also report:

```yaml
pilot_evidence:
  proposal:
  pilot_scope:
  explicit_pilot_instruction:
  session_applied_only: true
  evidence:
    useful_catches: []
    missed_cases: []
    friction: []
    false_positives: []
    repeated_corrections: []
    process_anomalies: []
  outcome:
    recommendation: adopt | revise | park | reject | continue_pilot
    rationale:
    human_decision_required: true
```

## Review report format

Reviewer should report:

```yaml
review_report:
  status:
  artifact_reviewed:
  source_basis:
  findings:
    blocking: []
    non_blocking: []
  risks:
  verdict: ready_to_mark_review | needs_revision | blocked
  authority_note: advisory_only
```

## Relationship to capability substrate

The capability substrate architecture defines what aiwf-core is.

This SOP defines how aiwf-core changes safely move through the repo.

The architecture answers:

> What is AIWF Core?

This SOP answers:

> How do we safely change AIWF Core?

## Current intended follow-up uses

This SOP should govern future work such as:

* Order pilot evidence-set fate
* repo-adoption-assessment capability bundle
* runtime inventory schema
* repo governance map schema
* upgrade assessment schema
* downstream adapter cleanup and adoption
* NVIDIA/cuOpt or other external skill-source intake planning

## Done criteria

A change following this SOP is not done until:

* intended files changed only
* validation status reported
* CI status reported when PR exists
* source contradictions surfaced
* deviations from plan reported
* human-only decisions remain human-only
* proposal docs are not treated as adopted merely because they merged
* pilot use, if any, is labeled session-applied only
* pilot evidence is captured before any adopt / revise / park / reject recommendation
* process anomalies are surfaced as evidence when they affect the workflow
