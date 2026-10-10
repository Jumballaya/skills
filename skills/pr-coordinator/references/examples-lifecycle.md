# Many-shots 01–12: lifecycle and scheduling

These are worked coordination traces for fictional repositories. Symbolic SHAs simplify the examples; use full verified SHAs in real assignments. The examples demonstrate choices, not a fixed test checklist.

## 01. Cold start with capacity for three PR pairs

**Request and observations.** “Watch acme/engine, review and test every open PR, and post results.” A complete inventory finds #41 at H41, #42 at H42, and #43 at H43. There are seven total agent slots, including the coordinator, with no unrelated workers. None has been assessed.

**Coordinator actions.** Persist three generation-1 records and their base/context identities. Six free slots support three pairs. Reserve two slots per PR, then spawn a reviewer and tester for each using the full contracts. Allocate independent fixture/build directories and runtime ports. Record each actual worker handle; a reservation is not proof of a successful spawn.

**Result.** All three records are running, with exactly one role owner each. The coordinator continues polling while workers operate. The first user update is concise: “Assigned reviewer/tester pairs to #41, #42, and #43. I’ll post consolidated results against their recorded revisions.”

**What this avoids.** Six agents each doing an entire review/test task, duplicate postings, or a coordinator that waits for #41 to finish before noticing updates to #42. Parallelize PRs, but keep roles and publication ownership explicit.

## 02. A new PR appears while the existing pair is busy

**Before.** Four total slots permit the coordinator plus one pair; one spare slot cannot host another complete pair. #41 is running. The next complete repository inventory discovers #44. Polling only the old watch list would never find it.

**Coordinator actions.** Record #44 generation 1 and its first queued time. Do not spawn a lone reviewer into the spare slot. Keep #41's valid work running and tell the user #44 is queued for a reviewer/tester pair. Once #41 finishes, persist its handoffs, close/complete its workers as supported, verify capacity, refresh #44's remote snapshot, and assign its pair.

**Result.** #41 becomes idle, #44 becomes running, and discovery continues for both updates and new PRs. A change to #44 while queued updates its desired snapshot without creating an unnecessary abandoned pair.

**What this avoids.** Claiming unlimited autoscaling, silently omitting new PRs, or forcing the coordinator to act as the missing tester. Queueing is a visible capacity state, not a failure to discover the PR.

## 03. A push arrives while the tester is inside a game

**Before.** #45 generation 6 targets H6. The reviewer has a provisional 5/5; the tester is holding Right in a live engine process and has completed only two of five scenarios. A poll observes H7.

**Coordinator actions.** Persist desired generation 7 and revoke both generation-6 leases before sending cancellation. Interrupt both workers. The tester releases input, shuts down its verified engine session, and records the two completed scenarios plus three unrun ones. If it cannot respond, the coordinator uses the resource manifest to inspect and stop that owned process. Wait for cleanup/debounce, then give a fresh pair H7 and the historical manifest.

**Result.** No H6 final verdict is published. H7's pair decides whether either completed scenario remains reusable after examining the changed inputs. A useful update is: “#45 changed during gameplay testing; the previous pair is stopped and the new revision is queued.”

**What this avoids.** Merely messaging the tester to “pick up H7” while its executable still runs H6, or treating the reviewer's old 5/5 as current because it finished first.

## 04. Three rapid pushes collapse into one fresh pair

**Timeline.** #46 generation 3 is running H3. At 12:00:00 GitHub shows H4; at 12:00:08 it shows H5; at 12:00:16 it shows H6. Cleanup of the old server completes at 12:00:18. The quiet window is 20 seconds.

**Coordinator actions.** H4 immediately revokes generation 3. Record subsequent desired generations/snapshots without starting H4 or H5 workers. Each relevant snapshot moves the quiet deadline; the latest one makes it 12:00:36. Continue polling and receiving messages. At admission, refresh head/base/context and launch a pair for H6 if it is still current and capacity exists.

**Result.** Only one replacement pair starts. The ledger retains the superseded observations and a single actionable desired target. If pushes continue beyond the 90-second deferral cap, consider admission of the latest snapshot and explain the churn; any subsequent observed push still invalidates that run.

**What this avoids.** Launching six workers that will immediately be canceled, or using the debounce cap as permission to publish a known stale result. Debounce saves work; it never relaxes freshness.

## 05. Completed workers return late after invalidation

**Before.** #47 moved from generation 9/H9 to generation 10/H10. Both new workers are running. A queued completion message from the old reviewer arrives: “5/5, no findings.” A second message from the old tester says its cleanup finished.

**Coordinator actions.** Compare each message's session, generation, role, attempt, and worker ID with the current leases. Reject the old review as a current result and preserve it only as historical evidence. Accept the cleanup observation for the old resource record without accepting the old verdict. Do not overwrite generation 10's reviewer field or treat cleanup as a test pass.

**Result.** Generation 10 remains running, and the old process reservation can be released when verified. No extra GitHub comment is necessary merely to announce that an obsolete message was ignored.

**What this avoids.** A last-message-wins ledger that lets an excellent but stale review replace a current one. Cancellation cannot prevent every queued message; identity checks must remain effective after cancellation.

## 06. Idle means no repeated reviews and no live test server

**Before.** #48 has matching generation-2 results, both 5/5, and a confirmed report URL. No relevant input changes appear in the next ten polls. A second PR is waiting for capacity.

**Coordinator actions.** Save #48's source coverage and runtime manifests, verify owned processes stopped, and release its workers through supported completion/closure behavior. Keep #48 in the ledger as idle and continue observing it. Admit the queued PR. Consume events caused by #48's own posted report without creating a new generation.

