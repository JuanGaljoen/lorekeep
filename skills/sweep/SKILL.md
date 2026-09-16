---
name: sweep
description: Scan a whole repo for code that stopped earning its place — unreachable files and exports, orphaned dependencies, shallow modules worth deepening — and report ranked candidates with evidence. Use for "sweep", "garbage collect", "find dead code", "what can we delete", or a codebase-health pass with no change in flight.
---

Every other skill on the spine follows a change. Sweep is pointed at a repo with nothing in flight,
and asks the one question a diff review structurally cannot, because the answer lives outside the
diff: **is this reachable?**

Verify reads a diff; Sweep reads a codebase. Where the two overlap — judging whether code is any
good — Verify's smell baseline (`skills/verify/SMELLS.md`) is the single source for that vocabulary,
and Sweep consults it rather than holding its own copy.

Sweep reports. The candidates it produces become ordinary work on the spine, or a ticket via
`/file-ticket`, once you choose from them.

## Reachability is a hypothesis, not a verdict

A reachability result is evidence about a graph, and the graph is always a model of the program
rather than the program itself. Dynamic dispatch, framework convention and serialization all move
real calls outside it. Tool authors say so themselves: the standard remedy for their output is an
afternoon of tuning entry points before anyone deletes on it.

So every candidate carries two things — **why it looks dead**, and **what would make it live**. The
second is the load-bearing half. A candidate whose counter-evidence you haven't looked for is a
hypothesis dressed as a finding, and acting on it spends exactly what the tiers below protect.

The blind spots that generate false positives are in [BLIND-SPOTS.md](BLIND-SPOTS.md). Read it
before step 4; it's what makes that step mean something.

## Process

### 1. Scope the sweep

A whole monorepo produces a list no one reads. Take a package, a directory, a layer — whatever the
user named, or the area whose commit history is busiest.

*Done when:* the boundary is stated, and you can say what falls outside it.

### 2. Find the real entry points

Everything downstream rests on this, and it's the step tools get wrong. Entry points run well past
`main`: CLI bins, route files, task registries, migrations, plugin manifests, framework-convention
directories, test harnesses, anything named in a build config or package manifest. Read the build
configuration — it's the source of truth for what the program actually starts from.

Establish here whether this is an application or a library. For a library's public API, "no internal
caller" is the correct state, and reporting it as dead is the single most expensive mistake a sweep
can make.

*Done when:* every entry point traces back to something in the environment that names it — a config
key, a manifest script, a framework convention — rather than to your assumption about the stack.

### 3. Trace outward and collect the leftovers

Prefer what the repo already has. A linter that flags unused imports has settled part of this, and
whatever CI already runs owns its own checks. Reach for a new tool only where the repo has none.

Treat any tool's output as a hypothesis list. Where no maintained tool exists for the ecosystem,
trace by hand across the scoped area, which is why step 1 keeps the area small.

Long scans go to the **`runner` agent** and broad reads to a sub-agent, so raw output stays out of
the main context.

*Done when:* every leftover has a path and a reason it surfaced.

### 4. Attack your own list

Take each candidate through [BLIND-SPOTS.md](BLIND-SPOTS.md) and try to prove it live. Search for
the dynamic reference, the registry that loads it by string, the decoder that fills it, the test
that's its only caller.

*Done when:* every surviving candidate carries the specific counter-evidence you looked for and
failed to find. Candidates that don't clear this bar leave the list.

### 5. Rank what survives

- **Tier 1 — safe.** Unreferenced, in an application, clear of every blind spot, confirmed by more
  than one signal. Commented-out blocks and orphaned files land here. These need no argument.
- **Tier 2 — likely, needs a human.** Unreferenced but touching a blind spot, or reachable yet
  apparently unexercised. Name the doubt exactly: *"no static caller, but the module loads handlers
  by string — check the registry."*
- **Tier 3 — a fence.** Something whose purpose the code doesn't explain. Chesterton's Fence
  applies, so report it as the question *what is this for?* rather than as a candidate.

Sort by tier, then by size of win. An honestly short tier 1 beats a long list padded with tier 2.

*Done when:* every candidate sits in exactly one tier and carries its counter-evidence.

### 6. Look for refactor candidates, separately

The second axis, and a different question: not *is this reachable* but *is this shaped well*. Walk
`git log --oneline` for hot spots and read those for shallowness — modules whose interface is nearly
as complex as their implementation, seams that leak, concepts that need three files to understand.

Apply the **deletion test** to each: would deleting this concentrate complexity, or just move it?
"Concentrates" is the signal worth reporting.

These are proposals for work rather than cleanups, so they stay in their own section, clear of the
deletion candidates.

*Done when:* each carries its deletion-test answer and a strength of `Strong`, `Worth exploring`, or
`Speculative`.

## Rules

- **Sweep reports; you choose; the spine does the work.** Removal carries its own cost, and a sweep
  that deletes has decided that cost is worth paying on your behalf.
- **Report what you scanned and what you left out.** A sweep's silence about an area reads as a
  clean bill of health for it.
- **A null result is a real result.** "This package is clean" is worth saying, and worth more trust
  than a padded list.
- **Leave what you find intact, including the obvious one-liner.** The moment Sweep edits, it has
  become an unplanned refactor with no plan behind it.
- **The repo overrides.** A documented convention wins, and a check that tooling already owns stays
  with the tooling.

## Output

Two sections, kept apart.

**Dead code** — candidates by tier, each with its path, why it looks dead, and what would make it
live. State the scope and what fell outside it.

**Refactor candidates** — shallow modules and leaky seams, each with its deletion-test answer and
strength.

Then one line on what you'd do first.

Say plainly what the case rests on: comprehension and maintenance cost, not defect rates — no
evidence connects dead code to bugs.
