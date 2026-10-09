---
name: atlas-people
activation_card: on
description: >-
  Use when the operator needs to look up, remember, or update people and
  relationships stored as person pages on the Atlas the operator chooses and
  confirms; when importing people and claims once from any notes app or
  export (e.g. Apple Notes, Obsidian, a Markdown export); or when they need
  to recall who someone is, how they relate, or what was noted about them. Not for
  council or decision memory (use a separate council/decision-memory skill),
  not for continuous notes sync, not for LinkedIn ingest in v0, not
  for Contacts.app mutation.
---

# atlas-people

People skill for Atlas. Stable people + relationships stored as person
pages on **the Atlas the operator chooses and confirms** for each run; a
one-shot notes import proves the shape once. The skill asks where person
pages should be stored; it does not forbid or force any particular Atlas.

**Design lineage / Autogenesis subject:** work_ids `2026-10-05-people-atlas`
and `2026-10-05-people-privacy` live on **this repository's `atlas` branch**
(`github.com/sergio-sisternes-epam/atlas-people`, ref `atlas`), declared in
this package's `atlas-mesh.json`. Person pages are **data**, not skill
process memory, whichever Atlas the operator stores them in.

British English. Prose uses **roles** (the operator, the provisioner, the
package maintainer), not named humans.

## Store target (operator-confirmed per run)

This skill ships **no** store identity, host, checkout path, push remote, or
credential location. The operator chooses and confirms the target Atlas for
person pages on each run:

| Field | Supplied by | Placeholder in this skill |
| --- | --- | --- |
| `atlas_id` (target Atlas id) | operator confirmation (options from the Enter card, install config, EXTERNAL `atlas` listing, or any other Atlas the operator names) | `<target-atlas-id>` |
| `atlas_root` (working checkout) | EXTERNAL `atlas` `resolve` of that id | `<atlas-root>` |
| `push_remote` (only push target for the run; `none` for a confirmed local-only target) | operator, confirmed together with `atlas_id` | `<push-remote>` |
| Transport credentials | operator environment; never in this skill | — |

Rules (one target-neutral rule; the operator decides where person pages
live):

1. **Ask where to store person pages.** Before the first write (remember,
   import-notes, or compile/push) in a run, ask the operator which Atlas the
   person pages should be stored in. Offer any known or bound Atlas as an
   option (for example one named on the Enter card or in the install config,
   or Atlases the EXTERNAL `atlas` skill can list or resolve) and also allow
   any other Atlas the operator names.
2. **Write only after explicit per-target confirmation.**
   `atlas_target: confirmed` means the operator explicitly confirmed this
   `atlas_id` (and its `push_remote`) as the target for this run. It is a
   per-target confirmation, not an allow-list. An install-config or
   Enter-card value is a suggested default, not an implicit confirmation:
   still ask the operator to confirm it before the first write. If the
   target changes, ask and confirm again. For a local-only Atlas with no
   remote, the operator confirms `push_remote: none` as part of this target
   confirmation; that target is valid for writes with publishing disabled
   (see **4. Compile + push**). Never default to `push_remote: none` when
   the target has a remote.
3. **Never refuse a target on policy grounds.** The skill never refuses a
   target on policy grounds: a work, project, personal, shared, or another
   agent's Atlas is accepted once the operator confirms it.
4. **Privacy notes are advice only (non-blocking).** When the chosen target
   is shared, a work or project Atlas, or a public repository branch,
   mention that person pages will be visible to that Atlas's readers and let
   the operator decide. This advice never blocks a write; the one consent
   gate for public or unknown-visibility targets is the acknowledgement in
   rule 5.
