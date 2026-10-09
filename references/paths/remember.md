# Path: remember

Load after the `atlas-people` Enter card with `path: remember`.

## When

Persist or update a person page, bio/history/excerpts, or a typed
relationship edge on the Atlas the operator chooses for person pages.

## Inputs

- Person fields (`person_id` or enough to allocate one) and/or
- Typed edge (`knows` | `reports_to` | `family` | `collaborates_with` |
  `introduced_by` | `related`) plus evidence
- Optional Notes / manual source pointers (id-safe)

## Procedure

1. Confirm the target: before the first write, ask the operator which Atlas
   the person pages should be stored in, offering any known or bound Atlas
   and allowing any other. Proceed only when `atlas_id` is the
   operator-confirmed `<target-atlas-id>`, `push_remote` is filled,
   `atlas_target: confirmed`, and `memory_sync` / `compile_push` are filled.
   No confirmation → **stop** (`incomplete: atlas target not confirmed`).
   The skill never refuses a target on policy grounds; for a shared,
   work/project, or public target add a non-blocking visibility note.
2. Reject secret-class content (passwords, SSN-class). Redact or **stop**.
3. **Dry-run gate (`memory_sync: off`):** after redaction and **before**
   identity resolution or any store mutation, emit a read-only preview of
   the would-be person page / edge / review-queue entry. **Do not** resolve
   identity in a way that writes, **do not** update pages or edges, **do
   not** open review-queue entries, **do not** mount the Atlas overlay
   (no `schema install`, no change to `schema.d/` or `templates/`), and
   **do not** invoke Atlas remember / compile / commit / push. Stop with
   receipt `memory_sync: off` and `overlay: skipped`.
4. Load EXTERNAL **`atlas`** path `mount`. If the live store is missing →
   **stop** with deferral `awaiting store provision`. Do not invent a
   tip. Resolved store differs from the confirmed `atlas_id` → **stop**.
   Only now (`memory_sync: on`) run SKILL.md **2. Mount the Atlas overlay**
   on the confirmed target, asking the operator first.
5. Resolve identity (only when `memory_sync: on`):
   - Existing `person_id` → update that page.
   - Hard id match (email/phone/profile slug) to exactly one page → update.
   - Name-only or single-token / ambiguous → **do not auto-merge**; open or
     append to the review queue and ask the operator.
6. Allocate `person_id` when creating: Atlas-owned kebab slug from primary
   name + disambiguator if needed. Never use CNContact id or Notes title.
7. Write/update a person page with `person_contract: v1` per
   `references/person-page-schema.md`. Set `sensitivity: restricted`. New
   pages use `type: person`. A legacy v0.1.2 page (`type: document` +
   `person_contract: v1`) stays valid; set `type: person` on it only when
   the `atlas-people` overlay is mounted on this Atlas
   (`schema.d/atlas-people.json` present), otherwise leave its `type` as
   it is.
8. Add `relates_to` edges with the closed vocabulary (+ `related` escape).
   Optionally write the reciprocal edge on the other person page.
9. Source pointers: for Apple Notes use **note id** (and folder id when
   known). Title-only → **stop**.
10. Load EXTERNAL **`atlas`** path `remember` and follow compile rules.
11. When `compile_push: on`: EXTERNAL **`atlas-compile-commit-push`** to
    the operator-confirmed `<push-remote>` only. When `compile_push: off`:
    **do not** publish (no compile-for-push / commit / push).

## Outputs

- Pages written; compile green; tip SHA when pushed
- Or read-only dry-run preview when `memory_sync: off`
- Or review-queue entry for ambiguous identity
- Or deferral `awaiting store provision`

## Blockers

- Missing stable id strategy / name-only merge attempt
- Secret-class content
- Title-only Notes targeting
- Target not confirmed by the operator, changed without a fresh
  confirmation, or resolving to a different `atlas_id`
- Store not provisioned
