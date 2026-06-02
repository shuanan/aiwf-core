---
name: task-assessment
description: Assess a non-trivial request before execution — classify it, find blocking unknowns, and decide proceed / split / research / stop. Does not approve or authorize writes.
disable-model-invocation: true
allowed-tools: Read Grep Glob
---

# task-assessment

## Purpose

Before non-trivial work, assess the request: classify scope and task type, surface
blocking unknowns, and decide whether to proceed, split, research first, or stop —
before entering TaskEnvelope or Write Preview. Derived from the Pre-Task Assessment
Gate methodology; this skill is the aiwf-core executable form, not a redefinition.

## Must

- Classify the request: scope_mode (task class) and task_type.
- Separate blocking unknowns from non-blocking ones.
- Emit a decision: proceed | split | research | stop.
- State the next smallest safe action, marked read / write / human_decision / blocked.
- Route writes through the write-preview / task-envelope templates; never skip them.

## Decision

- proceed: scope clear, source/target/authority clear, no load-bearing unknown, next action safe.
- split: multiple independent lanes, or mixed review/write, or multiple targets.
- research: a load-bearing unknown exists but the agent can resolve it before design/write.
- stop: approval / source / target / safety / authority boundary unclear and not agent-resolvable.

## Must not

- approve, merge, install hooks, edit settings, promote candidate components, claim human approval.
- authorize or perform writes; decision=proceed routes to write-preview, it does not grant approval.
- create PRs, delete or perform destructive actions, or cause any external state change.
- mark adopted or mark approved.
- bypass write-preview or task-envelope.
- replace TaskEnvelope or Write Preview.

## Additional resources

- `reference.md` — full input/output schema, decision rules, routing, boundaries.
- `examples.md` — eval cases.
