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
- **A non-obvious lesson** — a bug whose cause surprised you, a sharp edge in a dependency, a
  gotcha the next person will hit. → an **ADR** (it's a dated finding).
- **A reusable pattern or convention** the codebase should follow consistently. → a note in
  `CLAUDE.md`.
- **New or sharpened vocabulary** — a fuzzy term you pinned down, an overloaded word you split. →
  `CLAUDE.md`, alongside the project's facts.

## Where it goes — pick by kind

| Kind | Home |
|------|------|
| **A decision or hard-won lesson** (code-local) | `docs/adr/NNNN-title.md` — a **dated, immutable** ADR: the decision, *why*, and what it rules out. "We chose X; never do Y, it bit us" lives here. |
| **A fact, convention, or vocabulary term** (code-local) | `CLAUDE.md` — the **living** project doc that loads every session. |
| **A lesson that outlives this repo** (cross-project) | **Obsidian** (`~/ObsidianVault/Personal/`) — a dated file, a title, a paragraph. No schema, no ceremony. |

The split that matters: **decisions and lessons are ADRs** (dated; you don't edit them, you
supersede them); **facts and conventions are `CLAUDE.md`** (living; you keep it current). A lesson
never goes in `CLAUDE.md`; a live convention never goes in an ADR. There is no `CONTEXT.md`. In-repo
is the default — reach for Obsidian only when the lesson genuinely travels beyond this repo.

## Rules

- **Skip the trivial.** A routine change, an obvious fix, a rename — nothing to chronicle. Say so
  and stop. Don't manufacture an entry to look thorough.
- **State the lesson, not the diff.** Git already has the diff. Record *why*, and what future-us
  should do differently — the thing the code can't tell them.
- **Write it where it'll be found.** An entry nobody stumbles on later is wasted effort.

## Output

The entry (or entries) written, with paths — or an explicit "nothing worth chronicling here" when
that's the honest answer.
