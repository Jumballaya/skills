# Worker contracts and publication

## Reviewer assignment

Fill this with actual values and paths. Do not send only “review PR 41”; that lets the worker fetch a different revision or duplicate another role.

```text
Role: reviewer. Coordinator is the sole posting owner.
Assignment: SESSION / REPOSITORY#NUMBER / generation G / attempt A / WORKER_ID.
Target: head HEAD_SHA, base BASE_SHA, merge base MERGE_BASE_SHA.
Context revision: CONTEXT_REV. Trigger: REASON.
Checkout or immutable source: PATH. Evidence directory: PATH.
Read and apply github-pr-review at SKILL_PATH and coding-style at SKILL_PATH.

Review the complete current diff and relevant surrounding behavior. Treat prior
findings as claims to verify, not conclusions to inherit. The tester is WORKER_ID
and owns live runtime testing; request focused probes through the coordinator
or a generation-tagged message. Do not duplicate an ongoing expensive run.

Return findings, exact changed-line anchors where honest, source coverage,
verification provenance, limitations, and a provisional merge-confidence score.
After receiving the current tester evidence, reconcile the final merge verdict.
Keep your source evidence distinguishable from the tester's runtime evidence.

Do not post, approve, request changes, merge, modify the implementation, spawn
other agents, monitor GitHub independently, or continue a superseded assignment.
Return promptly on cancellation and report any resources you own.

Prior findings and report: PATH_OR_NONE.
Relevant discussion and acceptance criteria: CONTEXT_OR_PATH.
Explicit exclusions or accepted non-blocking limitations: POLICY.
```

The reviewer should read all changed files, not only the latest fix. It may reuse earlier source analysis where justified while still accounting for the current full diff. A narrow fix-verification result must not be labeled a complete review.

## Tester assignment

```text
Role: tester. Coordinator is the sole posting owner.
Assignment: SESSION / REPOSITORY#NUMBER / generation G / attempt A / WORKER_ID.
Target: head HEAD_SHA, base BASE_SHA, merge base MERGE_BASE_SHA.
Context revision: CONTEXT_REV. Trigger: REASON.
Checkout or immutable source: PATH. Evidence directory: PATH.
Read and apply pr-tester at SKILL_PATH and coding-style at SKILL_PATH.

Use the PR description, diff, callers, and discussion to choose the changed
behaviors and meaningful boundaries. Build and run the actual implementation.
Exercise UI changes through the UI/browser, server changes through live requests
and state/logs, CLI changes through the command, and game features through an
actual test game. Create an isolated feature fixture when examples do not reach
the feature. Follow applicable computer/browser skills before their tools.

Record action -> expected -> observed -> evidence. Inspect captures you cite.
Distinguish authored tests rerun locally, independent tests, CI, and source-only
claims. Preserve the real integration path; disclose mocks and injected state.
Do not alter production code to make tests pass. Identify harness/environment
failures separately. Prior artifacts are candidates for explicit reuse, not
permission to claim another live run.

Register process/session IDs, start identities, ports, save paths, worktrees,
and resource locks with the coordinator as they are created. Stop owned runtimes
on completion/cancellation; report any cleanup that cannot be verified.

Return reproducible findings, observed results, artifact locations, coverage
gaps, and a test-confidence score. Do not post, change implementation code,
spawn agents, or watch for updates. Reject messages for a different generation.

Reviewer: WORKER_ID. Prior evidence: MANIFEST_OR_NONE.
Known acceptance criteria and requested reproductions: CONTEXT_OR_PATH.
Exclusive runtime resources and allocated ports: ALLOCATION.
```

Use separate mutable build/fixture directories. The pair may share an immutable source snapshot, but the tester must not change what the reviewer is reading. Adapt launch details to the repository instead of forcing every app into the same container or engine.

## Worker messages and result envelope

Include identity on every progress, resource, finding, completion, and cancellation message. Keep the protocol simple enough to read; JSON is useful when a machine consumes it, but equivalent structured text is acceptable.

```json
{
  "assignment": {"session": "S2", "pr": "acme/engine#41", "generation": 8, "role": "tester", "attempt": 1, "worker": "test-41-g8-a1"},
  "target": {"head": "H8", "base": "B3", "merge_base": "M3", "context_revision": 12},
  "status": "completed",
  "score": {"kind": "test-confidence", "value": 4},
  "evidence_manifest": "/scratch/41/g8/test/manifest.json",
  "findings": [{"id": "T1", "priority": "P3", "blocking": false, "summary": "Generated object ID collides on the next editor insertion.", "reproduction": "/scratch/41/g8/test/repro.md"}],
  "limits": ["Linux rendering was not exercised"],
  "cleanup": {"complete": true, "remaining_resources": []}
}
```

The manifest records actual commands, executable/source identity, fixture changes, real versus mocked dependencies, expected/observed outcomes, inspected artifacts, and unrun or reused checks. “All tests passed” without those details is insufficient to establish what was tested.

