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
`document` pages, and the skill's recall path recognises person pages by
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
and confirmed as the target for person pages, on a real write run
(remember or import-notes with `memory_sync: on`). Recall and dry runs never
mount it, because mounting changes `schema.d/` and `templates/`:

```bash
apm install sergio-sisternes-epam/atlas-people#v0.1.4
# Package root: apm_modules/sergio-sisternes-epam/atlas-people/
# (confirm the tag in apm.lock.yaml)
python3 <atlas-skill>/scripts/atlas.py schema install \
  <pkg-root>/contributions/atlas-people \
  --root <atlas-root>
python3 <atlas-skill>/scripts/atlas.py compile --root <atlas-root>
```

This overlay ships in the tagged source package that the `apm install`
above places. The `apm pack` plugin bundle attached to GitHub Releases
carries the skill only, not this overlay. If `<pkg-root>` has no
`contributions/atlas-people/SCHEMA.overlay.json` (a bundle-only or
deployed-skill-only install), stop the mount and install from the tagged
repository; do not fetch or guess another source.

## Upgrade

After `apm install sergio-sisternes-epam/atlas-people#vNEW` or `apm update`,
the store keeps the old overlay until the mount is re-run from the new
package root (`<new-pkg-root>`). Ask the operator, then on the confirmed
target uninstall, install, and compile:

```bash
python3 <atlas-skill>/scripts/atlas.py schema uninstall atlas-people --root <atlas-root>
python3 <atlas-skill>/scripts/atlas.py schema install \
  <new-pkg-root>/contributions/atlas-people \
  --root <atlas-root>
python3 <atlas-skill>/scripts/atlas.py compile --root <atlas-root>
```

Why not a plain re-install: re-running `schema install` (with or without
`--force`) on a store that already has `templates/person.md` does not
overwrite that template and rewrites the receipt without it, so the
template stays at the old version and a later `schema uninstall` leaves it
behind. Uninstalling first removes the old overlay and template; the fresh
install writes the new template and lists it on the receipt again, so
`--force` is not needed. Uninstall never deletes person pages. If
`templates/person.md` is still present after the uninstall (left by an
earlier plain re-install), the overlay no longer owns it; with the
operator's agreement delete it before the install so the new template is
written and recorded. Verified with Atlas 0.13.0 and 0.13.1
(`scripts/overlay-smoke.sh`).

## Remove

`apm uninstall` leaves `schema.d/atlas-people.json` and its receipt in every
store. Remove the overlay from each store explicitly:

```bash
python3 <atlas-skill>/scripts/atlas.py schema uninstall atlas-people --root <atlas-root>
python3 <atlas-skill>/scripts/atlas.py compile --root <atlas-root>
```

Uninstall does not delete person pages. Pages with `type: person` remain
legal OKF; Atlas simply stops checking their frontmatter.

If a store was upgraded with a plain re-install under an older version of
these instructions, `templates/person.md` may remain after
`schema uninstall`. It is an unused template, not part of the contract file
or `schema.d/`; the operator may delete it.
