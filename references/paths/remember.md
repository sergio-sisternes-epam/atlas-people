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
   `push_remote` is the confirmed remote, or `none` only for a local-only
   Atlas with no remote when the operator confirmed `none` as part of the
   target confirmation (writes allowed, publishing disabled). Never default
   to `none` when the target has a remote; an unconfirmed `none` is an
   unconfirmed target.
   No confirmation → **stop** (`incomplete: atlas target not confirmed`).
   The skill never refuses a target on policy grounds; for a shared,
   work/project, or public target add a non-blocking visibility note.
2. **Public-visibility acknowledgement** (only when `memory_sync: on`).
   After the target confirmation, determine the target's visibility from
   its push remote / hosting service (SKILL.md Store target rule 5) and set
   `atlas_target_visibility`. Unknown visibility is treated like public,
   never assumed private. When it is `public` or `unknown`, ask the operator
   a separate explicit acknowledgement before the overlay mount and the
   first write, using exactly this text:

   ```text
   Person pages will be publicly readable and can't be fully removed (history and forks keep them). Continue?
   ```

   Only an explicit yes sets `atlas_target_visibility: public-acknowledged`.
   `atlas_target: confirmed` never counts as this acknowledgement. Declined
   or unanswered → **stop** with no write
   (`incomplete: public target not acknowledged`); the target itself is not
   refused (it stays confirmed; the operator may choose another target or
   acknowledge later). A changed target → determine visibility and
   acknowledge again. A private target with known visibility
   (`atlas_target_visibility: private`) needs no extra step. A confirmed
   local-only target (`push_remote: none`) is `private`. A dry run
   (`memory_sync: off`) writes nothing and needs no acknowledgement.
3. Reject secret-class content (passwords, SSN-class). Redact or **stop**.
4. Source pointers: for a notes source use the **note id** (and folder id
   when known). For a file export, use the file path relative to the export
   root as the stable id. Title-only → **stop**.
5. **Dry-run gate (`memory_sync: off`):** after redaction and **before**
   identity resolution or any store mutation, emit a read-only preview of
   the would-be person page / edge / review-queue entry. **Do not** resolve
   identity in a way that writes, **do not** update pages or edges, **do
   not** open review-queue entries, **do not** mount the Atlas overlay
   (no `schema install`, no change to `schema.d/` or `templates/`), and
   **do not** invoke Atlas remember / compile / commit / push. Stop with
   receipt `memory_sync: off` and `overlay: skipped`.
6. Load EXTERNAL **`atlas`** path `mount`. If the live store is missing →
   **stop** with deferral `awaiting store provision`. Do not invent a
   tip. Resolved store differs from the confirmed `atlas_id` → **stop**.
7. Resolve identity (only when `memory_sync: on`; read-only, no write yet):
   - Existing `person_id` → update that page.
   - Hard id match (email/phone/profile slug) to exactly one page → update.
   - Name-only or single-token / ambiguous → **do not auto-merge**; plan a
     review-queue entry and ask the operator.
8. Allocate `person_id` when creating: Atlas-owned kebab slug from primary
   name + disambiguator if needed. Never use CNContact id or Notes title.
9. **Mount the overlay (once, before the first write).** Only now, with
   `memory_sync: on` and steps 1–8 passed (including the public-visibility
   acknowledgement when the target is public or unknown), run SKILL.md
   **3. Mount the Atlas overlay** on the confirmed target, asking the
   operator first. This is the only place this path mounts: a request
   stopped by any earlier step never mounts, and the later writes in this
   run do not re-run it. Record the `overlay:` result for the receipt.
10. Write/update a person page with `person_contract: v1` per
    `references/person-page-schema.md`, or open / append the review-queue
    entry planned in step 7. Set `sensitivity: restricted`. New
    pages use `type: person`. A legacy v0.1.2 page (`type: document` +
    `person_contract: v1`) stays valid; set `type: person` on it only when
    the `atlas-people` overlay is mounted on this Atlas
    (`schema.d/atlas-people.json` present), otherwise leave its `type` as
    it is.
11. Add `relates_to` edges with the closed vocabulary (+ `related` escape).
    Optionally write the reciprocal edge on the other person page.
12. Load EXTERNAL **`atlas`** path `remember` and follow compile rules.
13. When `compile_push: on`: EXTERNAL **`atlas-compile-commit-push`** to
    the operator-confirmed `<push-remote>` only. With a confirmed
    `push_remote: none` (local-only target), publishing is disabled:
    compile green, commit locally per EXTERNAL `atlas-compile-commit-push`
    if it supports a local-only commit (otherwise compile only), skip the
    push, and record `push: skipped (push_remote: none)` on the receipt;
    this is not an incomplete exit. When `compile_push: off`:
    **do not** publish (no compile-for-push / commit / push).

## Outputs

- Pages written; compile green; tip SHA when pushed (or
  `push: skipped (push_remote: none)` for a confirmed local-only target)
- Or read-only dry-run preview when `memory_sync: off`
- Or review-queue entry for ambiguous identity
- Or deferral `awaiting store provision`

## Blockers

- Missing stable id strategy / name-only merge attempt
- Secret-class content
- Title-only Notes targeting
- Target not confirmed by the operator, changed without a fresh
  confirmation, or resolving to a different `atlas_id`
- Public or unknown-visibility target not acknowledged
  (`incomplete: public target not acknowledged`; the target itself is not
  refused)
- Store not provisioned
