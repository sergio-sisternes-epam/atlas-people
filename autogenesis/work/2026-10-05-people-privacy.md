---
type: work
title: "people — privacy harden + history recreate"
created: "2026-10-05"
updated: "2026-10-05"
work_id: "2026-10-05-people-privacy"
status: done
description: >-
  Privacy-harden the people skill text; operator-supplied store binding;
  close the first pre-publication pull request and recreate a clean one from
  main. Cut B (design-store history rewrite) parked.
origin: agent
sensitivity: public
relates_to:
  - path: autogenesis/plans/2026-10-05-people-privacy.md
    kind: related
  - path: autogenesis/plans/2026-10-05-people-atlas.md
    kind: related
  - path: autogenesis/experiences/2026-10-05-people-privacy-implement.md
    kind: related
---

# Work: people privacy

**Status:** done — implemented after explicit approval by the maintainer in a pre-publication pull request; released inside the former monorepo as 0.1.1.

**Plan:** [autogenesis/plans/2026-10-05-people-privacy.md](../plans/2026-10-05-people-privacy.md)

## Scope

Cut A: scrub the `people` package of private identifiers; todoist-style
operator store binding; history via the closed first pre-publication pull
request + a new pull request from main. Cut B (shared design-store
people-commit rewrite) is an explicit non-goal for this work_id.

## Outcomes

- Design plan persisted and challenged.
- Approved by the maintainer on 2026-10-05.
- Implemented: new branch `feat/people-v0.1.1-privacy` from `main`, in a second pre-publication pull request (with a follow-up after automated review); the first pull request stays closed.
- Evaluation: 23/23 scenario smokes green (live-store smoke deferred: operator env unset); privacy negative control red on the first pull request's tree; APM install/compile/pack green.
- Experience: [2026-10-05-people-privacy-implement](../experiences/2026-10-05-people-privacy-implement.md).
- Cut B (shared design-store people-commit rewrite) remains parked.
