---
type: work
title: "people — operator-owned people Atlas skill"
created: "2026-10-05"
updated: "2026-10-05"
work_id: "2026-10-05-people-atlas"
status: done
description: >-
  Implement the people package with an operator-owned people Atlas as runtime
  store; Notes one-shot import path; LinkedIn deferred. Approved and
  implemented 2026-10-05.
origin: agent
sensitivity: public
relates_to:
  - path: autogenesis/plans/2026-10-05-people-atlas.md
    kind: related
  - path: autogenesis/experiences/2026-10-05-people-atlas-implement.md
    kind: related
---

# Work: people Atlas

**Status:** done. Approved by the maintainer and implemented 2026-10-05.

**Plan:** [autogenesis/plans/2026-10-05-people-atlas.md](../plans/2026-10-05-people-atlas.md)

**Implement experience:** [autogenesis/experiences/2026-10-05-people-atlas-implement.md](../experiences/2026-10-05-people-atlas-implement.md)

## Scope

The `people` skill package. Change class `new-skill`. Runtime store
`<people-atlas-id>` (provisioned empty by the provisioner; owned by the
operator). Autogenesis lineage lives only on this repository's `atlas` branch
(ref `atlas`).

## Outcomes

- Package scaffolded (hybrid layout) with query / remember / import-notes
  paths, person-page schema, adversarial v1 scenarios.
- People store live; implement fixture remembered; compile green; tip pushed.
- agent-spec Gherkin deferred (agent-spec not installed in the implementation
  environment); @forbidden families retained in the plan.
