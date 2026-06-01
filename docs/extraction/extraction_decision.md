# Extraction Decision

## Decision

Create a new independent repository for AIWF Core instead of continuing to refactor the original AIWF exploration repo in place.

## Reason

The original repo contains useful logic mixed with exploration history, project-specific decisions, old workflow notes, and lab-era artifacts. Continuing to patch it risks carrying forward too much context and producing another thick rule package.

## Extracted into this repo

- Thin kernel.
- Adapter-first adoption model.
- Capability registry.
- Worker entitlement model.
- Control plane adapter contract.
- Library lifecycle.
- Release / upgrade boundary.
- Small templates and draft skills.

## Not extracted by default

- Old archives.
- Project-specific decisions.
- Runtime hooks already installed in old repo.
- `.claude/settings.json`.
- Historical AIWF/Lab wording.
- Research OS / Prism / FinanceBot project decisions.
