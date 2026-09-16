# The smell baseline

Consulted on the quality axis of Verify. "Simplicity holds up" is a good instinct with nothing
behind it, so walk this list against the diff.

It's Fowler's catalogue (*Refactoring*, ch. 3), and it applies **even in a repo that documents no
standards of its own** — which is most of them. Each reads *what it is → how to fix*:

- **Mysterious Name** — a function, variable or type whose name doesn't reveal what it does or
  holds. → Rename it; if no honest name comes, the design is murky.
- **Duplicated Code** — the same logic shape in more than one hunk or file. → Extract the shape,
  call it from both.
- **Feature Envy** — a method reaching into another object's data more than its own. → Move the
  method onto the data it envies.
- **Data Clumps** — the same few fields or params keep travelling together. → Bundle them into one
  type and pass that.
- **Primitive Obsession** — a string or primitive standing in for a domain concept. → Give the
  concept its own small type.
- **Repeated Switches** — the same `switch`/`if`-cascade on the same type recurs. → Polymorphism,
  or one map both sites share.
- **Shotgun Surgery** — one logical change forces scattered edits across many files. → Gather what
  changes together into one module.
- **Divergent Change** — one module edited for several unrelated reasons. → Split it so each module
  changes for one reason.
- **Speculative Generality** — abstraction, parameters or hooks added for needs the plan doesn't
  have. → Delete it; inline back until a real need shows.
- **Message Chains** — long `a.b().c().d()` navigation the caller shouldn't depend on. → Hide the
  walk behind one method on the first object.
- **Middle Man** — a class or function that mostly just delegates onward. → Cut it, call the real
  target.
- **Refused Bequest** — a subclass that ignores or overrides most of what it inherits. → Drop the
  inheritance, use composition.

## Three rules keep this a review and not a nitpick generator

- **The repo overrides.** A documented convention always wins. Where `CLAUDE.md` or the surrounding
  code endorses something the baseline would flag, suppress the smell — matching the neighbours is
  the standard.
- **Always a judgement call.** Name each as a possibility — *"possible Feature Envy in `x`"* — never
  as a violation. A breach of a documented standard can be hard; a baseline smell never is.
- **Skip what tooling enforces.** Where the linter or formatter already owns it, leave it with the
  tooling.

Two of these are principles you already hold, made visible in a diff: **Speculative Generality** is
Forge's YAGNI caught after the fact, and **Divergent Change** / **Shotgun Surgery** are what shallow
modules look like from the outside.
