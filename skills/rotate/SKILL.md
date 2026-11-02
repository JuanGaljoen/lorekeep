---
name: rotate
description: Rotate the secrets a repo depends on — find every key, token and credential it uses, work out where each one actually lives, replace it with a fresh one, and revoke the old. Use for "rotate the keys", "rotate this secret", "I leaked a key", "a key got committed", or a routine credential-hygiene pass.
---

# Rotate 🔑

*Which secrets does this repo depend on, and can we replace every one without breaking it?*

Off-spine, like Sweep: pointed at a repo with nothing in flight, or reached from a Fix the moment a
key is found somewhere it shouldn't be. It's a procedure, not a phase. Open with the one-line banner
(**🔑 Rotate** — and what it's doing here) like any other skill.

**The repo doesn't hold the rotation.** A key is issued by a provider, so the real rotation happens
there. The repo only holds *consumers* of it: env files, CI secrets, deploy config, code that reads
it. Rotating means changing the provider, then every consumer, in an order that never leaves the app
without a working credential. Treat the repo as the map, not the territory.

**A leaked key is already compromised.** Deleting it from the file, or rewriting git history, does
not un-leak it: clones, forks, CI logs and caches keep it. The fix is revoking it at the provider.
History cleanup is optional hygiene afterwards, never a substitute.

## Hard rules

- **Never print, echo, log or commit a secret value.** Not in the report, not in a commit message,
  not in a command line (shell history keeps it). Name secrets by *key name and location*, show at
  most the last 4 characters to identify one. Read values only to move them, and pipe them
  (`gh secret set NAME < file`, stdin to a CLI) rather than interpolating them.
- **Never revoke without confirmation.** Revocation is irreversible and outward-facing. Confirm each
  one, naming the provider, key and what depends on it, unless the user has said to just go.
- **Overlap, don't swap.** Create new → deploy it → verify → *then* revoke old. Revoking first is an
  outage you caused.
- **Do what you can reach, hand over what you can't.** A secret is reachable only if a logged-in CLI
  or MCP can issue its replacement. For every other one (no tool, a dashboard-only provider, an
  interactive step, a permission that was denied) don't pretend, don't stall the rest, and don't work
  around a denial: rotate everything reachable, and give the user a runbook for the remainder (step 5).

## Process

### 1. Scope and trigger

Routine pass, or incident? An incident (a key is known to be exposed) reorders everything: revoke
fast, accept a brief outage if the key is live and abused. A routine pass keeps the overlap.

*Done when:* trigger, urgency and the boundary (this repo, which environments) are stated.

### 2. Inventory

Find every secret the repo *uses*, not only the ones it *contains*:

- **Where they're read:** `process.env.X`, `os.environ`, config loaders, `.env.example`, docker
  compose, IaC, CI workflows (`secrets.X`), deploy configs.
- **Where they're stored:** `.env*` files (tracked or not), CI secret stores, the platform's env
  (Vercel, Cloudflare, etc.), a secrets manager.
- **Where they've leaked:** run a scanner the repo or machine already has (`gitleaks`, `trufflehog`)
  over the working tree *and* history; otherwise grep for known key shapes. Treat scanner output as
  a hypothesis list: check each hit is a real credential, not a test fixture or example.

Each secret gets a row: **name · provider · where it's consumed · where it's stored · exposed?**

*Done when:* every secret has a provider and a full list of consumers, and anything unattributable
is listed as a question rather than guessed at.

### 3. Plan, then get a yes

On an incident, keep the plan to a line or two per secret so revocation isn't delayed, but the
go-ahead still applies: revoking stays confirmed. Order the rotation per secret, and flag the ones that can't overlap (a provider that allows only
one active key, signing keys whose old tokens must stay valid, DB passwords needing a coordinated
restart). Show the plan with the blast radius of each step. **Stop here for the user's go-ahead.**

*Done when:* the user has approved the plan, or named which secrets to leave.

### 4. Rotate, one secret at a time

For each, in order:

1. **Issue** the new key at the provider (CLI/MCP, or console steps for the user).
2. **Update every consumer** from the inventory: local `.env` (never tracked), CI secret store,
   platform env. Code changes (renamed variable, new scope) go through the normal Forge path.
3. **Deploy and verify** with a real call that proves the new key works. If it can't be proven,
   say so and don't proceed to revoke.
4. **Revoke the old**, after confirmation, then confirm the old one is actually dead (a call using
   it must now fail).

One secret fully done before the next. A half-rotated set is the worst state to be interrupted in.

*Done when:* per secret, the new key is live in every consumer and the old one is confirmed dead.

### 5. Hand over what you couldn't rotate

Don't stop at the first blocker: finish every reachable secret first, then write one runbook per
unreachable secret, in the order the user should do them. Each runbook entry has:

1. **Why it's manual** — one clause (*no CLI*, *dashboard only*, *interactive*, *denied*).
2. **Issue** — the exact place to create the new key (console path or command).
3. **Install** — the exact command that puts it where the repo consumes it, with the value on stdin
   and the secret name filled in (`wrangler secret put NAME --env production`, `gh secret set NAME`),
   or the `.env` line to edit. Name every consumer from the inventory, not just the first.
4. **Verify** — the check that proves the new key works, which you can run once they say it's in.
5. **Revoke** — when and where to delete the old key, and what a dead one looks like.

When the user reports a step done, run its verify, then move to the next. Hand over only what
you truly couldn't do; a runbook for something you could have rotated is a skipped step.

### 6. Close the hole

If a key was committed or `.env` was tracked: add it to `.gitignore`, remove it from the index
(`git rm --cached`), and consider a pre-commit scanner so it can't recur. Offer history rewriting
only as optional, say it needs a force-push and invalidates every clone, and never do it unasked.

## Output

A table of secrets with status: **rotated and old revoked / rotated, old still live / skipped (why)
/ manual (runbook below)**. Then the step-5 runbook for each manual one, and one line on what was
*not* checked (other environments, other repos sharing the same key). Never include a value.

Chronicle only if the rotation exposed something worth keeping: a provider that can't overlap, a
consumer nobody knew about. Put it in `CLAUDE.md` as a convention or in an ADR, never a log of
when keys were rotated.
