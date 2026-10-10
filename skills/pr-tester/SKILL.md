---
name: pr-tester
description: Test a pull request or branch by building and running its exact revision, exercising the changed behavior through the real UI, API, CLI, or game, and reporting reproducible findings with a test-confidence score. Use for hands-on PR verification and retesting fixes; pair with github-pr-review for a full source review.
---

# PR Tester

Establish what the change actually does when used. Build the code, run it, exercise the feature, and preserve enough evidence for another person to reproduce the result. A successful build or passing unit suite alone does not establish that a runtime feature works.

## Establish the target and responsibilities

Use the PR description, diff, discussion, repository instructions, and relevant callers to identify the intended behavior and acceptance criteria. Resolve the repository, PR or branch, exact head SHA, and comparison base. Ask only for missing information that prevents useful work; infer normal build and launch commands from the repository.

Read [revisions-and-watch.md](references/revisions-and-watch.md) when acquiring a checkout, reusing earlier results, coordinating agents, or monitoring updates. Reuse a suitable local worktree or obtain the PR in an isolated worktree. Preserve existing work. Record the actual source revision, fixture changes, and built executable; a directory named after a PR is not proof of its contents.

Apply the available `coding-style` skill when writing a test game, fixture, harness, or other code. When a full review is requested or the session requires it, also use `github-pr-review` for source analysis and the merge recommendation. This skill supplies runtime evidence and a **test-confidence** score; it does not substitute that score for a complete code review.

If agents are already assigned or delegation is requested, separate responsibilities: the tester owns runtime verification, the reviewer owns source review and the combined verdict, and one named agent owns posting. Cover every assigned PR without duplicating reviews. Do not silently turn a bounded test request into an ongoing watcher.

## Turn the change into a small experiment

Make a compact checklist of **action → expected observable → actual result/evidence**. Cover the changed happy path and the failure, transition, or lifecycle boundary most likely to expose a defect. Choose scenarios from the implementation and contract; do not expand every PR into a general audit.

Use existing examples when they genuinely reach the changed code. For an engine feature, create or adapt a small test game that invokes the real feature through its public interface. A demo PR can use its supplied game. Keep fixtures isolated and label any injected state, mocked dependencies, or instrumentation. Do not modify the implementation under test to make the test pass; investigating a fix is a separate, disclosed experiment.

Read the relevant sections of [runtime-playbooks.md](references/runtime-playbooks.md) for UI/browser, server/API, CLI, game/engine, or generated-asset testing. Use the interface whose behavior is claimed:

- UI changes require actual UI interaction and inspection. APIs may prepare data or corroborate state.
- Server changes require requests to a running instance and verification of relevant responses, logs, and state effects.
- CLI changes require executing the built command and examining its output or resulting artifacts.
- Game changes require running a game and applying inputs while observing gameplay state; visual claims also require the real renderer and inspected captures.

Read applicable computer-use or browser skills before using their tools. Discover available MCP and application interfaces rather than inventing commands. Prefer the repo's existing driver or automation where it provides real runtime control; use computer interaction when that is the feature's actual surface.

## Execute and diagnose

Build and run the checks appropriate to the changed area. Then launch the actual application or server with isolated test state and exercise the planned scenarios. Capture commands, relevant logs, state transitions, and visual evidence as needed. Check readiness separately from feature correctness: HTTP 200, an open window, or a running process is only the beginning.

Assert outcomes, not activity: a save survives restart, another client sees the update, a character lands on the platform, or a generated file works in its consumer. Inspect screenshots before citing them. Never substitute a mockup or generated image for a runtime capture.

Distinguish a product defect from a broken harness or unavailable environment. Confirm identifiers, response schemas, timing, and callback phases before blaming the change. Reduce a suspected defect to the shortest reliable reproduction and connect it to relevant code. Where feasible, compare with the base revision to distinguish a regression from an existing problem.

Use bounded waits and explicit input release. After an interrupted tool call, check whether the process started or remains running before retrying. Keep evidence states distinct: queued, built, started, completed, interrupted. If the runtime never started, say so even when all build and rule tests passed. Continue other useful verification while a genuine environmental limitation is unresolved.

Once the planned checks pass, stop repeating them unless a new change, failure, or unresolved question justifies more testing. Reuse results only when the relevant source, dependency, configuration, fixture, and asset inputs still support them. Record the earlier tested revision and the reuse rationale instead of claiming a fresh run.

## Report and finish

Read [reporting.md](references/reporting.md) before scoring, handing off, or posting. Report observed behavior, actionable findings, evidence provenance, and material gaps. Distinguish independently designed checks from rerun author tests, CI results, and source inspection. Give each finding a trigger, actual versus expected outcome, consequence, and concrete next step.

Post the result to the PR when authorized, including standing instructions such as “always post.” Otherwise deliver the same publication-ready report locally. In a reviewer/tester pair, send evidence to the posting owner. A numeric score does not authorize approval, requesting changes, merging, or deployment.

Track and stop only processes owned by this test, release held inputs, and retain useful artifacts or reproduction fixtures. Leave unrelated servers, worktrees, and user changes intact. Finish with the tested SHA, score, key result, report location, and any remaining gap. If the user accepts a non-blocking score, do not manufacture more work to force it to 5/5.
