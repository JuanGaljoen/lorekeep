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
| **Recall 📚** | What do we already know? | Load only the knowledge the task needs — repo `CLAUDE.md`, ADRs, past decisions. |
| **Understand 🧭** | What problem are we solving? | Interview until aligned. Clarify, constrain, define success. Classify the work. |
| **Design ✍️** | What's the cleanest way? | Explore one or two approaches, pick the simplest, name the files and tests. Freeze it. |
| **Forge ⚒️** | Build exactly what's needed. | Implement test-first in vertical slices. Only what the plan requires. |
| **Verify 🔍** | Did we build the right thing? | Run it. Check against success criteria. Review quality. Hunt regressions. |
| **Chronicle 📖** | What should future-us know? | Record decisions and patterns worth keeping. Skip the trivial. |

Off-spine, reachable from any phase: **Research 🔬** (what does the world know that we don't?),
**Sweep 🧹** (what's no longer earning its place?), **Quiz 🎓** (what do *I* actually know now?).

Each phase is a skill under `skills/`. The agent reaches for them as it moves through the
work; you can also invoke any of them by name (`/recall`, `/understand`, …).

**Research 🔬 is off-spine, reachable from any phase.** The six phases assume the facts are
available; when a decision turns on one that isn't — a trade tolerance, a standard, someone else's
API contract — `skills/research` fetches it from primary sources. It fires on a narrow tell: *about
to justify a value with my own reasoning instead of a citation*. Not doubt — invention. Understand
and Design use it to get the number right up front; Verify uses it to catch one that was invented.

**Quiz 🎓 is off-spine too, and it's the one that points at me.** Chronicle writes what the work
taught *to the repo*; `skills/quiz` writes it *to me* — same moment, different destination, and only
one of them still works away from the keyboard. On a domain I'm learning, correct code is no
evidence I could defend it, and that gap compounds silently. So at **Chronicle**, when the work
leaned on domain facts you had to look up, offer it in one line — *"Want a 🎓 quiz on the
capacity-market side of this? (5 questions, ~5 min)"* — and drop it if I say no. Never a gate before
ship, never unasked, and never on a refactor whose domain content is zero. Questions come only from
what this ticket touched, they're about the domain rather than our code, and a missed one produces
one real sourced link to go read — never an invented answer or an invented URL.

## Moving along the spine

**Classify first, then walk only the phases the work earns.**

- **Question** ("how…", "what…", "explain…") — answer directly. No spine.
- **Fix** ("broken", "error", a stack trace) — Recall → Understand (lightly) → reproduce → Forge → Verify → Chronicle (only if the bug was non-obvious).
- **Feature** (new behaviour) — the full spine.

Skip a phase when it adds nothing: a one-line config change doesn't need a Design doc, and a
throwaway fix doesn't need a Chronicle entry. **When in doubt, do the phase.** The cost of a
skipped Understand is building the wrong thing; the cost of an extra question is a minute.

**Name the phase as you enter it.** Whether you walk the spine organically or via `/<skill>`, open
each phase with a one-line banner so I always know where on the spine we are — the phase name, its
emoji, and a clause on what it's doing here:

> **🧭 Understand** — pinning CP4's request contract before any code

Use the spine's emojis (Recall 📚 · Understand 🧭 · Design ✍️ · Forge ⚒️ · Verify 🔍 · Chronicle 📖 ·
ship 🚢). One line, then get on with the work — don't turn it into a header block.

**Delivering the work.** The spine ends at knowledge, not delivery. When Verify is green and you
want it on the remote, `/ship` publishes the branch and opens the PR in one motion (they're two
separate steps otherwise). Optional and outward-facing — it confirms before opening the PR.

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

**Long mechanical runs never wait on the strong model.** A test suite, a batch build, watching a
slow loop — hand it to the **`runner` agent** (`agents/runner.md`, pinned to Haiku): it executes the
command, waits it out, and returns a compact report — headline numbers, failing output verbatim. No
pause, no asking; the downshift is config, not a request that can be forgotten. The full dump stays
in the runner's context, so only the distilled report enters this session. Diagnosing a failure is
judgement — that comes back here, to the strong model.

**Reading the web never happens in this session either.** Research goes to the **`researcher` agent**
(`agents/researcher.md`, pinned to Sonnet) — it chases claims to primary sources, writes a cited
note, and returns a verdict with numbers and confidence. Same firewall: twenty fetched pages die in
its context, a dozen lines come back. Sonnet rather than Haiku because judging whether a source
actually owns the answer takes more than the runner needs. Deciding what to *do* with the finding
stays here.

Caveat — **auto mode**: in auto mode I won't pause to answer the phase-boundary offer (auto mode is
"run, don't check in"), so there you'll just flag it and continue.

## Where knowledge lives

Two homes, split by scope. Recall reads from both; Chronicle writes to the right one.

| Scope | Example | Home |
|-------|---------|------|
| **Code-local** | this module's seam, a named concept, why we chose X *in this repo* | `CLAUDE.md` (facts, conventions, vocabulary) + `docs/adr/` (dated decisions & lessons) **in the repo** — version-controlled, travels with a clone |
| **Cross-project** | a lesson that bit you in several repos, a pattern you reuse everywhere | **Obsidian** (`~/ObsidianVault/Personal/`) — the only thing that needs an external, cross-repo store |

In-repo is the default. Promote to Obsidian only when the lesson outlives this repo, and keep
it dead simple there: a dated file, a title, a paragraph. No index caps, no schema, no lint.

## Source of truth for work in flight

Knowledge has two homes above. *Work-in-progress state* — which checkpoint has landed, what's next
— has exactly one. **The repo is the source of truth: the spec file (`specs/<TICKET-KEY>.md`) and
the branch's commits. Jira is a mirror.** When the spec and the tracker disagree, the spec wins;
the tracker is what drifted.

This matters because state is written by hand from more than one place — Verify ticks the spec and
comments Jira, ship transitions the ticket — and any of those writes can be interrupted. Rather than
hope every write always fires, one is authoritative and the rest are recoverable:

- **The spec tick is the load-bearing write.** Checking a checkpoint off in `specs/<TICKET-KEY>.md`
  is what makes it done. The Jira comment is a courtesy mirror — miss it and nothing is lost, only
  the mirror goes stale.
- **Reconcile is the recovery action.** Bringing Jira back in line with the spec is a single,
  idempotent step (see start-ticket, *"Reconcile the tracker"*) — safe to run any time, a no-op when
  they already agree. Recovery never depends on every earlier step having fired perfectly.

The payoff of one authoritative home: **the conversation is disposable.** The spec's ticks plus the
branch's commits are the complete working state, so a `/clear` mid-ticket costs nothing — Recall
rebuilds from those two and continues at the open checkpoint. Clearing a heavy context is a routine
token-saving move, not a loss to be avoided.

Disposable isn't the same as worthless, so **rule out simply continuing first.** Clearing costs
nothing *when the spec holds everything the next phase needs* — true at a checkpoint boundary, false
in the middle of one. The case that catches people is Understand → Forge: the build wants the
reasoning verbatim, and the spec carries the plan, not the argument behind it. Clear at the
boundaries between checkpoints, not inside one.

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
- **Say the least that lands.** The report is for me, not for you. Lead with the decision I have
  to make; put the reasoning under it, short. If a paragraph doesn't change what I do next, cut
  it. Length is not thoroughness — it's the cost I pay to find the one line I needed.
- **Confirm before the irreversible.** Deletes, pushes, anything outward-facing — check first
  unless I've told you to just go.
