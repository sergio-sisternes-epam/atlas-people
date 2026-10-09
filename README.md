# atlas-people

People skill for Atlas. Query and remember people and typed relationships as
person pages on **the Atlas the operator chooses and confirms**; run a
supervised **one-shot Apple Notes** import that proves the person-page shape.
Neutral across personal and professional life.

## What it does

1. **Query** people and relationships on the target Atlas.
2. **Remember** person fields and typed relationship edges with evidence.
3. **Import-notes** once from Apple Notes (EXTERNAL `apple-notes`): id-safe
   source pointers, hard-id match only, ambiguous merges → review queue.
4. **Compile + push** via EXTERNAL `atlas` + `atlas-compile-commit-push` to
   the operator-confirmed push remote only.

## Storage target (operator-confirmed)

This package ships **placeholders only** — no store id, host, checkout path,
push remote, or credential path. The skill does not forbid or force any
Atlas: before the first write in a run it asks the operator which Atlas the
person pages should be stored in, offering any known or bound Atlas (Enter
card, install config, or Atlases the `atlas` skill can list) and accepting
any other Atlas the operator names.

| Field | Placeholder | Source |
| --- | --- | --- |
| Target Atlas id | `<target-atlas-id>` | operator confirmation each run |
| Working checkout | `<atlas-root>` | `atlas resolve` of that id |
| Push remote for the run | `<push-remote>` | confirmed with the target |

Writes require `atlas_target: confirmed` — the operator explicitly confirmed
that specific `atlas_id` (and its `push_remote`) for this run. It is a
per-target confirmation, not an allow-list; an install-config value is a
suggested default, not a confirmation. If the target changes, the skill asks
again. No confirmation → `incomplete: atlas target not confirmed` (fail
closed). Query needs no write confirmation: it resolves a known or
operator-named Atlas and reads it with `atlas_target: unknown`, read-only.

The skill never refuses a target on policy grounds: a work, project,
personal, shared, or another agent's Atlas is accepted once the operator
confirms it. When the target is shared, a work or project Atlas, or a public
repository branch, the skill notes that person pages will be visible to that
Atlas's readers — advice only, never a block.

Council decisions and principles belong to a separate
council/decision-memory skill, not to this one.

## Non-goals (v0)

- Continuous Apple Notes sync
- LinkedIn (or other) ingest — later overlay on the same `person_id`s
- Restricting or forcing the Atlas target on policy grounds (the operator
  decides; the skill asks and confirms)
- Treating person pages as *skill* process memory (they are data)
- Shipping live hostnames, remotes, checkout paths, or SSH identity paths in
  this package
- Replacing Contacts.app / CNContact as a system of record
- Naming 1Password item titles, vault names, or ids in skills or Atlas process
  pages — say only that 1Password is the vault when credentials are needed

## Design lineage

Autogenesis work_ids `2026-10-05-people-atlas` and `2026-10-05-people-privacy`
live on **this repository's `atlas` branch**
(`github.com/sergio-sisternes-epam/atlas-people`, ref `atlas`), declared in
`atlas-mesh.json`.

## Install

Releases are tagged `v<version>`. Install a pinned release with APM:

```bash
apm install sergio-sisternes-epam/atlas-people#v0.1.3
```

Optionally record a suggested `atlas_id` and `push_remote` in the install
config, not in this package; the skill offers it as an option and still asks
the operator to confirm it before the first write.

**Compose pins:** installed `atlas`, `atlas-compile-commit-push`, and
`apple-notes` (for import-notes).

## Atlas overlay (type `person`)

The package ships an Atlas overlay in `contributions/atlas-people/` that
declares one new type, `person`, so Atlas compile can check person-page
frontmatter. It claims no folder, carries no extension slot, and redeclares
no core type. `apm install` never mounts it: the skill asks the operator,
then mounts it only on the confirmed target Atlas, and only on a real write
run (remember or import-notes with `memory_sync: on`; never for query or a
dry run). The path module mounts it once, after the path module's gates
pass and immediately before the first write:

