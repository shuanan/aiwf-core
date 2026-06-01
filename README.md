# AIWF Core

AIWF Core is an adapter-first portable governance library for AI-assisted software development.

It provides a small AI execution kernel, repo-local adapter contracts, approved capability registry patterns, worker entitlement profiles, and templates for human-gated AI coding workflows.

AIWF Core is not a Kanban app, not a production runner, not an auto-merge system, and not an approval authority.

## Why this repo exists

This repository extracts the reusable logic from the previous AIWF exploration repo into a clean standalone library.

The old repo remains a source archive / research history. This repo is the clean product surface.

## Principles

- Keep the kernel thin.
- Downstream repos adopt through `aiwf.adapter.yaml`.
- AI may select approved capabilities, but cannot approve, install, or promote them.
- Hooks and settings are optional enforcement modules, never default.
- Linear / Slack / Notion / Langfuse are adapters, not required dependencies.
- Worker access is per user/profile, not assumed globally.
- No hidden paid worker runs.

## Repository layout

```text
aiwf/
  kernel/
  registry/
  adapters/
  workers/
  control-plane/
  modules/
    templates/
    skills/
    hooks/
    schemas/
    sops/
  lifecycle/
  releases/

docs/
  architecture/
  extraction/
  decisions/
```

## Start here

1. Read `docs/architecture/architecture.v0.1.md`.
2. Read `aiwf/kernel/kernel.v0.1.yaml`.
3. Use `aiwf/adapters/templates/aiwf.adapter.yaml` to draft a repo-local adapter.
4. Use `aiwf/workers/templates/worker-profiles.yaml` to define worker access.
5. Do not install hooks or automation until explicitly approved.
