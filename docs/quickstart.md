# AIWF Core Quickstart

This quickstart shows the default adoption path for AIWF Core. It is adapter-first, manual by default, and documentation-oriented until a downstream repository explicitly adopts more.

## Adoption Flow

1. Read the kernel in `aiwf/kernel/kernel.v0.1.yaml`.
2. Copy `aiwf/adapters/templates/aiwf.adapter.yaml` into the downstream repository as a draft adapter.
3. Fill in the downstream repository identity, source reference, local boundaries, and verification commands.
4. Select only the approved skills and templates that the downstream repository wants to adopt.
5. Review the adapter with a human maintainer before treating it as active.
6. Run `scripts/validate-aiwf-core.sh` in this repository before changing AIWF Core structure.

The adapter is the adoption boundary. AIWF Core does not assume that a downstream repository has adopted a capability just because it exists in this repository.

## Adapter-First Usage

Start from:

```text
aiwf/adapters/templates/aiwf.adapter.yaml
```

Keep the first adapter small:

```yaml
status: draft
adoption_state: draft_only
# adopted: is the selected capability/kernel set for this adapter record.
# It is not proof of downstream repo adoption unless status=approved and adoption_state=approved_adopted.
adopted:
  kernel:
    version: v0.1
  capabilities:
    skills: []
    templates:
      - id: write-preview
        version: v0.1
      - id: task-envelope
        version: v0.1
    hooks: []
```

Use `local_boundary` to describe the downstream repository, including allowed paths, protected paths, forbidden paths, and verification commands. Local repository rules override generic AIWF guidance.

## Notify And Manual Default

The default operating model is notify/manual:

- A notification may say that work is ready for human review or launch.
- A human decides whether work proceeds.
- Persistent writes require a preview with target, operation, risk, reversibility, verification, and rollback.
- No worker run, hook install, settings change, merge, deployment, or external automation is implied by this quickstart.

External systems can be represented by adapter documents, but those documents are contracts and examples. They are not live automation.

## Validation

Run the repository validation script before committing structural changes:

```bash
bash scripts/validate-aiwf-core.sh
```

The validation script checks required files, forbidden default runtime surfaces, YAML parsing when PyYAML is available, and internal references between the registry, release manifest, kernel, skills, and templates.

See `docs/development/validation.md` for the full validation checklist.

## Out Of Scope

This quickstart does not create a real downstream adapter, install hooks, edit settings, configure external automation, or execute AI coding work.
