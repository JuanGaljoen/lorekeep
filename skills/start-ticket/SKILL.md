---
name: start-ticket
description: Begin work from a Jira ticket. Use when the user says "start TICKET-ID", "let's pick up RNG-532", "work on this ticket", or gives a Jira issue key to begin. Fetches the ticket, branches, and feeds it into the spine.
---

# start-ticket 🎫

The on-ramp from Jira onto the spine. Turn a ticket into a ready workspace, then hand off to
**Recall → Understand**. This skill sets up context and moves the ticket into progress — it does
**not** build anything itself.

## Steps

### 1. Identify the ticket
Take the issue key from the request (e.g. `RNG-532`). If none was given, ask for it. If the Jira
tools aren't authed yet, call `mcp__jira__jira_get_myself` to trigger auth.

### 2. Fetch it
`mcp__jira__jira_get_ticket` — pull title, description, type/labels, priority, status. This is the
raw material Understand will sharpen; read it, don't skim it. Also check for `specs/<TICKET-KEY>.md`
— if it exists, this ticket is already mid-flight on a multi-checkpoint plan; Recall will read it
next, so don't re-derive the design from scratch.

### 3. Branch
Name it `<type>/<lowercase-key>-<short-kebab-title>` — `feature/` by default, `fix/` if a `bug`
label is present, `refactor/` if a `refactor` label is present (precedence: bug → refactor →
feature). Branch from the detected default branch, not a hardcoded `main`:
```bash
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|^refs/remotes/origin/||')
DEFAULT_BRANCH=${DEFAULT_BRANCH:-main}
git checkout "$DEFAULT_BRANCH" && git pull origin "$DEFAULT_BRANCH"
git checkout -b <branch-name>
```

### 4. Move it to In Progress
Transition the ticket if it isn't already there: `mcp__jira__jira_get_transitions` to find the
right id, then `mcp__jira__jira_transition`. Skip silently if already In Progress or if no such
transition exists.

### 5. Hand off to the spine
Summarise what you set up, then continue **on the spine** — the ticket is now the input to Recall
and Understand:
```
## Started: <KEY> — <title>
Branch: <branch-name>   ·   Status: In Progress
Type: <feature|fix|refactor>

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