5. **Public-visibility acknowledgement (separate consent gate).** After the
   operator confirms the target, determine its visibility and record it on
   the activation card as `atlas_target_visibility`:
   - `private` — visibility known to be private (the hosting service
     reports a private repository, or a local-only Atlas with no remote is
     private, so a confirmed local-only target with `push_remote: none` is
     `private`). A private target with known visibility
     (`atlas_target_visibility: private`) needs no extra step.
   - `public` — the hosting service reports a public repository; not yet
     acknowledged → no write.
   - `unknown` — the host cannot be queried, the query fails, or the answer
     is ambiguous. Treat `unknown` like `public`; never assume private. Not
     yet acknowledged → no write.
   - `public-acknowledged` — the operator answered yes to the
     acknowledgement below for this target.

   Determine visibility from the target's push remote / hosting service
   when available: for example the hosting API's repository visibility
   field, such as `gh repo view <owner>/<repo> --json visibility` for
   GitHub, or the equivalent for other hosts. Do not guess from the
   repository name. Never store credentials or hostnames in package text
   (placeholders only).

   When `atlas_target_visibility` is `public` or `unknown`, ask the operator
   a separate explicit acknowledgement before the first write in the run,
   and before the overlay mount (which also writes to the store), using
   exactly this text:

   ```text
   Person pages will be publicly readable and can't be fully removed (history and forks keep them). Continue?
   ```

   Only an explicit yes sets `atlas_target_visibility: public-acknowledged`;
   writes on a public or unknown-visibility target require
   `atlas_target_visibility: public-acknowledged`. A plain target
   confirmation (`atlas_target: confirmed`) never counts as this
   acknowledgement: it is a separate question and answer, asked after the
   target confirmation. If the target changes, determine visibility and ask
   for the acknowledgement again. Operator declines (or does not answer) →
   **stop** with no write (`incomplete: public target not acknowledged`).
   The target itself is not refused: it stays confirmed, and the operator
   may choose another target or acknowledge later. Recall (read-only) and
   dry runs (`memory_sync: off`) write nothing and need no acknowledgement.
   This gate never refuses a target on policy grounds.
6. **Fail closed on missing information.** No confirmed target →
   `atlas_target: unknown` → **stop** before writing:
   `incomplete: atlas target not confirmed`. Recall needs no write
   confirmation: it reads the selected Atlas (a known or operator-named
   Atlas) with `atlas_target: unknown` and stays read-only; no Atlas
   selected at all → recall explains the contract only. If `atlas resolve`
   of the selected Atlas fails, or resolves to something other than the
   selected `atlas_id` → **stop**. Never guess, never fall back to a
   remembered value, never copy a value from another skill's docs.
7. `atlas_root` is filled from EXTERNAL `atlas` `resolve` of the selected
   `atlas_id` (the confirmed target for remember, import-notes, and
   compile/push; the known or operator-named Atlas for recall) **before**
   the Enter card is emitted — do not require the operator to pre-fill
   `atlas_root`.
8. Only placeholders appear in this package. Do not paste live hostnames,
   remotes, absolute checkout paths, SSH identity paths, or personal Atlas
   slugs into skill text, scenarios, CHANGELOG, or commit messages.

## Pins (normative)

1. **Operator-confirmed target** — person pages are written only to the
   Atlas the operator explicitly confirmed for this run
   (`<target-atlas-id>`). The skill asks where to store them and never
   refuses a target on policy grounds.
2. **Atlas-owned person_id** — primary key is owned by the target Atlas.
   CNContact / device contact ids and Notes titles are **source pointers
   only**, never the primary key.
3. **No name-only merge** — auto-merge only on Phase-1 hard identifiers
   (email / phone / profile slug) when present. Never auto-merge on name
   alone. Single-token names stay unmerged. Ambiguous pairs → review queue
   for the operator.
4. **Notes id, not title** — import and remember source pointers use a
   stable note **id** (or a file path relative to the export root).
   **Title-only targeting is a blocker.**
5. **One-shot import only** — no continuous notes sync watcher or schedule
   in v0. Continuous sync needs a new design after this pass proves shape.
6. **LinkedIn deferred** — LinkedIn ingest is a v0 non-goal; later overlay
   must reuse the same `person_id`s.
7. **Secrets standing** — credentials live in the operator's password
   manager or secret store (e.g. 1Password). When credentials are needed,
   say only that they are in the password manager or secret store; never
   name item titles, vault or collection names, or ids. Do not copy passwords
   or SSN-class values into Atlas. Richer excerpts OK otherwise.
8. **Compile green + push** via EXTERNAL `atlas-compile-commit-push` to the
   operator-confirmed `push_remote` only. No dual-push to any second remote.
   A confirmed `push_remote: none` (local-only target) disables publishing:
   compile still runs and the push step is skipped and recorded.
9. **The provisioner provisions the empty store only** — when the confirmed
   target does not exist yet, the provisioner provisions it empty and the
   operator owns its content. Do not invent a fake store tip when the live
   store is missing.
10. **Operator target confirmation** — store id and push remote are confirmed
    by the operator for this run (Enter card or install config values are
    options, not confirmations); checkout comes from `atlas resolve`;
    unconfirmed → stop before writing.

