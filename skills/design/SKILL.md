---
name: design
description: Turn an understood problem into the simplest implementation plan. Use after Understand, when the user asks "what's the cleanest way to build this", or before Forge on any non-trivial change.
---

# Design ✍️

*What's the cleanest way to build this?*

Design is where you buy simplicity. A few minutes choosing the smallest sound approach saves
hours of untangling a clever one. The output is a plan concrete enough to build against.

## The work

1. **Explore one or two viable approaches.** Not five — just enough to know the obvious path
   isn't hiding a trap. Name the trade-off that separates them.
2. **Choose the simplest that satisfies the success criteria.** The best change is the smallest
   one that solves the real problem. Favour deep modules: a lot of behaviour behind a small
   interface, placed at a clean seam, testable through that interface. When the work *is*
   deepening a module — a Sweep refactor candidate, or a shallow layer the obvious approach would
   add — read [DEEPENING.md](DEEPENING.md) and design the interface twice before freezing.
3. **Name the trust boundaries it touches** — auth, user or external input, files and paths,
   outbound requests, secrets, LLM prompts — or say "none". This line is what tells Verify to run
   its security pass, so a missing one means a skipped check. **Name the hard-to-undo categories**
   too — money, permissions, deleting data, running cost, retries by an external system, legal
   wording — or say "none". That line is what keeps the strong model on Forge and calls in the
   independent review, so a missing one means both are skipped.
4. **Name the files to modify** — the actual paths, and a line on what changes in each.
5. **Name the tests to write** — which seams, and what behaviour each test pins. Confirm the
   seams with me before Forge writes anything.
6. **Freeze the plan.** Two things block the freeze. First, an Understand question I never
   answered — one that still carries only your recommendation, not my pick. List those and put them
   to me; a recommendation I didn't take is a guess, not a decision. Second, when step 3 named a
   hard-to-undo category or the plan spans checkpoints, the **independent review** of the plan
   (see below) runs *before* I agree, so its findings land while the plan is still soft.
   Once we agree, that's the plan. Scope creep — "while I'm in here…" — is
   how simple changes become balls of mud. New ideas go on a list for later, not into this change.
7. **If the plan spans more than one checkpoint** (CP1, CP2, …), write it to a durable spec file —
   `specs/<TICKET-KEY>.md` — before Forge starts. This is the **resume artifact**: a fresh session
   (or `/start-ticket`, or Recall) rebuilds the whole picture from it without re-deriving anything,
   so it has to carry the *bar* as well as the *plan* — otherwise a resuming Verify has nothing to
   check against. Include:
   - **Classification** — fix / feature / refactor (from Understand), so a resume knows how much
     process the work earns.
   - **Success criteria** — the definition of done from Understand, verbatim, as a `- [ ]` checklist.
     This is the acceptance bar Verify checks against; if it lives only in the conversation it dies
     with the session.
   - **Approach & contracts** — the chosen approach, the placement/formula/contract details, and
     the trust boundaries from step 3, so a resuming Verify knows whether to run its security pass.
   - **Decisions** — every call I made, in my words, each with the test that will pin it (or
     "text — no test" for wording and docs). A decision that lives only in the conversation is the
     one that never reaches the code; Verify checks each line has its evidence.
   - **Checkpoints** — a `- [ ]` tickbox list, one line per checkpoint with its file list, so Verify
     can commit and tick each off as it lands (see Verify, "Close the checkpoint") and the spec stays
     in step with the tracker.

   A skeleton:
   ```markdown
   # <TICKET-KEY> — <title>
   Classification: feature

   ## Success criteria (the bar Verify checks)
   - [ ] <criterion 1 — concrete and checkable>
   - [ ] <criterion 2>

   ## Approach
   <chosen approach; contracts, placement, formulae>
   Trust boundaries: <list or none> · Hard to undo: <list or none>

   ## Decisions
   - <decision, in the owner's words> · pinned by: <test name | text — no test>

   ## Checkpoints
   - [ ] CP1 — <slice> · files: <paths>
   - [ ] CP2 — <slice> · files: <paths>
   ```

   Single-checkpoint work doesn't need this — the frozen plan in this response, plus the success
   criteria from Understand, is enough to build and verify in one session.

## Independent review of the plan

When step 3 named a hard-to-undo category, or the plan spans more than one checkpoint, hand the
draft to the **`reviewer` agent** (`agents/reviewer.md`) before the freeze. It reads files, not this
conversation — that's the point: the plan was written and judged in the same head, and only a reader
without our assumptions can see what they hid. Write the draft spec and the open-ticket list (if
there is a tracker) to a scratch directory and point it there. Its verdict is **advice**: show it to
me with your read of each finding, fold in what I accept, and freeze. On a single-checkpoint change
with no hard-to-undo category, skip it — say so in one line.

*Done when:* the reviewer's verdict is in front of me, or the plan carries neither trigger.

## Rules

- **Design against the success criteria from Understand**, not against a vague sense of "good".
- **Simplest sound option wins.** If you're reaching for a framework, a new dependency, or an
  abstraction, justify it against the smaller alternative.
- **Don't freeze a plan resting on an unsourced external fact.** If the approach depends on a
  tolerance, a threshold, a standard or someone else's contract that neither the repo nor this
  conversation can source, run **Research 🔬** first and freeze against the answer. A number
  invented at Design becomes a number everything is built on.
- **Surface risks, don't bury them.** Name the two or three things most likely to go wrong.
- **Recommend, don't lay out neutrally.** When you put the approach choice to me as a picker
  (`AskUserQuestion`), the option you'd take **must** be the **first** one, its label ending with
  **"(Recommended)"**, with the *why* in its description. Simplest-sound-option-wins means you have
  a lean — state it. A neutral picker is only for a genuine toss-up; say so if it is one.

## Output

A short plan: the chosen approach and why, the file-change list, the tests to write (with seams),
and the top risks. For a decision that's hard to reverse or that future-us will question, flag it
now — Chronicle decides whether it earns an ADR.
