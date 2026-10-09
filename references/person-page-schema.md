# Person page schema (normative contract)

Target Atlas: the operator-confirmed `<target-atlas-id>` (the skill asks the
operator where to store person pages each run; never hard-coded in this
skill).

## OKF type pin

- **OKF type:** `person`, declared by this package's Atlas overlay
  (`contributions/atlas-people/SCHEMA.overlay.json`; mount it with the
  EXTERNAL `atlas` path `schema`, see `SKILL.md`). New person pages use
  `type: person`.
- **Contract marker:** frontmatter `person_contract: v1` (required on every
  person page)
- **Stable id:** `person_id` (Atlas-owned slug; required). Never CNContact id.
  Never Notes title.

### Legacy pages (v0.1.2)

Pages written by v0.1.2 use `type: document` with `person_contract: v1`.
They stay valid. Identify person pages by `person_contract: v1`, not by
`type`: query recognises both `type: person` and `type: document` person
pages. When remember updates a legacy page, it may set `type: person` only
on an Atlas where the overlay is mounted; otherwise it leaves `type` as it
is. New person pages always use `type: person`.

### Who enforces which keys

With the overlay mounted, Atlas compile checks 8 required keys on
`type: person` pages (`type`, `title`, `created`, `updated`, `sensitivity`,
`person_contract`, `person_id`, `names`) and reports a missing one as a
`page_contract` warning. Atlas allows at most 8 required keys per type, so
`origin` and `aliases` are only recommended there. The skill enforces every
key under **Required frontmatter** below, including `origin` and `aliases`,
on every person page, whether or not the overlay is mounted.

## Required frontmatter

```yaml
type: person            # legacy v0.1.2 pages: document
title: "<primary display name>"
created: "YYYY-MM-DD"
updated: "YYYY-MM-DD"
origin: agent | user | derived
sensitivity: restricted
person_contract: v1
person_id: "<atlas-owned-slug>"
names:
  - "<primary>"
aliases: []
```

`sensitivity: restricted` is the default for person pages.

## Recommended body sections

1. **Bio** — short paragraph.
2. **History** — timeline bullets OK.
3. **Notes excerpts** — list of excerpts with source pointers (see below).
4. **Sources** — durable pointers out to Notes / LinkedIn / manual.
5. **Relationships** — mirrored in prose only when helpful; authoritative
   edges live in `relates_to`.

## Source pointers

```yaml
sources:
  - kind: apple-notes   # apple-notes | linkedin | manual
    id: "<note-id>"     # Notes id required for apple-notes; never title alone
    folder_id: "<folder-id>"  # optional but preferred
    url: null           # optional
    captured_at: "YYYY-MM-DD"
```

Notes excerpts in body or frontmatter:

```yaml
notes_excerpts:
  - excerpt: "<redacted excerpt>"
    source_note_id: "<note-id>"
    source_folder_id: "<folder-id>"
    captured_at: "YYYY-MM-DD"
```

## Relationship vocabulary (closed set + escape)

Use `relates_to` edges to other person pages (`path` relative inside the
target Atlas). Closed kinds:

| kind | Meaning |
| --- | --- |
| `knows` | Acquaintance / general connection |
| `reports_to` | Org reporting line |
| `family` | Family relation |
| `collaborates_with` | Working partnership |
| `introduced_by` | Introduction provenance |
| `related` | Escape hatch when none of the above fit |

Edges are first-class on person pages (optionally reciprocal). Do not invent
a second graph store.

Example:

```yaml
relates_to:
  - path: people/<other-person_id>.md
    kind: collaborates_with
```

## Forbidden content

- Passwords, SSN-class identifiers, payment-card numbers
- 1Password item titles, vault names, or ids (say only that 1Password is the
  vault when credentials are needed)
- Using CNContact id or Notes title as `person_id`

## Identity match rules (import / remember)

1. Prefer hard identifiers when present: email, phone, profile slug.
2. **Never** auto-merge on name alone.
3. Single-token names stay unmerged.
4. Ambiguous pairs → review queue for the operator; do not guess.
