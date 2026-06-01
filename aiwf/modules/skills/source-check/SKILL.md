---
name: source-check
description: Verify claims against current sources and label fact/inference/assumption/unknown.
disable-model-invocation: true
allowed-tools: Read Grep Glob
---

# source-check

## Purpose

Verify claims against current sources and label fact/inference/assumption/unknown.

## Output

Produce a draft artifact only.

## Must not

- approve
- merge
- install hooks
- edit settings
- promote candidate components
- claim human approval
