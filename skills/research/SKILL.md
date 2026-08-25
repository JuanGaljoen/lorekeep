---
name: research
description: Find out what's actually true from primary sources when a decision rests on an external fact the repo can't answer. Use when about to justify a number, tolerance, threshold or contract with reasoning instead of a citation, or when the user asks to research, look up, or check something against the real spec.
---

# Research 🔬

*What does the world know that we don't?*

Recall's outward arm. Recall loads what **we** already know — this repo, its decisions, its code.
Research fetches what **nobody here knows**: the trade tolerance, the standard, the API contract,
the domain convention that lives outside the repo entirely.

It isn't a phase on the spine. It's a move any phase can make when it hits a fact it can't source.

## When it must fire

Not "whenever unsure" — that would turn every ticket into a reading session. The tell is narrower
and much more specific:

> **You are about to justify a value with your own reasoning, and somewhere out there a spec, a
> standard, a trade practice, or an API doc owns the real answer.**

That's the moment. Not doubt — *invention*. When you catch yourself constructing an argument for
why 0.25 is about right, stop: an argument is what you produce when you don't have a source. The
danger sign is that the argument sounds good. A plausible derivation is indistinguishable from a
correct one right up until someone checks.

Concretely, fire when:

- A **constant, threshold, tolerance or limit** is being chosen and the number's real home is
  outside this repo.
- A value is being set **from how the output looked**, or from the user's reaction to it — the
  purest form of the failure. Eyeballing tells you *something is wrong*; it never tells you *what
  the right value is*.
- The work depends on **someone else's contract** — an API's actual behaviour, a format's spec, a
  library's documented guarantee — and we're going from memory.
- The user says some version of **"I don't know the answer either."** Two people guessing is not
  more reliable than one.

**Don't fire** for facts the codebase can answer (read the code), for decisions that are ours to
make (that's Design), or for anything where being roughly right is genuinely fine.

Fire it **before** the value is baked in where you can. Researching at Design costs a few minutes;
researching at Verify costs whatever was built on the wrong number.

## How to run it

**Dispatch the `researcher` agent** (`agents/researcher.md`, pinned to Sonnet) — don't read the web
in the main session. Reading twenty pages to extract three numbers is exactly the token-heavy work
the strong model shouldn't sit on, and the fetched pages would crowd out your working context.

Give it: the question, **the current value if one exists** (so it can tell you it's wrong), and any
constraint that narrows the answer. Then keep working on what doesn't depend on the result.

What comes back is a verdict, the numbers with sources, an agrees/contradicts call on the current
value, a confidence rating, and the path to a cited note.

## Acting on what comes back

- **A contradiction is a finding, not an inconvenience.** If the sources disagree with what's
  already built, that's a defect — treat it as one. Fix it in this change; don't file it away.
- **Correct reasoning is not the same as a correct answer.** If research confirms the value but for
  a different reason than you gave, **say both**. The next person inherits your reasoning, and
  reasoning that happened to land right will mislead them somewhere else.
- **Contested or thin? Surface it and decide with me.** A genuine conflict between sources is a
  judgement call, and judgement calls are mine.
- **Don't re-research settled ground — but a null result is not settled ground.** The note is
  durable so a question that *has* an answer is asked once; Recall reads it on the next pass. A
  question that came back empty is a record of one search, not an answer: don't cite it as a
  negative, and if the decision still turns on it, run it again with a wider surface than last
  time. Absence hardens into "nothing exists" precisely by being read twice.

## Where the note lands

The researcher writes a cited Markdown note in the repo's existing docs convention. That's
**code-local knowledge**: it travels with a clone and Recall finds it next time.

If the research **settled a decision** — we chose X over Y because the standard says so — that
earns an ADR at Chronicle, with the note as its evidence. A pure fact lookup doesn't; it stays a
note. Promote to Obsidian only if the lesson outlives this repo.

## Rules

- **Primary sources.** The body that owns the answer, not a write-up of them. A summary is a
  signpost — follow it home.
- **Cite everything, inline.** An uncited number in the note is worth exactly as much as the guess
  it replaced.
- **"The sources don't say" is a valid result — if it shows its work.** An absence is only worth
  something when it names where it looked: which authorities were actually consulted, and the
  strongest place the answer would have lived had it existed. "We searched and found nothing" is a
  claim about our search, not about the world. Report it that way and decide with me. Never close
  the gap with a plausible number — that's the thing research exists to prevent.
- **Never research to justify a decision already made.** That's not research, it's a search for
  supporting evidence, and it will find some. Go in willing to be wrong.
