# Schema Examples

This page explains the example YAML files in `examples/schemas/`.

These examples help downstream adopters understand the shape of AIWF Core schema-backed files before writing their own repository-specific records. These examples do not imply adoption or approval.

## Files

- `examples/schemas/adapter.example.yaml` shows the adapter structure from `aiwf/adapters/aiwf.adapter.schema.yaml` and `aiwf/adapters/templates/aiwf.adapter.yaml`.
- `examples/schemas/worker-profiles.example.yaml` shows the worker profile structure from `aiwf/workers/aiwf.worker-profiles.schema.yaml` and `aiwf/workers/templates/worker-profiles.yaml`.
- `examples/schemas/release-manifest.example.yaml` shows the release manifest structure from `aiwf/lifecycle/release_manifest.schema.yaml` and `aiwf/releases/aiwf.v0.1.0.yaml`.

## Boundaries

The example files are documentation aids only. They do not approve a downstream repository, promote a capability, install hooks, configure automation, or authorize paid worker execution.

For a minimal downstream adoption draft, see `docs/quickstart.md` and `examples/minimal-repo/`.