```bash
python3 <atlas-skill>/scripts/atlas.py schema install \
  apm_modules/sergio-sisternes-epam/atlas-people/contributions/atlas-people \
  --root <atlas-root>
python3 <atlas-skill>/scripts/atlas.py compile --root <atlas-root>
```

After `apm install sergio-sisternes-epam/atlas-people#vNEW` or `apm update`,
re-run the mount on the confirmed target, after asking the operator:
`schema uninstall atlas-people --root <atlas-root>`, then
`schema install <new-pkg-root>/contributions/atlas-people --root <atlas-root>`,
then compile. A plain re-install (with or without `--force`) neither
refreshes `templates/person.md` nor keeps it on the receipt, so a later
uninstall would leave it behind. Uninstall never deletes person pages.
Remove the overlay with `schema uninstall atlas-people --root <atlas-root>`,
then compile; if a store was upgraded with a plain re-install under older
instructions, a leftover `templates/person.md` is an unused template the
operator may delete. Declining the mount is fine: the skill still works
without Atlas-side checks. New person pages use `type: person`; v0.1.2
`type: document` pages stay valid.
Tested with Atlas 0.13.0 and 0.13.1 on SCHEMA 1.0 and 2.0 stores. Details,
including which keys Atlas enforces and which the skill enforces:
`contributions/atlas-people/README.md`.

## Maintaining

Root `SKILL.md` is canonical; `.apm/skills/atlas-people/SKILL.md` is a
byte-identical mirror. Edit the root, copy it over the mirror in the same
commit; the `apm-mirror-lockstep` smoke fails on drift.

Scenarios (`references/scenarios/`):

- `people-adversarial-v2.yaml` — behaviour pins (target question and
  per-target confirmation, person_id, Notes id, merge, one-shot, secrets,
  package shape, live-store reachability or deferral).
- `people-privacy-adversarial-v1.yaml` — forbids private hosts, absolute
  home-directory paths, SSH identity paths, private role names, and personal
  Atlas slugs in package text.
- `people-overlay-v1.yaml` — Atlas overlay shape (contract keys only, no
  slot, no core redeclaration), SKILL.md mount / upgrade / remove wording,
  and the live overlay smoke.

Run every smoke from the package root (needs `python3`, PyYAML, and
`ripgrep`):

```bash
bash scripts/run-scenarios.sh
```

Environment-dependent smokes record a deferral and pass when their input is
unset:

- `PEOPLE_PUSH_REMOTE` — operator-supplied remote for the live-store smoke.
- `PEOPLE_FORBIDDEN_SLUGS` — space- or comma-separated list of regular
  expressions for personal Atlas slug prefixes that must never appear in
  package text. The package does not ship the list itself.
- `ATLAS_CLI` — path to an Atlas checkout's `scripts/atlas.py` for the
  overlay smoke. `scripts/overlay-smoke.sh` also accepts `ATLAS_CLIS`, a
  space-separated list, and runs each CLI against fresh SCHEMA 1.0 and 2.0
  stores (needs `jsonschema` for 2.0 stores).

Before publishing, run the public hygiene scan (tree, commit metadata, added
lines, and gitleaks when installed):

```bash
bash scripts/public-hygiene-scan.sh --all
```

CI (`.github/workflows/`) runs **Compile and smoke** (consumer install,
`apm compile --validate`, Atlas overlay smoke against Atlas v0.13.1 and
v0.13.0, scenario runner, `apm pack --dry-run`) and
**Public hygiene scan**. Pushing a `v*` tag runs the release workflow, which
packs and publishes a GitHub Release.

## Autogenesis / Atlas (skill-associated)

This package's Autogenesis subject store is this repository's `atlas` branch.
Durable design plans and implement experiences live under that store's
`autogenesis/` tree. That is process memory for the skill; person pages are
data, stored wherever the operator confirms.

## License

Apache License 2.0 — see `LICENSE` and `NOTICE`.
