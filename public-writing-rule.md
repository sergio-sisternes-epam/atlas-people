---
type: decision
title: "Public writing rule for this Atlas"
created: "2026-10-09"
description: "Rules every agent or person must follow when writing to this public, permanent atlas branch."
status: accepted
---

# Public writing rule for this Atlas

## Decision

This branch is public and permanent. Every commit is visible forever; a leak
can only be removed by a history rewrite, which branch protection blocks. Write
every page as if it were already published.

**Voice and content**

- Write in a neutral, public-grade voice.
- Record design decisions, rationale, pins, recipes and outcomes, not
  operational chatter.
- Refer to people and agents by role only ("the maintainer", "the package
  steward", "a consumer Atlas", "the operator"); never by personal names,
  private agent or bot names, or personas.
- Use neutral synthetic examples (for example, a software-release plan),
  never real personal data.

**Never include**

- Private hostnames or domains; SSH remotes.
- Absolute machine paths; use placeholders such as `<atlas-root>`.
- Credential or vault references; session or conversation ids.
- Email addresses other than GitHub noreply addresses.
- Personal or family details.
- Links to pull requests or issues outside this public repository.

**How changes land**

- Commits use a GitHub noreply author and committer and plain messages.
- All changes reach `atlas` by pull request and must pass the
  `Public hygiene scan` check.
