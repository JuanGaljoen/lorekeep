# lorekeep

A lean, six-phase workflow for doing real engineering with Claude Code.

No orchestrator owns the process. No hook blocks your keystrokes. No state machine to appease.
Just a spine you move along and a handful of small skills that hold the discipline — composable,
easy to adapt, and yours to bend.

```
Recall 📚  →  Understand 🧭  →  Design ✍️  →  Forge ⚒️  →  Verify 🔍  →  Chronicle 📖
```

| Phase | Question | Skill |
|-------|----------|-------|
| **Recall 📚** | What do we already know? | [`skills/recall`](skills/recall/SKILL.md) |
| **Understand 🧭** | What problem are we solving? | [`skills/understand`](skills/understand/SKILL.md) |
| **Design ✍️** | What's the cleanest way to build this? | [`skills/design`](skills/design/SKILL.md) |
| **Forge ⚒️** | Build exactly what's needed. | [`skills/forge`](skills/forge/SKILL.md) |
| **Verify 🔍** | Did we build the right thing? | [`skills/verify`](skills/verify/SKILL.md) |
| **Chronicle 📖** | What should future-us know? | [`skills/chronicle`](skills/chronicle/SKILL.md) |

Plus three off-spine skills, which aren't phases and don't wait for a change to be in flight:

| | Question | Skill |
|-------|----------|-------|
| **Research 🔬** | What does the world know that we don't? | [`skills/research`](skills/research/SKILL.md) |
| **Sweep 🧹** | What in here is no longer earning its place? | [`skills/sweep`](skills/sweep/SKILL.md) |
| **Quiz 🎓** | What do *I* actually know now? | [`skills/quiz`](skills/quiz/SKILL.md) |

## How it works

[`CLAUDE.md`](CLAUDE.md) is the spine — loaded every session. It tells the agent to classify the
work first (question / fix / feature), then walk only the phases the work earns. Each phase is a
skill the agent reaches for automatically, or that you invoke by name (`/recall`, `/forge`, …).

Knowledge lives in two homes: **in-repo** (`CLAUDE.md` for facts + `docs/adr/` for decisions) by default, and
**Obsidian** for the rare lesson that outlives a single repo.

**Research 🔬** is the outward arm of Recall. Recall loads what
*we* know; Research fetches what nobody here does — a trade tolerance, a standard, someone else's API
contract — from primary sources, and leaves a cited note behind so the question is only asked once.
It fires on a deliberately narrow tell: *about to justify a value with reasoning instead of a
citation*. Not doubt — invention. A plausible derivation is indistinguishable from a correct one
until someone checks, so Design researches before freezing a number and Verify treats any constant
without a source as unverified, however green the suite is.

**Sweep 🧹** is the other one, and the only skill you point at a whole repo with nothing in flight.
Verify reads a diff; Sweep reads a codebase, and asks the question a diff review structurally can't:
*is this reachable?* It reports candidates — unreferenced files and exports, orphaned dependencies,
shallow modules worth deepening — tiered by confidence, each carrying **what would make it live**.
That second half is the point, because a reachability graph is a model of the program rather than
the program, and dynamic dispatch, framework convention and serialization all move real calls
outside it. Sweep never deletes: you choose from the list, and what you choose becomes ordinary work
on the spine.

