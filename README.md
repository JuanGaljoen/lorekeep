# lorekeep

A lean, six-phase workflow for doing real engineering with Claude Code.

No orchestrator owns the process. No hook blocks your keystrokes. No state machine to appease.
Just a spine you move along and six small skills that hold the discipline — composable, easy to
adapt, and yours to bend.

```
Recall 📚  →  Understand 🧭  →  Design ✍️  →  Forge ⚒️  →  Verify 🔍  →  Chronicle 📖
```

| Phase | Question | Skill |
|-------|----------|-------|
| **Recall 📚** | What do we already know? | [`skills/recall`](skills/recall/SKILL.md) |
| **Understand 🧭** | What problem are we solving? | [`skills/understand`](skills/understand/SKILL.md) |
| **Design ✍️** | What's the cleanest way to build this? | [`skills/design`](skills/design/SKILL.md) |
| **Forge ⚒️** | Build exactly what's needed. | [`skills/forge`](skills/forge/SKILL.md) |
| **Verify 🔍** | Did we build the right thing? | [`skills/verify`](skills/verify/SKILL.md) |
| **Chronicle 📖** | What should future-us know? | [`skills/chronicle`](skills/chronicle/SKILL.md) |

## How it works

[`CLAUDE.md`](CLAUDE.md) is the spine — loaded every session. It tells the agent to classify the
work first (question / fix / feature), then walk only the phases the work earns. Each phase is a
skill the agent reaches for automatically, or that you invoke by name (`/recall`, `/forge`, …).

Knowledge lives in two homes: **in-repo** (`CONTEXT.md` + `docs/adr/`) by default, and
**Obsidian** for the rare lesson that outlives a single repo.

## Credit

Shaped by [Matt Pocock's "Skills For Real Engineers"](https://github.com/mattpocock/skills) —
the small-and-composable philosophy, the grilling interview, the CONTEXT.md idea.
