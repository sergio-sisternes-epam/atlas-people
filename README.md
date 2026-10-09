# atlas-people

Operator-owned **people Atlas** skill. Query and remember people and typed
relationships on a dedicated runtime store; run a supervised **one-shot Apple
Notes** import that proves the person-page shape. Neutral across personal and
professional life.

## What it does

1. **Query** people and relationships on the people Atlas.
2. **Remember** person fields and typed relationship edges with evidence.
3. **Import-notes** once from Apple Notes (EXTERNAL `apple-notes`): id-safe
   source pointers, hard-id match only, ambiguous merges → review queue.
4. **Compile + push** via EXTERNAL `atlas` + `atlas-compile-commit-push` to
   the operator-supplied push remote only.

## Runtime store (operator-supplied)

This package ships **placeholders only** — no store id, host, checkout path,
push remote, or credential path. The operator's Enter card or the install
config supplies them for each run:

| Field | Placeholder | Source |
| --- | --- | --- |
| People store id | `<people-atlas-id>` | operator / install config |
| Working checkout | `<atlas-root>` | `atlas resolve` of that id |
| Sole push remote | `<push-remote>` | operator / install config |

Writes require `atlas_target: confirmed`. Missing or ambiguous binding → the
skill stops (fail closed), the same pattern as `atlas-tasks-todoist`.

**Never write** people pages into any non-people Atlas (for example the
operator's personal or work Atlas, or another agent's Atlas); those stay
domain-pure. Council decisions and principles belong to a separate
council/decision-memory skill, not to this one.

## Non-goals (v0)

- Continuous Apple Notes sync
- LinkedIn (or other) ingest — later overlay on the same `person_id`s
- Nesting this graph under the operator's personal or work Atlas, or any
  other non-people Atlas
- Provisioning the people store as a *skill* process store (the people store
  is data)
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
apm install sergio-sisternes-epam/atlas-people#v0.1.2
```

Record `atlas_id` and `push_remote` in the install config, not in this
package.

**Compose pins:** installed `atlas`, `atlas-compile-commit-push`, and
`apple-notes` (for import-notes).

## Maintaining

Root `SKILL.md` is canonical; `.apm/skills/atlas-people/SKILL.md` is a
byte-identical mirror. Edit the root, copy it over the mirror in the same
commit; the `apm-mirror-lockstep` smoke fails on drift.

Scenarios (`references/scenarios/`):

- `people-adversarial-v2.yaml` — behaviour pins (person_id, Notes id, merge,
  one-shot, secrets, package shape, live-store reachability or deferral).
- `people-privacy-adversarial-v1.yaml` — forbids private hosts, absolute
  home-directory paths, SSH identity paths, private role names, and personal
  Atlas slugs in package text.

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

Before publishing, run the public hygiene scan (tree, commit metadata, added
lines, and gitleaks when installed):

```bash
bash scripts/public-hygiene-scan.sh --all
```

CI (`.github/workflows/`) runs **Compile and smoke** (consumer install,
`apm compile --validate`, scenario runner, `apm pack --dry-run`) and
**Public hygiene scan**. Pushing a `v*` tag runs the release workflow, which
packs and publishes a GitHub Release.

## Autogenesis / Atlas (skill-associated)

This package's Autogenesis subject store is this repository's `atlas` branch.
Durable design plans and implement experiences live under that store's
`autogenesis/` tree. That is process memory for the skill — **not** the
runtime people graph.

## License

Apache License 2.0 — see `LICENSE` and `NOTICE`.
