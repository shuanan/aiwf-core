# Downstream Adapter Template

Use `aiwf/adapters/templates/aiwf.adapter.yaml`.

Rules:
- Adapter draft is not adoption.
- Only `status: approved` is active.
- Local repo boundary wins.
- Unlisted capabilities are not adopted.

Machine-readable adoption semantics:
- `status: draft` and `adoption_state: draft_only` mean the adapter is not active adoption.
- `source.adapter_created_at` records when the adapter record was created; it is not an adoption date.
- `adopted:` lists the selected capability/kernel set for the adapter record. It is not proof of downstream repo adoption unless `status: approved` and `adoption_state: approved_adopted`.
- External pilot evidence must carry machine-readable non-adoption state, not only prose comments.
