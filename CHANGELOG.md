# Changelog

## 0.1.3 — 2026-10-09

Target-neutral storage for person pages, and an Atlas overlay that declares
the `person` type.

- Removed the package policy that forced person pages into a separately
  bound people store and forbade writing them to a work, project, personal,
  or other agent's Atlas. The skill no longer forbids or forces any Atlas
  target.
- Before the first write (remember, import-notes, or compile/push) in a run,
  the skill now asks the operator which Atlas the person pages should be
  stored in, offers any known or bound Atlas (Enter card, install config, or
  Atlases the EXTERNAL `atlas` skill can list or resolve), and accepts any
  other Atlas the operator names.
- Writes happen only after explicit per-target confirmation:
  `atlas_target: confirmed` now means the operator confirmed that specific
  `atlas_id` (and its `push_remote`) for this run. Install-config and
  Enter-card values are suggested defaults, not confirmations; a changed
  target is confirmed again. The skill never refuses a target on policy
  grounds.
- Privacy notes about visibility on shared, work/project, or public targets
  are advisory and never block.
- Stop string renamed from `incomplete: missing people store binding` to
  `incomplete: atlas target not confirmed`; placeholder renamed from
  `<people-atlas-id>` to `<target-atlas-id>`.
- Scenarios: dropped the smokes asserting the old forbid rule; added smokes
  for the target question, per-target confirmation, acceptance of a
  confirmed work/project Atlas, no policy refusal, non-blocking privacy
  advice, and a negative smoke against the old forbid wording.
- New Atlas overlay `contributions/atlas-people/` (`SCHEMA.overlay.json`,
  `templates/person.md`, `README.md`) declaring one new type, `person`. It
  carries contract keys only (`contribution_id`, `templates`): no claimed
  folders, no extension slot, no core type redeclared. Atlas checks 8
  required keys (`type`, `title`, `created`, `updated`, `sensitivity`,
  `person_contract`, `person_id`, `names`); the skill still requires
  `origin` and `aliases` and the rest of the person-page schema.
- New person pages use `type: person`. Pages written by v0.1.2
  (`type: document` + `person_contract: v1`) stay valid; query recognises
  both by `person_contract: v1`, and remember retypes a legacy page to
  `person` only on an Atlas where the overlay is mounted.
- SKILL.md gains a **Mount the Atlas overlay** step: `apm install` never
  mounts the overlay; after target confirmation and resolve, the skill asks
  the operator and mounts it only on the confirmed target with
  `atlas.py schema install <pkg-root>/contributions/atlas-people --root
  <atlas-root>` and compile. Declining is advisory, not a block. Upgrade
  re-runs `schema install` from the new package root (`--force` when
  required keys change); removal is `schema uninstall atlas-people` and
  compile. The package ref is recorded on the exit receipt.
- Tested with Atlas 0.13.0 and 0.13.1 on SCHEMA 1.0 and 2.0 stores. New
  `scripts/overlay-smoke.sh` (static contract check plus install, compile,
  missing-key, reinstall, and uninstall runs) and scenario file
  `people-overlay-v1.yaml`.
- CI installs `jsonschema==4.25.1` (needed by the Atlas CLI for SCHEMA 2.0
  stores; the pin matches Atlas `scripts/requirements-ci.txt`), checks out
  the Atlas CLI at v0.13.1 and v0.13.0, and runs the overlay smoke against
  both.

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
