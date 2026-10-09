# Path: import-notes

Load after the `atlas-people` Enter card with `path: import-notes`.

## When

Supervised **one-shot** Apple Notes import into the operator-confirmed
target Atlas. Proves
person-page shape. Not continuous sync.

## Pins inherited

- Folder scope required (no whole-library default)
- Notes **id** for source pointers (title-only is a blocker)
- Skip locked / unreadable notes (count only; do not invent bodies)
- No name-only auto-merge; ambiguous → review queue
- No watcher / schedule / continuous sync in v0
- Secrets standing: redact password/SSN-class; 1Password is the vault only
- Honour Enter `memory_sync` / `compile_push` dry-run controls (below)

## Import plan memento (emit and keep live)

| # | Field | Notes |
| --- | --- | --- |
| I1 | Folder scope | One or more **folder ids** (preferred) named by operator |
| I2 | Cap | Inherit apple-notes list/search default cap (25); say when truncated |
| I3 | Mac + Automation | EXTERNAL apple-notes prerequisites satisfied |
| I4 | Confirm | Explicit operator confirm for this one-shot scope |
| I5 | Match policy | Hard ids only for auto-merge; name-only → review |
| I6 | Secrets check | No password/SSN-class into Atlas |
| I7 | Dry-run flags | `memory_sync` / `compile_push` filled; `off` skips write / publish |
| I8 | Compile + push | Green compile; EXTERNAL ccp only when `compile_push: on` and live; confirmed `push_remote: none` (local-only) → push skipped and recorded, not incomplete |
| I9 | Visibility ack | `atlas_target_visibility` is `private` or `public-acknowledged` before the overlay mount and first write |

Reload this checklist before list, before read, and before Atlas writes.

## Procedure

1. Confirm the target: before the first write, ask the operator which Atlas
   the person pages should be stored in, offering any known or bound Atlas
   and allowing any other. Proceed only when `path: import-notes`,
   `import_scope` is not `none`, `atlas_id` is the operator-confirmed
   `<target-atlas-id>`, `push_remote` is filled, `atlas_target: confirmed`,
   and `memory_sync` / `compile_push` are filled. `push_remote` is the
   confirmed remote, or `none` only for a local-only Atlas with no remote
   when the operator confirmed `none` as part of the target confirmation
   (writes allowed, publishing disabled). Never default to `none` when the
   target has a remote; an unconfirmed `none` is an unconfirmed target.
   No confirmation → **stop**
   (`incomplete: atlas target not confirmed`). The skill never refuses a
   target on policy grounds; for a shared, work/project, or public target
   add a non-blocking visibility note.
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
3. If `import_scope` is missing / `none` / "whole library" without named
   folders → **stop**. Refuse unbounded library export.
4. Confirm Mac + Automation approval via EXTERNAL **`apple-notes`**
   prerequisites. Load that skill and follow it exactly (S7 bridge).
5. Emit the import plan memento (above); require operator confirm (I4).
6. Within scope only: EXTERNAL apple-notes **list/search** (cap); collect
   note **id** + title + folder. Never dump bodies in logs.
7. For each approved note: **read by note id**. On locked/unreadable:
   increment skip count; do not invent a body.
8. Extract candidate people + claims + excerpts. Redact secret-class
   strings before any Atlas write **or** preview.
9. **Dry-run gate (`memory_sync: off`):** after redaction, return a
   read-only preview (candidates, proposed merges, skips, review-queue
   candidates). **Do not** write person pages, review-queue entries, or
   other store mutations; **do not** mount the Atlas overlay (no
   `schema install`, no change to `schema.d/` or `templates/`); **do not**
   compile, commit, or push. Emit the import receipt with
   `memory_sync: off` and `overlay: skipped`, and stop.
10. Only when `memory_sync: on`: load EXTERNAL **`atlas`** path `mount`
    for the confirmed target. If the live store is not provisioned →
    **stop** writes with deferral `awaiting store provision`. Keep the
    extraction/review receipt locally in the turn report only — do not
    invent a tip. Resolved store differs from the confirmed `atlas_id` →
    **stop**.
11. Match against existing people pages (read-only, no write yet):
    - Hard identifiers only for auto-merge.
    - Never auto-merge on name alone; single-token names stay unmerged.
    - Ambiguous pairs → planned review-queue entries (human checkpoint).
      Do not guess.
12. **Mount the overlay (once, before the first write).** Only now, with
    `memory_sync: on` and steps 1–11 passed (including the public-visibility
    acknowledgement when the target is public or unknown), run SKILL.md
    **3. Mount the Atlas overlay** on the confirmed target, asking the
    operator first. This is the only place this path mounts: a request
    stopped by any earlier step never mounts, and it runs once per import,
    not once per note. Record the `overlay:` result for the receipt.
13. Write/update person pages and the planned review-queue entries on the
    confirmed target Atlas only, with source pointers
    `{kind: apple-notes, id: <note-id>, folder_id?, captured_at}`.
    Follow `references/person-page-schema.md` (new pages `type: person`;
    legacy `type: document` pages handled as in path `remember`) and path
    `remember` compile rules via EXTERNAL **`atlas`**. A confirmed target does **not**
    override `memory_sync: off` (already gated in step 9).
14. When `compile_push: on` and the live store is reachable: compile green;
    EXTERNAL **`atlas-compile-commit-push`** to the operator-confirmed
    `<push-remote>`. With a confirmed `push_remote: none` (local-only
    target), publishing is disabled: compile green, commit locally per
    EXTERNAL `atlas-compile-commit-push` if it supports a local-only commit
    (otherwise compile only), skip the push, and record
    `push: skipped (push_remote: none)` on the receipt; this is not an
    incomplete exit. When `compile_push: off`: **do not** compile for
    publication, commit, or push — leave local preview/write state as the
    receipt describes and stop.
15. Emit import receipt: notes read, persons created/updated (or previewed),
    skips, review-queue size, `overlay:` result, tip SHA (or deferral /
    dry-run reason, or `push: skipped (push_remote: none)`).
16. **Stop.** No watcher. Continuous sync needs a new approved design.

## Outputs

- Person pages + edges + source pointers (only when `memory_sync: on`)
- Review queue for ambiguous merges (only when `memory_sync: on`)
- Import receipt (counts + tip, deferral, or dry-run preview)

## Blockers

- Locked notes (skip + count)
- Title-only targeting
- Whole-library without explicit folder scope
- Name-only merge attempts
- Target not confirmed by the operator
- Public or unknown-visibility target not acknowledged
  (`incomplete: public target not acknowledged`; the target itself is not
  refused)
- Store not provisioned (awaiting store provision)
- Continuous-sync requests → refuse; point to future design
