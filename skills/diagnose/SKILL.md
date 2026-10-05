---
name: diagnose
description: Find the real cause of a bug before fixing it. Use on the Fix path, when the user reports something broken, pastes an error or stack trace, says "why is this happening" or "debug this", or when a fix attempt didn't hold.
---

# Diagnose 🩺

*What's actually causing this?*

The Fix path's thinking phase — it stands where Design stands on a feature. A fix built on a
guessed cause is a second bug waiting; the job here is to *prove* the cause, so Forge can fix it
in one move. This is judgement work: it belongs on the strong model.

## Process

### 1. Build the loop first

Before any theory, get a **pass/fail signal** for the bug: a failing test, a script, a command
whose output shows the defect. Make it fast and make it deterministic — a flaky loop lies to you.
With a tight loop the cause *will* fall out; without one you're guessing in the dark.

If you can't reproduce it, that's the finding. Say so, and say what you'd need (logs, data, the
exact input) — don't theorise past it.

*Done when:* one command shows the bug, every time.

### 2. Hypotheses you can kill

Each hypothesis is a prediction: *"if X is the cause, then changing Y makes the bug go away."*
Rank them by likelihood × cheapness to test, and run the loop against each. A hypothesis with no
test that could disprove it is a story, not a lead.

Change one thing at a time. Instrument freely — logging, assertions, a bisect — but treat every
probe as temporary.

*Done when:* one hypothesis survived its test and the others died to theirs.

### 3. Pin it at the real seam

The regression test lives where the bug lives — at a seam where it reads like a specification
and would have caught this. If no such seam exists, and the only way to test it is through
internals, **that is a finding**: name it, it's a refactor candidate. Don't bend the test to fit.

This test becomes Forge's red.

*Done when:* a test at the right seam fails for the proven cause.

## Rules

- **Cause before fix.** No patching symptoms while the cause is a guess. If you must ship a
  stopgap, call it one.
- **Look up, don't assume.** If the cause turns on how a library or protocol behaves, read its
  source or send it to **Research 🔬** — not your memory of it.
- **Clean up after yourself.** Every probe from step 2 comes out before Forge hands to Verify.

## Output

The cause, in a sentence, with the evidence that proved it; the hypotheses that died and what
killed them (one line each); and the failing regression test at its seam. The confirmed cause
goes in the fix's commit message — that's where the next person debugging this will look.
