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
