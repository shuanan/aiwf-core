---
name: repo-intake
description: Candidate skill to gather verifiable source facts about a repo for adoption assessment. Advisory only, read-only, not selectable.
disable-model-invocation: true
allowed-tools: Read Grep Glob Bash
---

# repo-intake

Status: candidate. Authority: advisory only. Not selectable.

This is a candidate skill skeleton. It is **not** an approved capability, **not**
registered, and **not** adopted by any adapter. Its existence does not make it
usable. It performs read-only inspection and produces a draft intake artifact for
a human to act on.

See the bundle design:
`docs/architecture/repo-adoption-assessment-capability-bundle.v0.1.md`.

## Purpose

Gather verifiable source facts about a target repository so that
`adoption-assessment` (see `aiwf/assessment/adoption_assessment.schema.yaml`) has
labeled evidence to work from. Intake gathers facts; it does not decide anything.

Intake covers, read-only:

- repository identity (remote, default branch, current HEAD)
- repository structure (top-level layout, governance/rule files)
- existing AIWF traces (adapter files, AIWF residue, prior assessment artifacts)
- existing execution surfaces worth a later runtime-inventory pass (hooks, skills, settings, CI/deploy entry points) — recorded as observations, not classified or changed here

## Output

Produce a **draft intake artifact only**. Every claim must carry an epistemic
label:

- `fact` — source-backed (current repo source / tool output)
- `inference` — reasoned conclusion derived from labeled facts
- `assumption` — unverified working premise
- `unknown` — missing, partial, stale, or unclear evidence
- `blocker` — a blocking unknown or constraint that prevents a confident handoff
- `human_decision_required` — a point only a human may decide

Inference and unknown must never be presented as fact. Blocking unknowns are
surfaced, not guessed past.

### Existing-adapter diff mode

A target repo may already carry AIWF state (an `aiwf.adapter.yaml`, a prior
assessment artifact, or a legacy/competing governance adapter). When it does,
do not re-derive identity and boundaries from scratch only — also compare what
the source actually shows against what the existing adapter claims, and label
each mismatch.

```yaml
existing_adapter_diff_mode:
  trigger:
    - aiwf.adapter.yaml exists
    - prior AIWF assessment exists
    - legacy governance adapter exists
  behavior:
    - do not re-derive from scratch only
    - compare observed repo facts against existing adapter claims
    - label mismatches as fact / inference / unknown / blocker
```

This stays advisory: intake reports the diff, it does not reconcile, update, or
approve the adapter.

### Output field additions

Record these, read-only and labeled, when the repo provides evidence for them
(use `unknown` when it does not):

```yaml
repo_intake_output_additions:
  consumers_or_downstream_dependents:   # repos/services that depend on this one
  deploy_method:                        # e.g. scp+systemd, docker-compose, git-based
  vcs_deployment_divergence:            # deploy target not a git repo / differs from VCS
  competing_governance_layers:          # >1 adapter or stale legacy governance present
  production_state_unknowns:            # deployed commit/state unverifiable offline
  runtime_inventory_boundary:           # what intake records vs. defers (see below)
```

### Boundary with runtime-inventory

Intake names execution and risk surfaces; it does not perform the deep inventory.

```yaml
runtime_inventory_boundary:
  repo_intake:
    - identify execution surfaces
    - identify risky runtime/deploy/secret boundaries
    - stop before deep runtime inventory
  runtime_inventory:
    - detailed service/process/scheduler/DB/deploy inventory
```

## Must

- Inspect only current source and tool output; prefer source over memory or prior summaries.
- Label every claim `fact` / `inference` / `assumption` / `unknown` / `blocker` / `human_decision_required`.
- Produce a draft intake artifact only, as advisory input to adoption-assessment.
- State clearly that this skill is candidate, not selectable, and advisory only.
- Surface blocking unknowns instead of resolving them.

## Must not

- approve, adopt, migrate, promote, or mark anything selectable
- install hooks, edit settings, or touch `.claude/**`
- modify the target repository or write to downstream repos
- call external services
- install or copy vendor (e.g. NVIDIA/cuOpt) skills
- claim CI passed or that human approval has been granted
- mark Done or merge
