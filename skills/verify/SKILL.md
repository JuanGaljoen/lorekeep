---
name: verify
description: Prove a change is correct before calling it done. Use after Forge, when the user asks "did this actually work", "review this", or before shipping any non-trivial change.
---

# Verify 🔍

*Did we build the right thing?*

Forge makes the tests pass. Verify proves the change actually does what Understand asked for, and
that it didn't break anything on the way. Two axes: does it work, and is it good.

## Does it work — against the spec

- **Run it.** Not just the unit tests — exercise the real behaviour end to end. Drive the flow a
  user would drive, and observe the result. "The tests pass" is necessary, not sufficient.
- **Check every success criterion** from Understand, one by one. Each should be demonstrably met,
  with evidence — a command's output, a rendered screen — not "I read the code and it looks right".
- **Hunt regressions and edge cases.** Empty, null, error, boundary, the auth edge. Run the full
  test suite and look at what the change is adjacent to.

## Is it good — against the standards

- **Follows the repo's conventions** — naming, structure, idiom, the vocabulary in `CONTEXT.md`.
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
