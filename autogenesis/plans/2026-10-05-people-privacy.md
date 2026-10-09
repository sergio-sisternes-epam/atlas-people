---
type: plan
title: "people — privacy-harden skill text + history recreate"
created: "2026-10-05"
updated: "2026-10-05"
work_id: "2026-10-05-people-privacy"
status: done
approval: approved
approval_ref: "Approved by the maintainer on 2026-10-05 (implement)"
change_class: hardening
catalogue_review: n/a
pattern_applicability: not-applicable
pattern_admission: "n/a — privacy pin + history recreate; no topology / gate / fan-out change"
origin: agent
sensitivity: public
description: >-
  Hardening: scrub the people skill text of private hostnames, paths,
  SSH identities, and personal Atlas slug names; resolve store id / checkout /
  remote from operator or install config only (todoist-style); close the first
  pre-publication pull request and recreate a clean one from main; park the
  shared design-store people-commit rewrite as optional cut B / non-goal for
  this work_id.
plan_path: autogenesis/plans/2026-10-05-people-privacy.md
behavioural_contract: "deferred: agent-spec not installed; @forbidden privacy families named below; Gherkin awaits agent-spec specify"
external_ref: "first pre-publication pull request (closed, unmerged; recreated) — pre-publication history"
relates_to:
  - path: autogenesis/work/2026-10-05-people-privacy.md
    kind: implements
  - path: autogenesis/plans/2026-10-05-people-atlas.md
    kind: related
  - path: autogenesis/experiences/2026-10-05-people-atlas-implement.md
    kind: related
  - path: autogenesis/experiences/2026-10-05-people-privacy-implement.md
    kind: related
---

# Plan: people privacy harden + history recreate

**work_id:** `2026-10-05-people-privacy`  
**change-class:** `hardening`  
**Subject:** the `people` skill package (paths below are relative to the package root)  
**atlas_id / ref:** this store's `CONTRACT.json` `atlas_id` / `atlas` (this repository's `atlas` branch)  
**Status:** done — approved by the maintainer on 2026-10-05; implemented in a second, clean pre-publication pull request. See [implement experience](../experiences/2026-10-05-people-privacy-implement.md). Released inside the former monorepo as 0.1.1.

British English. Prose uses roles (the operator, the provisioner, the maintainer), not named people.

## Autogenesis Enter card (recorded)

```text
schema: autogenesis.invocation-request/v1
request_id: ag-design-2026-10-05-people-privacy
parent_request_id: null
target: {skill: autogenesis, module: design, role: operation}
operation: design
arguments:
  objective: >-
    Privacy-harden the people package — no private URLs, private hostnames,
    absolute home-directory paths, SSH key paths, or personal Atlas slug names
    in skill text; store id/checkout/remote from operator/install config only
    (todoist-style); history cleanup via closing the first pre-publication pull
    request + a clean recreate in a new one; Genesis under Autogenesis; park
    the shared design-store people-commit scrub as optional cut B.
  behavioural_contract: deferred:agent-spec-not-installed
  change_evidence: >-
    first pre-publication pull request closed unmerged; audited leaks in the
    package + adversarial live smoke; earlier design-store commits restate
    private store URLs; the maintainer chose recreate over force-push;
    precedent atlas-tasks-todoist.
context:
  subject: people
  mode: run
  operation: design
  work_id: 2026-10-05-people-privacy
  atlas_id: <this-atlas-id>
  atlas_root: <atlas-root>
  approval_ref: null
resolved:
  skill_root: <install-root>/autogenesis
  module_root: <install-root>/autogenesis/references/modules/design
  entrypoint: <install-root>/autogenesis/references/modules/design/SKILL.md
state: awaiting-approval
```

## Genesis Artifacts (hardening)

### Intent

