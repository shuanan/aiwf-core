# Order — External Pilot Draft

This is an external pilot draft. It tests whether the aiwf-core
downstream adapter model works for a real production repo.

## Important

- Order repo has NOT adopted AIWF.
- Order repo does NOT commit any AIWF or AI governance files.
- This draft exists only in aiwf-core as pilot evidence.
- Enforcement: none.
- Status: draft — not evaluated, not approved, not adopted.
- No CI, no test suite, no automation in Order.
- Quality tracking is process evidence only, not software
  correctness proof.

## Order repo characteristics

- Tech: ASP.NET WebForms / .NET 4.8 / C# / SQL Server
- Deploy: manual IIS publish to jtitest.tw
- Remote: internal Gitea (ssh://192.168.1.188)
- CI: none
- Tests: none
- Existing AI tooling: graphify knowledge graph, CLAUDE.md

## What this pilot tests

1. Can a downstream repo be described by an aiwf-core adapter?
2. Does the adapter model work without CI/tests/automation?
3. Can L1/L2 quality tracking capture workflow discipline
   without software correctness claims?
