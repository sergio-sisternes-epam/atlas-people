# Path: remember

Load after the `atlas-people` Enter card with `path: remember`.

## When

Persist or update a person page, bio/history/excerpts, or a typed
relationship edge on the operator-owned people Atlas.

## Inputs

- Person fields (`person_id` or enough to allocate one) and/or
- Typed edge (`knows` | `reports_to` | `family` | `collaborates_with` |
  `introduced_by` | `related`) plus evidence
- Optional Notes / manual source pointers (id-safe)

## Procedure

1. Confirm Enter card: `atlas_id` is the operator-supplied
   `<people-atlas-id>`, `push_remote` is filled, `atlas_target: confirmed`,
   and `memory_sync` / `compile_push` are filled. Missing binding → **stop**
   (`incomplete: missing people store binding`).
2. Reject secret-class content (passwords, SSN-class). Redact or **stop**.
3. **Dry-run gate (`memory_sync: off`):** after redaction and **before**
   identity resolution or any store mutation, emit a read-only preview of
   the would-be person page / edge / review-queue entry. **Do not** resolve
   identity in a way that writes, **do not** update pages or edges, **do
   not** open review-queue entries, and **do not** invoke Atlas remember /
   compile / commit / push. Stop with receipt `memory_sync: off`.
4. Load EXTERNAL **`atlas`** path `mount`. If the live store is missing →
   **stop** with deferral `awaiting store provision`. Do not invent a
   tip.
5. Resolve identity (only when `memory_sync: on`):
   - Existing `person_id` → update that page.
   - Hard id match (email/phone/profile slug) to exactly one page → update.
   - Name-only or single-token / ambiguous → **do not auto-merge**; open or
     append to the review queue and ask the operator.
6. Allocate `person_id` when creating: Atlas-owned kebab slug from primary
   name + disambiguator if needed. Never use CNContact id or Notes title.
7. Write/update a `type: document` page with `person_contract: v1` per
   `references/person-page-schema.md`. Set `sensitivity: restricted`.
8. Add `relates_to` edges with the closed vocabulary (+ `related` escape).
   Optionally write the reciprocal edge on the other person page.
9. Source pointers: for Apple Notes use **note id** (and folder id when
   known). Title-only → **stop**.
10. Load EXTERNAL **`atlas`** path `remember` and follow compile rules.
11. When `compile_push: on`: EXTERNAL **`atlas-compile-commit-push`** to
    the operator-supplied `<push-remote>` only. When `compile_push: off`:
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
- Wrong Atlas (any non-people Atlas — the operator's personal or work Atlas,
  another agent's Atlas — or the Autogenesis subject)
- Missing or unconfirmed operator store binding
- Store not provisioned
