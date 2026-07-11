---
name: writing-skills
description: Reference for writing or auditing a lorekeep skill — the discipline that makes a skill's behaviour predictable and its prose earn its keep. Use when authoring a new skill, editing an existing SKILL.md, or auditing one for bloat.
---

# Writing Skills

A skill exists to wrangle determinism out of a stochastic system. **Predictability** — the agent
taking the same *process* every run, not necessarily producing the same output — is the root
virtue; every rule below serves it.

## Enforcement vs. guidance — decide this first

Before writing a rule into a skill, ask: is this deterministic and checkable, or judgement-based?

- **Deterministic ("never do X")** belongs in a **hook** (`hooks/pre_tool_use.py`), not prose.
  Prose can *ask* the model not to do something; only a hook can *guarantee* it. If a rule can be
  checked by a regex or a file path with no judgement call involved, it's a hook candidate —
  writing it as prose instead is a promise the skill can't actually keep.
- **Judgement-based ("usually do X, unless…")** belongs in a **skill**. This is most of what a
  skill is: a name for repeatable process that still routes through the model's judgement.

Get this backwards either way and it costs you: enforcing a judgement call in a hook makes it
brittle and wrong on the edge cases it didn't anticipate; leaving a genuinely mechanical rule as
prose makes it a coin flip. lorekeep found this out directly — the Forge model-switch
recommendation lived only as prose for a while, in a skill whose own opening line was "get on with
it," and got silently skipped in two real sessions before anyone noticed the pattern. Moving it to
the top of Forge as an explicit gate helped, but it's still prose asking nicely, not a guarantee —
worth remembering next time a "should have caught this" moment shows up in a skill that has no
hook backing it.

## Information hierarchy

Rank content by how immediately the agent needs it:

1. **In-skill step** — an ordered action in `SKILL.md` itself. Give each step a **completion
   criterion**: the condition that says it's actually done, checkable, not "produce a good
   result." A vague criterion invites the agent to call it done before it is.
2. **In-skill reference** — a rule or fact consulted on demand, often a flat list (Verify's
   test-vetting checks, Design's rules). Fine to keep inline; a flat reference list isn't sprawl
   by itself.
3. **External reference** — pushed out of `SKILL.md` into a linked sibling file, loaded only when
   a pointer fires.

**Progressive disclosure** is moving content down this ladder so the top stays scannable. The test
is *branching*: inline what every path through the skill needs, push behind a pointer what only
some paths reach. But a pointer only helps if the agent reliably follows it —
**a pointer's wording, not its target, decides whether it fires.** lorekeep tried splitting
Verify's checkpoint mechanics into a sibling `CHECKPOINTS.md` once, to shrink the main file. It got
reverted the same session: the mechanics were load-bearing (a resume depends on the exact commit
ordering) and there was no evidence the model would reliably fetch a reference file before acting
on it — reference files aren't auto-loaded, so a skipped fetch silently drops the discipline behind
it. Split for genuinely optional depth; don't split load-bearing procedure behind a pointer that's
never been tested to hold.

## Leading words

A **leading word** is a compact, already-understood concept the model can think *with* while
running the skill — lorekeep's own: *phase*, *spine*, *seam*, *vertical slice*, *frozen plan*,
*checkpoint*. Reused as the same token every time, rather than re-explained, it anchors behaviour
in fewer tokens than restating the idea from scratch. Prefer an existing, pretrained word over a
coined one — a coined term recruits no priors and has to earn its meaning from nothing.

## Pruning discipline

Keep each meaning in exactly **one place**. A rule stated in two skills is a maintenance liability
and inflates its own apparent importance. Then hunt these failure modes line by line:

- **No-op** — a line that doesn't change behaviour versus what the model would already do by
  default. It costs tokens to say nothing. The fix is a sharper, more specific word, not more
  words around the same one.
- **Negation** — steering by "don't do X" tends to name X, which can backfire by putting it in the
  model's attention. State the positive target behaviour instead; keep a bare prohibition only for
  a hard guardrail you genuinely can't phrase positively.
- **Sediment** — stale layers that accumulate because adding feels safe and deleting feels risky.
  The default fate of any skill nobody prunes. Chronicle's own rule — "skip the trivial, don't
  manufacture an entry" — is this same discipline aimed at documentation instead of skills; apply
  it to the skills themselves too.
- **Sprawl** — the skill is simply too long even when every remaining line pulls weight. The cure
  is the information hierarchy above: push reference material behind a pointer strong enough to be
  followed, or split by phase boundary if a run of steps tempts the agent to rush the one in front
  of it.

## Applying this in lorekeep

The six phase skills open with a banner (`**🔍 Verify** — <what you're proving>`) — that's the
spine's own leading-word pattern; keep it there. Bridge skills (`ship`, `start-ticket`,
`file-ticket`) skip the banner since they aren't phases — don't force it onto them for
consistency's sake alone, that's exactly the kind of no-op the pruning discipline above would flag.

When auditing an existing skill, hold it to the same two-axis standard Verify holds code to:
**does it work** (does every rule in it actually change behaviour, or would the model do that
anyway?) and **is it good** (does a "never do X" in here actually belong in the hook instead?).
