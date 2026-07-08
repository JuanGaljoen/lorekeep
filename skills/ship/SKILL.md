---
name: ship
description: Commit, push the branch, and open a solid pull request once the work is done and verified — then, once the PR is merged, sync the default branch and clean up the merged branch. Use when the user says "ship it", "ship this", "push and open a PR", "raise the PR", "I merged the branch", "clean up the merged branch", or wants to deliver finished work to the remote.
---

# ship 🚢

**Open by naming the phase:** lead with a one-line banner — `**🚢 ship** — <deliver or land>` — so it's
clear which motion is running. Then get on with it.

The outward tail. Take work that's **done and verified** and deliver it: commit, publish the branch,
and open a real pull request in one motion. Two steps people forget are separate — "Publish Branch"
only pushes; a PR is a second action on top — so this skill does both and never leaves you
half-shipped, and it writes a PR a reviewer can actually act on instead of GitHub's branch-name
default.

**Two halves, one skill.** Shipping isn't done when the PR opens — it's done when the branch is
merged and cleaned up. So `/ship` is lifecycle-aware:
- **Deliver** (steps 1–8) — the branch isn't merged yet: commit → push → PR.
- **Land** (step 9) — you've merged the PR and say so: verify it really merged, sync the default
  branch, and delete the merged branch.

**Pick the half by state, first thing.** If I say the branch/PR is merged ("I merged the branch",
"clean up the merged branch"), or `gh pr view` reports the current branch's PR as `MERGED`, go
straight to **step 9 (Land)** — don't re-run the deliver steps. Otherwise run Deliver.

Not a spine phase. The spine ends at Chronicle (knowledge); shipping is the delivery action that
follows a green **Verify**. Cheap, mechanical work — no strong model needed; if you're on the strong
model, say so and offer the switch before a long push/CI wait.

**Optional flags** (read them off the invocation; all optional):
- `--dry-run` — compute the branch, commit, and PR, print the preview, change nothing.
- `--ticket <KEY>` — the Jira key to reference and transition (e.g. `RNG-9`).
- `--title "…"` — override the derived PR title.

## Steps

### 1. Earn the ship
Don't deliver work that isn't done. Confirm, quickly:
- **Verify passed.** Tests green, success criteria met. If Verify never ran, say so and offer to run
  it first — don't ship on faith.
- **Chronicle considered.** The spine ends at knowledge, then ship delivers — so before you deliver,
  ask the Chronicle question once: did anything here earn a record (a surprising bug, a hard-won
  decision, a lesson)? If yes and nothing's captured, offer `/chronicle` first. If genuinely
  nothing, say "nothing worth chronicling" and carry on. Don't let knowledge fall off the end
  silently — a skipped Chronicle should be a conscious call, not an accident.
- **There's something to ship.** If `git status` is clean *and* the branch is already pushed with a
  PR, there's nothing to do — say so and stop.

If the work is clearly unfinished, say so and stop. Shipping half-work is worse than not shipping.

### 2. Determine branch, commit, and PR — then, if `--dry-run`, stop
Work out everything *before* touching the remote: the branch name (step 3), the commit message
(step 4), and the PR title + body (step 6).

If the invocation contains **`--dry-run`**, print the preview and make **no** changes — no
`checkout`, `add`, `commit`, `push`, or `pr create`:
```
## /ship --dry-run

Branch:     <name>
Commit:     <conventional commit message>
Push to:    origin/<name>
PR title:   <title>
PR body:    <first ~10 lines, truncated with "…">
```
Then stop and tell me to re-run without `--dry-run` to actually ship.

### 3. Get onto a real branch
- **If on `main`/the default branch, branch first** — never push straight to default. Name it in the
  repo's convention (read a recent branch): `feat/rng-9-<slug>` for `--ticket RNG-9`, otherwise a
  slug from the work. If you can't derive a sensible name, ask.
- **If already on a feature branch,** use it.

### 4. Stage and commit
- `git diff --stat` to show what's going in.
- Stage changes, but **never stage secrets** — warn and exclude any `.env` / credential file rather
  than committing it.
- Write a commit in the repo's house style (read recent commits — match `type(scope): summary`):
  - **Body** — the success criteria this delivers / what was built, not a file list.
  - **Footer** — `Refs: <KEY>` when a ticket's in play.
  - **No `Co-Authored-By: Claude` trailer** — I don't want Claude listed as a repo contributor.

### 5. Publish the branch
```bash
git push -u origin <branch>
```
`-u` sets upstream so future pushes are one word. If already published, this just fast-forwards.

### 6. Open the PR — or report the one that exists
Check first: `gh pr view` (or `gh pr status`). If a PR already exists for the branch, **don't make a
second** — the push above updated it; report the existing one.

Otherwise **build a real PR** — never GitHub's default (which mangles the branch slug into the title
and leaves the body empty). Read the commits and diff, and a recent merged PR for house format:
```bash
git log --oneline <default>..HEAD
git diff --stat <default>...HEAD
gh pr view <recent-n>        # match the format
```

**Title** (< 70 chars) — one crisp line naming the *outcome*, in the repo's commit style
(`feat(RNG-9): reusable gallery primitive + halo composition`). From `--title` if given, else the
ticket title, else the commit — never the raw branch slug.

