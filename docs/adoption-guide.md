> **Disclaimer:** This guide helps you create a draft adapter. Draft does not imply adoption or enforcement.

# Downstream Adoption Guide

## What this is

AIWF Core is a governance library. Adopting it means creating a single YAML file — `aiwf.adapter.yaml` — that declares how the framework applies to your repository. There is nothing to install, no runtime to add, and no settings to change. The adapter is a contract: it records which kernel rules and capabilities your repo opts into, where AI agents are allowed to write, and what they are forbidden from doing. Governance becomes auditable because it lives in the repo alongside your code.

## Prerequisites

Before you start:

- You can read `aiwf/adapters/templates/aiwf.adapter.yaml` from this repository (clone it or browse it on GitHub).
- You know your repository's identity (`owner/repo`) and the paths that should be protected or off-limits.
- You understand which capabilities from the registry you want to try (see Step 6 below for guidance).
- If your repo has a production deployment, you know the deploy method, host, and critical operational constraints.

## Steps

### 1. Read the source material

Read these files before writing anything:

- `docs/quickstart.md` — adoption overview
- `aiwf/adapters/aiwf.adapter.schema.yaml` — required fields and valid status values
- `aiwf/adapters/templates/aiwf.adapter.yaml` — the canonical starter template
- `aiwf/registry/aiwf.capabilities.yaml` — the approved capability catalog
- `aiwf/kernel/kernel.v0.1.yaml` — the seven kernel rules
- `examples/minimal-repo/aiwf.adapter.yaml` — a concrete minimal example

Do not write from memory. The schema file is the authority on required fields.

### 2. Copy the adapter template

Copy `aiwf/adapters/templates/aiwf.adapter.yaml` into the root of your repository and name it `aiwf.adapter.yaml`:

```bash
cp aiwf/adapters/templates/aiwf.adapter.yaml /path/to/your-repo/aiwf.adapter.yaml
```

### 3. Set identity fields

Fill in your repository identity and the source reference:

```yaml
version: v0.1
target_repo: owner/repo          # your GitHub repo
aiwf_core_version: "v0.1.0"      # pin to the release you read

source:
  aiwf_repo: shuanan/aiwf-core
  source_ref: aiwf@v0.1.0
  adopted_at: YYYY-MM-DD         # today's date
  last_reviewed_at: YYYY-MM-DD   # same as adopted_at for first draft
```

### 4. Set status and enforcement

Always start here. Do not advance either field until human review:

```yaml
status: draft
enforcement: none
```

`draft` signals that this file is an intent declaration, not an active adoption. `enforcement: none` means no rules are being enforced by this file. Both fields must stay at these values until a maintainer explicitly approves advancement.

### 5. Choose kernel rules

Adopt all seven kernel rules. They are minimal, low-risk, and designed to be always-on:

```yaml
adopted:
  kernel:
    version: v0.1
    rules:
      - K1_no_self_approval
      - K2_source_boundary
      - K3_task_boundary
      - K4_epistemic_boundary
      - K5_write_boundary
      - K6_local_boundary_wins
      - K7_load_on_demand
```

There is no reason to omit individual kernel rules at draft stage. K6 in particular (`local_boundary_wins`) ensures your repo's own rules take precedence over any generic AIWF guidance.

### 6. Choose capabilities

Only adopt capabilities with `status: approved` in `aiwf/registry/aiwf.capabilities.yaml`. Capabilities with any other status (`candidate`, `idea`, `reviewed`, `pilot_only`) are not selectable.

**Safe starting picks** (all low-risk, approved):

| ID | Type | When it activates |
|----|------|-------------------|
| `source-check` | skill | review, compare, shape tasks with factual claims |
| `hallucination-check` | skill | review/shape tasks with unsupported claims |
| `write-preview` | template | any persistent write or external state change |
| `task-envelope` | template | handoffs to an executor, bounded task scoping |

```yaml
  capabilities:
    skills:
      - id: source-check
        version: v0.1
        invocation: manual_or_on_demand
      - id: hallucination-check
        version: v0.1
        invocation: manual_or_on_demand
    templates:
      - id: write-preview
        version: v0.1
      - id: task-envelope
        version: v0.1
    schemas: []
    hooks: []
    sops: []
```

**Defer for now:**

- `repo-validation-check` — status is `candidate`, not selectable at draft stage
- `hook-candidate-generator` — medium risk, manual-only invocation, defer until post-approval
- `downstream-adapter` — meta-capability for the adoption process itself; only relevant if you are building adapters programmatically
- `slack-notify` — low-risk, but introduces an external notification pattern; add it deliberately when your workflow needs it

### 7. Declare local boundaries

This is the most repo-specific section. Declare current reality — do not prescribe changes to your repo structure.

```yaml
local_boundary:
  allowed_paths:
    - docs/**
    - src/**
    - tests/**

  protected_paths:               # AI can read; writes require elevated care
    - .github/workflows/**
    - config/**
    - migrations/**

  forbidden_paths:               # AI must not touch these at all
    - .env*
    - secrets/**
    - credentials/**
```

If your repo has a production deployment, add a `deploy_method` and `production_constraints` section to capture operational hard rules:

```yaml
local_boundary:
  deploy_method: git             # or scp, ansible, etc.
  production_constraints:
    - service restart requires explicit human approval
    - db migrations require explicit human approval
```

Also fill in `forbidden_actions`. The template default covers the most important cases. Add any repo-specific forbidden operations (e.g., `direct_production_db_write`, `alembic_upgrade_without_approval`).

The `write_gate` section controls what AI agents must provide before any persistent write. Keep the template defaults:

