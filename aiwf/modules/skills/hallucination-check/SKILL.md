---
name: hallucination-check
description: Detect unsupported claims, fake certainty, missing sources, and hidden unknowns.
disable-model-invocation: true
allowed-tools: Read Grep Glob
---

# hallucination-check

## Purpose

Detect unsupported claims, fake certainty, missing sources, and hidden unknowns.

## Output

Produce a draft artifact only.

## Must not

- approve
- merge
- install hooks
- edit settings
- promote candidate components
- claim human approval
