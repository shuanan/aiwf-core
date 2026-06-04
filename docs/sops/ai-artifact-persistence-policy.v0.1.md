# AI Artifact Persistence Policy SOP v0.1

Status: proposed SOP. Not adoption approval, not merge approval, not release approval.

## Purpose

This SOP classifies where AI/AIWF artifacts may persist, so that AI/AIWF
governance notes, maps, prompts, adapter drafts, and local agent configuration
do not silently leak into repositories that did not approve them.

Classification happens before writing or committing. Persisting an artifact is a
write, so the normal write boundary (preview + explicit human approval) always
applies in addition to the defaults below.

## AI Artifact Persistence Policy

AI/AIWF artifacts must be classified before writing or committing.

### Work / employer repositories

Default: local-only.

AI/AIWF governance notes, maps, prompts, adapter drafts, and local agent
configuration should stay out of tracked repo files unless the human explicitly
approves repo persistence.

Preferred local-only mechanisms:
- keep untracked AI artifacts ignored through `.git/info/exclude`
- avoid `.gitignore` changes unless the repo intentionally adopts the pattern
- avoid `skip-worktree` / `assume-unchanged` unless explicitly chosen,
  documented, and reversible

Do not treat local AI files as project adoption evidence.

### Personal / side-project repositories

Default: case-by-case.

AI/AIWF artifacts may be committed only when:
- they are project governance rather than machine-local convenience
- a write preview names the target, operation, risk, and reversibility
- the human explicitly approves persistence
- the artifact contains no secrets, credentials, private machine paths, or
  unsupported adoption claims

### AIWF-owned repositories

Default: commit allowed with normal preview and approval.

AIWF-owned repos may persist AIWF governance artifacts because they are part of
the source of truth, but the normal write boundary still applies.

### Non-claims

Persisting an AI artifact does not by itself mean:
- AIWF is adopted by a downstream repo
- a runtime adapter is enabled
- a tool or hook is installed
- selectability is approved
- deployment, migration, merge, or production behavior changed

## Relationship to the change lifecycle SOP

The change lifecycle SOP (`docs/sops/aiwf-change-lifecycle.v0.1.md`) governs how
an approved aiwf-core change moves from idea to merge. This SOP governs whether an
AI/AIWF artifact may persist in a given repository at all, and where. Both apply;
neither grants approval on its own.
