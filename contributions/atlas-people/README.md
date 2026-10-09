# atlas-people contribution

Atlas overlay shipped with the `atlas-people` skill package. It lets an Atlas
check the frontmatter of person pages.

## What this overlay does

- Adds **one new type, `person`**, with the template `templates/person.md`.
- Does **not** claim any folder. Person pages live wherever the operator
  keeps them (for example `people/`), and the Atlas CLI does not write them,
  so there is nothing to claim (Atlas rule: do not claim a folder just
  because pages live there).
- Does **not** redeclare any core type (`document`, `work`, `experience`,
  …). Atlas compile rejects that (`overlay_core_type`).
- Carries **Atlas contract keys only**: `contribution_id` and `templates`.
  There is no `atlas_people` extension slot and no other root key, so the
  overlay installs on SCHEMA 1.0 and 2.0 stores with any Atlas from 0.13.0.

## Who enforces what

The normative person-page contract is the skill's
`references/person-page-schema.md`. This overlay mirrors part of it so that
Atlas compile can check it.

| Rule | Enforced by |
| --- | --- |
| Required frontmatter `type`, `title`, `created`, `updated`, `sensitivity`, `person_contract`, `person_id`, `names` on `type: person` pages | Atlas (`page_contract` warning on compile) and the skill |
| `origin`, `aliases` (required by the skill) | The skill; Atlas lists them as recommended because a type may carry at most 8 required frontmatter keys |
| `sources`, `notes_excerpts`, `relates_to` (recommended) | The skill |
| Recommended sections Bio, History, Notes excerpts, Sources, Relationships | Atlas (recommended only) and the skill |
| `sensitivity: restricted` default, `person_contract: v1`, Atlas-owned `person_id`, relationship vocabulary, source pointers by Notes id, no secret-class content, no name-only merge | The skill only |

## Legacy pages

Pages written by atlas-people v0.1.2 use `type: document` with
`person_contract: v1`. They stay valid: Atlas treats them as ordinary
`document` pages, and the skill's query path recognises person pages by
`person_contract: v1` whatever their `type`. The remember path may set
`type: person` when it next updates such a page, but only on an Atlas where
this overlay is mounted; otherwise it leaves the type as it is. New person
pages use `type: person`.

## Requirements

- Atlas CLI 0.13.0 or later. Tested with Atlas 0.13.0 and 0.13.1 on SCHEMA
  1.0 and SCHEMA 2.0 stores (`scripts/overlay-smoke.sh`).
- Unmounted, the skill still works: an unknown `type` is legal OKF, so only
  Atlas-side frontmatter checks are missing.

## Mount

`apm install` only installs the skill package. It never mounts this overlay
into any Atlas. Mount it explicitly, and only on the Atlas the operator named
and confirmed as the target for person pages:

```bash
apm install sergio-sisternes-epam/atlas-people#v0.1.3
# Package root: apm_modules/sergio-sisternes-epam/atlas-people/
# (confirm the tag in apm.lock.yaml)
python3 <atlas-skill>/scripts/atlas.py schema install \
  <pkg-root>/contributions/atlas-people \
  --root <atlas-root>
python3 <atlas-skill>/scripts/atlas.py compile --root <atlas-root>
```

## Upgrade

After `apm install sergio-sisternes-epam/atlas-people#vNEW` or `apm update`,
the store keeps the old overlay until `schema install` runs again from the
new package root. Add `--force` when the overlay's required frontmatter keys
changed (install exits 2 otherwise). Then compile.

```bash
python3 <atlas-skill>/scripts/atlas.py schema install \
  <pkg-root>/contributions/atlas-people \
  --root <atlas-root> [--force]
python3 <atlas-skill>/scripts/atlas.py compile --root <atlas-root>
```

## Remove

`apm uninstall` leaves `schema.d/atlas-people.json` and its receipt in every
store. Remove the overlay from each store explicitly:

```bash
python3 <atlas-skill>/scripts/atlas.py schema uninstall atlas-people --root <atlas-root>
python3 <atlas-skill>/scripts/atlas.py compile --root <atlas-root>
```

Uninstall does not delete person pages. Pages with `type: person` remain
legal OKF; Atlas simply stops checking their frontmatter.
