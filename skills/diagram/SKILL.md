---
name: diagram
description: Draw how the current repo works as an interactive, plain-English map (parts, files, endpoints, screens, flows) using the Floorplan plugin. Use when the user says "diagram this repo", "draw the architecture", "show me the request flow", "floorplan this", "update the diagram", or asks for a picture of how the code works.
---

# diagram 🗺️

A thin wrapper around [Floorplan](https://github.com/haydenschmitty/floorplan) — a plugin that
scans the repo, has the agent name the parts and describe every file, and builds a self-contained,
interactive map at `floorplan/index.html`. We don't draw anything ourselves; this skill owns *when*
and *how* to run it, and what to report.

The map is a **mirror of the code**, not a source of truth. It's regenerated, never hand-maintained.
`floorplan/` is git-ignored by Floorplan itself — nothing in the repo depends on it.

> **Status: experimental.** Publishing the map to Orbit is not wired up yet (Orbit's diagram
> endpoint only accepts Mermaid views). Until Orbit can host the HTML, this skill generates the map
> locally and stops there. Don't invent an upload endpoint.

## Steps

### 1. Check Floorplan is available
It's a Claude Code / Codex plugin and needs Node 18+ (`node --version`). If the `floorplan` skill
isn't listed, don't improvise a substitute — tell me to install it, then start a new session:

```bash
claude plugin marketplace add haydenschmitty/floorplan
claude plugin install floorplan@floorplan
```

(Codex: `codex plugin marketplace add haydenschmitty/floorplan`, then `codex plugin add floorplan@floorplan`.)

### 2. Make or update the map
- No `floorplan/` folder yet → invoke the `floorplan` skill (`/floorplan:floorplan`) with
  *"Make me a floorplan of this app."*
- `floorplan/` exists → *"Update the floorplan."* It re-scans and rewrites only what changed, and
  lights up recent work.

Let Floorplan run its own scripts (`node …`) — that's the mechanical part and costs no tokens. For
a multi-repo app, run from the folder that holds them all.

By default it writes for the app's owner, in everyday words. If I asked for developers, say
*"Rewrite the floorplan for developers."*

### 3. Report
```
Floorplan: <repo> @ <short-sha>   ·   <n> parts · <k> flows
Map: floorplan/index.html   (open it, or `node floorplan/serve.mjs` for the Ask bar)
Health: <anything serious it flagged, or none>
```
If `git status --porcelain` is non-empty, say so — the map reflects the working tree.

## Rules

- **Wrap, don't reimplement.** Floorplan owns scanning, naming and layout. Don't hand-write
  Mermaid or graph JSON here.
- **No upload without a contract.** Pushing to Orbit needs an endpoint I've confirmed. Until then,
  report the local path and stop.
- **Don't commit `floorplan/`.** It ignores itself; leave it that way.
- **Optional extra, not load-bearing.** The workflow works without it. It depends on a third-party
  plugin, so nothing else in lorekeep may require it.
