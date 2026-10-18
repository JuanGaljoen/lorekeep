---
name: start-ticket
description: Begin work from an Orbit ticket. Use when the user says "start TICKET-ID", "let's pick up RING-12", "work on this ticket", or gives an Orbit ticket key to begin. Fetches the ticket, branches, and feeds it into the spine.
---

# start-ticket 🎫

The on-ramp from Orbit onto the spine. Turn a ticket into a ready workspace, then hand off to
**Recall → Understand**. This skill sets up context and moves the ticket into progress — it does
**not** build anything itself.

## Steps

### 1. Identify the ticket
Take the ticket key from the request (e.g. `RING-12`). If none was given, ask for it.

Orbit is reached over its REST API (`docs/api.md` in the Orbit repo) with two env vars, `ORBIT_URL`
and `ORBIT_API_TOKEN`. If either is unset, stop and ask me to export them — don't guess a URL. Every
call in this skill is this shape:
```bash
curl -s -H "Authorization: Bearer $ORBIT_API_TOKEN" -H 'content-type: application/json' \
  "$ORBIT_URL/api/v1/<path>" [-X PATCH|POST -d '<json>']
```

### 2. Fetch it
`GET tickets/<KEY>` — pull title, description, acceptance criteria, technical notes, type/labels,
priority, status, blockers. This is the
raw material Understand will sharpen; read it, don't skim it. Also check for `specs/<TICKET-KEY>.md`
— if it exists, this ticket is already mid-flight on a multi-checkpoint plan; step 3 will resume
its branch rather than start fresh, and Recall reads the spec next, so don't re-derive the design
from scratch.

### 3. Branch — or resume onto the existing one
The branch name is `<type>/<lowercase-key>-<short-kebab-title>` — `feature/` by default, `fix/`
if the ticket type is `bug` or a `bug` label is present, `refactor/` if a `refactor` label is
present (precedence: bug → refactor → feature).

But **check for an existing branch first.** An in-progress ticket (the spec check in step 2 is one
tell) is a **resume**, not a fresh start — re-branching from the default would orphan the work
already in flight. Hop onto the existing branch instead; only branch fresh when none exists. Detect
the default branch; never assume `main`.
```bash
KEY=<lowercase-key>   # e.g. ring-12

# Any existing branch for this ticket? Local first, then origin.
BRANCH=$(git branch --list "*${KEY}-*" --format='%(refname:short)' | head -1)
[ -z "$BRANCH" ] && BRANCH=$(git branch -r --list "origin/*${KEY}-*" \
  --format='%(refname:short)' | sed 's|^origin/||' | head -1)

if [ -n "$BRANCH" ]; then
  # Resume: check it out (DWIM makes a local tracking branch if it's only on origin) and
  # fast-forward if it has an upstream. Non-destructive — git refuses on conflicting local edits.
  git checkout "$BRANCH"
  git rev-parse --abbrev-ref '@{upstream}' >/dev/null 2>&1 && git pull --ff-only
else
  # Cold start: branch fresh from the detected default branch.
  DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|^refs/remotes/origin/||')
  DEFAULT_BRANCH=${DEFAULT_BRANCH:-main}
  git checkout "$DEFAULT_BRANCH" && git pull origin "$DEFAULT_BRANCH"
  git checkout -b "<type>/<lowercase-key>-<short-kebab-title>"
fi
```

### 4. Reconcile the tracker — resume only
Only when resuming an in-progress ticket (a `specs/<TICKET-KEY>.md` exists). The repo is the source
of truth; Orbit is a mirror that may have drifted — an earlier Verify could have been interrupted
between ticking the spec and commenting the ticket. Bring the tracker back in line, idempotently:

- **Read the spec's checkpoints.** The `- [x]`/`- [ ]` tickboxes under `## Checkpoints` in
  `specs/<TICKET-KEY>.md` are the real progress — that's the source of truth. (The *Success criteria*
  checklist is the acceptance bar, not progress — don't reconcile against it.)
- **Read the ticket.** Its status and latest progress comment (`GET tickets/<KEY>` — comments come
  back on the full ticket).
- **In sync? Do nothing.** If the ticket already reflects the spec's state, say "tracker in sync"
  and move on. This is the common case and the reason it's safe to run every resume.
- **Behind? Post the delta.** If a checkpoint is ticked in the spec but not noted on the ticket,
  post one catch-up comment (`POST tickets/<KEY>/comments` with `{"body": "…"}`) naming the checkpoints that have landed
  and what's next — match Verify's format (see Verify, *"Close the checkpoint"*). Don't touch the
  status: a checkpoint isn't the ticket; transitioning is ship's job at the terminal checkpoint.

Idempotent by construction — it posts only the missing delta and is a no-op once spec and tracker
agree. This is the recovery rail: running `/start-ticket <KEY>` on a drifted ticket silently repairs
it, so recovery never depends on every earlier write having fired.

### 5. Move it to In Progress
If the ticket's status category isn't already `in_progress`, set it: `PATCH tickets/<KEY>` with
`{"status": "in_progress"}`. Orbit has no transition graph — the status is just set. Skip silently
if it's already there.

### 6. Hand off to the spine
Summarise what you set up, then continue **on the spine** — the ticket is now the input to Recall
and Understand. Say **Started** for a cold start, **Resuming** when you hopped onto an existing
branch, and name the spec when one exists so Recall reads it first:
```
## Started: <KEY> — <title>            # "Resuming:" when the branch already existed
Branch: <branch-name>   ·   Status: In Progress
Type: <feature|fix|refactor>
Spec: specs/<KEY>.md                   # only when it exists — this is a resume; Recall reads it first

Next: Recall (what do we already know here?) → Understand (grill until aligned).
```

Do **not** jump to building. The ticket description is a starting point, not a frozen spec — the
Understand phase still closes the alignment gap before any code.

## Rules

- **Classify from the ticket, then let the spine decide depth.** A one-line bug ticket may skip
  straight to reproduce → Forge; a feature ticket earns the full spine.
- **Don't invent a spec.** If the ticket is thin, that's what Understand is for — interview, don't
  guess.
- **Detect the default branch; never assume `main`.**
- **Resume, don't clobber.** If a branch for this key already exists (local or `origin`), check it
  out and continue — never re-branch from the default over work in flight. `/start-ticket <KEY>`
  should do the right thing whether the ticket is cold or already underway.
