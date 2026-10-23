# Security pass

Read this when the diff crosses a trust boundary: authentication or authorization, input from a
user or another system, files and paths, outbound requests, secrets, serialization, or text that
reaches an LLM prompt or tool call. Design names these in the plan; a diff that touches none of
them skips this file.

This reviews the change, not the codebase. Pre-existing holes elsewhere stay invisible to it. For a
whole-repo audit, use Cloudflare's [security-audit-skill](https://github.com/cloudflare/security-audit-skill)
(MIT), which this file is adapted from.

## The candidate gate

A finding counts only when you can name all six:

1. **Who** — the lower-trust principal (anonymous caller, another tenant, a webpage, a document the
   model reads).
2. **What they send** — the input or action they control.
3. **The control** — what is supposed to stop them.
4. **The boundary** — what they cross that they shouldn't.
5. **The victim** — the principal or resource affected.
6. **The result** — a concrete outcome: a wrong record returned, a write that should have failed,
   script running in someone else's session.

Miss one and it's a hardening note, not a finding. Say so and keep it out of the verdict.

## Hunt with these questions

- **Authorization, not just authentication.** Does every new path check *what* the caller may do,
  on *this* resource, not only that they're logged in? Is there a weaker path to the same state
  change? Can a field in the request body override what the permission check restricted? Do bulk,
  export and import check each item?
- **Injection, including the indirect kind.** Can input reach a query, a shell, a path, a template
  or a prompt? Look past the direct path: data stored safely, then read back by other code into a
  dangerous context. Field names, keys and headers count, not just values.
- **Files and fetches.** Path traversal (encoded sequences, symlinks), outbound requests to a URL
  the caller chose (SSRF), archive extraction, unsafe deserialization.
- **Secrets.** In source, logs, error messages, URLs, or anything sent to the client. Compared in
  constant time. Generated with secure randomness.
- **Business logic.** Can a flow skip a step, replay, or race (check-then-act without atomicity)?
  Negative, zero or huge quantities? What is the posture when config is missing or a dependency is
  down: does it fail closed?
- **LLM input.** Is text from a document, page or tool result able to steer actions the user
  didn't ask for? Is model output used as a query, command, URL or HTML without the same handling
  as user input?

## Try to disprove it

Before reporting a finding, argue against it: find the control that already blocks it, the caller
that can't actually reach it, the framework default that escapes it. A finding that survives an
honest attempt to kill it is worth my time; one that wasn't challenged isn't.

## Don't guess what isn't in the repo

Proxy rules, IAM, deployment headers, provider settings and identity policy are real controls. When
the finding turns on one the repo can't show, don't assume it's present or absent: report it as
**needs validation**, name the exact missing fact, and give it no severity.

## Severity

Only a finding that passed the gate gets one, and it can't exceed the demonstrated result.

- **Critical** — an unauthenticated actor gains code execution, full data-store access, or takeover
  of arbitrary accounts.
- **High** — fully defeats an explicit control with real consequences: auth bypass, cross-tenant
  read or write, stored script affecting other users, authenticated code execution.
- **Medium** — a real boundary violation with limited reach, uncommon preconditions, or a narrow
  set of resources.
- **Low** — disclosure of non-secret internals, or real effort for minimal gain.

Between high and medium: does it fully defeat the control, or only weaken it? If you can't state
the concrete damage, it's lower than it feels.

## Fix it like a bug

Name the invariant the code must enforce, and fix it at the last point where the input is still
trusted, with a regression test that fails on the attack. That's Diagnose's discipline; the
attack is the repro.

## Not findings

- A checklist item the code doesn't follow, with no reachable boundary violation.
- A missing defence layer when an existing one already blocks the attack.
- A caller affecting only themselves, or using authority they legitimately have.
