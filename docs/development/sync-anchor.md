# AIWF Core Sync Anchor

Status: advisory. This file documents the **sync rule**, not live state.

It deliberately holds **no live state values** — no commit SHAs, no capability
statuses, no validation counts, no run ids. That keeps the anchor itself from
ever going stale. Anything that looks like current state must be read from the
repo, never copied into this file.

## Source of truth

The **repository is the single source of truth**. Current state is read directly
from these authoritative, in-repo artifacts:

- **git** — current `HEAD`, branch, history, and merged PRs.
- **`aiwf/registry/aiwf.capabilities.yaml`** — capability lifecycle state
  (id / type / status / version / trigger / location / authority_boundary / risk).
  This is the source of truth for what is `candidate` vs `approved`, and for what
  is selectable.
- **`docs/development/dogfood-runs/*.yaml`** — dogfood evidence records
  (gate-validated by `scripts/validate-aiwf-core.sh`).
- **`aiwf/releases/*`** — pinned release snapshots (intentionally frozen per
  version; not a live anchor).
- **`docs/sops/aiwf-change-lifecycle.v0.1.md`** — the lifecycle state machine and
  process (defines how changes move; holds no live values).

## Mirrors and inputs are subordinate

Everything outside the repo is a **mirror or an input**, never an authority:

- **Notion** — anchor / orientation only.
- **Linear** — task tracking only.
- **ChatGPT memory** — hint only.
- **Executor / Claude reports** — input, not authority.

Rules:

- Mirrors and inputs **derive from** the repo. State never flows back from a
  mirror into the repo.
- On any conflict, the **repo wins**. A mirror that disagrees with the repo is
  stale and must be corrected from the repo.
- Do not change repo state because a mirror, summary, prior conclusion, or chat
  memory says so (kernel K2: source beats memory).

## How to read current state (no snapshot file needed)

```bash
git rev-parse HEAD            # current commit
git branch --show-current    # current branch
git status --short           # working tree state
grep -n "status:" aiwf/registry/aiwf.capabilities.yaml   # capability statuses
ls docs/development/dogfood-runs/                          # dogfood evidence records
bash scripts/validate-aiwf-core.sh                        # current validation result
```

## Anti-drift note

Do **not** add hand-maintained snapshot files that copy live state. In this repo
such files have already gone stale (for example, foundation recap/checklist,
`MANIFEST.json`, and `CHANGELOG.md` lag behind current state). If a machine-readable
snapshot is ever wanted, it must be **generated from the repo**, never hand-edited,
and clearly marked **non-authoritative** — the registry and git remain the source
of truth.

## Non-claims

This file documents a rule only. It is **not**:

- promotion to `approved`
- selectability approval
- adapter adoption
- runtime / settings / hook configuration change
- merge or deploy authority
