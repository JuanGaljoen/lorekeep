---
name: forge
description: Implement a frozen plan with minimal complexity, test-first. Use when the user wants to build the change, mentions "red-green-refactor" or TDD, or when Design has produced a plan ready to build.
---

# Forge ⚒️

*Build exactly what's needed.*

**Open by naming the phase:** lead with a one-line banner — `**⚒️ Forge** — <what you're building>` —
so it's clear on the spine which phase is active. Then get on with it.

Implementation. Build only what the plan requires, in small verifiable steps, with tests leading
where they earn their keep.

## The loop — vertical slices

Work one slice at a time, not all-tests-then-all-code:

**one seam → one failing test → minimal code to pass → repeat.**

Each test is a tracer bullet: it responds to what the last slice taught you. Horizontal slicing
(bulk tests up front) verifies *imagined* behaviour and locks you into a structure before you
understand the implementation.

- **Red before green.** Write the failing test first, then only enough code to pass it. It must
  fail because the behaviour is missing — not because of a typo or an import error.
- **Test at confirmed seams, through public interfaces.** Never against internals. A good test
  reads like a specification and survives a refactor.
- **No tautological tests.** The expected value must come from an independent source of truth — a
  known-good literal, a worked example, the spec — not recomputed the way the code computes it.
- **One slice at a time.** One seam, one test, one minimal implementation per cycle.

## Rules

- **Minimum to satisfy the plan.** No speculative features, no "while I'm here". YAGNI.
- **Stay in the frozen plan.** A genuinely new idea goes on the list for later, not into this
  change. If the plan is wrong, stop and say so — don't quietly build something else.
- **Follow the repo's existing patterns.** Match the surrounding code's naming and idiom.
- **Refactoring is not part of this loop.** Cleanup belongs to Verify, with tests green.

## Output

The change: files created or modified (paths + a line each), the tests and what they cover, and
all test results. Note any deviation from the plan, with the reason.
