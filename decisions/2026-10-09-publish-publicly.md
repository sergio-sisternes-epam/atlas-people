---
type: decision
title: "Publish the people skill publicly as atlas-people"
created: "2026-10-09"
status: accepted
description: >-
  The earlier "private install only, never publish" rule is lifted; the
  package ships publicly as atlas-people v0.1.2 and its design memory moves to
  this repository's atlas branch. Approved by the maintainer on 2026-10-09.
origin: agent
sensitivity: public
relates_to:
  - path: autogenesis/plans/2026-10-05-people-atlas.md
    kind: related
  - path: autogenesis/plans/2026-10-05-people-privacy.md
    kind: related
---

# Decision: publish publicly as atlas-people

## Decision

Approved by the maintainer on 2026-10-09: the distribution rule pinned in
`2026-10-05-people-atlas` ("private install only — never publish") is lifted.
The skill package, called `people` in the former monorepo, is published as the
standalone public package `atlas-people` (v0.1.2) in this repository. Its
Autogenesis design memory lives on this repository's `atlas` branch (ref
`atlas`).

## Rationale

The privacy hardening (`2026-10-05-people-privacy`) already removed every
operator-private value from the package: the people store id, checkout root
and push remote are operator-supplied (`<people-atlas-id>`, `<atlas-root>`,
`<push-remote>`), and writes fail closed without a confirmed binding. With no
private infrastructure left in the product text, the remaining reason for a
private-only rule was gone.

## Alternatives considered

- **Keep private install only.** Rejected: no remaining privacy reason, and it
  blocks reuse by other operators.
- **Publish the package but keep design memory private.** Rejected: the
  plans, pins and challenge outcomes explain the package's safety boundaries
  (no name-only merge, Notes id targeting, secrets standing) and are useful to
  public readers once rewritten without private context.

## Consequences

- Design pages were rewritten for public release: roles replace private
  names, runtime ids and paths are placeholders, and links to pages of other
  former-monorepo packages became plain text.
- Release tags on the standalone repository use `vX.Y.Z`; `people/v0.1.1`
  remains the historical tag from the former monorepo.
- All earlier product pins (ownership, richer person pages, Notes one-shot
  first, secrets standing, operator store binding) are unchanged.
