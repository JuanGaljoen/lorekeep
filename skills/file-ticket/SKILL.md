---
name: file-ticket
description: Create a Jira ticket from work you've already thought through. Use when the user says "file a ticket", "raise a Jira for this", "turn this into a ticket", or wants to capture the current plan as a Jira issue.
---

# file-ticket 🎫

The reverse of `start-ticket`: take work you've understood and turn it into a Jira ticket. The
ticket's quality comes from the thinking that precedes it — lorekeep's **Understand** phase is the
validation gate, so a ticket filed straight off a vague idea is a ticket worth grilling first.

## Steps

### 1. Make sure it's worth a ticket
If the request is still fuzzy, run **Understand** first (interview until the problem, constraints,
and success criteria are clear). Don't file a ticket that just says "improve the dashboard".

### 2. Synthesize the ticket
From the conversation, draft:
- **Title** — one crisp line naming the outcome.
- **Description** — the problem, the intended behaviour, constraints, and success criteria. Use
  the project's vocabulary (`CONTEXT.md`) so it reads like the rest of the tracker.
- **Type** — Feature / Bug / Task, inferred from the work; confirm if ambiguous.

### 3. Fill in Jira metadata
Prompt for what the project needs — priority, labels, assignee, team, sprint/cycle — rather than
guessing. Use the helper tools to offer valid values: `mcp__jira__jira_get_issue_types`,
`mcp__jira__jira_get_priorities`, `mcp__jira__jira_search_users`. Auth via
`mcp__jira__jira_get_myself` if needed.

### 4. Create it
`mcp__jira__jira_create_ticket`. Show the draft (title + description + fields) and **confirm with
me before creating** — a filed ticket is outward-facing.

### 5. Return the handle
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
- **Match the tracker's conventions** — read a recent ticket or two if unsure of the house style.
