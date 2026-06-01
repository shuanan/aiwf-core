---
title: AIWF Core Architecture
version: v0.1
status: draft
authority: design_spec_only
created: 2026-06-01
---

# AIWF Core Architecture v0.1

AIWF Core is an adapter-first portable governance library for AI-assisted software development.

It is extracted from the useful reusable logic of the earlier AIWF exploration repo. It intentionally does not carry over historical notes, lab wording, one-off project decisions, or adopted state from the old repo.

## Layers

```yaml
layers:
  L0_kernel:
    role: minimal_always_loaded_ai_execution_core

  L1_capability_registry:
    role: approved_capability_catalog

  L2_downstream_adapter:
    role: per_repo_adoption_contract

  L3_optional_enforcement:
    role: hooks_validation_settings_as_opt_in_modules

  L4_library_lifecycle:
    role: source_to_release_flow

  L5_control_plane_adapter:
    role: Linear_Slack_Notion_Langfuse_or_other_board_bridge

  L6_worker_entitlement:
    role: per_user_worker_access_and_cost_boundary

  L7_release_version_upgrade:
    role: release_and_downstream_upgrade_boundary
```

## Non-goals

```yaml
non_goals:
  - custom_kanban_ui_v0
  - automatic_paid_worker_runs
  - auto_merge
  - production_deployment
  - default_hook_installation
  - full_copy_rulebook_adoption
```

## Adoption model

A downstream repo is not governed by AIWF Core until it has an approved local adapter.

```yaml
adoption:
  required_file: aiwf.adapter.yaml
  default_state: not_adopted
  local_repo_boundary_wins: true
  unlisted_capability_is_not_adopted: true
```

## Worker model

Worker access is per user/profile.

```yaml
worker_model:
  supported_modes:
    - notify_only
    - claude_manual
    - claude_subagents
    - codex_manual
    - codex_exec_bounded
    - claude_p_explicit

  rules:
    - no entitlement means no auto-run
    - extra paid usage requires explicit per-run approval
    - fallback is Slack notify
```
