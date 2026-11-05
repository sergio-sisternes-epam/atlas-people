# atlas-people

atlas-people lets an agent query and remember people and typed relationships as person pages on an Atlas chosen by the operator, and run a supervised one-time Apple Notes import.

## Why / what this is not

Person pages are data in the operator's Atlas, not skill process memory. The package does not choose a store, sync Apple Notes continuously, ingest LinkedIn, or replace Contacts.app. Every write requires the operator to confirm the specific Atlas and push target for that run. After target confirmation, public or unknown-visibility targets require separate consent before the first write and overlay mount:

> Person pages will be publicly readable and can't be fully removed (history and forks keep them). Continue?

## Capabilities

- **Query:** find people and typed relationships on a known or operator-named Atlas; queries are read-only.
- **Remember:** write person fields and typed relationship edges with evidence, then compile and publish only to the confirmed push remote.
- **Import-notes:** perform a supervised, one-time Apple Notes import with Notes-ID source pointers, hard-ID matching, and ambiguous matches sent to a review queue. There is no continuous watcher.
- **Person overlay:** provide an Atlas `person` type so compile can check person-page frontmatter. Installing the package does not mount the overlay.

## Install

```bash
apm marketplace add sergio-sisternes-epam/atlas-marketplace --name atlas
apm install atlas-people@atlas
```

The package manifest does not declare its composed skills as APM dependencies. Install `atlas` and `atlas-compile-commit-push` separately; install `apple-notes` for the Notes import. The overlay is mounted separately by the skill, only on the confirmed Atlas during a real write run.

## Use

- `Find <person> and their typed relationships on the Atlas I choose.`
- `Remember <person> and this relationship, with the supplied evidence: <details>.`
- `Prepare a one-time import from the Apple Notes folder <folder>.`

Queries remain read-only. Before a write, the skill asks the operator to choose and confirm the Atlas and push target; for a public or unknown target, it asks the separate consent question above. A confirmed local-only Atlas is valid with publishing disabled.

## Prerequisites

Use the APM CLI and have the Atlas skill/CLI available for store operations. Compile-and-push operations use `atlas-compile-commit-push`; Apple Notes import also requires `apple-notes`. Neither is automatically installed by this package's APM manifest.

## Related

- [Atlas marketplace](https://github.com/sergio-sisternes-epam/atlas-marketplace) — package catalog.
- [`atlas`](https://github.com/sergio-sisternes-epam/atlas) — Atlas operations and storage.
- [`SKILL.md`](SKILL.md) — target confirmation, visibility consent, and operation rules.
- [`contributions/atlas-people/README.md`](contributions/atlas-people/README.md) — overlay contract and install behavior.
- [`references/person-page-schema.md`](references/person-page-schema.md) — person-page contract.

## Migrate / upgrade

For legacy person pages or safe overlay refresh and removal, follow the procedures in [`SKILL.md`](SKILL.md) and the [overlay guide](contributions/atlas-people/README.md). Overlay changes require operator confirmation and do not delete person pages.

## License

Apache License 2.0 — see [`LICENSE`](LICENSE) and [`NOTICE`](NOTICE).
