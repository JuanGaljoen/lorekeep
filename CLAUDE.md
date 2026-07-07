# lorekeep

A lean, six-phase workflow for doing real engineering with Claude — not vibe coding.

The philosophy: small, composable, adaptable. No orchestrator owns the process, no hook
blocks your keystrokes, no state machine to appease. Just a spine you move along and six
skills that hold the discipline. Steal from it, bend it, make it yours.

## The spine

```
Recall 📚  →  Understand 🧭  →  Design ✍️  →  Forge ⚒️  →  Verify 🔍  →  Chronicle 📖
```

| Phase | Question | What it does |
|-------|----------|--------------|
| **Recall 📚** | What do we already know? | Load only the knowledge the task needs — repo `CONTEXT.md`, ADRs, past decisions. |
| **Understand 🧭** | What problem are we solving? | Interview until aligned. Clarify, constrain, define success. Classify the work. |
| **Design ✍️** | What's the cleanest way? | Explore one or two approaches, pick the simplest, name the files and tests. Freeze it. |
| **Forge ⚒️** | Build exactly what's needed. | Implement test-first in vertical slices. Only what the plan requires. |
| **Verify 🔍** | Did we build the right thing? | Run it. Check against success criteria. Review quality. Hunt regressions. |
| **Chronicle 📖** | What should future-us know? | Record decisions and patterns worth keeping. Skip the trivial. |

Each phase is a skill under `skills/`. The agent reaches for them as it moves through the
work; you can also invoke any of them by name (`/recall`, `/understand`, …).

## Moving along the spine

**Classify first, then walk only the phases the work earns.**

- **Question** ("how…", "what…", "explain…") — answer directly. No spine.
- **Fix** ("broken", "error", a stack trace) — Recall → Understand (lightly) → reproduce → Forge → Verify → Chronicle (only if the bug was non-obvious).
- **Feature** (new behaviour) — the full spine.

Skip a phase when it adds nothing: a one-line config change doesn't need a Design doc, and a
throwaway fix doesn't need a Chronicle entry. **When in doubt, do the phase.** The cost of a
skipped Understand is building the wrong thing; the cost of an extra question is a minute.

## Model discipline

Thinking phases and doing phases reward different models. Spend the strong model where judgement
lives; use the cheaper, faster one where the work is mechanical.

- **Strong model** (e.g. Opus) — **Understand, Design, diagnose.** Ambiguity, trade-offs, and
  hard bugs are where reasoning pays for itself.
- **Cheaper/faster model** (e.g. Sonnet) — **Forge and routine edits.** Red→green against a frozen
  plan is mechanical; the strong model adds little and burns the budget.

You can't switch the model yourself — only I can (`/model …`). So at each phase boundary, if the
current model doesn't match the phase, **say so and recommend the switch** (e.g. "moving to Forge —
`/model sonnet` saves your window"). This matters most on a Pro plan, where the usage window is the
real constraint. It's a recommendation, not a rule: I may keep the strong model on a gnarly Forge —
my call.

**Before a long or repeated mechanical run on the strong model** — a test suite, a batch build,
watching a slow loop — stop and offer the switch first ("you're on Opus about to run the suite;
`/model sonnet` saves your window — switch, or keep Opus?"), then wait for my answer. Running the
strong model to *wait on pytest* is the most wasteful thing you can do on a limited plan.

Caveat — **auto mode**: in auto mode I won't pause to ask (auto mode is "run, don't check in"), so
there you'll just flag it and continue. If you want the switch offered *before* a run, drop out of
auto for that step.

## Where knowledge lives

Two homes, split by scope. Recall reads from both; Chronicle writes to the right one.

| Scope | Example | Home |
|-------|---------|------|
| **Code-local** | this module's seam, a named concept, why we chose X *in this repo* | `CONTEXT.md` + `docs/adr/` **in the repo** — version-controlled, travels with a clone |
| **Cross-project** | a lesson that bit you in several repos, a pattern you reuse everywhere | **Obsidian** (`~/ObsidianVault/Personal/`) — the only thing that needs an external, cross-repo store |

In-repo is the default. Promote to Obsidian only when the lesson outlives this repo, and keep
it dead simple there: a dated file, a title, a paragraph. No index caps, no schema, no lint.

## Standing principles

- **Simplicity is the job.** The best change is the smallest one that solves the real problem.
  Deep modules: a lot of behaviour behind a small interface.
- **Small, deliberate steps.** The rate of feedback is your speed limit. Vertical slices, not
  big-bang. One test → one implementation → repeat.
- **TDD is guidance, not law.** Red before green where a test earns its keep. Test at seams you
  confirmed with me, through public interfaces — never against internals.
- **Facts are looked up; decisions are mine.** If the codebase can answer it, read the code.
  If it's a judgement call, put it to me.
- **Report honestly.** If tests fail, say so with the output. If a step was skipped, say that.
  When something's done and verified, say it plainly — no hedging.
- **Confirm before the irreversible.** Deletes, pushes, anything outward-facing — check first
  unless I've told you to just go.
