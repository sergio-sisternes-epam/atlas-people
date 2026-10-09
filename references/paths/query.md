# Path: query

Load after the `atlas-people` Enter card with `path: query`.

## When

Look up who someone is, how they relate, aliases, bios, history, or what was
noted about them on the operator-owned people Atlas.

## Inputs

- Name, alias, `person_id`, or a relationship question
- Optional: constrain to a known `person_id`

## Procedure

1. Confirm Enter card: `atlas_id` is the operator-supplied
   `<people-atlas-id>` (Enter card or install config). Missing → explain the
   contract only and **stop** before any store access.
2. Load EXTERNAL **`atlas`** path `mount` (or `resolve`) for that store.
   - If the store is not reachable → explain the contract and report
     deferral `awaiting store provision`. Do not invent pages.
3. Load EXTERNAL **`atlas`** path `recall` / query tooling as appropriate.
   Search by `person_id`, names, aliases, and `relates_to` edges.
4. Prefer pages with `person_contract: v1`. Ignore council-memory pages on
   other Atlases — never mount any non-people Atlas (such as the operator's
   personal or work Atlas) for this path.
5. Synthesise a short answer with:
   - Primary name + aliases
   - Bio / history highlights
   - Typed relationship edges (kind + other person)
   - Source pointers (Notes id, not title) when present
6. On ambiguous person matches, list candidates and **stop** — do not guess.

## Outputs

- Synthesised answer + page paths + source pointers
- Or explicit incomplete: store unmounted / ambiguous person / awaiting
  store provision

## Blockers

- Store unmounted or not provisioned
- Ambiguous person without operator disambiguation
- Request that would require writing any non-people Atlas
