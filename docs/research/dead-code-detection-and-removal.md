# Dead code / cruft detection and safe removal — research for `/sweep`

Date: 2026-09-16
Researcher: researcher agent (Sonnet), for the `/sweep` skill design.

## 1. Tooling landscape, per ecosystem

### TypeScript / JavaScript

| Tool | Detects | Status | Invocation | Static-only? |
|---|---|---|---|---|
| **knip** | Unused files, unused exports, unused *and* unlisted dependencies, unused enum/class members, unused types — grouped report by issue type. 150+ framework plugins (Next.js, Astro, Nx, Vitest, GH Actions, etc.) that teach it real framework entry points. | Current, actively maintained. [knip.dev](https://knip.dev/) | `knip` (config in `knip.json`); `knip --fix` auto-removes unused exports/deps. | Static (AST + type-aware resolution). |
| **ts-prune** | Unused exports only. | **Archived**, points to knip: *"The project is archived and recommends Knip."* — [knip.dev migration page](https://knip.dev/explanations/comparison-and-migration). Its own README states it's in maintenance mode, no new features. Equivalent knip invocation: `knip --include exports,types,nsExports,nsTypes`. | — | Static. |
| **depcheck** | Unused / missing npm dependencies. | **Archived** (June 2025). Own README banner: *"Depcheck is no longer actively maintained... We strongly recommend switching to knip."* — [github.com/depcheck/depcheck](https://github.com/depcheck/depcheck). | `depcheck` | Static. |
| **madge** | Module dependency graph, circular dependencies (`--circular`), orphan files with no imports/exports referenced (`--orphans`), leaf/terminal modules (`--leaves`). | Actively maintained, but scoped differently — a graph/visualisation tool, not a full unused-export/dependency scanner. Complements knip rather than replacing it. [github.com/pahen/madge](https://github.com/pahen/madge/blob/master/README.md) | `npx madge --circular src/`, `npx madge --orphans src/` | Static. |

**Verdict on ts-prune**: confirmed deprecated/archived, in favour of knip, from the horse's mouth (knip's own comparison-and-migration page, and ts-prune's README maintenance-mode notice). depcheck is *also* archived in favour of knip — this wasn't part of the original ask but is a live contradiction worth flagging if depcheck is anywhere in current tooling assumptions.

### Python

| Tool | Detects | Status | Invocation | Static-only? |
|---|---|---|---|---|
| **vulture** | Unused functions, classes, variables, imports, and attributes via AST analysis + a confidence score. | Current, maintained. [github.com/jendrikseipp/vulture](https://github.com/jendrikseipp/vulture) | `vulture mypackage/` | Static. |

No equally current alternative surfaced in this pass; vulture is the de facto tool. Dev commentary (secondary, dev.to) notes Python lacks a knip-equivalent that also covers unused *dependencies* — vulture only covers unused *code*, not unused packages in `requirements.txt`/`pyproject.toml`.

### Go

| Tool | Detects | Status | Invocation | Static-only? |
|---|---|---|---|---|
| **deadcode** (`golang.org/x/tools/cmd/deadcode`) | Unreachable *functions* — builds a whole-program call graph via Rapid Type Analysis (RTA) from every `main`/`init`, reports functions never reached. | Current, official `x/tools`. [pkg.go.dev/golang.org/x/tools/cmd/deadcode](https://pkg.go.dev/golang.org/x/tools/cmd/deadcode), announced on the official Go blog: [go.dev/blog/deadcode](https://go.dev/blog/deadcode) | `go install golang.org/x/tools/cmd/deadcode@latest`; `deadcode ./...`; `-whylive=function` explains why something is *not* dead; `-test` includes test binaries; `-json` for structured output. | Static (whole-program SSA analysis, not a running program). |

This is a genuinely different problem from the JS/Python tools above: it finds *unreachable functions in a binary*, not unused files/exports/dependencies in a source tree — the categories are not interchangeable and `/sweep` should not conflate them.

### Rust

| Tool | Detects | Approach | Limitations (documented) |
|---|---|---|---|
| **cargo-udeps** | Unused *dependencies* in `Cargo.toml`. | Compiles the crate on nightly and inspects the compiler's own record of which crates were actually used — most accurate but slowest, nightly-only. | Cannot see usage that only occurs in doc-tests, producing false positives for doc-only deps ([Rust Project Primer](https://rustprojectprimer.com/checks/unused.html)). Suppressible via `[package.metadata.cargo-udeps.ignore]`. |
| **cargo-machete** | Unused *dependencies*, text-level. | Greps `src/` for the dependency's name; fast, stable-toolchain. | Cannot detect deps used only via proc-macro-generated code or build scripts, since the generated code is invisible to text search ([bouvier.cc writeup](https://bouvier.cc/tech/cargo-machete/), corroborated by Rust Project Primer). Does *not* suffer cargo-udeps's transitive-dependency false-positive class, because absence of the name in `src/` is a stronger signal. |

Both are static/compile-time; neither runs the program. They solve the *dependency* problem, not unreachable-function detection — Rust has no single official equivalent of Go's `deadcode` surfaced in this search (not investigated further; would need a dedicated pass on `cargo-geiger`/clippy's `dead_code` lint if `/sweep` needs unreachable-function detection for Rust specifically).

**Confidence: settled** for tool identity and current/deprecated status — all confirmed from each project's own README/docs, not aggregator listicles.

## 2. Why these tools are wrong, and how often

This is the load-bearing section for `/sweep`: **every static tool above ships its own documented false-positive surface**, and the shape is consistent across ecosystems — anything resolved dynamically or by convention rather than by static reference is invisible to static analysis.

- **knip**: its own FAQ and issue tracker document this directly. *"Anything resolved dynamically, runtime `import()`, plugin systems, framework entry points it doesn't recognize (Next.js pages, a CLI bin, config files loaded by string), gets flagged as unused when it isn't. You will get false positives on day one."* — [knip.dev/reference/faq](https://knip.dev/reference/faq), [knip.dev/guides/handling-issues](https://knip.dev/guides/handling-issues). Template-string dynamic imports specifically are called out as unresolved ([GitHub issue #767](https://github.com/webpro-nl/knip/issues/767)). Knip's own remediation is *not* "trust the tool" — it's *"budget an afternoon to tune it [entry points, ignore lists] before you trust the output enough to delete on it."*
- **vulture**: ships a whole mechanism for this — the `--make-whitelist` flag and a bundled `vulture/whitelists/` directory of known false-positive patterns for common frameworks (e.g. Django). Its docs frame reflection/attribute-access/framework-convention usage (e.g. Django model fields, signal handlers) as the expected false-positive class, and `--min-confidence 100` as the lever to suppress everything but certainties. — [github.com/jendrikseipp/vulture](https://github.com/jendrikseipp/vulture)
- **depcheck**: its own README states plainly that its detection "rules may not be enough or even be wrong," and documents dependencies used only through build-tool plugins (webpack, eslint, prettier configs) as the main false-positive class it tries, imperfectly, to special-case.
- **deadcode** (Go): documents that its call graph is valid for exactly one `GOOS/GOARCH/-tags` build; a function dead under one build config can be live under another. It also doesn't fully resolve reflection-based dispatch, and doesn't see `//go:linkname` aliasing — both documented limitations on its own pkg.go.dev page.
- **cargo-udeps / cargo-machete**: opposite failure modes, both documented by the authors — udeps misses doc-test-only usage; machete misses proc-macro- and build-script-generated usage. Neither sees usage the compiler only produces after macro expansion in the other's blind spot.

**The general pattern to state in the skill**: static dead-code tools are blind to (a) dynamic/computed reference — `import(variable)`, reflection, string-keyed dependency injection, (b) framework-convention entry points that only a plugin (or hand-tuned entry-point config) teaches the tool about — routes, migrations, plugin registries, CLI bins, (c) serialization/deserialization targets (a struct field only ever set by a JSON/DB mapper), (d) test-only usage where the tool doesn't load test files into its graph by default, and (e) a library's public API, where "no internal caller" is the *normal*, correct state, not a defect. Every ecosystem's tool authors document at least one of these classes themselves; the tools all converge on the same fix — an explicit ignore-list / entry-point config — rather than claiming to solve it.

**The converse — what static tools miss (flag it live, but it's actually dead)**: none of the sources retrieved this pass discuss this converse case directly (a function statically reachable from `main` but never hit in practice — e.g. an error branch, a feature-flagged path never enabled, a config permutation never used). This is exactly the gap that motivates section 3 below; call it **not found** as a documented, named phenomenon in the tool docs themselves, though it's the direct rationale coverage-based tools give for existing.

**Confidence: settled** for the false-positive classes (all sourced from each tool's own docs/issues) — this is the strongest, most directly citable section.

## 3. Coverage-driven detection

This is thinner ground than section 2, and best sourced from practitioner write-ups rather than a spec or standard — there is no equivalent of "the knip docs" for this technique.

- **Coverband** (Ruby, Dan Mayer) is the clearest named, citable example: a production-instrumentation gem that samples code execution in the running app (originally via `set_trace_func`, later `Coverage`) rather than relying on test coverage. Reported outcome at LivingSocial: *"we have removed tens of thousands of lines [of] app code"* (and hundreds of thousands including CSS/JS/tests/deprecated services), using a configurable sampling rate (e.g. 20% in production, higher in dev) with a startup warm-up delay before measuring. — [mayerdan.com/coverband-railsconf](https://www.mayerdan.com/coverband-railsconf/)
- The Java ecosystem has an equivalent pattern using JVM instrumentation agents (e.g. Javassist-based) to flag unused classes at runtime, per a practitioner writeup on foojay.io — same idea, different substrate, not independently verified against a primary tool doc in this pass.
- The general framing that recurs across secondary sources: static analysis tells you what's *reachable*; coverage (test or production) tells you what's actually *exercised* — the two are complementary, and the coverage side is specifically the answer to section 2's stated blind spot (statically-reachable-but-practically-dead code, e.g. an old feature flag path).
- No large-codebase engineering blog (Google/Meta/Uber-scale) surfaced in this search describing coverage-driven dead-code sweeps as a named, systematic practice — what turned up was framework-level tooling (Coverband) and vendor content (Codecov, BuildPulse) describing the static+coverage combination in the abstract, not a documented large-scale program.

**Confidence: thin.** Coverband is a real, citable primary source for the technique and for one company's outcome; beyond it, this section rests on vendor blogs and one secondary write-up, not primary engineering accounts from large codebases. Treat the technique as validated in principle and by at least one shipped tool with real numbers, but don't cite it as an industry-standard large-scale practice — that claim isn't backed here.

## 4. Safe-deletion practice

- **Chesterton's Fence** is a live, named mental model in software-deletion writing — "never take down a fence until you understand why it was put up" — applied specifically to the fear of deleting code whose purpose isn't understood. Sourced to secondary essays (georgestocker.com, josephwoodward.co.uk, nicholasdipreta.com); **no direct primary Fowler essay applying it to code deletion surfaced in this search** — the connection is folklore-strength, not a citable Fowler quote. Flag this precisely: it's a real, widely-used framing, but "Fowler said this" would be an unverified claim.
- **Kent Beck**, directly, on record twice: a 2013 tweet — *"cleaning up large pile of ugly code, step 1: delete everything that isn't being used. if it doesn't exist, you don't have to fix it"* — and in his *Tidy First?* newsletter/book (2023): *"Delete it. That's all. If the code doesn't get executed, delete it."* ([newsletter.kentbeck.com/p/tidying-dead-code](https://newsletter.kentbeck.com/p/tidying-dead-code)). This is a primary, unambiguous source: Beck treats dead-code deletion as a zero-ceremony "tidying," not something requiring a design process. (The fuller article is paywalled past the opening directive — I could not confirm from primary text whether he separately argues for version-control-as-safety-net inside that same piece; treat that specific linkage as unconfirmed, even though it's widely repeated.)
- **Google — *Software Engineering at Google*, ch. 15 "Deprecation"** (Winters, Manshreck, Wright), primary source, fetched directly: frames unused/obsolete code as a maintained *liability*, not a neutral asset — cost is paid continuously, not just at write-time. Documents two removal modes: **advisory deprecation** (no deadline, no dedicated resourcing — the book's own verdict: *"Hope is not a strategy"*, rarely drives real migration) and **compulsory deprecation** (explicit deadline, *"actively staffed by a specialized team through completion"*). It explicitly warns the inverse can also be true — poorly managed deprecation *"may cost more than leaving them alone"* — i.e. the practice is not "always delete," it's "deletion has its own cost and needs staffing to pay off." — [abseil.io/resources/swe-book/html/ch15.html](https://abseil.io/resources/swe-book/html/ch15.html)
- **"git remembers, so delete boldly"**: this is the real, load-bearing consensus claim across practitioner writing, but it comes with a documented tension worth carrying into the skill rather than smoothing over: multiple sources state the *idea* that git makes reversal cheap (`git reflog`, branch recovery), while at least one 2026-era commentary observes that in practice teams (and LLM agents) behave as though there's an *asymmetric* penalty for deleting-then-needing-it vs. leaving dead code in place, "even though there isn't [an asymmetric cost] — git remembers everything." That's a documented gap between the stated principle and observed behaviour, not a contradiction of the principle itself.
- **Deletion mechanics** (small reviewable commits vs. one big sweep, deprecate-then-delete): repeatedly recommended across secondary practitioner sources (Built In / Braintree engineering write-up: mark `@Obsolete`/feature-flag off first, keep the flag off for a soak period, then delete) but I found **no primary standards document (Google eng-practices docs, SQLite, LLVM) that states a specific commit-granularity policy for dead-code removal** in this pass — the eng-practices angle that *did* surface primary-source (Google's ch.15) speaks to system-level deprecation, not line-level PR hygiene. Treat "small commits, not big-bang" as consensus practitioner advice, not a codified standard.
- **Is dead code a real defect risk, or just untidy?** I found **no direct empirical study connecting dead/unreachable code specifically to defect density** in this pass. What surfaced instead was general code-complexity/defect-density literature (e.g. path complexity correlating more than cyclomatic complexity; code churn as a defect predictor) — relevant background, but not evidence about *dead* code specifically. This is the honest gap: the case for removing dead code, on the evidence gathered here, rests on maintenance-cost and comprehension arguments (Google ch.15, Beck), not on a demonstrated defect-rate effect.

**Confidence: contested/thin, by sub-claim** — Beck's own words and Google's ch.15 are settled, primary, and directly citable. Chesterton's Fence's attribution to Fowler and "small commits" as a named standards-body policy are **not found** at primary-source strength in this pass — real practices, but sourced here only to blogs, not to Fowler/SQLite/LLVM policy text directly.

## 5. Evidence on cost (build times, comprehension, defect rate)

**Honest answer: this evidence is thin, and mostly absent as a rigorous empirical case.** What this search turned up:

- **Maintenance cost, stated not measured**: Google's ch.15 (primary) asserts continuous maintenance cost for unused/duplicate systems in qualitative terms — no cited benchmark numbers.
- **Concrete before/after line counts exist for one project**: Coverband/LivingSocial's "tens of thousands of lines removed" (section 3) is a real, named, quantified outcome — but it's a single company's report, not a controlled study, and it measures *lines removed*, not resulting defect rate or build-time change.
- **Defect-rate evidence specific to dead code**: **not found** in this pass. General code-complexity-vs-defects literature exists (path complexity, churn) but none of it isolates *unreachable/unused* code as the independent variable.
- **Build-time / onboarding cost**: **not found** — no study or primary engineering account surfaced quantifying build-time or onboarding-time impact of dead code specifically.

**Where it would have been, if it existed**: a peer-reviewed empirical SE study (ICSE/FSE/TSE) isolating "presence of statically-dead code" as a predictor in a defect-prediction model, or a large-company engineering blog (Google/Meta/Microsoft) publishing a before/after build-time delta from a dead-code sweep. Neither turned up.

**What I'd try next**: search ACM/IEEE venues directly (`site:dl.acm.org dead code defect prediction`), and check whether SQLite's or LLVM's own contribution/style docs state a removal policy with a stated rationale (this pass searched broadly but never fetched sqlite.org or llvm.org policy pages directly — that's the concrete gap to close before treating section 5 as settled).

**Confidence: thin to not found.** State this plainly in the skill: the case for `/sweep` is a maintenance/comprehension argument backed by named practitioners (Beck, Google), not a demonstrated defect-rate or build-time effect — don't oversell it as "proven to reduce bugs."

---

## Digest for the skill author

1. **ts-prune and depcheck are both archived, primary-source-confirmed, in favour of knip** — if `/sweep`'s TS/JS pass currently names either, that's outdated and should point to knip instead.
2. **The four "unused X" problems are genuinely different and the skill should not conflate them**: unused files/exports (knip), unused dependencies (depcheck/knip, cargo-udeps/machete), unreachable functions in a compiled binary (Go's `deadcode`), and circular-dependency/orphan-file graphing (madge). A tool solving one doesn't cover the others.
3. **Every static tool's own docs admit the same five false-positive classes**: dynamic/computed reference, framework-convention entry points, serialization targets, test-only usage, and public API surface. `/sweep` should treat "flagged by the tool" as a lead, not a verdict, and should require an entry-point/ignore-list pass (as knip's own docs insist) before proposing deletion.
4. **Coverage-driven detection is real (Coverband, with real numbers) but thin as an industry-wide practice** — good as a secondary signal, not documented at large-company scale in this search.
5. **Safe-deletion practice is consensus-strength but not policy-strength**: Beck says delete without ceremony; Google's ch.15 says deprecation needs staffing or it backfires; nobody in this search offered a primary standards document mandating small-commit granularity, and Chesterton's-Fence-as-Fowler is folklore, not a found citation.
6. **The defect-risk and cost case for dead code removal is not empirically established** in what this search found — say so in the skill rather than asserting it as proven.
