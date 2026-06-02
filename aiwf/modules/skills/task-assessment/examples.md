# task-assessment — examples

| # | input | scope_mode | task_type | status | decision | route_to | why |
|---|---|---|---|---|---|---|---|
| 1 | simple factual question | compare | other | assessed | proceed | none | read-only, no unknown |
| 2 | compare A/B only | compare | other | assessed | proceed | none | no write |
| 3a | vague task, agent can self-check | unknown | unknown | assessed | research | none | unknown is agent-resolvable |
| 3b | vague task, needs requester input | unknown | unknown | needs_human | stop | none | scope only resolvable by human |
| 4 | multi-lane task | review | other | assessed | split | none | independent lanes -> lanes[] |
| 5 | repo write, no target given | write | unknown | needs_human | stop | none | target unclear, human must specify |
| 6 | Notion/GitHub state unknown | review | other | assessed | research | none | agent can self-check |
| 7 | duplicates prior art | shape | tool_adoption | assessed | research | none | reconcile before new artifact |
| 8 | write with clear target | write | feature | assessed | proceed | write-preview | proceed routes, not approval |
| 9 | high-risk deploy/migration | transform | deployment | needs_human | stop | none | irreversible risk |
| 10 | bugfix without reproduction | review | bugfix | assessed | research | none | reproduce before fixing |
| 11 | tool adoption request | shape | tool_adoption | assessed | research | none | research gate first |
| 12 | mixed review + write | review | other | assessed | split | none | split review lane from write lane |
