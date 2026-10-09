# Path: query

Load after the `atlas-people` Enter card with `path: query`.

## When

Look up who someone is, how they relate, aliases, bios, history, or what was
noted about them on the Atlas the operator chooses for person pages.

## Inputs

- Name, alias, `person_id`, or a relationship question
- Optional: constrain to a known `person_id`

## Procedure

1. Identify the Atlas to read: the confirmed `<target-atlas-id>`, or —
   read-only — any known or bound Atlas (Enter card, install config) or any
   other Atlas the operator names. Query needs no write confirmation. None
   known → ask the operator which Atlas holds the person pages; no answer →
   explain the contract only and **stop** before any store access.
2. Load EXTERNAL **`atlas`** path `mount` (or `resolve`) for that store.
   - If the store is not reachable → explain the contract and report
     deferral `awaiting store provision`. Do not invent pages.
3. Load EXTERNAL **`atlas`** path `recall` / query tooling as appropriate.
   Search by `person_id`, names, aliases, and `relates_to` edges.
4. Identify person pages by `person_contract: v1`: both `type: person`
   pages and legacy v0.1.2 `type: document` pages count. Ignore
   council-memory pages; they belong to a separate council/decision-memory
   skill.
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
- Request that would require a write (switch to path `remember`, which asks
  for and confirms the target first)
