---
name: chronicle
description: Preserve knowledge that will improve future work. Use after a change lands, when the user says "write this down", "record this decision", or when a non-obvious lesson or reusable pattern emerged worth keeping.
---

# Chronicle 📖

*What should future-us know?*

The closing phase. Capture the knowledge that makes the next change cheaper — decisions,
patterns, hard-won lessons — and skip everything trivial. A chronicle of noise is worse than none.

## What's worth keeping

- **A decision that clears all three bars:** hard to reverse, surprising without its context, and
  a real trade-off between live alternatives. Why we chose this over the alternative — so nobody
  re-litigates it or quietly undoes it. → an **ADR**. Miss any one and it isn't one: easy to undo
  means just undo it; obvious from the code needs no record; no real alternative means there
  was no decision.
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
| **What a ticket did** — what shipped, what surprised us, which ADRs it left | `specs/<TICKET-KEY>.md`, under `## Outcome`. History, kept by key, loaded only when that ticket comes up. No spec yet? Create one holding just the Outcome. |
| **What's open, what's next, ticket status** | **The tracker.** Never the repo's docs. |
| **A lesson that outlives this repo** (cross-project) | **lorekeep itself** — the skill or spine line that would have caught it. From another repo, propose the change; don't make it. |

The split that matters: **decisions and lessons are ADRs** (dated; you don't edit them, you
supersede them); **facts and conventions are `CLAUDE.md`** (living; you keep it current). A lesson
never goes in `CLAUDE.md`; a live convention never goes in an ADR. There is no `CONTEXT.md`. A lesson
that genuinely travels is a lesson about the workflow — it sharpens a skill, not a vault.

## What `CLAUDE.md` is — and isn't

`CLAUDE.md` describes **the system as it is now**, in the present tense, for an agent about to touch
it. Every line is paid for on every turn of every session, so it earns its place harder than
anything else in the repo.

It is **not** a backlog, a status board, a "where we stand" or "next" section, a changelog, or a
place for per-ticket retrospectives. Those already have homes (above). A ticket key in `CLAUDE.md`
is a smell: the sentence around it is usually history wearing a fact's clothes.

**The admission test, per line:** *would this still be true and useful if the tracker and the git
history were deleted tomorrow?* If not, it's history — it goes in the spec's Outcome or the tracker.
And *does it change what the agent does?* If not, it's a no-op — leave it out.

**Why it bloats anyway:** adding feels safe and removing feels risky, so stale layers settle. Every
write to `CLAUDE.md` is also a chance to remove one.

## Rules

- **Skip the trivial.** A routine change, an obvious fix, a rename — nothing to chronicle. Say so
  and stop. Don't manufacture an entry to look thorough.
- **Don't cache what the environment already answers.** The repo is a source of truth in its own
  right — `package.json` scripts, config files, the directory layout, `--help` output. An entry that
  restates one is a *cache* of a lookup, and it earns its keep only when that lookup is expensive.
  The test: **could the agent find this by looking?** If yes, leave it in the environment, where it
  can't go stale. Chronicle what looking *can't* find — the unwritten convention, the reason behind
  the choice, the gotcha no config confesses.
- **A check beats a sentence.** Before writing a rule into `CLAUDE.md`, ask whether a lint, a
  test or a CI grep could enforce it instead. A mechanical rule ("no ticket keys in comments")
  belongs in tooling, which can't be skimmed past; prose is for judgement calls a check can't
  make. If a check fits, propose it — that's the entry.
- **State the lesson, not the diff.** Git already has the diff. Record *why*, and what future-us
  should do differently — the thing the code can't tell them.
- **Write it where it'll be found.** An entry nobody stumbles on later is wasted effort.
- **Edit in place; never append a dated paragraph.** A fact has one home. When it changes, find
  that line and rewrite it — don't add "as of TICKET-12, …" underneath. Two versions of a fact is
  a stale fact waiting to be believed.
- **Check the budget before every `CLAUDE.md` write.** Run `wc -l CLAUDE.md` and grep it for the
  tracker key (the prefix on `specs/` filenames, e.g. `grep -c 'RING-'`). Over ~200 lines, or any
  ticket key present: consolidate first — move history to its Outcome, fold duplicates, delete
  no-ops — and propose that cleanup to me before adding the new line. The number is a tripwire,
  not a law; crossing it means *look*, not *fail*.

## Output

The entry (or entries) written, with paths — or an explicit "nothing worth chronicling here" when
that's the honest answer.