**Result.** “#48 is complete at H2; its workers are idle/released. #49 is now being reviewed and tested.” If an author later adds a concrete reproduction, #48 receives a fresh pair with access to its saved history.

**What this avoids.** Keeping a game and two active agents resident merely to simulate waiting, or reviewing the unchanged PR every 30 seconds. The saved assignment/evidence is what persists; expensive execution does not have to.

## 07. Merge while the test build is still running

**Before.** #50's reviewer is finished, its tester is building, and its final report has not been posted. A direct PR read confirms `merged=true` and closed state. Another open PR is queued.

**Coordinator actions.** Revoke both roles, cancel the owned build, verify child process cleanup, and mark #50 retired with the merge observation. Keep existing build logs labeled incomplete. Do not admit another generation merely because the merged branch still has commits or the build eventually emits success.

**Result.** The queued PR can use released capacity. Report to the user: “#50 merged during verification; I stopped its workers. Runtime testing had not started.” Do not post an unqualified approval after merge or silently claim the interrupted test was completed.

**What this avoids.** Spending time finishing a retired PR against the user's lifecycle policy. If the user separately requests a post-merge audit, that is a new explicit assignment, with its own target and purpose.

## 08. Closed PR reopens with the same head

**Before.** #51 was retired at generation 4/H4 after closure. It is now open again with the same H4 but a changed base and a new explanation of the acceptance criteria. The watch is still active.

**Coordinator actions.** Confirm eligibility and refresh the whole snapshot. Advance to generation 5 rather than resurrecting generation 4's leases or resetting to generation 1. Queue a fresh pair with the previous report labeled historical. Recompute the merge base, diff scope, and interpretation of the changed requirements.

**Result.** The tester may reuse unchanged runtime evidence after verifying its inputs; the reviewer still evaluates the current base and contract. The new report states what was rerun and what was reused. Reopening alone does not make the previous verdict current.

**What this avoids.** Permanently ignoring every number ever marked retired, or trusting a same-head comparison while the target branch and meaning of the change have moved. Retirement ends an assignment, not the ability to recognize a future reopening.

## 09. A constantly updated PR must not starve the queue

**Before.** One pair fits. #52 has been reviewed twice and receives another push; #53 has waited eight minutes and #54 has waited four. The user has not assigned priority.

**Coordinator actions.** Revoke #52's superseded run and preserve its pending snapshot. Once cleanup finishes, admit #53, the older waiting PR, rather than giving #52 its third consecutive turn. Keep observing #52 and coalesce its updates. After #53 completes, consider remaining queue age and fairness, including #52's retained age, instead of sorting only by PR number or most recent activity.

**Result.** The queue makes progress across PRs. Explain the decision if useful: “#52 is queued at its latest head; #53 is using the next available pair after waiting.” An explicit user request to prioritize #52 changes policy, but should not erase the visibility of waiting work.

**What this avoids.** Treating “always newest” as “always serve the noisiest PR.” Freshness selects which revision to test; fairness selects which PR gets scarce capacity.

## 10. Capacity drops and the second spawn fails

**Before.** The coordinator reserved a pair for #55. Reviewer creation succeeds, but tester creation fails because an unrelated agent claimed the last slot. The reviewer has only begun reading metadata.

**Coordinator actions.** Re-read capacity. If the second slot is not actually available, cancel the lone reviewer, save any useful bounded progress, clear the pair reservation, and return #55 to the queue. Do not spawn another reviewer or ask the existing one to silently become a combined tester. If a slot is demonstrably about to be released, a short bounded reservation is acceptable; an indefinite half-pair is not.

**Result.** The ledger records a scheduling failure, not a product finding or a completed review. #55 retains its target and queue age. Report the capacity constraint once, then continue useful polling or other already-admitted work.

**What this avoids.** Leaking one worker per failed pair and exhausting all future capacity. Assignment is complete only when both actual handles are known; optimistic slot arithmetic cannot replace observing the tool result.

## 11. Drafts and explicit exclusions

**Request.** “Watch all open PRs, but ignore #22 and #23; they are disposable demos.” The inventory contains draft #56 and regular #57 alongside the excluded numbers.

**Coordinator actions.** Persist the two exclusions and apply them on every full discovery cycle. Admit #56 and #57 under the default all-open scope; draft status alone is not a hidden exclusion. If #22 is later retitled or reopened, its number remains excluded until the user changes the rule. If the user instead says “ready PRs only,” cancel any now-ineligible draft pair and retain the reason.

**Result.** The scope summary says exactly which PRs are eligible and which are excluded. New #58 is discovered normally; the presence of exclusions does not turn discovery into a fixed list.

**What this avoids.** Reintroducing ignored demos after every scan, quietly skipping drafts despite “all,” or copying old repository-specific exclusions into an unrelated repository. Scope belongs to this watch's explicit policy.

## 12. Empty inventory versus the user saying “all done”

**Timeline.** The user asked for an ongoing repository watch that includes new PRs. At 15:00 every known PR has merged, and a complete scan finds no open PRs. At 15:10 a new PR opens. At 15:20 the user says, “All done, all merged.”

**Coordinator actions.** At 15:00 retire the finished pairs but keep discovery active; absence of current work does not cancel a repository watch. At 15:10 discover and assign the new PR if eligible. At 15:20 stop admission, revoke any remaining workers, clean owned processes, persist the ledger, and end the watch. Do not resume because a later conversation asks how the skill worked.

**Result.** The final response names completed reports and anything interrupted, then states that monitoring stopped. For an explicitly fixed batch, draining that batch would have been a valid automatic stopping condition instead.

**What this avoids.** Missing future PRs by ending at the first empty scan, or ignoring a human stop instruction in the name of persistence. The stopping policy comes from the task, not a single API count.
