---
name: quiz
description: Test the user on the domain the code just touched, so they finish a ticket knowing more than when they started. Use when the user says "quiz me", "test me", "did I actually learn this", or at Chronicle on work in a domain they're still learning.
---

# Quiz 🎓

*What do I actually know now?*

Chronicle's inward twin. Chronicle writes what the work taught **to the repo**; Quiz writes it
**to you**. Same moment, different destination — and only one of them still works when you're
away from the keyboard.

It isn't a phase. It's what stops a ticket in an unfamiliar domain from leaving behind working
code and a driver who still couldn't explain it.

## The failure it exists to prevent

Shipping a correct change you could not defend.

The agent researched the interconnection queue, picked the right curtailment threshold, wrote the
test, and it's green. Nothing is wrong with the code. But the domain knowledge went into the repo
and into my context window, and none of it went into yours — so next ticket you're equally
dependent, and the ticket after that. Working code is not evidence that you learned anything, and
on a domain you've chosen to learn, that gap compounds silently until someone asks you a question
in a meeting.

## When it fires

**At Chronicle, as an offer — one line, never a gate.**

> 📖 Chronicle done — ADR 0007 written. Want a 🎓 quiz on the capacity-market side of this? (5 questions, ~5 min)

Offer it when *the work leaned on domain facts you had to look up* — a standard, a market rule, a
physical constant, a piece of vocabulary. Don't offer it on a refactor, a config bump, or anything
whose domain content is zero; a quiz on nothing trains you to decline quizzes.

And never run it unasked. A quiz you didn't agree to is an interruption between you and a ship.

## What you quiz on

**The domain, never the code.** The dividing line is whether the answer would still be true in
another company's repo:

- ✅ *Why does curtailment spike at midday in a solar-heavy grid?* — domain.
- ❌ *Why did we cache the forecast response?* — that's our code. Verify's territory, not this.

Draw questions from **what this ticket actually touched**. The change is the retrieval cue: you
just spent an hour inside the interconnection queue, so a question about interconnection queues has
somewhere to land. Generic domain trivia has nothing to attach to and evaporates by Friday.

Priority order when picking five:

1. **A fact the work depended on** — the threshold, the unit, the deadline that made the code
   correct.
2. **The why underneath it** — the mechanism that makes that fact true. This is the one that
   transfers.
3. **A term you used without defining** — the vocabulary you'd have to fake in a meeting.
4. **One thing you got wrong last time** (see *The gap log*).

## How to run it

- **One question at a time. Stop and wait.** Five questions in one message gets you one answer and
  four skims.
- **Open questions only — never multiple choice.** Recognising the right option among four is not
  the same act as producing it, and only the producing one teaches. Making you retrieve *is* the
  mechanism; the discomfort is the work happening.
- **Push once on a vague answer before revealing.** "Roughly right" is where learning stalls.
  *"You said it's about duck-curve timing — what's driving the timing?"* One push, then tell them.
- **Grade honestly, in a sentence.** Right, partly right, or wrong — say which. A quiz that
  congratulates every answer is a quiz that teaches nothing, and you'll correctly stop trusting it.
- **"I don't know" is a good answer.** Failing to retrieve and *then* being told beats reading the
  same sentence cold. Take it, answer it, move on — no consolation, no lecture.
- **Ladder it.** Fact → why → transfer. The last question should apply the idea to a case that
  wasn't in the code at all: *"Same grid, but the storage is behind the meter — what changes?"*
  Transfer is the only one of the three that proves it stuck.
- **Stop when it stops teaching.** Five is the default, not a quota. Three sharp questions and a
  clear gap beats five and a tired one.

**Stay in this session.** The quizzing is a conversation with me — it can't be handed to an agent.
It's also judgement-heavy (grading a partial answer, deciding what to push on), so it wants the
strong model; if we're on Sonnet from Forge, say so before starting.

## Never invent an answer

Every question you ask is a claim about the world, and a quiz makes me *believe* it — that's the
whole point of it, and exactly what makes a wrong one expensive. A plausible fabricated answer
doesn't just fail to teach; it installs something false and gives it the authority of a test.

So: **if you can't source the answer, don't ask the question.** Ask what the repo, the ADRs, or a
cited research note already answers — or send the `researcher` agent first (see
`skills/research`). A question whose answer you'd be constructing from reasoning is the one
question you must drop.

And if I answer something you can't confirm either way: **say so.** "I think that's right but I
can't source it" is a real result, and it's the honest one.

## On a miss: one real article

A wrong or shaky answer produces **one link to go read**. The gap is the diagnosis; the link is the
only actionable half, and without it "you conflated those two" is just a scoreboard.

- **Source it in this order.** First, a citation already in the research note this ticket generated
  — it's in the repo, it's free, and it's the source the code was actually built on. Failing that,
  dispatch the `researcher` agent for one primary source. **Never a URL from memory.**
- **Primary sources, same bar as `skills/research`** — the body that owns the answer (the ISO's own
  tariff, NREL, EIA, IEA) rather than someone's write-up of them.
- **One per gap, three per quiz, hard cap.** A ten-link reading list gets read zero times. If more
  than three questions went badly, the finding isn't three links — it's that we quizzed too early.
- **Unsourceable? Say so and name the search.** "I couldn't find a primary source; the place it
  would live is the CAISO tariff, section on curtailment" is a real result. A fabricated URL is
  worse here than in prose, because a dead link still *looks* like homework and the failure only
  surfaces when I'm sitting down to read it.

The link is written next to the gap in the log, not just said out loud — the moment I read it is
never the moment I'm told.

## The gap log

What I missed is the only durable output. Keep it in **Obsidian** (`~/ObsidianVault/Personal/`) —
domain knowledge outlives this repo by definition, and the next ticket may be in a different one.

One running note per domain, e.g. `clean-energy.md`. Two lists, nothing more:

```markdown
# Clean energy — gaps

## Shaky
- 2026-09-17 — Curtailment vs. negative pricing: I conflated them. (ENG-214, midday solar)
  → https://www.caiso.com/…  (primary; cited in docs/research/curtailment.md)

## Solid
- 2026-09-17 — Capacity factor vs. availability factor
```

At the **start** of the next quiz, re-ask one thing from *Shaky*. That single re-ask is the only
mechanism here that moves retention, and it costs one question. When it comes back clean twice,
move it to *Solid* and stop asking.

Keep it dead simple: a line, a date, a ticket, a link. No schema, no scoring, no streak.

## Output

The gaps, not the score. Close with the two or three things worth reading up on, and the path to
the note — then get out of the way.

> 🎓 4/5. Solid on capacity factors. The gap: curtailment vs. negative pricing — you have them as
> the same event, and they come apart when the constraint is transmission rather than supply.
> Read: https://www.caiso.com/… (20 min). Logged in `~/ObsidianVault/Personal/clean-energy.md`.

No percentage, no "great job", no encouragement padding. The gap is the deliverable.
