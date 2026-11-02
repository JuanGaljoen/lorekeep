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

> **Status: experimental.** The map can be pushed to Orbit, where it shows as the project's **Map**
> tab (the full Floorplan screen). That needs Orbit's `floorplan` endpoint (contract below). If it
> isn't deployed yet (404), the skill stops at the local map. Don't invent any other upload path.

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

### 3. Push to Orbit — only if a project is in play
Skip when there is no Orbit project (no ticket key, no `$ORBIT_URL`/`$ORBIT_API_TOKEN`) — the local
map is the result. The project key is the ticket-key prefix (`RNG-28` → `RNG`) from the spec or
branch; if it isn't obvious, ask me. Don't print the token; test it with `[ -n "$ORBIT_API_TOKEN" ]`.

Send `floorplan/graph.json` as it is, except blank the machine path (`meta.root`) and attach the
commit it was drawn from:

```bash
jq --arg c "$(git rev-parse HEAD)" '{commit:$c, graph:(.meta.root=null)}' floorplan/graph.json |
curl -s -X PUT "$ORBIT_URL/api/v1/projects/<KEY>/floorplan" \
  -H "Authorization: Bearer $ORBIT_API_TOKEN" -H 'content-type: application/json' --data-binary @-
```

- **2xx** → the Map tab shows it. Report `$ORBIT_URL/projects/<KEY>`.
- **404** → Orbit doesn't have the endpoint yet. Say so, keep the local map, stop.
- **422** → the body names the problem. Fix it; never retry blindly.
- **413, or a 422 about size** → the graph is over Orbit's 4 MB cap. Say so, keep the local map,
  stop. Don't trim the graph by hand; map a narrower root or ask me.
- Push the *whole* graph every time; the endpoint replaces, it doesn't merge.
- A dirty tree means the map isn't any commit's. Still push, but say so in the report.

### 4. Report
```
Floorplan: <repo> @ <short-sha>   ·   <n> parts · <k> flows
Map: floorplan/index.html   (open it, or `node floorplan/serve.mjs` for the Ask bar)
Orbit: <pushed to <KEY> | skipped — no project | endpoint not deployed (404)>
Health: <anything serious it flagged, or none>
```
If `git status --porcelain` is non-empty, say so — the map reflects the working tree.

## Rules

- **Wrap, don't reimplement.** Floorplan owns scanning, naming and layout. Don't hand-write
  Mermaid or graph JSON here — the pushed graph is Floorplan's own `graph.json`, unmodified apart
  from `meta.root`.
- **Only the one contract.** `PUT /api/v1/projects/<KEY>/floorplan` with `{commit, graph}` is the
  only Orbit upload. Never push HTML, never hand-build or edit the graph, never invent another path.
- **Don't commit `floorplan/`.** It ignores itself; leave it that way.
- **Optional extra, not load-bearing.** The workflow works without it. It depends on a third-party
  plugin, so nothing else in lorekeep may require it.
