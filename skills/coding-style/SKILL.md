---
name: coding-style
description: Write and review code in the style of John Ousterhout's "A Philosophy of Software Design" — minimize complexity through deep modules, information hiding, obvious code, and disciplined comments. Language-agnostic. Apply whenever writing, editing, refactoring, or reviewing code: when designing a module, interface, class, function, error path, name, or comment. Not for prose, config, or pure data files.
---

# Coding Style

The job when writing code is **minimizing complexity**, not just making it work. Working code that's complex is a liability — it gets harder to change every week. Spend the marginal effort now (strategic), don't just bolt on the fastest patch that passes (tactical).

This is grounded in *A Philosophy of Software Design* (Ousterhout) and is **language-agnostic** — the principles below hold in any language.

**Match the surrounding codebase over any default here.** Read a couple of source files, the formatter/linter config, and the existing patterns first. These rules are for greenfield code or a codebase with no clear opinion; an established convention always wins, because consistency lowers cognitive load more than any local "better" idea.

## The one definition that drives everything

**Complexity** = anything about the structure that makes code hard to understand or modify. Its two sources:

- **Dependencies** — when code can't be understood or changed in isolation.
- **Obscurity** — when important information isn't obvious.

It shows up as three symptoms. If you feel one while editing, complexity is the cause:
1. **Change amplification** — a simple change touches many places.
2. **Cognitive load** — you must hold a lot in your head to make a change safely.
3. **Unknown unknowns** — it's not obvious what you must change, or what knowledge you need. (The worst — you can't even see the risk.)

Complexity is **incremental**. There's no single catastrophic decision; it's a hundred small ones. So the bar each edit is: *don't add a chip of complexity that didn't have to be there.*

## Before you write — design it (briefly) twice

For anything non-trivial, sketch two different decompositions before committing to one. The first idea is rarely the best, and the act of comparing teaches you what "good" looks like for this problem. This costs minutes and routinely changes the design.

## The core move: deep modules

A module (function, class, file, service) has an **interface** (what a caller must know) and an **implementation** (everything else). The best modules are **deep**: a *simple interface* hiding a *powerful implementation*. The value of a module is its functionality minus its interface cost — so maximize the depth ratio.

- **Deep** ✅ — `read(file) → bytes` over a syscall-and-buffering machine. Tiny interface, huge capability.
- **Shallow** ❌ — a method whose signature is about as complicated as its body. It adds interface cost without hiding much. Thin wrappers and one-line pass-throughs are the canonical offenders.

When deciding where to put a function/abstraction boundary, ask: *does this interface let the caller forget something real?* If not, it's probably not earning its place.

## Working rules (apply while editing)

- **Information hiding.** Each module should encapsulate a design decision (a file format, an eviction policy, a wire protocol) and not leak it. **Information leakage** — the same knowledge baked into two+ places — is the most common depth-killer. If changing one decision forces edits in several modules, they're leaking.
- **Pull complexity downward.** It's better for the *implementer* of a module to absorb complexity than to push it up to every caller via config knobs and special cases. Accept flexible inputs and resolve the mess inside; prefer a sensible default computed internally over a parameter the caller must understand.
- **Make illegal states unrepresentable.** Encode invariants in the data shape so the wrong combination simply can't be built, and downstream error handling disappears. Prefer a tagged union of valid shapes (`{ status: "loading" } | { status: "ok", data } | { status: "error", message }`) over a bag of optional fields and boolean flags that permit contradictory state. Use precise types over generic maps / untyped blobs.
- **Define errors out of existence.** The best exception handling is needing none — each `throw` becomes a handling obligation somewhere else. Design the error away first:
  - **No-op** when the operation is already satisfied (deleting an absent key succeeds; `move(i, i)` returns immediately).
  - **Clamp / saturate** out-of-range arguments instead of throwing (a substring with overshooting indices returns what overlaps).
  - **Return empty / nothing** for "not found" when that's a normal, expected outcome.
  - **Mask** the condition once low in the stack, or **aggregate** handling high in one place — don't sprinkle `try/catch` everywhere.

  Reserve raising for genuine programmer errors and truly unhandleable conditions. Validate-and-throw on ordinary control flow is a smell.
- **General-purpose, somewhat.** Make the interface a little more general than today's single use ("somewhat general-purpose"). General interfaces are usually simpler and deeper than a pile of special-purpose ones. But don't speculatively build for imagined futures.
- **Different layer, different abstraction.** Adjacent layers should *not* have the same abstraction. If method A just calls B with the same signature (**pass-through method**), or a variable is threaded through many layers untouched (**pass-through variable**), the layer isn't earning its keep — collapse it.
- **Keep related code together; split unrelated code.** Don't structure by *time of execution* (**temporal decomposition** — "step 1 file, step 2 file"); structure by *knowledge*. Code that shares a secret belongs together even if it runs at different times.
- **Keep the happy path flat.** Use guard clauses and early returns instead of deep nesting. Handle the awkward cases first and get them out of the way so the main line reads top-to-bottom.
- **Make it obvious.** Obvious code is read once and understood. Fight obscurity: precise names, no clever indirection, no behavior hidden behind events/config the reader can't see from here.

