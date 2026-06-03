# AIWF Assessment Schemas (v0.1)

Status: design draft. Authority: advisory only.

These schemas describe the **advisory** assessment outputs of the
repo-adoption-assessment capability bundle. They are descriptive YAML
specifications, not executable code, and not capabilities.

See the bundle design: `docs/architecture/repo-adoption-assessment-capability-bundle.v0.1.md`.

## Non-authority statement

Nothing in this directory:

- approves a capability
- promotes a registry entry
- adopts AIWF Core into any repo
- approves a migration or an upgrade
- installs hooks or edits settings
- installs or copies external (e.g. NVIDIA/cuOpt) skills

A capability becomes selectable only when it is an artifact, registered,
`approved`, adopted by a downstream adapter, and allowed by the local boundary
(see `docs/architecture/capability-substrate.v0.1.md`). These schemas are none
of those yet — their existence does not make anything usable.

## Schemas in this directory

| File | Purpose |
| --- | --- |
| `runtime_inventory.schema.yaml` | Classify existing execution surfaces (hooks/skills/settings/CI/deploy) by owner, mode, risk flags, disposition. Classify only — never modify. |
| `repo_governance_map.schema.yaml` | Classify existing local rules; surface duplicated, conflicting, and missing boundaries as findings. |
| `adoption_assessment.schema.yaml` | Recommend exactly one next-safe-step disposition from intake + inventory + governance map. Advisory, not a decision. |
| `upgrade_assessment.schema.yaml` | Compare current adapter pin / source_ref / adopted capabilities against newer AIWF Core; emit findings + recommendation. Upstream of `upgrade_plan`. |

## Relationship to existing lifecycle schemas

`upgrade_assessment.schema.yaml` is **upstream** of the existing
`aiwf/lifecycle/upgrade_plan.schema.yaml`. The assessment reports whether an
upgrade plan should be drafted; the upgrade plan (a separate, human-approved
artifact) is what proposes an adapter patch. This bundle does **not** duplicate
or edit `upgrade_plan.schema.yaml`.

## Output labels

Assessment outputs preserve epistemic labels on each claim:

`fact` · `inference` · `assumption` · `unknown` · `blocker` · `human_decision_required`

Inference and unknown must never be presented as fact (kernel K4).

## Not in this PR

- External skill-source lifecycle schema — deferred to a later PR (PR C / PR E).
- `repo-intake` skill skeleton — deferred (PR B).
- Registry candidate entries — deferred, human review required (PR E).
