# Declaration Integrity Gate

## Purpose

Declaration Integrity Gate validates that AIWF Core declarations are internally consistent while preserving human authority over intent decisions.

The validator may detect mismatch. It must not decide whether to adopt, remove, approve, promote, or downgrade a capability.

## Surfaces

```yaml
declaration_surfaces:
  artifact:
    meaning: file exists
    examples:
      - aiwf/modules/templates/slack-notify.md
      - aiwf/modules/skills/source-check/SKILL.md

  registry:
    meaning: library exposes a selectable capability
    examples:
      - aiwf/registry/aiwf.capabilities.yaml

  adopter:
    meaning: an adapter claims repo adoption
    examples:
      - examples/minimal-repo/aiwf.adapter.yaml
      - downstream aiwf.adapter.yaml
```

## Valid adoption

```yaml
valid_adoption:
  requires:
    - artifact exists
    - registry entry exists
    - registry status is approved
    - adapter adopts it
```

## Validator boundary

```yaml
validator_may:
  - detect declaration mismatch
  - fail or warn according to policy
  - print affected item
  - print why it matters
  - print remediation options

validator_must_not:
  - silently remove adapter entries
  - silently approve registry entries
  - silently promote candidates
  - silently downgrade approved components
  - infer adoption intent
```

## Mismatch matrix

```yaml
artifact_exists_but_not_registered:
  meaning: file exists but library does not expose it as capability
  default: ok_or_warn
  human_options:
    - register as approved
    - register as candidate
    - leave as internal artifact

adapter_adopts_unregistered:
  meaning: adapter claims adoption but registry has no such capability
  default: fail
  human_options:
    - register capability if intended
    - remove from adapter if not adopted
    - keep artifact as candidate and do not adopt

registry_points_to_missing_artifact:
  meaning: registry exposes a capability whose file does not exist
  default: fail
  human_options:
    - create artifact
    - fix registry location
    - remove or deprecate registry entry

adapter_adopts_candidate:
  meaning: adapter adopts something not approved
  default: fail
  human_options:
    - promote through lifecycle
    - remove from adapter
    - document temporary exception only if policy allows

adapter_adopts_deprecated:
  meaning: adapter uses deprecated capability
  default: warn_or_fail_by_policy
  human_options:
    - migrate
    - pin older version with explicit note
    - remove adoption
```

## Example: slack-notify

A template file may exist without being adopted.

If an adapter adopts `slack-notify`, the registry must contain `slack-notify` as an approved capability. If not, the validator should report:

```yaml
mismatch: adapter_adopts_unregistered
affected_item: slack-notify
decision_required:
  - register capability
  - remove adapter adoption
  - keep as candidate and do not adopt
```

The validator must not choose one of these options silently.

## Rule

> Validators detect mismatch. Humans decide intent. AI may draft a patch only after the decision is clear.