## Comments

Comments capture what code *can't* express — they're part of the design, not an afterthought. But the first move is always to make the code obvious enough not to need one.

**Minimize comments. Each comment is at most 2 lines.** The default is no comment. Write one only when the code genuinely cannot carry the information — and keep it short. If you need more than two lines to explain a chunk, the design is too obscure; fix the code, don't write a longer comment.

**Be concise — sacrifice grammar for concision.** Fragments are fine. Drop articles and full sentences. One line beats three.

Comment when the code is **not self-evident**:
- **Magic numbers / non-obvious constants** — explain the value or its unit. (`sleep(300) // debounce: match input animation`)
- **Workarounds** — say *why*, link the cause. (`// platform fires resize before layout; defer a frame`)
- **Surprising-but-intentional code** — code that looks wrong but isn't. (`// bitwise floor, hot path`)
- **Hard-to-follow logic** — a dense algorithm, a tricky invariant, a unit. (`// invariant: head <= tail, both wrap at capacity`)
- **The "why" the code can't express** — a rationale, trade-off, or ordering constraint.
- **Genuine debt** — `TODO:` plus a short reason.

Two structural rules:
- Write the **interface comment** (what a caller needs to use the thing) **first**, as a design tool: if it's hard to describe the abstraction simply, the design is probably wrong (a **red flag**). Fix the design, not the comment. Keep **interface comments** separate from **implementation comments** (how it works) — don't leak implementation detail upward.
- **Never restate the code** (`i++  // increment i`) — delete it. And never leave a stale comment after changing the code; update or remove it.

## Naming

Names are the cheapest, highest-leverage complexity reducer. Make them **precise** and **consistent**. If a name is vague (`data`, `obj`, `process`) or you *can't* find a good one, that's usually a signal the underlying thing is muddled — the design needs splitting or clarifying, not a longer name.

## File organization

- **One cohesive concept per file.** Co-locate by concern with sibling files rather than a distant catch-all dump. Size is fine when it serves a single clear abstraction.
- **Don't shred a coherent abstraction into many shallow files** just to make files small — that's temporal/size-driven decomposition, and it spreads one secret across many places.

## Classes vs functions — pick by the problem

- **Stateful, long-lived machines** (engines, parsers, stores, strategy hierarchies) are natural classes: explicit fields declared in one place, real encapsulation. Avoid shallow pass-through getters/setters; expose one only when it computes or guards something.
- **Transformations, glue, and UI** are natural functions — keep them pure where practical.
- **Don't over-decompose.** Many tiny methods that only call each other add indirection and cognitive load. Subdivide only when it genuinely reduces complexity.

## Testing

- Write behavioral tests for anything with non-trivial logic; throwaway experiments can skip them.
- Test names describe the **behavior** (`"header format is correct"`), not the function name.
- Tests give you the confidence to refactor toward better design — let design drive the tests, not the reverse.

## Consistency

Similar things done the same way lower cognitive load and create reliable assumptions. Match the surrounding code's patterns, names, and idioms. A locally-clever deviation is a complexity cost even if it's "better" in isolation.

## Red flags — stop and reconsider when you see one

These are the tells that you're adding complexity. Treat any as a prompt to redesign the chunk you're touching:

- **Shallow module / class** — interface as complex as the implementation.
- **Information leakage** — a design decision reflected in multiple modules.
- **Temporal decomposition** — structure mirrors execution order, not knowledge.
- **Overexposure** — using a common case forces the caller to learn rarely-used options.
- **Pass-through method / variable** — a layer that adds nothing but indirection.
- **Repetition** — the same snippet copied; it wants to be one deep helper.
- **Special-general mixture** — special-case code tangled into a general mechanism.
- **Conjoined methods** — you can't understand one without reading the other.
- **Contradictory state possible** — optional fields / flags that permit invalid combinations; use a tagged union.
- **`throw` on an ordinary, expected condition** — every caller now has to catch it; define the error away.
- **Comment restates code** — the code needs to be more obvious, or the comment more useful.
- **Hard to name / hard to describe** — the abstraction is muddled; rethink the boundary.
- **Nonobvious code** — a reader needs facts not present here.

## Tactical vs strategic — the standing bias

Default to **strategic**: invest the small extra effort to keep the design clean as you go (a working figure is ~10–20% of dev time). Avoid the "tactical tornado" pattern of fast features that leave a worse codebase. The exception is a genuine throwaway/prototype — and even then, name it as such so nobody mistakes it for the real thing.

---

**Use this every time you write or edit code.** Before you finish an edit, run the chunk past: *Is the module deep? Does anything leak? Is the happy path flat? Are illegal states unrepresentable? Did I define the errors away? Is every name precise? Does each comment add what the code can't say, in ≤2 lines? Did I add a chip of complexity I didn't have to?*