**Body** — structured, sections that apply only (drop the rest, don't pad):
```markdown
## Summary
What this delivers and why it exists — one or two sentences.

## Changes
- The meaningful changes, grouped by area — the what and why, not a bare file list.

## Acceptance Criteria
- [x] The success criteria from Understand/Verify, checked off.

## Test Plan
- [ ] How a reviewer confirms it: what to run, what to look at.

## Jira
Refs: <KEY>   <!-- link the ticket; or `Closes #<issue>` to auto-close on merge -->
```
End the body with:
```
🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

Show the draft (title + body + base branch) and **confirm before creating** — a PR is
outward-facing. Then create it, passing the body via a file so markdown survives:
```bash
gh pr create --base <default> --title "…" --body-file <path>
```

### 7. Update Jira — if a ticket's in play
When a `--ticket`/`Refs` key exists, close the loop on the tracker:
- Transition it to **In Review** (`mcp__jira__jira_get_transitions` → `mcp__jira__jira_transition`).
- Comment the PR URL (`mcp__jira__jira_add_comment`).

### 8. Report
```
## Shipped 🚢
- Branch: <branch>
- Commit: <hash> — <summary>
- PR:     <url>
- Jira:   <KEY> → In Review   (if applicable)

Next: merge when checks pass, or keep iterating on this branch.
```

### 9. Land — after the PR merges
Triggered when I tell you the PR is merged (or `gh pr view` shows `MERGED`). This half syncs the
default branch and removes the merged branch. It deletes a branch, so **verify before you cut** —
don't act on my word alone.

**a. Confirm it actually merged.** Fetch, prune remote-tracking refs, and check the PR state:
```bash
git fetch origin --prune
gh pr view <branch-or-#> --json state,mergedAt,mergeCommit -q '.state + " @ " + (.mergedAt // "n/a")'
```
If the PR is **not** `MERGED` (still open, or closed-unmerged), **stop** — say what the real state
is and don't delete anything. Only a genuine merge earns the cleanup.

**b. Sync the default branch and delete the merged branch.**
```bash
git checkout <default>
git merge --ff-only origin/<default>      # fast-forward only — never a merge commit here
git branch -d <feature-branch>            # -d refuses to delete if it isn't merged (a safety net)
```
- If the remote branch still exists (origin didn't auto-delete on merge), remove it too:
  `git push origin --delete <feature-branch>`.
- If `git branch -d` refuses ("not fully merged"), **don't force with `-D`** — that means git can't
  see the merge (e.g. squash-merge). Confirm the PR is `MERGED` from step a, tell me it was a
  squash/rebase merge, and only then delete.

**c. Update Jira — only if this finished the ticket.** A merge is not automatically "ticket done."
- **Whole ticket delivered** → transition to **Done** (`mcp__jira__jira_get_transitions` →
  `mcp__jira__jira_transition`) and comment the merge.
- **One checkpoint of many** → the ticket stays **In Progress** for the next checkpoint (if step 7
  bumped it to In Review, move it back). Don't re-author the progress note — Verify already recorded
  which checkpoint landed and ticked `specs/<TICKET-KEY>.md` when it closed the checkpoint (see
  Verify, "Close the checkpoint"). Just comment the merge URL, and glance that the spec and the
  ticket already agree — reconcile only if they've drifted.
- **Unsure which** → ask before transitioning. Closing a ticket mid-work is worse than a question.

**d. Report the landing.**
```
## Landed 🛬
- <default>: fast-forwarded to <hash> (the #<pr> merge) — in sync with origin/<default>
- Merged branch <feature-branch> deleted (local<, and remote> if applicable)
- Jira: <KEY> → Done   (or "stays In Progress — CP<n> landed, CP<n+1> next"; omit if no ticket)

Next: <the next piece of work, if one is obvious from the ticket/plan — else "ready for the next task">.
```

## Rules
- **Verified before shipped.** No green Verify, no ship — offer to run it, don't deliver on faith.
- **Never push to the default branch.** On `main`? Branch first.
- **Never stage a secret.** Warn and exclude `.env` / credential files — the safety hook blocks it
  anyway, but don't rely on the floor.
- **Confirm before the PR.** Show the draft; a PR is outward-facing. Pushing your own branch is fine
  without asking; opening a PR is the checkpoint.
- **`--dry-run` changes nothing.** Preview only, then stop.
- **One PR per branch.** If one exists, push and report it — don't open a duplicate.
- **Report honestly.** If checks fail after push, say so with the output. Not shipped until the PR is
  actually open.
- **Never delete on my word alone.** In Land, confirm `MERGED` via `gh pr view` before touching a
  branch. Not merged → stop and say so. Never `git branch -D` (force) to work around an unmerged
  check unless the PR is confirmed merged (squash/rebase case).
- **Fast-forward only when syncing the default branch.** `git merge --ff-only` — never create a
  merge commit on `main` during Land.
- **Don't close a ticket mid-ticket.** A merged PR closes a *ticket* only when it finished the whole
  ticket. If the PR delivered one checkpoint of many, the ticket stays **In Progress** — advance the
  checkpoint, not the ticket. When unsure whether this was the last piece, ask before transitioning.