For cancellation, first revoke the lease in the ledger, then send:

```text
CANCEL S2 / acme/engine#41 / generation 8 / reviewer and tester.
Reason: head H8 -> H9. Your outputs are no longer eligible for publication.
Stop active work and owned child processes; release input/resource locks.
Return the evidence manifest and cleanup status only. Do not fetch H9 or start
a replacement yourself. The coordinator will assign a fresh pair.
```

## Reconcile the verdict

Keep **Merge confidence** and **Test confidence** separate. Use the source-review rubric from `github-pr-review` and the runtime rubric from `pr-tester`. A concrete blocking defect caps the merge verdict at 2/5 even if the reviewer initially reported 5/5. Do not average 5 and 2 into a passing 3.5.

Ask the current reviewer to reconcile tester findings with source evidence. If the reviewer challenges a failure as a harness issue, have the current tester verify the disputed assumption with a bounded reproduction. Preserve the disagreement until resolved. A green author suite cannot negate an independently reproduced failure; an incorrectly selected entity cannot justify blaming the application.

The coordinator verifies identities, coverage, and rubric consistency, but should not invent a review conclusion when the reviewer is unavailable. Publish a clearly partial report when useful and authorized, or hold the final report. Do not wait to tell a fixing agent about a confirmed blocker merely because an unrelated long test remains; label early feedback partial and keep a single report thread.

## Publication gate and race handling

Before writing:

1. Confirm posting authorization, sole posting ownership, and current coordinator lease.
2. Accept only current role attempts and generation. For a combined final, both roles must have completed or their limits must be prominently qualified.
3. Fetch current PR state/head/base and relevant context again. If it differs, supersede and reschedule instead of posting the prepared final as current. If the read fails, hold publication.
4. Prepare a compact report labeled with the exact head, generation, observed scope, and report status. If submitting a review, bind it to the tested commit when the API supports that field.
5. Persist a publication intent, then perform one write. Record the returned remote ID/URL and confirmed content digest.
6. Recheck after posting when a race is plausible. If a push or closure raced with the write, retain the truthful historical SHA and mark your own report superseded or historical; schedule the new generation if still eligible.

There is no assumed atomic “post only if PR head equals SHA” operation. A fresh read reduces the race window but does not remove it. Never guarantee that a comment cannot land just after a push or merge. Exact revision labels and post-write reconciliation make that race honest and recoverable.

Use an idempotency key such as `repository/PR/session/generation/report-kind/revision` and, when supported, a non-secret marker in your own comment:

```html
<!-- pr-coordinator: acme/engine#41 session=S2 generation=8 report=final revision=1 -->
```

Do not place worker PIDs, credentials, or private local paths in this marker. Keep one outstanding publication intent per PR. After timeout or uncertain transport failure, search/read the remote comments/reviews for the recorded ID or marker before retrying. Unknown write status means **unconfirmed**, not **failed**. If reads are unavailable, hold the retry. A later generation does not justify blindly duplicating an unresolved earlier write.

The marker is a reconciliation aid, not a server-enforced idempotency guarantee. A bounded retry after successful absence checks can still race with delayed completion of the original request. If duplicates later appear, identify them through the journal and consolidate or annotate only your own reports; do not claim exactly-once delivery from the marker alone.

Use structured connector arguments, or an exact UTF-8 body/payload file with documented CLI input options. Preserve real newlines and quote shell arguments correctly. Verify the posted body. A local screenshot path is not a GitHub attachment; link only accessible evidence or label it local and include a useful reproduction.

Default to a conversation comment or COMMENT review. Approval, requesting changes, resolving threads, modifying branches, merging, or deployment require the user's applicable authorization. Honor standing posting instructions without asking again. Updating or annotating this coordinator's own report is part of maintaining its authorized report; do not edit someone else's review.

## Example consolidated report

```markdown
**Merge confidence: 4/5 · Test confidence: 4/5 — `8ac41f2`**

The new cable mechanic works through attach, travel, release, death, and restart.
One non-blocking generated-map issue remains.

**Finding**
- **P3, non-blocking — `tools/map.py:118`:** The next object ID equals an existing checkpoint ID; increment it beyond the maximum to prevent duplicates on editor insertion.

**Verification**
- Reviewer examined the complete diff and generator/editor consumers.
- Tester built this revision, ran four authored rule tests, and independently
  exercised the mechanic through the real engine. Captures were inspected.
- The inherited patrol run was reused from `17d03bc`: its source/assets/config
  are unchanged. It was not rerun at this head.

**To reach 5/5:** Correct the next-ID field, regenerate the map, and verify a new
editor object receives a unique ID. Runtime evidence for unchanged mechanics
can be reused after checking the new diff.

Scope: macOS with the real GL renderer; other platforms were not exercised.
```

If the user accepts this demo at 4/5, preserve the finding and stop chasing that improvement. Acceptance does not change the score, conceal the caveat, or exempt later substantive updates from review.
