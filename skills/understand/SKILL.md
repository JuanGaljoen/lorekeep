---
name: understand
description: Close the alignment gap before writing code. Use when a request is ambiguous, when the user says "grill me", "interview me", "help me think this through", or before any non-trivial fix or feature so you build the right thing.
---

# Understand 🧭

*What problem are we solving?*

**Open by naming the phase:** lead with a one-line banner — `**🧭 Understand** — <the gap you're closing>` —
so it's clear on the spine which phase is active. Then get on with it.

The most common failure in software is misalignment: you build a thing, and it turns out that
wasn't what was wanted at all. This phase closes that gap **before** any code exists.

## The interview

Interview me relentlessly about this change until we reach a shared understanding. Walk down
each branch of the decision tree, resolving dependencies between decisions one at a time.

- **Ask one question at a time.** Wait for my answer before the next. A wall of questions is
  bewildering and gets shallow answers.
- **For each question, give your recommended answer.** Don't just ask — propose, and let me
  correct you. That's faster and surfaces your assumptions. When you present the choice as a
  picker (`AskUserQuestion`), the recommended option **must** be the **first** option and its
  label **must** end with **"(Recommended)"** — never lay the options out neutrally and leave me
  to infer your steer. Reserve a neutral picker (no recommendation) for the rare case where you
  genuinely have no lean; then say so in the prompt.
- **Look up facts; ask about decisions.** If the codebase can answer it, go read the code. The
  *decisions* are mine — put each one to me and wait.
- **Don't start building until I confirm** we've reached a shared understanding.

## What we're pinning down

- **The real problem** — not the solution I first reached for. Why do we want this?
- **Constraints and assumptions** — what must stay true, what we're taking for granted.
- **Success criteria** — how we'll both know it's done and correct. Concrete and checkable.
- **The shape of the work** — is this a *question* (just answer it), a *fix* (reproduce first),
  or a *feature* (full spine)? This decides how much process the rest of the work earns.

## Close with a recommendation

Don't end on a neutral problem statement and leave me to infer the direction. Once we're aligned,
state your **recommendation**: the direction you'd take and *why*, in plain terms — the approach
you'd reach for, the trade-off you're accepting, the risk you're watching. Make it concrete enough
that I can accept it, refine it, or reject it in one read.

This doesn't cross into Design (which works the direction into a plan, files, and tests) — it's
the synthesized read that *points* at Design. And it doesn't take the decision from me: a
recommendation is how you help me decide, not a substitute for my call. State it plainly, then
wait for my steer.

## Output

A crisp statement of the problem, the constraints, the success criteria, and the classification —
plus your recommendation on how to proceed — enough that Design can start without re-asking. On
multi-checkpoint work the **success criteria and the classification outlive this conversation**:
Design writes them into `specs/<TICKET-KEY>.md` as the durable acceptance bar a resuming Verify
checks against, so make them concrete enough to survive into a file a later session reads cold. If
the work touches project vocabulary that's fuzzy or overloaded, note it for a `CLAUDE.md` update.
