---
name: atlas-people
activation_card: on
description: >-
  Use when the operator needs to look up, remember, or update people and
  relationships on the operator-owned people Atlas; when importing people and
  claims once from Apple Notes; or when asking who someone is, how they relate,
  or what was noted about them. Not for council or decision memory (use a
  separate council/decision-memory skill), not for continuous Notes sync, not
  for LinkedIn ingest in v0, not for Contacts.app mutation.
---

# atlas-people

Operator-owned **people Atlas** skill. Stable people + relationships on a
dedicated runtime store; Apple Notes proves the shape once. Never nest people
pages in any non-people Atlas (for example the operator's personal or work
Atlas, or another agent's Atlas).

**Design lineage / Autogenesis subject:** work_ids `2026-10-05-people-atlas`
and `2026-10-05-people-privacy` live on **this repository's `atlas` branch**
(`github.com/sergio-sisternes-epam/atlas-people`, ref `atlas`), declared in
this package's `atlas-mesh.json`. The people store is **data**, not skill
process memory; never provision it as a skill process host.

British English. Prose uses **roles** (the operator, the provisioner, the
package maintainer), not named humans.

## Store binding (operator-supplied only)

This skill ships **no** store identity, host, checkout path, push remote, or
credential location. The operator's Enter card or the install config
supplies them for each run (same fail-closed pattern as `atlas-tasks-todoist`):

| Field | Supplied by | Placeholder in this skill |
| --- | --- | --- |
| `atlas_id` (people store id) | operator Enter card or install config | `<people-atlas-id>` |
| `atlas_root` (working checkout) | EXTERNAL `atlas` `resolve` of that id | `<atlas-root>` |
| `push_remote` (sole push target) | operator Enter card or install config | `<push-remote>` |
| Transport credentials | operator environment; never in this skill | — |

Rules:

1. Writes, imports, and compile/push require `atlas_target: confirmed` — the
   operator (or install config the operator set up) named `atlas_id` and
   `push_remote` for this run. `atlas_root` is filled from EXTERNAL `atlas`
   `resolve` of that `atlas_id` **before** the Enter card is emitted — do not
   require the operator to pre-fill `atlas_root`.
2. Missing, partial, or ambiguous binding → **stop**:
   `incomplete: missing people store binding`. Never guess, never fall back to
   a remembered value, never copy a value from another skill's docs.
3. Only placeholders appear in this package. Do not paste live hostnames,
   remotes, absolute checkout paths, SSH identity paths, or personal Atlas
   slugs into skill text, scenarios, CHANGELOG, or commit messages.

**Forbidden write-homes for people pages:** any non-people Atlas (for example
the operator's personal or work Atlas, or another agent's Atlas), and the
Autogenesis subject store (this repository's `atlas` branch, declared in
`atlas-mesh.json`). If `atlas_id` resolves to any of these roles → **stop**.

## Pins (normative)

1. **Sole runtime store** — people pages live only on the operator-bound
   people store (`<people-atlas-id>`). Never write people pages into any
   non-people Atlas, such as the operator's personal or work Atlas.
2. **Atlas-owned person_id** — primary key is owned by the people Atlas.
   CNContact / device contact ids and Notes titles are **source pointers
   only**, never the primary key.
3. **No name-only merge** — auto-merge only on Phase-1 hard identifiers
   (email / phone / profile slug) when present. Never auto-merge on name
   alone. Single-token names stay unmerged. Ambiguous pairs → review queue
   for the operator.
4. **Notes id, not title** — import and remember source pointers use Notes
   **id**. Title-only targeting is a blocker.
5. **One-shot import only** — no continuous Notes sync watcher or schedule
   in v0. Continuous sync needs a new design after this pass proves shape.
6. **LinkedIn deferred** — LinkedIn ingest is a v0 non-goal; later overlay
   must reuse the same `person_id`s.
7. **Secrets standing** — when credentials are needed, say only that
   **1Password is the vault**. Do not name item titles, vault names, or ids
   in skills or Atlas process pages. Do not copy passwords or SSN-class
   values into Atlas. Richer excerpts OK otherwise.
8. **Compile green + push** via EXTERNAL `atlas-compile-commit-push` to the
   operator-supplied `push_remote` only. No dual-push to any second remote.
9. **The provisioner provisions the empty store only** — the operator owns
   its content. Do not invent a fake store tip when the live store is
   missing.
10. **Operator store binding** — store id, checkout, and push remote come from
    the operator Enter card or install config only; unconfirmed → stop.

## Activation card

`activation_card: on`. Before any Atlas write, compile/push, or Notes import,
emit this Enter card with **every field filled**. Missing required field →
**stop**.

```text
skill: atlas-people
skill_path: <resolved install / package root>
mode: run
path: query | remember | import-notes
intent: <one line>
atlas_id: <people-atlas-id>          # operator-supplied
atlas_root: <atlas-root>             # filled by atlas resolve BEFORE emit
push_remote: <push-remote>           # operator-supplied
atlas_target: confirmed | unknown
memory_sync: on | off
compile_push: on | off
import_scope: <folder id(s) or none>
invocation: actor-session
```

### Defaults when omitted (still must appear filled on the emitted card)

- Omitted `memory_sync` / `compile_push` → both **`on`** for remember and
  import-notes. `off` only with an explicit operator dry-run override.
- Omitted `import_scope` → **`none`**. import-notes with `none` → **stop**
  (folder scope required).
- Omitted `path` → infer from intent; ambiguous → **stop**.
- Omitted `atlas_id` / `push_remote` → **no default**. Take them from the
  install config the operator set up; if absent → `atlas_target: unknown` →
  **stop** for any write. Query may explain the contract only.

### Fail closed

- Missing or partial Enter card → **stop**.
- `atlas_target` not `confirmed` for remember / import-notes / compile-push
  → **stop**.
- `atlas_id` naming any non-people Atlas (the operator's personal or work
  Atlas, another agent's Atlas) or the Autogenesis subject for people pages
  → **stop**.
- import-notes without explicit folder scope → **stop**.
- Title-only Notes targeting → **stop**.
- Name-only auto-merge → **stop**; queue review instead.
- Secret-class content (passwords, SSN-class) in remember/import payload →
  **stop** / redact; do not write.
- Exit incomplete if remember/import with `memory_sync: on` but no Atlas
  write, or if compile fails, or if `compile_push: on` and push skipped
  while the live store is reachable.
- If the live people store is not yet provisioned, do not invent a tip;
  record deferral **awaiting store provision** (the provisioner has not yet
  provisioned the empty store) and still complete package/docs work.

## Composition (substrate)

| Box | Mode | Rationale |
| --- | --- | --- |
| Query / remember / import-notes procedures | **LOCAL** `references/paths/*.md` | Progressive disclosure; path-segregated |
| Person page schema + relationship vocabulary | **LOCAL** `references/person-page-schema.md` | Unique to this skill |
| Atlas mount / query / remember / compile | **EXTERNAL** (`atlas`) | Claim-bearing store authority |
| Compile → commit → push | **EXTERNAL** (`atlas-compile-commit-push`) | Standing hygiene to the operator-supplied remote |
| Apple Notes read bridge | **EXTERNAL** (`apple-notes`) | S7 deterministic Mac bridge; id-safe |
| Council / decision memory | **Not selected** | Different write-homes; a separate council/decision-memory skill owns it |
| LinkedIn ingest | **Not selected** (v0) | After Notes proves shape |
| Autogenesis invocation protocol on this skill | **Not selected** | No full fusion by default |

Load EXTERNAL skills by installed pin name, read each `SKILL.md`, and follow
it — never a cwd-relative reinvented copy.

## Procedure

### 0. Enter

1. Resolve `path`: `query` | `remember` | `import-notes`.
2. Take `atlas_id` and `push_remote` from the operator Enter card or install
   config. Missing → **stop** (`incomplete: missing people store binding`).
3. **Resolve `atlas_root` before the card:** load EXTERNAL **`atlas`** path
   `mount` / `resolve` for the operator-named `<people-atlas-id>` and set
   `atlas_root` only from that result. Do **not** require `atlas_root` to be
   pre-filled by the operator. If mount / `git ls-remote` fails because the
   empty store is not yet provisioned → **stop** with deferral reason
   `awaiting store provision` (query may still explain the contract;
   remember/import that need a live write must defer). Wrong Atlas / foreign
   store → **stop**.
4. Emit the activation card with **every field filled**, including the
   resolved `atlas_root`. Missing resolve → incomplete card → **stop**.
5. Load the matching LOCAL path module under `references/paths/` and follow it.

### 1. Mount (all paths that need the store)

1. Mount/resolve already ran in **0. Enter** step 3. Reuse the resolved
   `atlas_root`; do not re-guess a checkout path.
2. If a later path step rediscovers that the live store is unreachable →
   **stop** with deferral `awaiting store provision`. Do not invent a fake
   tip.
3. Wrong Atlas / foreign store → **stop**.

### 2. Path dispatch

| Path | Load | Summary |
| --- | --- | --- |
| query | `references/paths/query.md` | Look up people / edges; synthesise with source pointers |
| remember | `references/paths/remember.md` | Write/update person pages and typed edges; compile; push |
| import-notes | `references/paths/import-notes.md` | One-shot Notes import; id-safe; review queue; no watcher |

Person page contract: `references/person-page-schema.md`.

### 3. Compile + push (Pins 8–10)

After Atlas writes, when `compile_push: on` and the live store is reachable:

1. Run `atlas compile` green on the people store root
   (`python3 <atlas-skill>/scripts/atlas.py compile --root <atlas-root>`).
2. Load EXTERNAL **`atlas-compile-commit-push`** and follow it exactly.
3. Push branch `atlas` to `<push-remote>` only.
4. **Forbidden:** dual-push to any second remote; `GIT_LFS_SKIP_PUSH` on
   ordinary pushes; writing people pages to any non-people Atlas.

Exit incomplete if compile fails or push is skipped while `compile_push: on`
and the store is reachable. If the store is not provisioned, record the
deferral and do not claim a tip.

## Exit checklist

- [ ] Activation card emitted (every field filled; `atlas_target: confirmed` for writes)
- [ ] Right Atlas chosen (operator-bound people store only for people pages)
- [ ] Path module followed; person contract observed
- [ ] No nest into any non-people Atlas; no name-only merge
- [ ] Notes id required; no title-only Notes targeting
- [ ] No secret-class content; 1Password named only as the vault
- [ ] Compile green + push to `<push-remote>` when writes landed and store is live (EXTERNAL ccp)
- [ ] Or explicit deferral `awaiting store provision` when store missing
- [ ] No continuous sync; no LinkedIn in v0
- [ ] No live host, remote, checkout path, or credential path echoed into skill text

## Non-goals

- Continuous Apple Notes sync
- LinkedIn (or other) ingest in v0
- Nesting people pages in any non-people Atlas (for example the operator's
  personal or work Atlas, or another agent's Atlas)
- Treating the people store as skill process memory (it is data)
- Dual-push to retired local bare repositories or any second remote
- Shipping a default store id, host, checkout path, push remote, or SSH
  identity in this package
- Full Autogenesis runtime fusion (unless a later approved plan selects it)
- Replacing Contacts.app / CNContact as a system of record
- Naming 1Password item titles, vault names, or ids in skills or Atlas
  process pages

## Maintaining this package

`SKILL.md` (root) is canonical. `.apm/skills/atlas-people/SKILL.md` is a
byte-identical hybrid mirror for APM targets: edit the root file, then copy
it over the mirror in the **same commit**. The `apm-mirror-lockstep` smoke in
`references/scenarios/people-adversarial-v2.yaml` fails on any drift.

## Install

Install a tagged release (tag `v<version>`), for example:

```bash
apm install sergio-sisternes-epam/atlas-people#v0.1.2
```

The install config is where the operator records `atlas_id` and
`push_remote` for this skill; the package itself carries placeholders only.
