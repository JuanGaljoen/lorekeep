---
name: chronicle
description: Preserve knowledge that will improve future work. Use after a change lands, when the user says "write this down", "record this decision", or when a non-obvious lesson or reusable pattern emerged worth keeping.
---

# Chronicle 📖

*What should future-us know?*

The closing phase. Capture the knowledge that makes the next change cheaper — decisions,
patterns, hard-won lessons — and skip everything trivial. A chronicle of noise is worse than none.

## What's worth keeping

- **A decision that was hard to reverse or hard to reach.** Why we chose this over the
  alternative — so nobody re-litigates it or quietly undoes it. → an **ADR**.
- **A reusable pattern** the codebase should follow consistently. → `CONTEXT.md` or a convention note.
- **A non-obvious lesson** — a bug whose cause surprised you, a sharp edge in a dependency, a
  gotcha the next person will hit. → wherever it'll be found again.
- **New or sharpened vocabulary** — a fuzzy term you pinned down, an overloaded word you split. →
  `CONTEXT.md`, the shared glossary.

## Where it goes — pick by scope

| Scope | Home |
|-------|------|
| **Code-local** (this repo's decision, pattern, or vocabulary) | `CONTEXT.md` or `docs/adr/NNNN-title.md` **in the repo** — the default |
| **Cross-project** (a lesson that outlives this repo) | **Obsidian** (`~/ObsidianVault/Personal/`) — a dated file, a title, a paragraph. No schema, no ceremony. |

In-repo is the default. Reach for Obsidian only when the lesson genuinely travels beyond this repo.

## Rules

- **Skip the trivial.** A routine change, an obvious fix, a rename — nothing to chronicle. Say so
  and stop. Don't manufacture an entry to look thorough.
- **State the lesson, not the diff.** Git already has the diff. Record *why*, and what future-us
  should do differently — the thing the code can't tell them.
- **Write it where it'll be found.** An entry nobody stumbles on later is wasted effort.

## Output

The entry (or entries) written, with paths — or an explicit "nothing worth chronicling here" when
that's the honest answer.