## Activation card

`activation_card: on`. Target resolution is the only operation permitted
before the card: EXTERNAL `atlas` `resolve` / `mount` of the selected Atlas,
a `git ls-remote` reachability check, and the visibility lookup
(**0. Enter** steps 2–3). It reads no person-page content. Emit this Enter
card with **every field filled** before any person-page content is read or
written, and before any compile/push, overlay mount, or Notes import.
Missing required field → **stop**.

```text
skill: atlas-people
skill_path: <resolved install / package root>
mode: run
path: recall | remember | import-notes
intent: <one line>
atlas_id: <target-atlas-id>          # selected Atlas: confirmed target (writes) or known / operator-named Atlas (recall)
atlas_root: <atlas-root>             # filled by atlas resolve of atlas_id BEFORE emit
push_remote: <push-remote> | none    # confirmed with the target; none = read-only recall, or a confirmed local-only target (writes allowed, publishing disabled)
atlas_target: confirmed | unknown    # confirmed = operator confirmed this atlas_id for this run; required for remember / import-notes / compile-push only
atlas_target_visibility: private | public | unknown | public-acknowledged   # public / unknown → no write until the separate acknowledgement sets public-acknowledged; recall may stay unknown
memory_sync: on | off
compile_push: on | off
import_scope: <folder/collection id(s) or none>
invocation: actor-session
```

### Defaults when omitted (still must appear filled on the emitted card)

- Omitted `memory_sync` / `compile_push` → both **`on`** for remember and
  import-notes. `off` only with an explicit operator dry-run override. For
  recall both are **`off`** (read-only).
- Omitted `import_scope` → **`none`**. import-notes with `none` → **stop**
  (folder or collection scope required).
- Omitted `path` → infer from intent; ambiguous → **stop**.
- Omitted `atlas_id` / `push_remote` → **no default**. Ask the operator
  which Atlas the person pages should be stored in, offering any known or
  bound Atlas (install config, Enter card, EXTERNAL `atlas` listing) and
  allowing any other. An install-config or Enter-card value is a suggested
  default, not an implicit confirmation. No explicit confirmation →
  `atlas_target: unknown` → **stop** for any write. Recall may still run
  read-only against a known or operator-named Atlas with
  `atlas_target: unknown` and `push_remote: none`.
- `push_remote: none` on a write run (remember / import-notes) is valid
  only for a local-only Atlas with no remote, and only when the operator
  confirmed `none` as part of the target confirmation. Never default to
  `none` when the target has a remote; offer that remote instead. With a
  confirmed `push_remote: none`, publishing is disabled: compile still
  runs, the push step is skipped and recorded (not an incomplete exit), and
  `atlas_target_visibility` is `private`.
- Omitted `atlas_target_visibility` → **`unknown`** (never `private`) until
  visibility is determined from the confirmed target's push remote /
  hosting service (Store target rule 5).

### Fail closed

- Missing or partial Enter card → **stop**.
- `atlas_target` not `confirmed` for remember / import-notes / compile-push
  → **stop** (`incomplete: atlas target not confirmed`).
- Target changed since the operator confirmed it → ask and confirm again
  before the next write; no fresh confirmation → **stop**.
- `atlas_target_visibility` is `public` or `unknown` for remember /
  import-notes / compile-push → ask the separate public-visibility
  acknowledgement (exact text in Store target rule 5) before the overlay
  mount and the first write. Declined or unanswered → **stop** with no
  write (`incomplete: public target not acknowledged`); the target itself
  is not refused. `atlas_target: confirmed` never counts as this
  acknowledgement. A changed target → determine visibility and acknowledge
  again.
- Recall with `atlas_target: unknown` → read-only: no write, no overlay
  mount, no compile/push. A recall that would need a write → switch to
  path `remember`, which asks for and confirms the target first.
- `atlas resolve` of the selected Atlas (the confirmed target for writes;
  the known or operator-named Atlas for recall) fails, or resolves to
  something other than the selected `atlas_id` → **stop**.
- Never stop because of *which* Atlas the operator chose: a work, project,
  personal, shared, or another agent's Atlas is accepted once confirmed.
  Privacy notes about visibility are advice only.
- import-notes without explicit folder or collection scope → **stop**.
- Title-only Notes targeting → **stop**.
- Name-only auto-merge → **stop**; queue review instead.
- Secret-class content (passwords, SSN-class) in remember/import payload →
  **stop** / redact; do not write.
