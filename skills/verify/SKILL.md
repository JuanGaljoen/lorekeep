---
name: verify
description: Prove a change is correct before calling it done. Use after Forge, when the user asks "did this actually work", "review this", or before shipping any non-trivial change.
---

# Verify 🔍

*Did we build the right thing?*

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
- **Check every success criterion**, one by one — from the spec's acceptance bar
  (`specs/<TICKET-KEY>.md`, the *Success criteria* checklist) when one exists, else from Understand
  in this session. On a resume the conversation that set the bar is gone, so the spec *is* the bar;
  a Verify with no criteria to check hasn't proven anything. Each should be demonstrably met, with
  evidence — a command's output, a rendered screen — not "I read the code and it looks right".
- **Hunt regressions and edge cases.** Empty, null, error, boundary, the auth edge. Run the full
  test suite — hand a long one to the `runner` agent (Haiku-pinned; it babysits and reports
  compactly) rather than waiting it out on a strong model — and look at what the change is
  adjacent to.

## Is it good — against the standards

- **Follows the repo's conventions** — naming, structure, idiom, the vocabulary in `CLAUDE.md`.
- **Simplicity holds up** — is this still the smallest sound change, or did complexity creep in
  during Forge? Now is when refactoring happens, with tests green.
- **Blast radius understood** — what else touches this code path? Anything downstream affected?
- **Every magic number has a source.** Walk the constants, thresholds and tolerances this change
  introduced or moved, and ask where each one came from. A value justified by reasoning — or worse,
  by how the output looked, or by my reaction to it — is **unverified**, not verified, however
  green the suite is. Tests confirm the code does what you told it; they can't tell you that what
  you told it is right. Send those to **Research 🔬** before you call this done.

## Rules

- **Fix what you find before calling it done.** A finding you noted but didn't address is an open
  bug, not a closed review.
- **Report honestly.** If something fails, show the output and say so. If a criterion is only
  partly met, say which part. Don't declare done to be agreeable.

## Output

A verdict: each success criterion met or not (with evidence), the quality findings and what you
did about them, and any regressions surfaced. If it's not done, say what's left.

## Hand off to Chronicle before delivery

**This is the terminal handoff — it fires when the spine is actually ending:** single-shot work, or
the *final* checkpoint of a multi-checkpoint ticket. For a non-terminal checkpoint, **skip it** —
you're committing and moving to the next checkpoint, not delivering, so Chronicle waits for the end
(see "Close the checkpoint" below, which is what a mid-ticket checkpoint runs instead). Asking
"anything to chronicle?" after every checkpoint is just noise.

Green Verify points at Chronicle, not straight at ship. So **before you offer to ship, ask the
Chronicle question out loud**: did anything here earn a record? A
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
tracker, so if Verify doesn't, Jira drifts from the repo and a fresh session — or `/start-ticket`
resuming — can't tell where things stand. So when a checkpoint lands, record it in the source of
truth, then mirror it:

- **Tick the spec, then commit — together the source-of-truth write.** Check the landed checkpoint
  off in `specs/<TICKET-KEY>.md`, then commit the slice — its code, its tests, and the spec tick —
  on the feature branch, in the repo's house style (match recent commits; no `Co-Authored-By`
  trailer). **This commit is Verify's to make.** It's what makes the closed checkpoint durable in
  the source of truth and gives the mirror a real hash to cite; a checkpoint no one committed is the
  exact gap that used to bite. (The *terminal* checkpoint is the one exception — it flows on to
  Chronicle then ship, which commits and delivers it.)
- **Comment the ticket — the mirror.** One line via `mcp__jira__jira_add_comment`, citing the hash
  from the commit above — what landed and what's next, e.g. *"CP2 complete (side_loc geometry, commit
  `98d15bb`). CP3 (MODULES/ARCHETYPES registration) next — stays In Progress."* If this write is
  interrupted, don't panic — it's only the mirror; the next `/start-ticket` reconcile reposts it from
  the spec (see start-ticket, *"Reconcile the tracker"*).
- **Leave the status alone.** The ticket stays **In Progress** — a checkpoint is not the ticket.
  Transitioning (In Review / Done) is ship's job, at the terminal checkpoint.

Order matters: tick and commit the spec **before** the Jira comment, so an interruption leaves the
mirror stale (recoverable) rather than the source of truth. Ship, when it later delivers, *reads*
this progress rather than re-authoring it — so don't expect ship to re-post per-checkpoint notes.
