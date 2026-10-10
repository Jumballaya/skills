# What was distilled from Adapt

Inspected on 2026-10-10 at [adaptcom/adapt-v1 commit 6371af7](https://github.com/adaptcom/adapt-v1/tree/6371af7886945ff52073d9084bbec40d031b3104). Links below are pinned to that revision. This is implementation evidence, not proof of the deployed configuration or a benchmark of review quality.

## Review-specific process

1. A GitHub opened/ready-for-review event seeds the regular agent conversation for that repository and PR. Drafts wait; automatic review normally runs once per PR. Manual reruns seed the same structured review. The run starts with `intelligenceLevel: "deep"`.
2. The seed supplies PR title, author, description, branch, and exact head SHA. It instructs the agent to authenticate with the connected GitHub integration, clone the repository, check out that SHA, and diff against the base branch.
3. The review instruction covers every changed line, explicitly including style, naming, dead code, edge cases, and subtle regressions. It says actionable findings matter regardless of severity and forbids assuming other reviewers or CI will cover omissions.
4. The model returns JSON: merge-confidence score, short summary, important files, and findings with optional locations and a blocking flag.
5. The backend parses and renders the result, posts an initial COMMENT review plus RIGHT-side inline comments, and concludes a check. Re-reviews can rewrite the existing review body. Follow-up mentions reuse the PR conversation.

Sources: [webhook.ts: review seed and orchestration](https://github.com/adaptcom/adapt-v1/blob/6371af7886945ff52073d9084bbec40d031b3104/packages/adapt-backend/src/integrations/github/webhook.ts#L663), [buildReviewRequest](https://github.com/adaptcom/adapt-v1/blob/6371af7886945ff52073d9084bbec40d031b3104/packages/adapt-backend/src/integrations/github/webhook.ts#L1093), [notification rendering/delivery](https://github.com/adaptcom/adapt-v1/blob/6371af7886945ff52073d9084bbec40d031b3104/packages/adapt-backend/src/integrations/github/notification.ts), [GitHub review API](https://github.com/adaptcom/adapt-v1/blob/6371af7886945ff52073d9084bbec40d031b3104/packages/adapt-backend/src/external/github/api.ts#L799).

The review-specific entrypoint does not hard-code a plan/analyze/critic ensemble, a reviewer council, or an external specialist review service. It supplies a short task to the general agent loop; the agent can choose its tools.

## What the harness contributes

| Capability | Evidence and implication |
| --- | --- |
| Model and reasoning routing | The review starts at deep. User/org model recipes resolve that level into an actual client. The source default is `frontier-anthropic`, whose deep route is `fable-5.1-xhigh`; the registered provider ID is `claude-fable-5-1@default`. Other recipes map deep to other models. These are literal source configurations, not proof of what a particular review used. |
| Full working environment | Networked Ubuntu sandbox, git, gh, ripgrep, language runtimes, and integration credentials let the agent inspect callers and run checks rather than see only a patch. |
| Persistent conversation | One chat per repo/PR preserves review discussion across turns. Follow-up replies can recheck prior findings with that context. |
| Knowledge and integrations | Message insertion can retrieve organization and user knowledge; a feature flag replaces org pre-injection with another retrieval path. Tools expose connected sources and skills. Actual available/retrieved context depends on the organization and run. |
| Optional delegation | General-purpose research/task/analysis/verification subagents exist. The PR seed does not mandate their use or count. |
| General response standard | The system prompt calls for evidence, challenging assumptions, completing work, and reviewing the finished answer before delivering it. |
| Output consistency | A deterministic function lowers a passing confidence score to 2 when any finding says blocking=true. This is not a second model reviewing the code. |
| Delivery reliability | Parsing, score gating, inline placement, duplicate suppression, retry handling, and review updates make output usable on GitHub; they do not themselves discover bugs. |

Sources:

- [agent LLM resolution](https://github.com/adaptcom/adapt-v1/blob/6371af7886945ff52073d9084bbec40d031b3104/packages/adapt-backend/src/agent-llm-config.ts), [model recipes and overrides](https://github.com/adaptcom/adapt-v1/blob/6371af7886945ff52073d9084bbec40d031b3104/packages/adapt-backend/src/services/model-recipe-service.ts), [model registry](https://github.com/adaptcom/adapt-v1/blob/6371af7886945ff52073d9084bbec40d031b3104/packages/adapt-backend/src/model-registry.ts).
- [sandbox tool](https://github.com/adaptcom/adapt-v1/blob/6371af7886945ff52073d9084bbec40d031b3104/packages/adapt-agent/src/sandbox/tool.ts), [backend toolset](https://github.com/adaptcom/adapt-v1/blob/6371af7886945ff52073d9084bbec40d031b3104/packages/adapt-backend/src/services/agent/agent-toolset-service.ts), [subagent tool](https://github.com/adaptcom/adapt-v1/blob/6371af7886945ff52073d9084bbec40d031b3104/packages/adapt-agent/src/tool/sub-agent-tool.ts).
- [knowledge injection](https://github.com/adaptcom/adapt-v1/blob/6371af7886945ff52073d9084bbec40d031b3104/packages/adapt-backend/src/services/insert-message.ts#L834), [system prompt assembly and skills](https://github.com/adaptcom/adapt-v1/blob/6371af7886945ff52073d9084bbec40d031b3104/packages/adapt-agent/src/system-prompt-builder.ts).
- [general system prompt](https://github.com/adaptcom/adapt-v1/blob/6371af7886945ff52073d9084bbec40d031b3104/system-prompt.yaml), [score reconciliation](https://github.com/adaptcom/adapt-v1/blob/6371af7886945ff52073d9084bbec40d031b3104/packages/adapt-backend/src/integrations/github/notification.ts#L802).

The sandbox image also installs Claude Code and Codex CLIs ([installer](https://github.com/adaptcom/adapt-v1/blob/6371af7886945ff52073d9084bbec40d031b3104/images/agent/install_coding_agents.sh)). Installation alone does not establish invocation during reviews, credentials for those CLIs, or a multi-model workflow.

## Observed examples and attribution limits

In [PR #3987](https://github.com/adaptcom/adapt-v1/pull/3987), the bot's initial review identified missing/legacy provider fields, numeric-string rule IDs, an extractor-controlled decision boundary, and an obsolete prompt header. It also requested a specific missing regression test. The thread shows follow-up verification against later commits and further malformed-input cases.

That example supports retaining cross-boundary tracing and actionable lower-severity feedback. It does not establish every finding as correct. One proposed follow-up fix was itself strengthened by the author because it still admitted an invalid array shape. Preserve independent verification rather than copying bot suggestions uncritically.

In [PR #3992](https://github.com/adaptcom/adapt-v1/pull/3992), the structured review reported 5/5 and exact-head CI evidence while explicitly saying it had not rerun tests locally. This supports distinguishing verification sources rather than forcing a local full-suite run on every review.

These are observed GitHub outputs, not full execution traces. They cannot tell us which model, knowledge entries, optional skills, subagents, or tool calls caused the results. Later source defaults may differ from those used when earlier reviews ran.

## Portability choices in this skill

Preserved: exact revision, full repository context, every-line coverage, smaller actionable findings, terse results, merge confidence, blocking-score consistency, and PR history during re-review.

Made explicit for reliable local use: merge-base comparison, pagination/truncation handling, evidence checks for candidate findings, exact-revision CI, correct diff anchors, and separating review from publication. These are implementation choices in this skill, not claims of hidden Adapt prompt stages.

Changed: readable chat output by default, with the original JSON shape available on request; existing local GitHub authentication replaces Adapt secret injection. The detailed meanings of scores 0–5 are this skill's calibration; Adapt specifies only the range, merge-safety meaning, passing threshold of 3, and blocking reconciliation to 2.

Not reproduced: organization memories, private integrations, deployed model recipes, dynamic skills, chat history absent from this session, webhooks, check runs, automatic publication, or an unobserved agent ensemble. No new service or model subscription is required.

The likely quality contributors are the combination of a capable reasoning model, complete source/tool access, broad review scope, and useful accumulated context. The relative contribution of each remains a hypothesis. A controlled comparison would hold PR revisions and model/effort constant, vary prompt/context independently, and score verified findings, false positives, misses, time, and cost. This skill has not established equivalent review quality through such a benchmark.
