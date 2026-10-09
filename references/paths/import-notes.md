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
| I8 | Compile + push | Green compile; EXTERNAL ccp only when `compile_push: on` and live |

Reload this checklist before list, before read, and before Atlas writes.

## Procedure

1. Confirm the target: before the first write, ask the operator which Atlas
   the person pages should be stored in, offering any known or bound Atlas
   and allowing any other. Proceed only when `path: import-notes`,
   `import_scope` is not `none`, `atlas_id` is the operator-confirmed
   `<target-atlas-id>`, `push_remote` is filled, `atlas_target: confirmed`,
   and `memory_sync` / `compile_push` are filled. No confirmation → **stop**
   (`incomplete: atlas target not confirmed`). The skill never refuses a
   target on policy grounds; for a shared, work/project, or public target
   add a non-blocking visibility note.
2. If `import_scope` is missing / `none` / "whole library" without named
   folders → **stop**. Refuse unbounded library export.
3. Confirm Mac + Automation approval via EXTERNAL **`apple-notes`**
   prerequisites. Load that skill and follow it exactly (S7 bridge).
4. Emit the import plan memento (above); require operator confirm (I4).
5. Within scope only: EXTERNAL apple-notes **list/search** (cap); collect
   note **id** + title + folder. Never dump bodies in logs.
6. For each approved note: **read by note id**. On locked/unreadable:
   increment skip count; do not invent a body.
7. Extract candidate people + claims + excerpts. Redact secret-class
   strings before any Atlas write **or** preview.
8. **Dry-run gate (`memory_sync: off`):** after redaction, return a
   read-only preview (candidates, proposed merges, skips, review-queue
   candidates). **Do not** write person pages, review-queue entries, or
   other store mutations; **do not** compile, commit, or push. Emit the
   import receipt with `memory_sync: off` and stop.
9. Match against existing people pages (only when `memory_sync: on`):
   - Hard identifiers only for auto-merge.
   - Never auto-merge on name alone; single-token names stay unmerged.
   - Ambiguous pairs → review queue (human checkpoint). Do not guess.
10. Write/update person pages on the confirmed target Atlas only, with
    source pointers `{kind: apple-notes, id: <note-id>, folder_id?, captured_at}`.
    Follow `references/person-page-schema.md` (new pages `type: person`;
    legacy `type: document` pages handled as in path `remember`) and path
    `remember` compile rules via EXTERNAL **`atlas`**. A confirmed target does **not**
    override `memory_sync: off` (already gated in step 8).
11. If the live store is not provisioned → **stop** writes with deferral
    `awaiting store provision`. Keep the extraction/review receipt
    locally in the turn report only — do not invent a tip.
12. When `compile_push: on` and the live store is reachable: compile green;
    EXTERNAL **`atlas-compile-commit-push`** to the operator-confirmed
    `<push-remote>`. When `compile_push: off`: **do not** compile for
    publication, commit, or push — leave local preview/write state as the
    receipt describes and stop.
13. Emit import receipt: notes read, persons created/updated (or previewed),
    skips, review-queue size, tip SHA (or deferral / dry-run reason).
14. **Stop.** No watcher. Continuous sync needs a new approved design.

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
- Store not provisioned (awaiting store provision)
- Continuous-sync requests → refuse; point to future design
