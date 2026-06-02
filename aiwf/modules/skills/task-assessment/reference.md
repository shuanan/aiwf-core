# task-assessment — reference

## Upstream

- Methodology upstream: Pre-Task Assessment Gate v0.1 (human-readable framework; not repo-local authority).
- This skill is the aiwf-core executable convergence of that methodology — not a redefinition.

## aiwf-core kernel alignment (repo-local authority)

- K1 no self-approval → decision is never approval; output is advisory.
- K3 task boundary / classes → scope_mode uses K3 task classes (compare/shape/review/transform/write); "sharing" means it is not a task.
- K4 epistemic boundary → preserve fact / inference / assumption / unknown in output.
- K5 write boundary → any write routes to write-preview/task-envelope; this skill cannot authorize writes.
- K6 local boundary wins → downstream repo rules override; this skill yields to target-repo boundaries.
- K7 load on demand → candidate status is not selectable; this skill cannot approve/install/promote capabilities.
- No kernel edit. No rule adoption. No capability promotion.

## Input

```yaml
request:                 # the user ask, verbatim or summarized
declared_context: []     # what the user stated as given
available_sources: []    # sources the agent may read to resolve unknowns
```

## Output (must stay short — not a long report)

```yaml
task_assessment:
  status: assessed | needs_human | blocked
  scope_mode: compare | shape | review | transform | write | unknown   # + optional secondary
  task_type: new_service | feature | bugfix | tool_adoption | data_pipeline | deployment | other | unknown
  source_boundary:
  write_boundary:
  blocking_unknowns: []
  non_blocking_unknowns: []
  dependencies: []
  risks: []
  options: []
  recommendation_non_binding:        # never an approval (K1)
  decision: proceed | split | research | stop
  route_to: write-preview | task-envelope | none
  next_smallest_safe_action:
    type: read | write | human_decision | blocked
    description:                     # if write, name the template to load
  must_not_do: []
  lanes: []                          # only when decision=split
```

## Axes

- scope_mode = K3 task classes (compare/shape/review/transform/write) + unknown.
- task_type = 6 types from Pre-Task Assessment Gate + other + unknown.
- mixed / multi-lane is expressed via decision=split + lanes[], not as an axis value.

## status to decision (kept separate)

- decision in {proceed, split, research} → status: assessed
- decision = stop, a human can decide → status: needs_human
- decision = stop, not resolvable at all → status: blocked

## route_to (registry ids only)

- write path → route_to: write-preview (or task-envelope for executor handoff).
- otherwise → route_to: none. The actual next move is carried by next_smallest_safe_action.type.
- research is a generic read-first next action, NOT a registry capability (unless later registered).
- blocked_report is an output pattern, NOT a registered capability (unless later registered).

## Boundaries

- Runs before TaskEnvelope / Write Preview; does not replace either.
- Cannot authorize writes (K5). decision=proceed only routes; it is not approval (K1).
- If source/target/authority unclear → research or stop, never proceed (K2/K5).
- If the task duplicates prior art → research or stop before creating a new artifact.
- Output is advisory; epistemic labels preserved (K4).