Make the `people` package safe to review and ship without embedding
operator-private infrastructure: skill prose must not name private hostnames,
working-checkout absolute paths, SSH identity paths, or personal Atlas slug
names. Runtime store identity (atlas_id), checkout root, and push remote come
**only** from the operator's Enter card / install config (the same fail-closed
pattern as `atlas-tasks-todoist`). Restore a clean product history by
**closing the first pre-publication pull request and opening a new one from
main** (the maintainer's choice). Do not implement until explicit approval.

### Scope

**In (cut A — this work_id, after approval):**

1. **Privacy pin (product text).** Rewrite the package's skill body,
   README, CHANGELOG, path modules, person-page schema, atlas-mesh notes, and
   adversarial scenarios so that:
   - No private hostnames / private remote URLs appear as normative store
     targets.
   - No absolute home-directory paths appear as normative checkouts or install
     targets (describe the install root / mesh mount shape generically).
   - No SSH private-key paths appear in scenarios or prose.
   - No personal Atlas slug names appear; forbid nesting via **role language**
     ("any non-people Atlas — the operator's personal or work Atlas, another
     agent's Atlas", "Autogenesis subject store") without baking private
     identifiers.
2. **Operator/install config only (todoist-style).** The Enter card carries
   `atlas_id`, `atlas_root`, and push remote (or an equivalent compile-push
   binding) supplied by the operator or install config. Writes require an
   explicit confirmed target (mirror `atlas_target: confirmed`). Missing /
   ambiguous → **stop**. Skill text may show placeholders
   (`<people-atlas-id>`, `<atlas-root>`, `<push-remote>`), never live private
   values.
3. **Retain product behaviour** from the approved `2026-10-05-people-atlas`
   plan (query / remember / import-notes; person_id; no name-only merge; Notes
   id; one-shot; LinkedIn deferred; secrets standing "1Password is the vault").
4. **Review threads from the first pull request still in scope** on the clean
   recreate:
   - Keep the hybrid `.apm` mirror in lockstep with root `SKILL.md` (same
     sibling pattern; document "edit root then copy" or generate — no drift).
   - Fix adversarial YAML leading indentation (column 0).
   - Soften the version smoke to SemVer / `^version:` shape, not a single
     frozen patch string as the only assertion.
   - Remove the hard-coded SSH identity path; the live reachability smoke
     becomes operator-env parameterised **or** an explicit deferral when unset.
   - README: replace the vague "council settle memory" wording with a clear
     route to a separate council/decision-memory skill.
   - SKILL checklist: "no title-only Notes targeting" (match pin language).
5. **History cut A (the maintainer's choice):** keep the first pre-publication
   pull request closed (already closed, unmerged); do **not** reopen it; its
   head branch may be deleted after approval; open a **new** branch from
   current `main` and recreate the scrubbed package as a new pull request. No
   force-push. No rewrite of `main`.
6. **Adversarial privacy suite** (new file
   `people-privacy-adversarial-v1.yaml` or bump) forbidding private URL /
   hostname / path / SSH / personal-slug patterns in package text.
7. Version: treat as **0.1.1** privacy patch if 0.1.0 was never tagged on main;
   if implement finds 0.1.0 already tagged elsewhere, bump accordingly — pin at
   implement after a `git tag` check. Prefer **0.1.1** after the clean recreate.

**Out / non-goals (this work_id):**

- **Cut B — shared design-store people-commit scrub / rewrite** of the earlier
  atlas-branch commits that recorded the people design (and any other
  atlas-branch pages that restate private store URLs). **Parked** as an
  optional follow-on. Requires a separate explicit grant from the maintainer,
  a pause of other agents writing the shared atlas branch, and a dedicated
  history plan (filter-repo / redact / GC). Not implement authority here.
  Autogenesis lineage pages on that store may keep historical private
  identifiers until cut B; that is accepted residual for cut A.
- Force-push of any published branch (`main`, `atlas`, or the closed pull
  request head).
- Opening the implement pull request from this design Run.
- Recreating package files during design.
- Marketplace publish (superseded on 2026-10-09 — see
  [publish publicly](../../decisions/2026-10-09-publish-publicly.md));
  continuous Notes sync; LinkedIn ingest; Contacts.app mutation; nesting
  people pages in any non-people Atlas.
- Rotating live SSH host keys unless the maintainer separately orders it (paths
  leave the skill; credentials on disk are out of package scope).

### Acceptance

1. The new pull request from `main` contains the `people` package with **zero**
   matches for the forbid patterns listed under Evaluation / adversarial draft.
2. Enter card + path modules require operator/install-supplied `atlas_id` /
   `atlas_root` / push binding; fail closed when missing.
3. All six review threads from the first pull request addressed in the new
   pull request body or resolved by redesign notes.
4. Adversarial privacy smokes green on the new tree.
5. The first pull request remains closed; no force-push; the design Run never
   opened the implement pull request.
6. Cut B explicitly parked (this plan's non-goal) unless the maintainer expands
   scope in a new design.

## Pinned decisions

1. **Operator store binding (todoist-style)** — the skill never hardcodes the
   people runtime atlas_id, checkout path, or push remote. Operator Enter /
   install config supplies them; unconfirmed → stop.
2. **Role-language forbid list** — replace concrete personal Atlas slug names
   with role phrases; the adversarial suite still forbids those literal strings
   if they reappear.
3. **History A: recreate** — close the first pull request (done) + open a new
   one from main after the scrub. No reopen. No force-push. Residual
   closed-pull-request blobs may remain server-side until GitHub GC; accepted
   for a private pre-publication repository.
4. **History B: design-store rewrite parked** — optional second cut; not this
   work_id's implement scope. Recommend the people recreate first.
5. **Precedent** — `atlas-tasks-todoist` privacy + activation
   (`atlas_id` / paths from the card; no host/path bake-in).
6. **Genesis under Autogenesis** — this hardening plan is the sole implement
   authority after the maintainer's approval; the prior
   `2026-10-05-people-atlas` plan remains lineage, not a licence to re-ship
   leaked text.
7. **Live store smoke** — parameterise via env (e.g. an operator-supplied
   `GIT_SSH_COMMAND` / remote) or defer with an explicit reason; never embed
   private key paths in the package.
8. **Stop-for-approval** — design ends here. Implement only after explicit
   approval of this pinned plan by the maintainer.

## SOLID (hardening abbreviated)

| Principle | Status | Rationale |
| --- | --- | --- |
| S | applicable | One reason to change this Run: privacy surface of `people` + clean pull-request history. Product paths unchanged in purpose. |
| O | applicable | Stable behavioural pins (person_id, Notes id, one-shot) stay closed; extension is the operator-supplied store binding, not new ingest surfaces. |
| L | not-applicable | No interchangeable skill substitutes claimed. |
| I | applicable | Enter card still narrow: path + operator store fields + sync flags; progressive path modules unchanged. |
| D | applicable | Depend on Atlas / apple-notes / compile-push **capabilities**; invert concrete host/path/key details out to operator config. |

Omitted none beyond L (explicitly n/a).

## Catalogue Review

`catalogue_review: n/a` — hardening of copy/contract privacy + history
recreate; no topology, gate map, multi-agent fan-out, or pattern-catalogue
extension. `pattern_applicability: not-applicable`. `pattern_admission: not-selected`.

## Think-challenge summary

Support `think-challenge` nest-loaded catalogue `think-challenge` with search
grounding (GitHub sensitive-data removal; publish-time scrubbing; OWASP agent
secrets-scan / CWE-798). Material counters and pin responses:

| # | Counter | Disposition |
| --- | --- | --- |
| C1 | A closed pull request / deleted branch leaves blobs reachable by SHA until GC (GitHub docs). | **Accept residual** for a private pre-publication repository; pin recreate (A); no force-push theatre that rewrites main. |
| C2 | Earlier design-store pages and commits still restate private store URLs. | **Park as cut B / non-goal** for this work_id; requires pause + separate grant. |
| C3 | Operator-only config can strand agents without a store. | **Pin fail-closed**; confirmed target required (todoist precedent). |
| C4 | Scrubbing personal Atlas slug names removes "never nest" clarity. | **Pin role-language** forbid list; keep the adversarial literal forbid. |
| C5 | Naming exact leak patterns in smokes re-encodes them. | **Pin** smokes as necessary detection, written as placeholders or bracket classes; skill body uses placeholders only; plan lineage may name classes for the scrub checklist. |

## Challenge-success criteria

- **C1** non-trivial counters: yes (history residual, design-store park, fail-closed).
- **C2** high-severity pinned or rejected with rationale: yes (table above).
- **C3** visible pins: yes.
- **C4** scope intact: hardening only; cut B parked.
- **C5** no implementation in this operation: yes.
- **change-class** stated: `hardening`.
- **Genesis Artifacts** complete for hardening: intent + scope + acceptance + pins/non-goals.

## Behavioural contract (agent-spec)

**deferred:** the agent-spec package was not installed in the implementation
environment. `@forbidden` families for implement / later specify:

- `@forbidden` private-hostname-or-url in skill product text
- `@forbidden` absolute home-directory path as normative checkout/install in skill text
- `@forbidden` SSH identity path in skill text / scenarios
- `@forbidden` personal Atlas slug names in skill text
- `@forbidden` people write without an operator-confirmed store binding
- Retain prior `@forbidden` families from `2026-10-05-people-atlas` (nest,
  name-only merge, title-only Notes, secrets class, unbounded import)

## Evaluation plan

**Deterministic (primary):**

1. `rg` forbid-pattern suite over the package tree (see adversarial draft).
2. Package shape: root + `.apm` SKILL parity; `apm.yml` name `people`.
3. Enter / path modules require operator store fields; fail-closed language present.
4. Review-thread checklist items present (YAML column 0; SemVer smoke; no SSH
   path; README council-memory wording; Notes targeting checklist).
5. No implement pull request opened by the design Run; the first pull request
   remains closed.

**Agent narrative (secondary):** none required for the privacy pin.

## Adversarial scenario draft

Commands run from the package root. `<private-host-pattern>` and
`<personal-slug-prefix>` are operator-supplied patterns; literal forbidden
strings are written as bracket classes so the suite never contains what it
forbids.

```yaml
id: people-privacy-adversarial-v1
packages:
  - people
work_id: 2026-10-05-people-privacy
adversarial: true
smokes:
  - id: no-private-hostname-url
    source: challenge-C5-publish-time-scrub
    expect: skill product text has no private hostname / private remote URL patterns
    check: |
      ! rg -n -i '<private-host-pattern>|[a-z]+@[^[:space:]]+:repos/' .
  - id: no-home-box-absolute
    source: challenge-C5-publish-time-scrub
    expect: no normative absolute home-directory paths in skill product text
    check: |
      ! rg -n '/hom[e]/' .
  - id: no-ssh-identity-path
    source: review-thread-ssh-path
    expect: no SSH private key paths in package text
    check: |
      ! rg -n '\.ss[h]/|IdentitiesOnly|GIT_SSH_COMMAND=.*-i ' .
  - id: no-personal-atlas-slug
    source: pin-role-language
    expect: no personal Atlas slug names in skill product text
    check: |
      ! rg -n '<personal-slug-prefix>' .
  - id: operator-store-binding
    source: atlas-tasks-todoist-precedent
    expect: Enter/paths require operator-supplied atlas_id/root; fail closed if missing
    check: |
      rg -n 'atlas_id:|atlas_root:|confirmed|operator|install config|fail closed|stop' SKILL.md references/paths/
      rg -n 'placeholder|<people-atlas-id>|<atlas-root>|operator-supplied|install' SKILL.md README.md
  - id: role-forbid-nest
    source: pin-role-language
    expect: nesting into any non-people Atlas (personal / work / another agent's) still forbidden in role language
    check: |
      rg -n 'non-people Atlas|personal or work Atlas|Forbidden write-homes|Never write|never nest' SKILL.md README.md
  - id: yaml-column-zero
    source: review-thread-yaml-indent
    expect: adversarial yaml top-level keys at column 0
    check: |
      python3 -c "import pathlib; p=pathlib.Path('references/scenarios/people-privacy-adversarial-v1.yaml');
t=p.read_text(); assert not t.startswith(' '), 'leading indent'; assert t.lstrip()==t or True"
  - id: version-shape-not-frozen-only
    source: review-thread-version-pin
    expect: version smoke allows SemVer shape rather than sole frozen 0.1.0 string assert
    check: |
      ! rg -n 'version: \\"0\\.1\\.0\\"' references/scenarios/*.yaml
      rg -n 'version:|SemVer|^version' apm.yml references/scenarios/
```

Filename contract on implement:
`references/scenarios/people-privacy-adversarial-v1.yaml`
(keep prior `people-adversarial-v1.yaml` behaviours that remain valid after the
scrub, rewritten to match privacy pins; do not drop approved prior smokes
without a new design — migrate them into the scrubbed suite).

## Implement todos (only after the maintainer's approval)

1. Confirm the first pre-publication pull request is closed; optionally delete
   its head branch after the maintainer's OK (not force-push).
2. Branch from current `main`: `feat/people-v0.1.1-privacy` (name flexible).
3. Recreate the scrubbed package (using the prior tree as reference, not as a
   git cherry-pick of leak commits if that reintroduces blobs — prefer a file
   rewrite on clean main).
4. Apply privacy pins + review-thread fixes + adversarial suite.
5. Run deterministic smokes; record evidence in the implement experience.
6. Open a **new** pull request; do not reopen the first one.
7. Remember the implement experience on the subject Atlas; compile green; push
   the `atlas` tip (no rewrite of prior people commits — cut B still parked).
8. Stop for merge authorisation by the maintainer.

## Stop for approval

This design Run **stops here**.  
**Awaiting the maintainer's approval** before any implement, package recreate,
or new pull request. (Approval was later given on 2026-10-05; see Status.)

## Invocation receipt (design)

```text
schema: autogenesis.invocation-receipt/v1
request_id: ag-design-2026-10-05-people-privacy
target: {skill: autogenesis, module: design, role: operation}
state: completed
result:
  disposition: awaiting-approval
  artifact: autogenesis/plans/2026-10-05-people-privacy.md
  work_id: 2026-10-05-people-privacy
  approval_ref: null
loaded_entrypoints:
  - <install-root>/autogenesis/SKILL.md
  - <install-root>/autogenesis/references/modules/workflow-discipline/SKILL.md
  - <install-root>/autogenesis/references/modules/design/SKILL.md
  - <install-root>/autogenesis/references/modules/think-challenge/SKILL.md
  - <install-root>/genesis/SKILL.md
  - <install-root>/think-challenge/SKILL.md
  - <install-root>/atlas/SKILL.md
  - <install-root>/atlas/references/paths/mount.md
  - <install-root>/atlas/references/paths/remember.md
  - <install-root>/atlas/references/paths/work.md
external_skills: [genesis, think-challenge, atlas]
atlas_id: <this-atlas-id>
atlas_root: <atlas-root>
change_class: hardening
```
