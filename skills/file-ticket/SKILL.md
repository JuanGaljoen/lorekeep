---
name: file-ticket
description: Create an Orbit ticket from work you've already thought through. Use when the user says "file a ticket", "raise a ticket for this", "turn this into a ticket", or wants to capture the current plan as an Orbit ticket.
---

# file-ticket 🎫

The reverse of `start-ticket`: take work you've understood and turn it into an Orbit ticket. The
ticket's quality comes from the thinking that precedes it — lorekeep's **Understand** phase is the
validation gate, so a ticket filed straight off a vague idea is a ticket worth grilling first.

## Steps

### 1. Make sure it's worth a ticket
If the request is still fuzzy, run **Understand** first (interview until the problem, constraints,
and success criteria are clear). Don't file a ticket that just says "improve the dashboard".

### 2. Synthesize the ticket
From the conversation, draft:
- **Title** — one crisp line naming the outcome.
- **Description** — the problem, the intended behaviour, and constraints. Use the project's
  vocabulary (`CLAUDE.md`) so it reads like the rest of the tracker.
- **Acceptance criteria** — the success criteria as a `- [ ]` checklist. Orbit keeps these in their
  own field, not buried in the description.
- **Technical notes** — the approach or seams, if Understand/Design already settled them.
- **Type** — `feature | bug | task | improvement | research | documentation`, inferred from the
  work; confirm if ambiguous.

### 3. Fill in Orbit metadata
Orbit is reached over its REST API (`docs/api.md` in the Orbit repo) using `ORBIT_URL` and
`ORBIT_API_TOKEN`; if either is unset, stop and ask me to export them. Calls are
`curl -s -H "Authorization: Bearer $ORBIT_API_TOKEN" -H 'content-type: application/json' "$ORBIT_URL/api/v1/<path>"`.

Prompt for what the project needs — project, priority, labels, milestone — rather than guessing.
`GET projects` lists the project keys and `GET milestones?project=<KEY>` the milestones. For
priority and labels, an unknown name comes back as a 400 that lists the valid values, so a wrong
guess corrects itself rather than filing garbage.

### 4. Link it into the backlog — never file standalone
A ticket in a linked backlog that links to nothing is a bug. Before creating, **read one or two
recent tickets** (`GET tickets?project=<KEY>&limit=5`, then `GET tickets/<KEY-n>`) to learn the
house style, then match it:
- **Dependencies & ordering** — what must land before this, and what it unblocks. If the project
  writes an explicit note ("should land before RING-9") or a **"Depends on"** section, include it.
- **Blockers** — `blockedBy: [KEYs]` on create for what must land first; for a ticket this one
  blocks, `POST tickets/<THAT-KEY>/blockers` with `{"blockedBy": "<NEW-KEY>"}` after creating.
  Orbit has no "relates to" link — name related tickets in the description instead.
- **Parent / milestone** — `parent: KEY` under the parent the related work sits in, and the
  `milestone` it belongs to.

Trace *why this ticket exists now*: what surfaced it, which earlier ticket introduced the gap —
those are the links. If it genuinely blocks nothing, say so, but still link what it relates to.

### 5. Create it
`POST tickets` with the JSON body. Show the draft (title + description + fields + links) and **confirm
with me before creating** — a filed ticket is outward-facing.

### 6. Return the handle
Output the new key and URL, and the natural next step:
```
Filed: <KEY> — <title>
<url>

Next: /start-ticket <KEY> to branch and begin, or keep going here.
```

## Rules

- **Confirm before creating.** Show the draft first; don't create silently.
- **The description is a spec, not a title restated.** If you can't write the success criteria,
  you haven't Understood it yet — go back.
- **File it linked, never standalone.** Read a recent ticket or two and match the house style —
  dependencies, issue links, ordering, parent/epic. A ticket that links to nothing in a linked
  backlog is a bug, not a shortcut.