- `push_remote: none` on a write run that the operator did not confirm as
  part of the target confirmation, or on a target that has a remote →
  treat the target as unconfirmed → **stop**
  (`incomplete: atlas target not confirmed`).
- Exit incomplete if remember/import with `memory_sync: on` but no Atlas
  write, or if compile fails, or if `compile_push: on` and push skipped
  while the live store is reachable. Exception: with a confirmed
  `push_remote: none` (local-only target) the push step is skipped and
  recorded, not an incomplete exit.
- If the confirmed target store is not yet provisioned, do not invent a tip;
  record deferral **awaiting store provision** (the provisioner has not yet
  provisioned the empty store) and still complete package/docs work.

## Composition (substrate)

| Box | Mode | Rationale |
| --- | --- | --- |
| Recall / remember / import-notes procedures | **LOCAL** `references/paths/*.md` | Progressive disclosure; path-segregated |
| Person page schema + relationship vocabulary | **LOCAL** `references/person-page-schema.md` | Unique to this skill |
| Atlas overlay (type `person`) | **LOCAL** `contributions/atlas-people/` | Lets Atlas compile check person-page frontmatter |
| Atlas mount / recall / remember / compile | **EXTERNAL** (`atlas`) | Claim-bearing store authority |
| Overlay mount / upgrade / remove | **EXTERNAL** (`atlas` path `schema`) | CLI is the only writer of `schema.d/`; mounted only on the confirmed target |
| Compile → commit → push | **EXTERNAL** (`atlas-compile-commit-push`) | Standing hygiene to the operator-confirmed remote |
| Council / decision memory | **Not selected** | Out of scope; a separate council/decision-memory skill owns it |
| LinkedIn ingest | **Not selected** (v0) | After a notes import proves shape |
| Autogenesis invocation protocol on this skill | **Not selected** | No full fusion by default |

Load EXTERNAL skills by installed pin name, read each `SKILL.md`, and follow
it — never a cwd-relative reinvented copy.

## Procedure

### 0. Enter

1. Resolve `path`: `recall` | `remember` | `import-notes`.
2. **Ask for the target before the first write.** For remember,
   import-notes, or any compile/push, ask the operator which Atlas the
   person pages should be stored in. Offer any known or bound Atlas (for
   example one named on the Enter card or in the install config, or
   Atlases the EXTERNAL `atlas` skill can list or resolve) and allow any
   other Atlas the operator names. Set `atlas_id` and `push_remote` from the
   operator's answer and `atlas_target: confirmed` only after the operator
   explicitly confirms that specific target. For a local-only Atlas with no
   remote, the operator confirms `push_remote: none` as part of that
   confirmation (writes allowed, publishing disabled; never default to
   `none` when the target has a remote). If the target is shared, a
   work or project Atlas, or a public repository branch, add a non-blocking
   note that person pages will be visible to its readers. No confirmation →
   `atlas_target: unknown` → **stop** before writing
   (`incomplete: atlas target not confirmed`). Once the target is
   confirmed, determine its visibility and set `atlas_target_visibility`
   (Store target rule 5). When it is `public` or `unknown`, ask the
   separate public-visibility acknowledgement (exact text in rule 5) after
   the target confirmation and before the overlay mount and the first
   write; only an explicit yes sets
   `atlas_target_visibility: public-acknowledged`, and
   `atlas_target: confirmed` never counts as this acknowledgement.
   Declined → **stop** with no write
   (`incomplete: public target not acknowledged`); the target itself is not
   refused. A private target with known visibility needs no extra step.
   For recall, no write confirmation or acknowledgement is needed: select a known or operator-named Atlas to read,
   leave `atlas_target: unknown` (or `confirmed` if the operator already
   confirmed it this run), set `push_remote: none` when none is confirmed,
   and stay read-only. No Atlas selected → recall explains the contract
   only and **stop** before any store access.
3. **Resolve `atlas_root` before the card:** load EXTERNAL **`atlas`** path
   `mount` / `resolve` for the selected `<target-atlas-id>` (the confirmed
   target for remember, import-notes, and compile/push; the known or
   operator-named Atlas for recall) and set `atlas_root` only from that
   result. This target resolution (`atlas resolve` / mount, `git ls-remote`,
   and the visibility lookup in step 2) is the only operation permitted
   before the card; it reads no person-page content. Do **not** require
   `atlas_root` to be pre-filled by the
   operator. If mount / `git ls-remote` fails because the empty store is
   not yet provisioned → **stop** with deferral reason
   `awaiting store provision` (recall may still explain the contract;
   remember/import that need a live write must defer). Resolve returns a
   different `atlas_id` than the one selected → **stop** and ask the
   operator to confirm (writes) or name (recall) the Atlas again.
