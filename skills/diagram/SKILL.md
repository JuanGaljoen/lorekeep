---
name: diagram
description: Draw the current repo's architecture as a Mermaid flowchart and push it to its Orbit project. Use when the user says "diagram this repo", "draw the architecture", "update the Orbit diagram", or asks for a picture of how the modules connect.
---

# diagram 🗺️

An Orbit bridge, like `start-ticket` and `ship`: it publishes something derived from the repo
rather than doing work on the spine. The diagram is a **mirror of `HEAD`**, not a source of truth —
it's regenerated, never hand-maintained, so a stale one is fixed by running this again.

The cost discipline is the point. A dependency graph is built by a pipeline, not by reading source
files into the session: the only files read in full are `package.json` (or `pyproject.toml`), the
directory tree and `CLAUDE.md`.

## Steps

### 1. Read the frame
- `package.json` / `pyproject.toml` — what the project *is*, its entry scripts, its real
  dependencies (the import counts below include noise; the manifest says what's installed).
- The directory tree, not the file list: `git ls-tree -r -d --name-only HEAD | awk -F/ 'NF<=3'`.
- `CLAUDE.md` — the project's own vocabulary for its layers. Name nodes the way it does.

### 2. Count the links between modules
This greps import lines out of the committed tree, resolves each to a repo path or an external
package, groups paths by their first two directories (`src/` stripped — `app/api`, `server/db`,
`components`), and counts links between groups. It reads `HEAD`, so the result matches the commit
the diagram is sent with. JS/TS (`import`, `export … from`, `require`, dynamic `import()`, `@/` and
`~/` aliases) and Python (absolute and relative).

```bash
{ git ls-tree -r -d --name-only HEAD | sed 's/^/D /'
  git grep -I -E -e "(from|import|require)[ (]*['\"]" -e '^[[:space:]]*(from|import)[[:space:]]+[.[:alnum:]_]' HEAD \
    -- '*.js' '*.jsx' '*.ts' '*.tsx' '*.mjs' '*.cjs' '*.vue' '*.svelte' '*.py' | sed 's/^HEAD://'
} | awk -v q="'" '
function norm(p,  n,a,o,i,k,r) { n = split(p, a, "/"); k = 0
  for (i = 1; i <= n; i++) { if (a[i] == "" || a[i] == ".") continue
    if (a[i] == "..") { if (k) k--; continue } o[++k] = a[i] }
  r = ""; for (i = 1; i <= k; i++) r = r (i > 1 ? "/" : "") o[i]; return r }
function grp(p,  n,a,s) { if (p in dir) p = p "/index"
  n = split(p, a, "/"); s = (a[1] == "src" && n > 2) ? 2 : 1
  if (n - 1 < s) return "(root)"; return (n - 1 > s) ? a[s] "/" a[s+1] : a[s] }
function base(p) { sub(/\/[^\/]*$/, "", p); return p }
function edge(t) { t = grp(t); if (t != from) print from " -> " t }
function ext(x) { print from " -> ext:" x }
/^D / { dir[substr($0, 3)] = 1; top[substr($0, 3)] = 1; next }
{ path = $0; sub(/:.*/, "", path); line = substr($0, length(path) + 2); from = grp(path) }
path ~ /\.py$/ {
  if (match(line, /^[ \t]*from[ \t]+[.A-Za-z0-9_]+/)) { m = substr(line, RSTART, RLENGTH); sub(/^[ \t]*from[ \t]+/, "", m); mods[1] = m; nm = 1 }
  else if (match(line, /^[ \t]*import[ \t]+[A-Za-z0-9_., \t]+/)) { m = substr(line, RSTART, RLENGTH); sub(/^[ \t]*import[ \t]+/, "", m); gsub(/[ \t]/, "", m); nm = split(m, mods, ",") }
  else next
  for (i = 1; i <= nm; i++) { m = mods[i]; d = match(m, /^\.+/) ? RLENGTH : 0; name = substr(m, d + 1); gsub(/\./, "/", name)
    if (d) { b = base(path); for (j = 1; j < d; j++) b = base(b); edge(norm(b "/" name)) }
    else { seg = name; sub(/\/.*/, "", seg)
      if (seg in top) edge(name); else if (("src/" seg) in top) edge("src/" name); else ext(seg) } }
  next }
{ re = "(from|import|require)[ (]*[\"" q "][^\"" q "]+[\"" q "]"
  while (match(line, re)) { spec = substr(line, RSTART, RLENGTH); line = substr(line, RSTART + RLENGTH)
    sub("^[^\"" q "]*[\"" q "]", "", spec); sub(".$", "", spec)
    if (spec ~ /^\./) edge(norm(base(path) "/" spec))
    else if (spec ~ /^[@~]\//) edge((("src") in dir ? "src/" : "") substr(spec, 3))
    else if (spec !~ /^node:/) { n = split(spec, a, "/"); ext(spec ~ /^@/ && n > 1 ? a[1] "/" a[2] : a[1]) } } }
' | sort | uniq -c | sort -rn
```

Output is one line per link, heaviest first: `14 app/api -> server/db`, `6 server/db -> ext:@prisma/client`.
It's a model of the imports, not the program — config-driven aliases other than `@/`/`~/`, framework
routing by convention, and stdlib imports (`ext:os`, `ext:fs`) all land slightly wrong. That's fine
at fifteen nodes; read it with the tree and the manifest, don't open files to fix it.

### 3. Collapse it into ≤ ~15 nodes
A `flowchart LR`, reading left to right, with one `subgraph` per layer — **named the way `CLAUDE.md`
names its layers**. Absent that, something like:
- **Entry** — routes, pages, CLI, workers, whatever the manifest and tree say receives traffic.
- **Core** — the domain / service layer the entry points call.
- **Data** — DB clients, schemas, caches.
- **External** — only what sits **across a process or network boundary**: things that can be down,
  slow, or billed (Stripe, a hosted database, an LLM API, S3). One node per service.

What goes where:
- **A library is not a service.** In-process libraries (Trimesh, build123d, Prisma's client) are
  drawn only when they're the system's engine, labelled `library`, inside the layer that uses them.
- **Vendored or bundled code isn't external.** `static/vendor/three` belongs to whatever ships it.
- **Drop the plumbing:** tests, UI-library internals (`components/ui`, `@radix-ui/*`, icon sets),
  stdlib, utility packages (`zod`, `clsx`, `lodash`). Merge groups that play the same role.

How it's drawn:
- **One arrow meaning, stated once.** Arrows mean *calls / depends on* — the response is implied.
  Say so in a key node: `key["→ calls / depends on (returns implied)"]`. Without it, readers take
  arrows for message flow and go looking for the replies.
- **Edge labels name the call, not the traffic.** `POST spec → STL`, not `HTTP JSON / STL`. A label
  that names a request *and* a response makes every unlabelled edge look one-way. Most edges need
  no label.
- **No counts on edges, ever.** Counts decide which edges to keep, then stay out of the picture.
- **Shapes mean something.** A cylinder `[( )]` is only for what stores data — database, cache,
  bucket. Services and libraries are rectangles.
- **Untangle crossings.** If two edges into the same target cross, drop the weaker one (lower
  count) or merge the sources. Fewer true edges beat a complete hairball.
- Safe ids with quoted labels: `api["app/api"]`.

### 3b. Read the render before showing it
Write it to a temp file (`F=$(mktemp)`), then check it parses — `npx -y @mermaid-js/mermaid-cli -i "$F" -o /tmp/diagram.svg` if Node is around;
otherwise re-read the source for unbalanced brackets and unquoted labels. Then ask: **what would a
newcomer wrongly conclude from this?** A missing key, a library in the External box, an edge that
reads as a reply. Fix those before step 5.

### 4. Find the project key
The same way `start-ticket` does: the repo's `CLAUDE.md`, or the prefix of `specs/<KEY>-*.md`. If
neither names one, `GET projects` lists them — ask which, don't guess. `ORBIT_URL` and
`ORBIT_API_TOKEN` must be set; if either isn't, stop and ask me to export them.

### 5. Show it, then push it
Show the Mermaid and the commit it describes. If `git status --porcelain` is non-empty, say so: the
diagram is of `HEAD`, not the working tree. **Confirm before the PUT** — it overwrites the project's
current diagram.

Send the file from 3b and let Python do the JSON escaping:
```bash
python3 -c 'import json,subprocess,sys; print(json.dumps({"mermaid": open(sys.argv[1]).read(), "commit": subprocess.check_output(["git","rev-parse","HEAD"],text=True).strip()}))' "$F" \
  | curl -s -w '\nHTTP %{http_code}\n' -X PUT --data-binary @- \
      -H "Authorization: Bearer $ORBIT_API_TOKEN" -H 'content-type: application/json' \
      "$ORBIT_URL/api/v1/projects/<KEY>/diagram"
```
Then `GET projects/<KEY>/diagram` and check its `commit` is the one you sent.

### 6. Report
```
Diagram: <KEY> @ <short-sha>   ·   <n> nodes
<one line on anything dropped or uncertain>
```

## Rules

- **Never read source files to build the graph.** The pipeline counts; you judge. If the counts look
  wrong, say so in the report rather than opening files to second-guess them.
- **Architecture, not inventory.** Fifteen nodes is a ceiling. A diagram that lists every folder
  shows nothing.
- **Every visual element means one thing.** Arrows mean *depends on*, cylinders mean *stores data*,
  the External box means *across a network boundary*. Anything drawn for looks misleads.
- **Confirm before the PUT.** It's outward-facing and it overwrites.
- **The diagram is a mirror.** Nothing in the repo depends on it, so it never needs a hand edit —
  rerun instead.
