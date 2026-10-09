# Person page schema (normative contract)

Runtime people store: the operator-supplied `<people-atlas-id>` (Enter card
or install config; never hard-coded in this skill).

## OKF type pin

The people store's SCHEMA typically ships recommended types
`experience`, `decision`, `work`, `document`, `protostar`, `lesson`,
`recipe` — **no** native `person` type. v0 pin:

- **OKF type:** `document`
- **Contract marker:** frontmatter `person_contract: v1` (required on every
  person page)
- **Stable id:** `person_id` (Atlas-owned slug; required). Never CNContact id.
  Never Notes title.

A later SCHEMA overlay that introduces a first-class `person` type is a new
design; do not invent overlays in v0.

## Required frontmatter

```yaml
type: document
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
people store). Closed kinds:

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
- Writing these pages into any non-people Atlas (for example the operator's
  personal or work Atlas, or another agent's Atlas)

## Identity match rules (import / remember)

1. Prefer hard identifiers when present: email, phone, profile slug.
2. **Never** auto-merge on name alone.
3. Single-token names stay unmerged.
4. Ambiguous pairs → review queue for the operator; do not guess.