4. Emit the activation card with **every field filled**, including the
   resolved `atlas_root`, before any person-page content is read or
   written, and before any compile/push or overlay mount. Missing resolve →
   incomplete card → **stop**.
5. Load the matching LOCAL path module under `references/paths/` and follow
   it. **Enter does not mount the Atlas overlay.** For remember and
   import-notes with `memory_sync: on` (a real write run), the path module
   runs **3. Mount the Atlas overlay** exactly once, after the path
   module's gates pass and immediately before the first write. A request
   that any gate rejects never mounts. **Skip the mount** for recall and for
   any preview or dry run (`memory_sync: off`): no `schema install`, no
   compile, no change to `schema.d/` or `templates/`.

### 1. Mount (all paths that need the store)

1. Mount/resolve of the selected Atlas already ran in **0. Enter** step 3.
   Reuse the resolved `atlas_root`; do not re-guess a checkout path.
2. If a later path step rediscovers that the live store is unreachable →
   **stop** with deferral `awaiting store provision`. Do not invent a fake
   tip.
3. Mounted store differs from the selected `atlas_id`, or the operator
   names a different target mid-run → **stop** writes until the operator
   confirms the target again (recall: stop reading until the operator names
   the Atlas again).

### 2. Path dispatch

| Path | Load | Summary |
| --- | --- | --- |
| recall | `references/paths/recall.md` | Recall people / edges; synthesise with source pointers |
| query | (deprecated alias) | Routes to recall; same module and rules |
| remember | `references/paths/remember.md` | Write/update person pages and typed edges; compile; push |
| import-notes | `references/paths/import-notes.md` | One-shot Notes import; id-safe; review queue; no watcher |

Person page contract: `references/person-page-schema.md`.

The remember and import-notes modules invoke **3. Mount the Atlas overlay**
themselves, once, from inside their validated write flow; it is not a
separate step between Enter and the path module.

### 3. Mount the Atlas overlay (confirmed target, write runs only)

This package ships an Atlas overlay at `contributions/atlas-people/` that
declares the type `person` (see `contributions/atlas-people/README.md`).
`apm install` only installs the skill package; it never mounts the overlay
into any Atlas. Mounting is a separate, explicit step through EXTERNAL
**`atlas`** path `schema`. It is never run from **0. Enter**: the remember
or import-notes path module invokes it exactly once per run, after the path
module's gates pass (target confirmed, public-visibility acknowledgement
given when the target is public or of unknown visibility, secret-class
content redacted or rejected, stable note ids and import scope valid, chosen
source readable, store
resolved, merge review settled) and immediately before the first write
(person page, edge, or review-queue entry). A request that any gate
rejects never reaches this step, so it never changes `schema.d/` or
`templates/`. Later writes in the same run do not re-run it or ask again.

Mount only on a real write run: path remember or import-notes with
`memory_sync: on`. **Skip this step** for recall and for previews or dry
runs (`memory_sync: off`): mounting runs `schema install` and compile,
which change `schema.d/` and `templates/`, and a dry run promises no store
mutation. Record `overlay: skipped` on the receipt.

1. **Locate the package root.** After
   `apm install sergio-sisternes-epam/atlas-people#v0.1.4`, the package
   root is `apm_modules/sergio-sisternes-epam/atlas-people/` in the project
   where it was installed (`<pkg-root>`). Confirm the tag
   (`resolved_ref` / `version`) in `apm.lock.yaml`, and check that
   `<pkg-root>/contributions/atlas-people/SCHEMA.overlay.json` exists.
   The overlay ships in the tagged source package that this install
   places; the `apm pack` plugin bundle attached to GitHub Releases
   carries the skill only, not the overlay. If the file is missing (for
   example a bundle-only or deployed-skill-only install), **stop this
   step**: tell the operator to install from the tagged repository
   (`apm install sergio-sisternes-epam/atlas-people#v0.1.4`), record
   `overlay: unavailable`, and continue as for a declined mount. Do not
   fetch or guess another source.
