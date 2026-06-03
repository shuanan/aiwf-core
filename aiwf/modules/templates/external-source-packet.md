# External Source Packet Template

Status: template. Authority: advisory only.

A **source packet** records an external skill source (vendor / community /
prompt pack / third-party hook bundle) as a **source, not a capability**.
Recording a source here does **not** make it usable: a source packet is **not
selectable, not installed, and not copied** into AIWF. It carries no registry
entry and no adapter adoption.

See the lifecycle and constraints in:

- `docs/architecture/capability-substrate.v0.1.md` (external skill-source management)
- `docs/architecture/repo-adoption-assessment-capability-bundle.v0.1.md` (external-skill-source lifecycle + NVIDIA/cuOpt constraints)

This file is a **template only**. It is not a captured packet and not an example
instance.

## Lifecycle stages

A source advances only through the full lifecycle, and only with human decisions.
No stage before the last yields a usable capability:

1. `raw_source` — captured only; not usable.
2. `source_packet` — this record: URL, author/org, source type, captured_at, source_as_of, license/terms if known, risk surface.
3. `concept_extraction` — separate facts, source claims, inferences, unknowns, and possible AIWF components.
4. `candidate_component` — may become an AIWF candidate; still **not selectable**.
5. `reviewed` — advisory review only (source trace, duplication, authority boundary, license, supply-chain risk, tool permissions, prompt-injection risk).
6. `pilot_only` — single repo, single task type, reversible, with evidence.
7. `human_adoption_decision` — required before release.
8. `approved_after_release_registry_update` — only after release and registry update.

## Evidence labels

Every claim in a packet carries an epistemic label:

`fact` · `inference` · `assumption` · `unknown` · `blocker` · `human_decision_required`

Inference and unknown must never be presented as fact.

## Template

```yaml
source_id:                 # local handle for this source; not a capability id
lifecycle_stage: raw_source   # raw_source | source_packet | concept_extraction | candidate_component |
                              # reviewed | pilot_only | human_adoption_decision | approved_after_release_registry_update
                              # NEVER set candidate/approved here; promotion is a separate human-only lifecycle

url:                       # source location; label unknown if not verified
author_or_org:             # author or organization
source_type:               # vendor | community | prompt_pack | third_party_hook_bundle | other
captured_at:               # YYYY-MM-DD this packet was recorded
source_as_of:              # YYYY-MM-DD the source content reflects; unknown if not verifiable
license:                   # SPDX or text; unknown if not stated
terms:                     # usage terms; unknown if not stated

risk_surface:
  supply_chain_risk:           # true | false | unknown
  tool_permissions:            # true | false | unknown
  prompt_injection_risk:       # true | false | unknown
  can_read_secrets:            # true | false | unknown
  can_call_external_services:  # true | false | unknown
  can_write:                   # true | false | unknown

concept_extraction:
  facts: []                  # source-backed, each labeled fact
  source_claims: []          # claims the source makes about itself (not AIWF facts)
  inferences: []             # reasoned conclusions from facts
  unknowns: []               # missing / unclear / stale
  possible_aiwf_components: []  # ideas only; not candidates, not selectable

boundaries:
  not_selectable: true
  not_installed: true
  not_copied: true
  vendor_verification_is_source_claim_not_approval: true
  promotion_requires_separate_lifecycle_release_registry_and_human: true

human_decision_required: []  # points only a human may decide (advance stage, adopt, promote)
```

## Rules

- A source packet is a **source, not a capability**. It is not selectable, not installed, not copied.
- Do **not** run `npx skills add` or any installer. Do **not** copy repo skills into AIWF.
- Do **not** mark a source `approved` or `candidate` without the separate external-skill-source lifecycle (human-only).
- Vendor "verified" / "official" wording is a **source claim**, not AIWF approval.
- Promotion past candidate requires the separate lifecycle, a release and registry update, and an explicit human decision.

## Illustrative placeholder (NVIDIA/cuOpt) — not a captured packet, not an adoption

The following is an **illustrative example of how to record** such a source. It
is a placeholder, not a real captured packet, and adopts nothing. NVIDIA/cuOpt is
referenced here as an **external source only**.

```yaml
source_id: example-nvidia-cuopt    # illustrative only
lifecycle_stage: source_packet     # recorded as a source; NOT candidate, NOT approved
url: unknown                       # fill with the actual source URL when verified
author_or_org: NVIDIA              # source claim
source_type: vendor
captured_at: unknown
source_as_of: unknown
license: unknown                   # verify before any use
terms: unknown                     # verify before any use

risk_surface:
  supply_chain_risk: unknown
  tool_permissions: unknown
  prompt_injection_risk: unknown
  can_read_secrets: unknown
  can_call_external_services: unknown
  can_write: unknown

concept_extraction:
  facts: []
  source_claims:
    - "Vendor describes the skills as official/verified — this is a source claim, not AIWF approval."
  inferences: []
  unknowns:
    - "License, terms, and risk surface not yet verified."
  possible_aiwf_components: []     # ideas only; not candidates

boundaries:
  not_selectable: true
  not_installed: true
  not_copied: true
  vendor_verification_is_source_claim_not_approval: true
  promotion_requires_separate_lifecycle_release_registry_and_human: true

human_decision_required:
  - "Whether to extract any concept from this source at all."
  - "Whether this source ever advances beyond source_packet."
```

Do not run `npx skills add`, do not copy NVIDIA/cuOpt repo skills into AIWF, and
do not treat vendor wording as AIWF approval.
