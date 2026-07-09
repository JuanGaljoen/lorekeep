---
name: design
description: Turn an understood problem into the simplest implementation plan. Use after Understand, when the user asks "what's the cleanest way to build this", or before Forge on any non-trivial change.
---

# Design ✍️

*What's the cleanest way to build this?*

**Open by naming the phase:** lead with a one-line banner — `**✍️ Design** — <what you're shaping>` —
so it's clear on the spine which phase is active. Then get on with it.

Design is where you buy simplicity. A few minutes choosing the smallest sound approach saves
hours of untangling a clever one. The output is a plan concrete enough to build against.

## The work

1. **Explore one or two viable approaches.** Not five — just enough to know the obvious path
   isn't hiding a trap. Name the trade-off that separates them.
2. **Choose the simplest that satisfies the success criteria.** The best change is the smallest
   one that solves the real problem. Favour deep modules: a lot of behaviour behind a small
   interface, placed at a clean seam, testable through that interface.
3. **Name the files to modify** — the actual paths, and a line on what changes in each.
4. **Name the tests to write** — which seams, and what behaviour each test pins. Confirm the
   seams with me before Forge writes anything.
5. **Freeze the plan.** Once we agree, that's the plan. Scope creep — "while I'm in here…" — is
   how simple changes become balls of mud. New ideas go on a list for later, not into this change.
6. **If the plan spans more than one checkpoint** (CP1, CP2, …), write it to a durable spec file —
   `specs/<TICKET-KEY>.md` — before Forge starts. This is the **resume artifact**: a fresh session
   (or `/start-ticket`, or Recall) rebuilds the whole picture from it without re-deriving anything,
   so it has to carry the *bar* as well as the *plan* — otherwise a resuming Verify has nothing to
   check against. Include:
   - **Classification** — fix / feature / refactor (from Understand), so a resume knows how much
     process the work earns.
   - **Success criteria** — the definition of done from Understand, verbatim, as a `- [ ]` checklist.
     This is the acceptance bar Verify checks against; if it lives only in the conversation it dies
     with the session.
   - **Approach & contracts** — the chosen approach and the placement/formula/contract details.
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

   ## Checkpoints
   - [ ] CP1 — <slice> · files: <paths>
   - [ ] CP2 — <slice> · files: <paths>
   ```

   Single-checkpoint work doesn't need this — the frozen plan in this response, plus the success
   criteria from Understand, is enough to build and verify in one session.

## Rules

- **Design against the success criteria from Understand**, not against a vague sense of "good".
- **Simplest sound option wins.** If you're reaching for a framework, a new dependency, or an
  abstraction, justify it against the smaller alternative.
- **Surface risks, don't bury them.** Name the two or three things most likely to go wrong.
- **Recommend, don't lay out neutrally.** When you put the approach choice to me as a picker
  (`AskUserQuestion`), the option you'd take **must** be the **first** one, its label ending with
  **"(Recommended)"**, with the *why* in its description. Simplest-sound-option-wins means you have
  a lean — state it. A neutral picker is only for a genuine toss-up; say so if it is one.

## Output

A short plan: the chosen approach and why, the file-change list, the tests to write (with seams),
and the top risks. For a decision that's hard to reverse or that future-us will question, flag it
now — Chronicle will record it as an ADR.
