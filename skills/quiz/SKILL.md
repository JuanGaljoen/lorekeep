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
4. **One thing you got wrong last time** (see *The domain note*) — and nothing already written in
   its *What I know* section, which is the record of what's settled.

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

The link is written next to the gap in the domain note, not just said out loud — the moment I read
it is never the moment I'm told.

## The domain note

Everything durable lands in **one running note per domain** in Obsidian
(`~/ObsidianVault/Personal/clean-energy.md`) — domain knowledge outlives this repo by definition,
and the next ticket may be in a different one.

Two sections, doing two different jobs. Keep them apart: gaps are a **worklist** that should stay
short and get emptied; facts are a **reference** that grows and gets re-read. Merged, the worklist
stops being actionable and nobody re-reads a page of their own wrong answers.

```markdown
# Clean energy

## Open gaps
- 2026-09-17 — Curtailment vs. negative pricing: I conflated them. (ENG-214)
  → https://www.caiso.com/…  (primary; cited in docs/research/curtailment.md)

## What I know

### Curtailment
- Curtailment is a **grid operator instruction to generate less**, not a price signal — it's an
  answer to a constraint (transmission or oversupply), and it happens at any price.
  (2026-09-17, ENG-214) → https://www.caiso.com/…

### Capacity
- **Capacity factor** = actual output ÷ nameplate over a period. **Availability factor** = time the
  plant *could* run. A wind farm has a low capacity factor and a high availability factor — the
  difference is the resource, not the machine. (2026-09-17, ENG-214) → https://www.nrel.gov/…
```

**Gaps** — one line, dated, ticketed, with the link to read. **Open the next quiz by re-asking one
of them.** That single re-ask is the only mechanism here that moves retention, and it costs one
question. When it comes back clean twice, **delete the line** and make sure the fact is written
below — a closed gap is not history worth keeping, it's a fact that graduated.

**What I know** — one entry per fact that *survived a question*. Grouped by topic rather than by
date, because you re-read by topic and you'd never scroll to find "that thing from September."

Rules for the facts half, which is the half you'll actually trust:

- **Only what was asked.** A fact earns a line by having been put to me and resolved — right, or
  wrong and then told. Everything the ticket merely touched belongs in the repo's research notes,
  not here. That filter is the only thing keeping this note short enough to re-read.
- **Write the claim, not the question.** "Why does curtailment spike at midday?" is a quiz
  transcript. The claim, stated flat, is a reference. One or two sentences, including *why* it's
  true — the mechanism is what transfers; the bare fact decays.
- **Every line carries its source.** Same bar as everything else here: the primary source, inline.
  This note is the one artefact I'll read repeatedly and believe, so a wrong line in it is the most
  expensive line in the whole workflow.
- **Sharpen in place, don't append.** When the same ground comes up again with more precision, edit
  the existing line. Two entries on one fact means re-reading it twice and trusting neither.
- **Read it before the next quiz.** It's the memory of what's already solid: don't re-ask what's
  written here — build the transfer question on top of it instead.

No schema beyond those two headings, no scoring, no streak. A line, a date, a ticket, a link.

## Output

**Write the note first, then report.** The note is the deliverable; the message is a receipt for it.
Update both halves in the one domain file — new facts filed under their topic, the gap added or
cleared — then close in three lines: what's now solid, what isn't, and the path.

> 🎓 4/5. Two facts filed under *Curtailment* and *Capacity*. The gap: curtailment vs. negative
> pricing — you have them as the same event, and they come apart when the constraint is
> transmission rather than supply. Read: https://www.caiso.com/… (20 min).
> `~/ObsidianVault/Personal/clean-energy.md`.

No percentage, no "great job", no encouragement padding.
