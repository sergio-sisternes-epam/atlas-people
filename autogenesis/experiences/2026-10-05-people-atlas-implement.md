---
type: experience
title: "people Atlas implement v0.1.0"
created: "2026-10-05"
updated: "2026-10-05"
work_id: "2026-10-05-people-atlas"
implements: "2026-10-05-people-atlas"
closes:
  - "2026-10-05-people-atlas"
plan_path: autogenesis/plans/2026-10-05-people-atlas.md
origin: agent
sensitivity: public
relates_to:
  - path: autogenesis/plans/2026-10-05-people-atlas.md
    kind: implements
  - path: autogenesis/work/2026-10-05-people-atlas.md
    kind: implements
---

# Experience: people implement

The approved plan `autogenesis/plans/2026-10-05-people-atlas.md` was
implemented as the `people` package (branch `feat/people-v0.1.0`, in a
pre-publication pull request). Approved by the maintainer on 2026-10-05, once
the provisioner had created the empty people store.

## Changed files

Paths are relative to the package root.

- `SKILL.md`
- `.apm/skills/people/SKILL.md`
- `apm.yml`
- `README.md`
- `CHANGELOG.md`
- `atlas-mesh.json`
- `references/person-page-schema.md`
- `references/paths/query.md`
- `references/paths/remember.md`
- `references/paths/import-notes.md`
- `references/scenarios/people-adversarial-v1.yaml`

Subject Atlas (this store) lineage updates:

- `autogenesis/plans/2026-10-05-people-atlas.md` (status done + approval_ref)
- `autogenesis/work/2026-10-05-people-atlas.md` (status done)
- `autogenesis/experiences/2026-10-05-people-atlas-implement.md` (this page)
- `autogenesis/index.md` (active row)

Runtime people store (not this Autogenesis subject):

- `people/fixture-implement-smoke.md` (synthetic fixture)
- `people/index.md`
- `index.md`, `log.md` (structural)

## Evaluation

Deterministic adversarial smokes from
`references/scenarios/people-adversarial-v1.yaml` ran green on the local
package tree (package shape, no-nest into any non-people Atlas, stable
person_id, notes id not title, no name-only merge, one-shot no watcher,
LinkedIn deferred, secrets standing, skip locked, import scope, atlas-mesh
subject vs runtime, APM copy identical).

Live people store smoke:

- `git ls-remote <push-remote> HEAD` → the tip advanced from the empty-store
  init commit to the fixture commit after the push.
- `atlas compile --root <atlas-root>` → ok (informational
  legacy_document / missing_gist only).
- Fixture remember + EXTERNAL-style commit/push to `<push-remote>` branch
  `atlas` succeeded.

## Deferrals

- **agent-spec specify / Gherkin:** deferred — agent-spec was not installed in
  the implementation environment. Plan `@forbidden` / `@critical` family names
  retained; behavioural_contract frontmatter records the deferral. Not a silent
  drop of the approved smoke set.
- **Tag `people/v0.1.0` + install:** package ready; tag and install left to the
  package steward and the maintainer (standing: do not merge unless asked).
  0.1.0 was never tagged; the first release was 0.1.1.
- **LinkedIn / continuous Notes sync:** approved non-goals for the v0 body.

## Version identity

- Package version `0.1.0` in `apm.yml`
- Intended tag: `people/v0.1.0` (not cut in this Run). Tags on the standalone
  `atlas-people` repository use `vX.Y.Z`.