**Quiz 🎓** is the third, and the only one pointed at *you* rather than the code. On a domain you're
still learning, the knowledge flow runs one way: Research fetches the market rule, Forge bakes it
in, Chronicle writes the ADR — and all of it lands in the repo while none of it lands in your head.
Working code is not evidence you could defend it. So at Chronicle, when the work leaned on facts you
had to look up, Quiz offers five questions drawn **only from what this ticket touched** — the change
is the retrieval cue that generic flashcards lack. Open questions, one at a time, graded honestly;
domain rather than our code (*"why does curtailment spike at midday?"*, not *"why did we cache
that?"*). A miss produces one **sourced** link to go read, and a line in a running gap log in
Obsidian that the next quiz opens by re-asking. It never invents an answer or a URL — a quiz makes
you believe things, which is exactly what makes a wrong one expensive.

A third in-repo file is ticket-scoped rather than permanent: when **Design** freezes a plan that
spans multiple checkpoints, it writes `specs/<TICKET-KEY>.md` — the approach, contracts, and
per-checkpoint file list. `start-ticket` and `Recall` read it to resume mid-ticket instead of
re-deriving the design, `Verify` checks off checkpoints there as they land, and `ship` reads them to
deliver. Unlike an ADR (a permanent decision record written by Chronicle), a spec file is working
scaffolding for the life of the ticket — it doesn't need to outlive it.

For a ticket in flight, **the repo is the source of truth** for where things stand — the spec file
and the branch's commits. Jira is a mirror. When they drift (a progress write got interrupted),
`start-ticket` reconciles the tracker from the spec on the next resume; the spec always wins.

## Keeping the token window cheap

On a Pro plan the usage window is the real constraint, so three moves protect it:

- **Model discipline.** Thinking phases (Understand, Design, diagnosis) earn the strong model;
  mechanical phases don't. At each phase boundary the agent recommends the switch when the current
  model doesn't match the phase (e.g. "entering Forge — `/model sonnet` saves your window"). A
  recommendation, not a rule — keeping Opus on a gnarly Forge is your call.
- **The runner agent** ([`agents/runner.md`](agents/runner.md)). Long mechanical runs — a test
  suite, a batch build, a slow loop — go to a **Haiku-pinned** agent instead of idling the session
  model. The pin lives in the agent's frontmatter, so the downshift is config, not a prose request
  that can be skipped. The runner executes, waits, and reports compactly (headline numbers, failing
  output verbatim); it never edits and never diagnoses — judgement comes back to the session. The
  full output dump dies in the runner's context, so only a handful of lines enter yours.
- **The researcher agent** ([`agents/researcher.md`](agents/researcher.md)). Same firewall, applied
  to reading instead of waiting: a **Sonnet-pinned** agent chases claims to primary sources and
  returns a verdict, the numbers with citations, and a confidence rating. Twenty fetched pages die
  in its context; a dozen lines come back. Sonnet rather than Haiku because judging whether a source
  actually owns the answer takes real judgement — but deciding what to do with the finding comes
  back to your session.
- **Disposable context.** Because the spec's ticks and the branch's commits are the complete
  working state, a `/clear` mid-ticket loses nothing — Recall rebuilds from those two and continues
  at the open checkpoint. Clearing a heavy context is a routine move, not a loss.

## Install

```bash
scripts/install.sh
```

This symlinks every skill under `skills/` into `~/.claude/skills/` (so `/recall`, `/forge`, … work
in any session), every agent under `agents/` into `~/.claude/agents/` (the `runner` and the
`researcher`, above), and symlinks the spine to `~/projects/personal/CLAUDE.md`, so Claude Code
auto-loads the workflow for every project under `~/projects/personal/` — and nowhere else. The
script auto-discovers both, so new ones are picked up on the next run.

Alongside the six phases, a few optional skills bridge to the outside world. Two **Jira** skills
bridge the tracker: `start-ticket` (fetch a ticket, branch, and drop onto the spine) and
`file-ticket` (turn understood work into a ticket) — they use the Jira MCP server configured in
`~/.claude.json`. And `ship` (`/ship`) is the delivery tail: once Verify is green, it publishes the
branch and opens the pull request in one motion — the two steps people forget are separate.

The symlinks point back into this repo, so editing a skill here updates your live workflow with no
reinstall, and a `git pull` keeps it current. To remove the symlinks (never the repo):

```bash
scripts/uninstall.sh
```

## Safety floor (the one hook)

lorekeep is prose-first, but prose can only *ask* the model not to do something — it can't
*guarantee* a block. A single `PreToolUse` hook (`hooks/pre_tool_use.py`, stdlib only) is the sole
always-on enforcement. It blocks a short list of catastrophic, hard-to-undo actions and secret
leaks — nothing about style or process:

- catastrophic filesystem wipes (`rm -rf /`, `~`, `$HOME`, `/*`)
- fork bombs
- piping a remote download into a shell (`curl … | sh`)
- raw-disk destruction (`dd of=/dev/…`, `mkfs`, `> /dev/sd…`)
- writing to `.env` / credential files
- writing a hardcoded provider secret (AWS / GitHub / Slack / OpenAI / private key)

Force-push and `git reset --hard` are deliberately *not* blocked — recoverable and often
intentional. The hook fails open: a bug in it never blocks your work. `install.sh` symlinks it into
`~/.claude/hooks/` and registers it globally; `uninstall.sh` removes it.

## Status line

`statusline/statusline.sh` renders model, context usage, and the Pro/Max rate-limit windows — and,
while a test suite is running, a live `⚒ pytest 7m35s` segment. Claude Code's own footer tells
you a shell exists but not *what* it is or how long it's been going, which is the one thing you
want while waiting on a suite. Test runners only (pytest, jest, vitest, mocha, rspec, `go test`,
`cargo test`, `npm test`); matching every background command is noisy and hard to label.
`install.sh` symlinks it into `~/.claude/` and registers it, backing up any existing status line
first; `uninstall.sh` restores it.

## Credit

Shaped by [Matt Pocock's "Skills For Real Engineers"](https://github.com/mattpocock/skills) —
the small-and-composable philosophy and the grilling interview.
