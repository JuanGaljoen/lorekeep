# Blind spots — how a reachability graph lies

Consulted at step 4 of Sweep. Every class below is documented by the tool authors themselves, and
they converge across ecosystems: anything resolved dynamically or by convention, rather than by
static reference, is invisible to static analysis by construction.

Take each candidate through this list and try to prove it **live**.

## Live code that reads as dead

1. **Dynamic or computed reference.** `import(someVariable)`, reflection, string-keyed dependency
   injection, a registry assembled at runtime from names. Search for the string, not the symbol.
2. **Framework-convention entry points.** Routes, migrations, plugin registries, CLI bins, config
   files loaded by name. Live because a framework knows where to look; the tool knows only if a
   plugin taught it.
3. **Serialization targets.** A field set only by a JSON decoder, an ORM, or a wire format. Nothing
   in the codebase assigns it, and it is load-bearing.
4. **Test-only usage.** Many tools leave test files out of the graph by default, so a helper whose
   only callers are tests reads as orphaned.
5. **A library's public API.** For anything consumed outside this repo, no internal caller is the
   correct state. Settle application-or-library at step 2, before reporting a single unused export.

## Two more to carry

- **Build-config blindness.** A reachability graph is usually valid for exactly one build
  configuration — one platform, one feature-flag set, one set of tags. Code dead under the config
  you scanned can be live under another. Say which configuration you scanned.
- **The converse, which no static tool catches.** Code reachable from an entry point but never
  executed: an error branch that can't fire, a feature-flag path switched off years ago. Static
  analysis answers *reachable*; coverage answers *exercised*. Read existing coverage data as a
  second signal where the repo has it. Production sampling is the stronger version and a thing to
  propose, not to install mid-sweep.

## The remedy tools converge on

Every ecosystem's answer is the same: an explicit entry-point config and ignore list, tuned before
the output is trusted. If the repo will keep sweeping, that tuning is worth committing — it turns a
noisy tool into a quiet one, and the next sweep starts where this one finished.
