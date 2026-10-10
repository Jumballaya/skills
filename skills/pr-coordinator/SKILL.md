---
name: pr-coordinator
description: Coordinate an ongoing, polling-based PR review and runtime-testing team. Discover open PRs, assign a reviewer and tester per PR within available capacity, replace both on relevant updates, consolidate current-revision results, and retire workers when PRs close. Use when asked to supervise or continuously monitor multiple PRs; creating or discussing this skill does not start monitoring.
---

# PR Coordinator

Act as the supervisor of a changing PR queue. Each eligible PR receives a dedicated reviewer and a dedicated tester. Poll for changes, keep assignments tied to the latest observed revision and context, publish coherent results when authorized, and preserve evidence between runs. The coordinator owns scheduling and posting; workers perform the review and live testing.

## Start deliberately

Resolve the repository, inclusion/exclusion rules, standing posting authorization, and stopping condition from the user and current context. Default to all open PRs, including drafts and new arrivals, unless instructed otherwise. A repository watch continues discovering after its queue becomes empty; a fixed-batch assignment can finish when that batch is retired. “Stop,” “all done,” or “all merged” from the user ends the current watch unless they explicitly say to keep watching. Creating this skill is not an instruction to start it.

Inspect actual tools, agent limits, active agents, repository guidance, and installed skills. Read [protocol.md](references/protocol.md) before starting the loop and [worker-contracts.md](references/worker-contracts.md) before assigning work or publishing. Use `github-pr-review` and `coding-style` for the reviewer, and `pr-tester` plus `coding-style` for the tester. Discover their real locations. If an essential skill is unavailable, report that gap rather than claiming its workflow was followed.

Running this coordinator authorizes the role delegation described here within the user's task. Inherit configured model settings. Do not invent a model switch, agent termination API, persistent daemon, or webhook capability. Poll for now; do not configure a tunnel or webhook.

## Preserve these invariants

1. **One coordinator owns the queue and publications.** Workers return evidence; they do not independently post, merge, approve, change application code, or expand the watch scope.
2. **Every assignment has an identity.** Record repository, PR, head, base, merge base, context revision, generation, role, attempt, and worker ID. Generations increase monotonically and survive coordinator recovery.
3. **Updates revoke both assignments.** A relevant observed change invalidates the previous generation before cancellation begins. Replace both workers after cleanup and a short debounce, even if only one had finished. Fresh workers may assess reusable evidence; they cannot relabel it as a new run.
4. **Only current results are eligible.** Accept a result only from the current worker attempt for its role and generation. Recheck remote state immediately before publishing. A final report cannot silently combine generations.
5. **Runtime evidence is real.** The tester builds and runs the exact code, uses the relevant UI/API/CLI/game surface, creates a feature fixture where needed, and distinguishes passed, failed, unrun, inconclusive, and reused checks.
6. **Capacity and resources have owners.** No duplicate role assignment, unbounded spawning, shared mutable checkout, or competing control of a singleton engine/browser session.

## Operate the loop

Keep a durable ledger outside the product working tree. Save desired PR state, current assignments, reusable evidence, resource ownership, queue age, retries, and publication intents. Acquire single-writer ownership before dispatching or posting. Do not store credentials in this ledger.

On each cycle:

1. **Observe:** Fetch a complete, paginated open-PR inventory and relevant metadata, discussion, reviews, and checks. Preserve the last good state on API failure. Confirm closure directly instead of treating absence from a partial list as closure.
2. **Reconcile:** Classify changes using the protocol. New head/base snapshots, changed requirements, substantive feedback, and relevant completed checks can require a new generation. A timestamp bump, your own unchanged report, reaction, or cosmetic edit does not by itself justify restarting workers.
3. **Revoke and clean:** Invalidate superseded assignments, interrupt both workers, stop their verified owned processes, and quarantine resources until cleanup is confirmed. Collapse bursts into the newest desired snapshot.
4. **Schedule:** Reserve a reviewer/tester pair for each runnable PR within available capacity. Use explicit user priority and queue age; do not let one rapidly changing PR starve new work. Revalidate the target before launch.
5. **Collect:** Validate worker identities and evidence. Resolve disagreements through the current reviewer and tester. A worker infrastructure failure can retry that role with a new attempt; a PR update replaces both roles with a new generation.
6. **Publish or hold:** Reconcile separate merge and test scores, run the freshness and authorization checks, and publish once through the coordinator. Keep an idempotent publication journal. Partial findings must be labeled partial.
7. **Idle or retire:** Completed pairs become logically idle with saved handoffs and no active test processes. Release physical worker capacity where supported. Closed/merged PRs retire both workers. Continue bounded polling until the user's stopping condition.

A practical starting cadence is a 30-second poll with a 20-second quiet window for updates, configurable for the repository. Bound debounce at 90 seconds to avoid indefinite deferral; a launched run is still revoked if newer input arrives. Respect API rate limits and retry guidance. Break waits into interruptible intervals consistent with the environment's communication requirements.

## Scale without pretending

Each running PR needs two worker slots in addition to the coordinator and unrelated agents. Compute capacity from the actual runtime, not an imagined unlimited pool. With four total slots and one coordinator, only one complete pair fits. Queue excess PRs visibly. Do not silently replace the requested two-worker arrangement with one combined reviewer/tester.

“Idle” describes the PR's state, not a requirement to retain two expensive resident agents. Save handoffs and let workers finish or close them when supported. Interrupting an agent may not destroy it or release its slot; verify the actual semantics. If the runtime cannot reclaim enough capacity, report the limitation instead of spawning repeatedly. See the capacity and recovery examples below.

## Learn from the many-shot playbook

The examples are concrete decision traces, not mandatory extra checks for every PR. Read the relevant cluster before handling an unfamiliar case. Fictional IDs and SHAs are illustrative, not API values.

| Examples | Read for |
| --- | --- |
| [01–12: lifecycle and scheduling](references/examples-lifecycle.md) | Discovery, pair assignment, cancellation, debounce, fairness, idle, close, reopen, drafts, stop |
| [13–24: polling and publication races](references/examples-events.md) | Feedback classification, pagination, rate limits, base changes, recovery, duplicate posts, late pushes |
| [25–36: evidence and resource failures](references/examples-evidence.md) | UI/API/game testing, evidence reuse, scores, harness errors, worker retries, cleanup, constrained tools |

## Communicate and stop accurately

Give concise updates on newly assigned PRs, important findings, cancellations, completed reports, and actual limits. State the last successful observation when GitHub is unavailable. Do not fill PRs with polling heartbeats or claim to be watching after the active loop ends.

On user stop: stop admission first, revoke active assignments, clean owned processes, save the ledger and pending publication state, then report what completed and what was interrupted. Retain useful reproduction artifacts. Do not remove user changes, another agent's worktree, or unrelated servers. If the environment ends the session, make resumable state explicit; do not imply an unsupervised background service exists.
