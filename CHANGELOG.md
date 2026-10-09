# Changelog

## 0.1.2 — 2026-10-09

Standalone public package `atlas-people`.

- Published publicly as `atlas-people` from
  `github.com/sergio-sisternes-epam/atlas-people`; the owner lifted the
  earlier private-install-only rule. Releases are now tagged `vX.Y.Z`
  (install with `sergio-sisternes-epam/atlas-people#v0.1.2`).
- Skill renamed from `people` to `atlas-people` so the package name, skill
  name, and APM mirror path (`.apm/skills/atlas-people/SKILL.md`) agree.
- Role-neutral wording throughout: the operator owns the store content, the
  provisioner provisions the empty store, and forbidden write-homes are "any
  non-people Atlas (for example the operator's personal or work Atlas, or
  another agent's Atlas)". Council memory is routed to a separate
  council/decision-memory skill. The missing-store deferral now reads
  `awaiting store provision`.
- `atlas-mesh.json` points the Autogenesis subject at this repository's
  `atlas` branch; it is never the people write-home.
- The personal-slug smoke reads forbidden slug prefixes from
  `PEOPLE_FORBIDDEN_SLUGS` (space- or comma-separated regular expressions)
  and records a deferral when unset; the package no longer carries the
  prefix itself.
- Scenarios run from the package root; new `scripts/run-scenarios.sh` runs
  every smoke and prints PASS/FAIL per smoke id.
- Standalone CI (Compile and smoke), tag-driven release workflow, and a
  public hygiene scan (`scripts/public-hygiene-scan.sh`, job
  `Public hygiene scan`).
- Added `LICENSE` (Apache-2.0) and `NOTICE`.

## 0.1.1 — 2026-10-05

Privacy hardening (work_id `2026-10-05-people-privacy`); first release on
`main`.

- Store binding is operator-supplied only: `atlas_id`, `atlas_root`, and
  `push_remote` come from the Enter card or the install config, with
  `atlas_target: confirmed` required for writes. Missing or ambiguous binding
  fails closed (same pattern as `atlas-tasks-todoist`).
- Package text carries placeholders only (`<people-atlas-id>`, `<atlas-root>`,
  `<push-remote>`): no private hostnames or remotes, no absolute
  home-directory paths, no SSH identity paths, no personal Atlas slugs.
  Forbidden write-homes are named by role (the operator's personal and work
  Atlases, other agents' Atlases, the Autogenesis subject store).
- New `people-privacy-adversarial-v1.yaml` suite enforces the above.
- `people-adversarial-v2.yaml` carries the 0.1.0 behaviour smokes, rewritten:
  YAML at column 0; version smoke checks SemVer shape instead of a frozen
  patch string; live-store smoke is parameterised by operator environment
  (`PEOPLE_PUSH_REMOTE`) and records a deferral when unset; new
  `apm-mirror-lockstep` smoke.
- Documented the root `SKILL.md` → `.apm` mirror lockstep rule; README routes
  council memory to a separate council/decision-memory skill explicitly;
  exit checklist says "no title-only Notes targeting".

## 0.1.0 — 2026-10-05 (not released)

Initial design (work_id `2026-10-05-people-atlas`). Proposed in a pull
request that was closed unmerged and superseded by 0.1.1; never tagged.

- Paths: query, remember, import-notes (one-shot Apple Notes via EXTERNAL
  apple-notes).
- The provisioner provisions an empty store only; the operator owns its
  content.
- Person pages: document type + person contract (`person_id`, names/aliases,
  bio, history, notes excerpts, source pointers, typed `relates_to`).
- Identity: Atlas-owned `person_id`; never CNContact as primary key; never
  auto-merge on name alone; ambiguous pairs → review queue.
- Notes: id-safe source pointers; title-only targeting is a blocker; skip
  locked notes; folder scope required (no whole-library default).
- Secrets standing: say only that 1Password is the vault when credentials are
  needed; no item/vault ids in skill or Atlas process pages; no password /
  SSN-class content in person pages.
- Non-goals for v0: LinkedIn ingest, continuous Notes sync, nesting in the
  operator's personal or work Atlas.
