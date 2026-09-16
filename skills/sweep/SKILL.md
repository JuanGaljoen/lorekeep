---
name: sweep
description: Scan a whole repo for code that no longer earns its place — unreachable files and exports, orphaned dependencies, dead cruft, and modules worth deepening — and report ranked candidates with evidence. Use when the user says "sweep", "garbage collect", "find dead code", "what can we delete", or wants a codebase-health pass with no change in flight.
---

# Sweep 🧹

*What in here is no longer earning its place?*

Every other skill on the spine follows a change. Sweep doesn't — you point it at a repo with
nothing in flight and ask what has rotted. It answers in candidates, never in deletions.

It isn't a phase. Like Research 🔬, it's a move you make when you want it, and what it produces
feeds back onto the spine as ordinary work.

## The boundary with Verify

**Verify reads a diff. Sweep reads a repo.** That's the whole split, and it matters because the two
share vocabulary.

Verify's smell baseline (`skills/verify/SKILL.md`, *The smell baseline*) is Fowler's catalogue, and
it's the shared language for *is this good*. Sweep uses that list as-is — don't restate it here and
don't fork a second copy. What Sweep adds is the one question a diff review structurally cannot ask,
because the answer lives outside the diff:

> **Is this reachable at all?**

## Be honest about why

State this plainly when you report, because it's the part most sweeps oversell:

**There is no evidence that dead code causes bugs.** No study isolating unreachable or unused code
as a defect-rate predictor turned up in research; neither did any build-time or onboarding
measurement. The general complexity-and-churn literature exists, but it doesn't isolate *dead* code
as the variable.

The real case is maintenance and comprehension, and it has named backing:

- **Google** (*Software Engineering at Google*, ch. 15) frames unused code as a liability paid
  **continuously**, not once at write time. It also warns the other way: badly run deprecation
  *"may cost more than leaving them alone."* Removal has its own cost.
- **Kent Beck** treats it as zero-ceremony tidying: *"Delete it. That's all. If the code doesn't get
  executed, delete it."*

So sell Sweep on comprehension, not on defect rates. A repo where every file is reachable is one a
newcomer — human or agent — can trust. That's the claim, and it's enough.

Full citations: `docs/research/dead-code-detection-and-removal.md`.

## The method

Language-agnostic by design. Don't arrive with a tool in mind — find the repo's own, or work
without one.

1. **Find the real entry points first.** Everything downstream depends on this being right, and it
   is the step tools get wrong. Entry points are rarely just `main`: CLI bins, route files, task
   registries, migrations, plugin manifests, framework-convention directories, test harnesses, and
   anything named in a build config or `package.json`/`pyproject.toml` script. Read the build
   configuration, not your assumptions about the stack.
