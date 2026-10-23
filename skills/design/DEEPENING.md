# Deepening a module

Read this when the work is a refactor that deepens a module — usually a Sweep refactor candidate
you picked, or a Design where the obvious approach would add another shallow layer. Features that
don't reshape a module can skip it.

Adapted from Matt Pocock's `improve-codebase-architecture` and `codebase-design` skills
([mattpocock/skills](https://github.com/mattpocock/skills), MIT), which build on John Ousterhout's
*A Philosophy of Software Design*.

## Vocabulary

Use these words exactly, so a suggestion means the same thing every time. Name modules with the
project's domain terms from `CLAUDE.md` ("the order-intake module"), not class names.

- **Module** — anything with an interface and an implementation: a function, a class, a package.
- **Interface** — everything a caller must know to use it: signatures, but also ordering,
  error cases, and invariants. **The interface is the test surface.**
- **Depth** — how much behaviour hides behind how small an interface. A property of the interface,
  not a ratio of lines. **Shallow**: the interface is nearly as complex as what it hides.
- **Seam** — a place where behaviour can be swapped without editing the caller.
- **Adapter** — one concrete thing plugged into a seam. One adapter means the seam is
  hypothetical; two (say, production and in-memory) means it's real.
- **Leverage** — how many callers get simpler when this module gets deeper.
- **Locality** — whether a change to one concept lands in one place, or ripples across many.

## Classify the dependency first

What a deepened module hides decides where its seam goes and how it's tested:

| Dependency | Seam | Tests |
|------------|------|-------|
| **In-process** (pure code, same runtime) | None — merge the shallow modules | Directly, through the merged interface |
| **Local and substitutable** (e.g. an embedded or in-memory database) | Internal | Against the local substitute |
| **Remote but ours** (a service we own) | A port, with a production adapter and an in-memory one | Through the in-memory adapter |
| **Truly external** (a third-party API) | An injected port | A mock at the port, and nowhere else |

## Design it twice

The first interface you think of is rarely the deepest. Before freezing, draft **two radically
different interfaces** for the deepened module, each under one constraint:

1. **Minimal** — one to three entry points, as much hidden as possible.
2. **Common-case** — makes the most frequent caller trivial.

Add a third, **Flexible** (supports the widest range of callers), only when the module has many
callers with genuinely different needs. That's where a wider search pays for itself.

Frame the problem first (constraints, the dependency category, a rough sketch of callers), then
draft them one after another in this session, and don't revise an earlier one while writing a later
one. Parallel sub-agents keep drafts from converging further, but each one starts cold and re-reads
the code. Use them only when asked.

Compare them on **depth, locality and seam placement**, then recommend one — or a hybrid — rather
than presenting a menu. The comparison goes in the plan's *Approach*.

## Tests move to the new interface

Tests on the old shallow modules are replaced by tests at the deepened interface, asserting on
observable outcomes. A test that has to change when the implementation changes is testing past the
interface — rewrite or delete it.

## Rules

- **Don't propose an interface before the candidate is chosen.** Sweep reports friction; the
  interface work starts here, after Understand.
- **Respect the ADRs.** A refactor an ADR rules out comes back only when the friction is real
  enough to reopen that ADR — say so explicitly.