```yaml
write_gate:
  persistent_writes_require_preview: true
  preview_required_fields:
    - target
    - operation
    - risk
    - reversibility
    - verification
    - rollback
  approval:
    required: true
    accepted_phrases:
      - approved
      - go
```

### 8. Validate YAML

Before committing, confirm the file parses as valid YAML:

```bash
python3 -c "import yaml; yaml.safe_load(open('aiwf.adapter.yaml'))" && echo "YAML OK"
```

If you have a copy of aiwf-core checked out locally, also run the full validation:

```bash
bash scripts/validate-aiwf-core.sh
```

### 9. Commit

```bash
git add aiwf.adapter.yaml
git commit -m "chore: add aiwf-core draft adapter"
```

---

## Starter block

Copy-paste this minimal block and fill in the bracketed values:

```yaml
# aiwf-core downstream adapter — DRAFT, does not enforce anything
version: v0.1
target_repo: [owner/repo]
status: draft
enforcement: none
aiwf_core_version: "v0.1.0"

source:
  aiwf_repo: shuanan/aiwf-core
  source_ref: aiwf@v0.1.0
  adopted_at: [YYYY-MM-DD]
  last_reviewed_at: [YYYY-MM-DD]

adopted:
  kernel:
    version: v0.1
    rules:
      - K1_no_self_approval
      - K2_source_boundary
      - K3_task_boundary
      - K4_epistemic_boundary
      - K5_write_boundary
      - K6_local_boundary_wins
      - K7_load_on_demand

  capabilities:
    skills:
      - id: source-check
        version: v0.1
        invocation: manual_or_on_demand
      - id: hallucination-check
        version: v0.1
        invocation: manual_or_on_demand
    templates:
      - id: write-preview
        version: v0.1
      - id: task-envelope
        version: v0.1
    schemas: []
    hooks: []
    sops: []

local_boundary:
  allowed_paths:
    - docs/**
    - src/**
    - tests/**
  protected_paths:
    - .github/workflows/**
    - config/**
  forbidden_paths:
    - .env*
    - secrets/**
    - credentials/**

forbidden_actions:
  - auto_merge
  - deployment_without_approval
  - production_automation
  - silent_hook_install
  - silent_skill_install
  - settings_change_without_approval
  - reading_secrets

write_gate:
  persistent_writes_require_preview: true
  preview_required_fields:
    - target
    - operation
    - risk
    - reversibility
    - verification
    - rollback
  approval:
    required: true
    accepted_phrases:
      - approved
      - go

verification:
  default_commands:
    - git status --short
  if_unavailable: state_not_checked_with_reason

rollback:
  default: git revert

notes:
  - status draft means this is not active adoption.
  - enforcement none means no rules are enforced by this file.
  - Hooks are not adopted.
  - Worker auto-run is not enabled.
  - Paid worker execution is not enabled.
```

---

## What NOT to do

- **Do not set `status: approved` or `status: active`** without a human reviewer explicitly signing off. The adapter record is not self-approving.
- **Do not adopt capabilities with `status: candidate`** (e.g., `repo-validation-check`). Only `approved` capabilities are selectable.
- **Do not install hooks or add enforcement** at draft stage. Draft means intent only.
- **Do not add CI workflows** for AIWF validation as part of this step. That is a separate decision, made after the adapter is reviewed.
- **Do not modify existing repo files** to conform to the adapter. The adapter declares what is already true about your repo — it does not prescribe restructuring.
- **Do not copy non-selectable capabilities** from the registry into your `adopted.capabilities` block.

---

## After draft

Once you commit the draft adapter:

1. **Human review** — a maintainer reads the adapter and verifies that local boundaries accurately reflect the repo's structure and constraints.
2. **Evaluate fit** — decide whether the kernel rules and capability set are the right scope for your workflows.
3. **Consider enforcement level** — if the team wants rule enforcement, decide which mechanisms (hooks, CI, settings) to add and in which order. This is a separate decision from having a draft adapter.
4. **Advance status** — only after explicit maintainer approval should `status` be changed from `draft` to `approved`.

The draft adapter is a starting point for that conversation, not a completion of it.

---

## Re-evaluation

Your adapter can drift from reality over time. Re-evaluate when:

- CLAUDE.md, AGENTS.md, or equivalent governance docs change significantly
- Deploy method, database, or infrastructure changes
- New governance practices are added that the adapter doesn't capture
- At minimum every 3 months

Re-evaluation means: re-read the adapter, compare against current repo
state, update the `evaluation` section, and document any new gaps.
Status goes from `draft` → `evaluated` after the first successful
evaluation. It does not mean `adopted` — that is a separate human decision.

---

## Real-world example

The `shuanan/news-api` pilot adapter (committed as `aiwf.adapter.yaml` in the repo root on 2026-06-01) is a concrete example of what a completed draft looks like for a production service.

It adopts four approved capabilities — `source-check`, `hallucination-check`, `write-preview`, and `task-envelope` — and leaves `hooks` and `sops` empty. The `local_boundary` section reflects production operational constraints specific to the service: a non-git deploy method (`scp`), a live production host, and explicit `production_constraints` entries that mirror the repo's CLAUDE.md hard rules (e.g., Alembic upgrade requires human approval, service restart requires human approval, all DB queries must use the `news_api.` schema prefix). The `forbidden_actions` list extends the template defaults with repo-specific entries like `alembic_upgrade_without_approval` and `direct_production_db_write`. The file carries `enforcement: none` and `status: draft`, confirming that the adapter is a pilot evaluation and does not change the repo's existing governance.

That pattern — small capability set, boundaries that mirror existing constraints rather than inventing new ones, no enforcement at draft stage — is the right starting point for most production repositories.