2. **Check the confirmed target.** Mount only on the Atlas the operator
   confirmed as the target for this run (`<atlas-root>` from
   `atlas resolve`). Never mount on an Atlas the operator did not name and
   confirm. If `<atlas-root>/schema.d/atlas-people.json` already matches the
   package overlay and `schema.d/atlas-people.receipt.json` lists
   `templates/person.md`, the overlay is current; skip to step 5. If it
   differs (an older package version), run **Upgrade** below instead of a
   plain install.
3. **Ask before mounting.** Mounting changes that Atlas's contract, so ask
   the operator first (same ask-then-confirm flow as writes). If the
   operator declines, continue: the skill still works, because an unknown
   `type` is legal OKF and only Atlas-side frontmatter checks are missing.
   This is advisory, never a block.
4. **Mount and compile** (operator agreed):

   ```bash
   python3 <atlas-skill>/scripts/atlas.py schema install <pkg-root>/contributions/atlas-people --root <atlas-root>
   python3 <atlas-skill>/scripts/atlas.py compile --root <atlas-root>
   ```

   Compile must stay green; exit 2 → fix through `schema` verbs, never by
   editing `schema.d/` by hand.
5. **Record the package ref** (tag or commit from `apm.lock.yaml`) on the
   exit receipt, for example
   `overlay: mounted | current | upgraded | declined | skipped | unavailable` and
   `source: sergio-sisternes-epam/atlas-people#v0.1.4`.

**Upgrade.** After `apm install sergio-sisternes-epam/atlas-people#vNEW` or
`apm update`, the target keeps the old overlay until the mount is re-run
from the new package root (`<new-pkg-root>`). Re-run it after every
upgrade, on the confirmed target only and after asking the operator (same
flow as step 3), on each Atlas that holds the overlay: uninstall, then
install, then compile.

```bash
python3 <atlas-skill>/scripts/atlas.py schema uninstall atlas-people --root <atlas-root>
python3 <atlas-skill>/scripts/atlas.py schema install <new-pkg-root>/contributions/atlas-people --root <atlas-root>
python3 <atlas-skill>/scripts/atlas.py compile --root <atlas-root>
```

Why not a plain re-install: re-running `schema install` (with or without
`--force`) on a store that already has `templates/person.md` neither
refreshes that template nor keeps it on the receipt, so a later
`schema uninstall` would leave it behind. Uninstalling first removes the
old template and overlay; the fresh install writes the new template and
lists it on the receipt again, so `--force` is not needed. Uninstall never
deletes person pages. If `templates/person.md` is still present after the
uninstall (left by an earlier plain re-install), it is no longer owned by
the overlay; with the operator's agreement delete it before the install
so the new template is written and recorded.

**Remove.** `apm uninstall` leaves `schema.d/atlas-people.json` in every
store. To remove the overlay from a confirmed Atlas:

```bash
python3 <atlas-skill>/scripts/atlas.py schema uninstall atlas-people --root <atlas-root>
python3 <atlas-skill>/scripts/atlas.py compile --root <atlas-root>
```

Uninstall does not delete person pages; `type: person` stays legal OKF. If
the store was upgraded with a plain re-install under an older version of
these instructions, `templates/person.md` may remain after
`schema uninstall`. It is an unused template, not part of the contract
file or `schema.d/`; the operator may delete it.

**Page type.** New person pages use `type: person`. Legacy v0.1.2 pages
(`type: document` + `person_contract: v1`) stay valid; remember sets
`type: person` on them only where the overlay is mounted
(`references/person-page-schema.md`).

### 4. Compile + push (Pins 8–10)

After Atlas writes, when `compile_push: on` and the live store is reachable:

1. Run `atlas compile` green on the confirmed target root
   (`python3 <atlas-skill>/scripts/atlas.py compile --root <atlas-root>`).
2. Load EXTERNAL **`atlas-compile-commit-push`** and follow it exactly.
3. Push branch `atlas` to the confirmed `<push-remote>` only.
4. **Forbidden:** dual-push to any second remote; `GIT_LFS_SKIP_PUSH` on
   ordinary pushes; writing person pages to any Atlas other than the one
   the operator confirmed for this run.

**Local-only target (`push_remote: none`).** When the operator confirmed
`push_remote: none` for a local-only Atlas with no remote, publishing is
disabled. Step 1 still runs (compile green). In step 2, commit locally per
EXTERNAL `atlas-compile-commit-push` if it supports a local-only commit;
otherwise compile only. Skip step 3 and record
`push: skipped (push_remote: none)` on the receipt; this is not an
incomplete exit.

