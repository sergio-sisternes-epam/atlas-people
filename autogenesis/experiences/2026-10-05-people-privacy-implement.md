---
type: experience
title: "people privacy implement v0.1.1 (recreate from main)"
created: "2026-10-05"
updated: "2026-10-05"
work_id: "2026-10-05-people-privacy"
implements: "2026-10-05-people-privacy"
closes:
  - "2026-10-05-people-privacy"
plan_path: autogenesis/plans/2026-10-05-people-privacy.md
external_ref: "second pre-publication pull request (pre-publication history)"
origin: agent
sensitivity: public
relates_to:
  - path: autogenesis/plans/2026-10-05-people-privacy.md
    kind: implements
  - path: autogenesis/work/2026-10-05-people-privacy.md
    kind: implements
  - path: autogenesis/experiences/2026-10-05-people-atlas-implement.md
    kind: follows
---

# Experience: people privacy implement (cut A)

The approved hardening plan `autogenesis/plans/2026-10-05-people-privacy.md`
was implemented as `people` **0.1.1** on a new branch
`feat/people-v0.1.1-privacy` cut from `main`, in a second pre-publication pull
request, with one follow-up commit after automated review (dry-run / Enter
ordering). The first pre-publication pull request stays closed and was not
reopened. No force-push. Approved by the maintainer on 2026-10-05.

Files were rewritten on clean `main` (the reference tree was read from the
closed branch via `git archive`; no cherry-pick of leak commits).

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
- `references/scenarios/people-adversarial-v2.yaml`
- `references/scenarios/people-privacy-adversarial-v1.yaml`

Subject Atlas lineage (this store): plan + work node → done; autogenesis,
plans, work, experiences indexes; `log.md` (structural close); this page.

## What changed (against plan scope)

1. **Privacy pin** — package text carries placeholders only
   (`<people-atlas-id>`, `<atlas-root>`, `<push-remote>`); forbidden
   write-homes named by role (any non-people Atlas — the operator's personal
   or work Atlas, another agent's Atlas — and the Autogenesis subject store).
2. **Operator store binding (todoist-style)** — the Enter card gains
   `push_remote` and `atlas_target: confirmed | unknown`; writes require
   `confirmed`; a missing binding → `incomplete: missing people store binding`.
   New pin 10. Review-queue / dry-run wording uses "operator", not a name.
3. **Product behaviour retained** — query / remember / import-notes,
   person_id, no name-only merge, Notes id, one-shot, LinkedIn deferred,
   "1Password is the vault".
4. **Review threads from the first pull request** — `.apm` lockstep
   documented + `cmp` smoke; YAML column 0 + parse smoke; SemVer-shape version
   smoke; SSH identity path removed, live smoke parameterised by the operator
   env `PEOPLE_PUSH_REMOTE` with an explicit deferral; README routes council
   memory to a separate council/decision-memory skill; checklist "no
   title-only Notes targeting".
5. **Scenarios** — new `people-privacy-adversarial-v1.yaml` (the plan's 8
   approved smokes, tightened); `people-adversarial-v2.yaml` migrates all 13
   prior v1 behaviour smokes with privacy rewrites and adds
   `apm-mirror-lockstep` + `council-memory-route`. The prior v1 file was not
   carried (it only ever existed in the closed first pull request and embedded
   private identifiers) — no approved smoke dropped. Forbidden literals are
   written as bracket classes (e.g. `[.]ss[h]`) so the suite never contains
   the strings it forbids.
6. **Version** — 0.1.0 was never tagged (no `people/*` tags local or remote);
   shipped as **0.1.1**; CHANGELOG keeps a scrubbed 0.1.0 "not released"
   entry.

## Evaluation (actual evidence)

- Runner over both scenario files (bash `-euo pipefail` per smoke, package
  root): **23/23 PASS**. `people-store-live-or-deferred` printed
  `deferred: PEOPLE_PUSH_REMOTE unset (operator-supplied)`.
- Negative control: the privacy suite against the closed first pull request's
  tree → 7/8 FAIL (only yaml-column-zero passes). A canary leak injected into
  a copy of the clean tree → all 4 leak-pattern smokes FAIL.
- `git grep -nE '<private-host>|<home-path>|\.ssh|<personal-slug-prefix>'`
  over the package (the four operator-specified pattern classes) → no matches.
- CI-equivalent: `apm install <pkg> --target agent-skills,cursor` +
  `apm compile --validate` + `apm pack --dry-run` → green (pack lists
  SKILL.md + plugin.json, the same as sibling packages).
- Commit metadata: the shared checkout's local git identity carried a
  private-host email; the unpushed commit was amended (local only) to the
  repository's usual author identity before the first push. Commit message
  and pull request body scanned clean. Lesson: scan author metadata, not just
  file content, before a privacy-sensitive push.

## Deferrals / residuals

- **Live-store reachability smoke:** deferred — operator env not set in this
  Run (by design; the package ships no remote).
- **agent-spec / Gherkin:** deferred — agent-spec was not installed in the
  implementation environment (as planned).
- **Cut B** (shared design-store people-commit rewrite): parked at the time;
  earlier pages and commit metadata on the former shared store kept historical
  private identifiers. The public pages on this repository's `atlas` branch
  were rewritten for publication and do not carry them.
- **Closed first pull request's head branch:** deletion left to the
  maintainer (optional, plan todo 1).
- **Merge / tag / install:** left for separate authorisation at the time;
  later released inside the former monorepo as 0.1.1 (tag `people/v0.1.1`).
  New tags on the standalone `atlas-people` repository use `vX.Y.Z`.

## Version identity

- `apm.yml` version `0.1.1`; tagged in the former monorepo as `people/v0.1.1`.

## Follow-up after automated review

A follow-up commit on `feat/people-v0.1.1-privacy`:

- `import-notes`: gate durable writes on `memory_sync: on`; gate publish on `compile_push: on`.
- `remember`: `memory_sync: off` is a read-only preview before identity writes.
- `SKILL.md` and the `.apm` mirror: resolve `atlas_root` via `atlas resolve` before emitting the Enter card.

All three review threads on that pull request were resolved. Package smokes were re-checked green after the follow-up.
