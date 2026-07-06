---
name: recall
description: Load only the knowledge a task needs before starting. Use at the start of any fix or feature, or when the user asks "have we done this before", "what did we decide about X", or "what do we already know here".
---

# Recall 📚

*What do we already know?*

Before designing or building, spend a few minutes loading the knowledge this specific task
needs — and nothing more. The goal is a short brief you carry into Understand and Design, not a
research essay.

## Where to look, in order

1. **`CONTEXT.md`** (repo root, if it exists) — the shared vocabulary. Read it so your names and
   questions match the project's language.
2. **`docs/adr/`** (or wherever this repo keeps ADRs) — past decisions in the area you're
   touching. A decision already made is a question you don't have to re-litigate.
3. **The code itself** — existing patterns, the seam you'll work at, how similar things are done
   here. Facts live in the code; read it rather than guessing.
4. **Obsidian** (`~/ObsidianVault/Personal/`) — *only* if the task smells like something hit
   before in another repo. Don't trawl the vault for routine work.

## Rules

- **Scope to the task.** Load what this change needs. Resist reading the whole codebase.
- **Skip if nothing relevant exists.** Greenfield work or a trivial change may have nothing to
  recall — say so and move on. An empty Recall is a valid Recall.
- **Facts, not decisions.** Recall surfaces what's already known and decided. It doesn't make new
  choices — that's Understand and Design.

## Output

A short brief: the relevant vocabulary, prior decisions that constrain this work, the patterns to
follow, and the integration points the change will touch. A handful of lines, with `file:line`
refs where they help.