Exit incomplete if compile fails or push is skipped while `compile_push: on`
and the store is reachable, unless the confirmed `push_remote` is `none`.
If the store is not provisioned, record the deferral and do not claim a
tip.

## Exit checklist

- [ ] Activation card emitted after target resolution only (`atlas resolve` / mount, `git ls-remote`, visibility lookup) and before any person-page content is read or written, any compile/push, and any overlay mount (every field filled; `atlas_target: confirmed` for writes; may stay `unknown` for read-only recall)
- [ ] Operator asked which Atlas the person pages should be stored in (known or bound Atlases offered; any other allowed)
- [ ] Target explicitly confirmed by the operator before the first write; re-confirmed if it changed
- [ ] No target refused on policy grounds; privacy note given as advice only when the target is shared, work/project, or public
- [ ] Target visibility determined from the push remote / hosting service (`atlas_target_visibility` on the card; `unknown` never assumed private); for a public or unknown target, the separate acknowledgement asked with the exact text after the target confirmation and before the overlay mount and first write, and `atlas_target_visibility: public-acknowledged` recorded; declined → `incomplete: public target not acknowledged` with no write and the target not refused; private targets with known visibility need no extra step
- [ ] Atlas overlay (write runs with `memory_sync: on` only): never mounted from Enter; mounted at most once, by the remember / import-notes path module after its gates passed and immediately before the first write; operator asked before mounting on the confirmed target only (`schema install <pkg-root>/contributions/atlas-people`, then compile green), or already current, or declined (advisory), or unavailable (no overlay at the package root; install from the tagged repository); skipped for recall, dry runs, and requests a gate rejected; package ref recorded on the exit receipt
- [ ] After a package upgrade, the mount re-run from the new package root (`schema uninstall atlas-people`, then `schema install <new-pkg-root>/contributions/atlas-people`, then compile) on each Atlas that holds the overlay, after asking the operator
- [ ] New person pages use `type: person`; legacy `type: document` pages retyped only where the overlay is mounted
- [ ] Path module followed; person contract observed
- [ ] No name-only merge
- [ ] Notes id required; no title-only Notes targeting
- [ ] No secret-class content; credentials are located only as being in the password manager or secret store
- [ ] Compile green + push to the confirmed `<push-remote>` when writes landed and store is live (EXTERNAL ccp)
- [ ] Or, with a confirmed `push_remote: none` (local-only target), compile green, local commit only if EXTERNAL ccp supports it, push skipped and recorded on the receipt (not an incomplete exit)
- [ ] Or explicit deferral `awaiting store provision` when store missing
- [ ] No continuous sync; no LinkedIn in v0
- [ ] No live host, remote, checkout path, or credential path echoed into skill text

## Non-goals

- Continuous notes sync
- LinkedIn (or other) ingest in v0
- Restricting or forcing the Atlas target on policy grounds (the operator
  decides; the skill asks and confirms)
- Treating person pages as skill process memory (they are data)
- Dual-push to retired local bare repositories or any second remote
- Shipping a default store id, host, checkout path, push remote, or SSH
  identity in this package
- Full Autogenesis runtime fusion (unless a later approved plan selects it)
- Replacing Contacts.app / CNContact as a system of record
- Password-manager item titles, vault names, or ids in skills or Atlas
  process pages

## Maintaining this package

`SKILL.md` (root) is canonical. `.apm/skills/atlas-people/SKILL.md` is a
byte-identical hybrid mirror for APM targets: edit the root file, then copy
it over the mirror in the **same commit**. The `apm-mirror-lockstep` smoke in
`references/scenarios/people-adversarial-v2.yaml` fails on any drift.

## Install

Install a tagged release (tag `v<version>`), for example:

```bash
apm install sergio-sisternes-epam/atlas-people#v0.1.4
```

The install config is where the operator may record a suggested `atlas_id`
and `push_remote`; the skill offers it as an option and still asks the
operator to confirm it before the first write. The package itself carries
placeholders only.

The install does not touch any Atlas. The package's Atlas overlay
(`contributions/atlas-people/`, type `person`) is mounted separately, only
on the confirmed target, on a write run, and with the operator's agreement:
see **3. Mount the Atlas overlay** above.