2. **Find out what the repo already uses.** A repo with a linter that already flags unused imports
   has settled part of this question; don't relitigate what tooling owns
   (Verify's *skip what tooling enforces* applies here too). Check dev-dependencies and CI config
   before reaching for anything new.
3. **Trace reachability outward** from the entry points, and collect what's left over. If a
   maintained tool for this ecosystem exists and the repo will tolerate it, use it and treat its
   output as **a hypothesis list, not a verdict**. If there isn't one, trace by hand across a
   bounded area rather than guessing across the whole repo.
4. **Attack your own list** with the five blind spots below. This is the step that makes Sweep
   trustworthy rather than dangerous; a candidate that hasn't survived it doesn't get reported.
5. **Rank what survives** into the three tiers below.
6. **Then, and separately, look for refactor candidates** — the second axis. Walk `git log
   --oneline` for hot spots and read those for shallowness: modules whose interface is nearly as
   complex as their implementation, seams that leak, concepts that require bouncing between files
   to understand. Apply the **deletion test** to each: *would deleting this concentrate complexity,
   or just move it?* "Concentrates" is the signal worth reporting. These are proposals for work, not
   cleanups — keep them in their own section, well clear of the deletion candidates.

Long scans go to the **`runner` agent**; broad reads go to a sub-agent. Neither the raw tool output
nor a directory-by-directory read belongs in the main session's context.

## The five ways the tools lie

Every dead-code tool across every ecosystem documents its own false positives, and they converge on
the same five classes. knip's own FAQ puts it bluntly: **"You will get false positives on day one."**
Its recommended remedy is not to trust the output but to budget time tuning entry points first.
Treat any tool's output accordingly.

Code that is live but will be reported dead:

1. **Dynamic or computed reference** — `import(someVariable)`, reflection, string-keyed dependency
   injection, anything assembled at runtime from a name. Invisible to static analysis by
   construction.
2. **Framework-convention entry points** — routes, migrations, plugin registries, CLI bins, config
   files loaded by string. Live only because a framework knows where to look; the tool doesn't
   unless a plugin taught it.
3. **Serialization targets** — a field only ever set by a JSON decoder, an ORM, or a wire format.
   Nothing in the codebase assigns it, and it is still load-bearing.
4. **Test-only usage** — many tools don't load test files into the graph by default, so a helper
   used exclusively by tests reads as orphaned.
5. **A library's public API** — for anything consumed from outside this repo, "no internal caller"
   is the **correct** state, not a defect. Establish whether the repo is an application or a library
   before you report a single unused export.

Two more worth carrying:

- **Build-config blindness.** A reachability graph is usually valid for exactly one build
  configuration — one platform, one feature-flag set, one set of tags. Code dead under the config
  you scanned can be live under another.
- **The converse case, which no tool catches.** Code statically reachable from an entry point but
  never actually executed — an error branch that can't fire, a feature-flag path switched off two
  years ago. Static analysis answers *reachable*; only coverage answers *exercised*. If the repo has
  coverage data, read it as a second signal; production sampling is the stronger version of it
  (Coverband's operators removed tens of thousands of lines that way), but that's a tool to propose,
  not to install mid-sweep.

## Rank by confidence, and say what would disprove each

Every candidate carries **the evidence that it's dead** and **what would make it live** — the
specific blind spot that could be hiding a caller. A candidate without its counter-evidence is an
invitation to delete something load-bearing.

- **Tier 1 — Safe.** Unreferenced, in an application (not a library), no dynamic-reference pattern
  anywhere near it, and reachability confirmed by more than one signal. Commented-out blocks and
  obviously orphaned files land here. Deleting these needs no argument.
- **Tier 2 — Likely, needs a human.** Unreferenced but touching one of the five classes, or
  reachable but apparently unexercised. Name the specific doubt: *"no static caller, but the module
  loads its handlers by string — check the registry."*
- **Tier 3 — Ask why the fence is there.** Something whose purpose isn't clear from the code.
  Chesterton's Fence applies: don't propose removing what you can't explain. Report it as a question
  — *what is this for?* — not as a candidate. (This framing is folklore rather than a citable source;
  it's a good instinct, not an authority.)

Sort by tier, then by size of the win. A tier-1 list that is honestly short beats a long list padded
with tier-2 guesses.

## Sweep does not delete

Sweep reports. **The deletion is a separate, explicit act** — you pick from the candidates, and what
you pick becomes ordinary work on the spine, or a ticket via `/file-ticket`.

Two reasons this line is firm. Removal has its own cost, and a sweep that deletes has already
decided that cost is worth paying on your behalf. And the tiers above exist precisely because some
candidates are wrong — acting on them automatically would spend the one thing the tiering was built
to protect.

When the removal work does happen: small reviewable commits with the suite green between them, not
one big sweep. Version control genuinely does make this cheap to reverse — so the appropriate
posture is bold, not timid — but "git remembers" is an argument for deleting confidently, not for
deleting unreviewably.

## Rules

- **Scope the sweep before running it.** A whole monorepo produces a list no one reads. Take a
  package, a directory, a layer — and say what you scanned and what you didn't.
- **Never report a candidate you haven't attacked.** Running the tool is step three of six. Handing
  over raw tool output is not a sweep.
- **A null result is a real result.** "This package is clean" is worth saying, and worth trusting
  more than a padded list.
- **Don't fix what you find.** Not even the obvious one-liner. Sweep's output is a list; the moment
  it starts editing it has stopped being a sweep and become an unplanned refactor.
- **The repo overrides.** A documented convention beats anything here, and tooling that already owns
  a check owns it.

## Output

Two sections, kept apart:

**Dead code** — candidates by tier, each with its path, why it looks dead, and what would make it
live. Say what was scanned and what wasn't.

**Refactor candidates** — shallow modules and leaky seams worth deepening, each with its deletion-test
answer, marked `Strong` / `Worth exploring` / `Speculative`.

Then one line: what you'd do first, if it were yours.
