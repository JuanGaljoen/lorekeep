---
name: verify
description: Prove a change is correct before calling it done. Use after Forge, when the user asks "did this actually work", "review this", or before shipping any non-trivial change.
---

# Verify 🔍

*Did we build the right thing?*

**Open by naming the phase:** lead with a one-line banner — `**🔍 Verify** — <what you're proving>` —
so it's clear on the spine which phase is active. Then get on with it.

Forge makes the tests pass. Verify proves the change actually does what Understand asked for, and
that it didn't break anything on the way. Two axes: does it work, and is it good.

## Trust the oracle first

"The tests pass" only means something if the tests are worth passing. Before you trust green, vet
the tests that gate this change — **especially any you inherited or didn't write.** Green from an
unvetted oracle is not evidence.

Fast checks (minutes, not a project):

- **Does it fail on a known-bad?** A test currently red on a real defect has proven it can
  discriminate. A test that's always green proves nothing.
- **Mutation check** — break the code on purpose (comment out the step, zero a constant) and
  confirm the test goes red. If it stays green, that test is asleep: fix it, or don't trust it.
- **No tautology** — the expected value must come from an independent source of truth (a known-good
  literal, a worked example, an objective property of the output), not recomputed the way the code
  computes it.
- **At a seam** — it exercises the public interface and observes behaviour, not private internals.
- **Fast enough to run** — a suite too slow to run in the loop can't drive one. Carve a quick
  subset for iteration; keep the slow full set as an occasional gate.

You don't re-vet trusted tests every time — **vet on first encounter or unknown provenance, then
trust.** But until the oracle is vetted, treat green as unproven, not as done.

## Does it work — against the spec

- **Run it.** Not just the unit tests — exercise the real behaviour end to end. Drive the flow a
  user would drive, and observe the result. "The tests pass" is necessary, not sufficient.
- **Check every success criterion** from Understand, one by one. Each should be demonstrably met,
  with evidence — a command's output, a rendered screen — not "I read the code and it looks right".
- **Hunt regressions and edge cases.** Empty, null, error, boundary, the auth edge. Run the full
  test suite and look at what the change is adjacent to.

## Is it good — against the standards

- **Follows the repo's conventions** — naming, structure, idiom, the vocabulary in `CLAUDE.md`.
- **Simplicity holds up** — is this still the smallest sound change, or did complexity creep in
  during Forge? Now is when refactoring happens, with tests green.
- **Blast radius understood** — what else touches this code path? Anything downstream affected?

## Rules

- **Fix what you find before calling it done.** A finding you noted but didn't address is an open
  bug, not a closed review.
- **Report honestly.** If something fails, show the output and say so. If a criterion is only
  partly met, say which part. Don't declare done to be agreeable.

## Output

A verdict: each success criterion met or not (with evidence), the quality findings and what you
did about them, and any regressions surfaced. If it's not done, say what's left.

## Hand off to Chronicle before delivery

Green Verify points at Chronicle, not straight at ship — the spine ends at knowledge. So **before
you offer to ship, ask the Chronicle question out loud**: did anything here earn a record? A
surprising bug, a decision that was hard to reach, a lesson the next person will trip on. If a
verify turned up a real one — a stale proxy, a sharp dependency edge — name it and ask whether it's
worth an ADR, rather than burying the rationale in an in-line comment and moving on.

- **Something worth keeping** → say so and offer `/chronicle` before `/ship`.
- **Genuinely nothing** → say "nothing worth chronicling here" explicitly, then it's clear to ship.

Either way the decision is **visible and mine** — never silently skipped.

## Close the checkpoint — keep the tracker honest

**Multi-checkpoint tickets only.** This fires when `specs/<TICKET-KEY>.md` exists **and** this green
Verify closed one checkpoint with more still to come. No spec file → single-shot work → skip this
entirely; ship moves the ticket when it delivers.

A checkpoint is done the moment its slice passes Verify — but that's usually not a ship (you commit
it and move to the next checkpoint on the same branch). Between ships, nothing else talks to the
tracker, so if Verify doesn't, Jira silently drifts from the repo and a fresh session — or
`/start-ticket` resuming — can't tell where things stand. So when a checkpoint lands, record it in
the two places that must agree:

- **Tick the spec.** Check off the landed checkpoint in `specs/<TICKET-KEY>.md`.
- **Comment the ticket.** One line via `mcp__jira__jira_add_comment` — what landed and what's next,
  e.g. *"CP2 complete (side_loc geometry, commit `98d15bb`). CP3 (MODULES/ARCHETYPES registration)
  next — stays In Progress."* Include the commit hash when the checkpoint is committed.
- **Leave the status alone.** The ticket stays **In Progress** — a checkpoint is not the ticket.
  Transitioning (In Review / Done) is ship's job, at the terminal checkpoint.

The spec and the Jira comment should tell the same story. Ship, when it later delivers, *reads* this
progress rather than re-authoring it — so don't expect ship to re-post per-checkpoint notes.
