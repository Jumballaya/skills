# Many-shots 25–36: evidence, scores, and resources

These examples connect coordination decisions to actual review and test quality. Use the role skills for detailed source review and runtime procedure; the coordinator checks identity, coverage, ownership, and whether the conclusion follows from the evidence.

## 25. The API works but the changed UI does not

**Assignment.** #81 changes a Save button and its success state. The reviewer sees a plausible request handler. The tester first calls the backing API successfully and receives HTTP 200, then reports that the feature works without clicking the button.

**Coordinator actions.** Keep that as API evidence, not completed UI verification. Ask the current tester to use the actual form in the branch's browser UI and inspect the resulting state. The tester discovers that clicking Save never submits because the button is outside the form; the console is quiet. A real capture and the absence of the expected network/state transition corroborate the failure.

**Result.** The tester returns the shortest interaction reproduction, and the reviewer verifies the changed markup/caller path. The consolidated finding explains the user-visible failure and correction. The API success remains in verification, but does not cancel the UI blocker.

**Lesson.** An easy lower-layer test is supporting evidence, not a substitute for the changed surface. The same principle catches visual regressions where a removed class is still overridden by `.screen img` or `.lightbox img`; inspect actual computed style and captured appearance.

## 26. Green unit tests, successful HTTP responses, lost data

**Assignment.** #82 promises that a counter survives server restart. The authored tests check incrementing and writing a file; both pass. The tester launches the exact artifact with a fresh state file and independently sends three POST requests.

**Observed sequence.** Each request returns HTTP 200; GET and disk both show value 3. The tester stops the owned server cleanly and restarts the same artifact with the same file. GET now returns value 0, and the next POST writes value 1. The loader reads `count`, while the writer saves `value`.

**Coordinator actions.** Accept the reproduced persistence blocker, retain the HTTP/disk evidence and restart commands, and send it to the reviewer for source reconciliation. Give the failure 2/5 under the localized-blocker calibration; do not respawn workers to search for a passing run.

**Result.** The report says the checks passed but the restart contract failed, with one concrete fix and a restart round-trip requirement. All owned server processes are stopped. This distinguishes readiness, immediate effect, and durable effect rather than treating HTTP 200 as the whole contract.

## 27. Testing an engine feature with a purpose-built game

**Assignment.** #83 adds one-way platforms. Existing demos never jump upward through them. The tester creates a small isolated scene against H83: player, solid ground, one-way ledge, and a drop-through control. The engine implementation remains unchanged.

**Live verification.** Through the real input/driver path, jump from below, observe passage through the underside, release jump, land on top, walk to an edge, and separately exercise drop-through. State snapshots use stable tags and actual serialized collision fields. A real renderer capture is inspected to verify that visual and collision surfaces agree. Bounded frame predicates prevent an endless “wait until landed.”

**Coordinator actions.** Check that the fixture invokes the production component and is tied to H83. Keep fixture changes and any starting-position injection in the manifest. Forward observed invariants to the reviewer so it can inspect system ordering and edge handling without replaying the same run.

**Result.** A 5/5 test result can be justified by these focused outcomes if no actionable issue remains. The claim is about the changed feature and transitions, not every engine mechanic or every frame rate. Save the fixture for retesting the next generation.

## 28. An apparent enemy bug is a harness identity error

**Before.** #84's tester says the player should have stomped an enemy but died. Its assertion selects `enemies[0]`, assuming that is the nearby enemy. The reviewer traces collision handling and asks whether the selected entity is actually the one contacted.

**Coordinator actions.** Keep the finding provisional. Ask the current tester to inspect entity tags/IDs and positions from the live dump and rerun a short checkpoint scenario. It discovers that iteration order changed, so index 0 was a distant enemy. Using a stable tag or verified nearby-entity property, a top contact stomps correctly while a side contact produces the intended death/respawn.

**Result.** Retract the product finding before publication. Record that the first probe failed because of a harness assumption and that the corrected independent checks passed. The death/respawn run remains useful lifecycle evidence; there is no need to repeat a whole level merely to obtain a no-death narrative.

**Lesson.** Reconciliation improves evidence quality without requiring a new PR generation. Internal reviewer/tester questions are not GitHub update events. Do not punish the product for unspecified entity ordering or hide the exploratory failure.

## 29. Eight rule tests pass, but gameplay never launches

**Before.** #85 builds successfully, passes eight authored rules, passes service checks, and generates the site. The interactive engine launch is interrupted before a process or capture directory exists. The tester's last message says “launch queued”; the user then ends the watch.

**Coordinator actions.** Stop admission and inspect whether the launch actually started. Preserve the completed checks, label gameplay not run, and mark unfinished assignments canceled. Do not convert queued work into a live test because the command was prepared or because the unit tests contain gameplay terms. Stop any verified owned processes that did start; the lack of a new process should also be recorded accurately.

**Result.** The final handoff says: “Build, eight rules, service checks, and site generation passed. Interactive gameplay did not run before the stop request.” If a runtime score is needed, absence of meaningful live evidence receives 0/5 with an execution limitation, not a fabricated product defect. Source-review confidence remains separately qualified.

**Lesson.** Built, launched, exercised, and verified are different states. An unrun game cannot receive a high runtime score, and a user's stop instruction does not authorize finishing the tests afterward.

## 30. Fresh workers can reuse evidence honestly

**Timeline.** #86 generation 5/H5 has inspected GL captures and verified gameplay. H6 changes only README wording. Later a rebase produces H7 with the same tree as H6. Both are distinct heads and therefore new generations under this coordinator.

**Coordinator actions.** Replace both workers on each relevant update. Give the fresh pairs H5's evidence manifest with source, asset, dependency, configuration, and fixture identities. For H6, inspect the documentation change and its instructions; reuse the unaffected gameplay only after comparing relevant inputs. For H7, verify tree/base implications rather than trusting the word “rebase.” If a dependency or build setting changed outside the claimed source tree, reconsider affected results.

**Result.** A report may say, “Documentation checked at H7; gameplay evidence reused from H5 because the engine, game assets, dependencies, configuration, and fixture inputs are unchanged.” It must not say “gameplay rerun at H7.” Scope and base still receive a current source review.

**Lesson.** Fresh worker context does not require wasteful duplicate execution. The evidence lineage persists, but its applicability is a new judgment. This is how the coordinator remains current without rebuilding identical games on every documentation correction.

## 31. The reviewer says 5/5 and the tester finds a blocker

**Before.** #87's source reviewer returns provisional merge confidence 5/5. The tester reproduces a crash after the new reconnect operation and returns test confidence 2/5 with logs. Both results are current generation 4.

**Coordinator actions.** Do not average the scores. Send the reproduction, affected state transition, and artifact identity to the current reviewer. It traces the lifetime error and updates its finding/merge verdict to 2/5. If it initially suspects a stale binary, the tester verifies executable/source identity before the conclusion is finalized.

**Result.** Publish “Merge confidence: 2/5 · Test confidence: 2/5” with the concrete blocker and the successful checks that remain useful. Explain that a fix plus the same reconnect/crash reproduction and relevant integration checks are needed for reconsideration. An author assertion that “CI is green” is new discussion to inspect, not evidence that erases the observed crash.

**Lesson.** A coordinator checks consistency, not merely whether two messages arrived. A material current disagreement means the final verdict is not ready; label an early blocker report partial if prompt feedback will help a fixing agent.

## 32. A demo is acceptable at 4/5

**Before.** #88's real game runs through travel, cable attachment/release, death, and restart. The reviewer identifies a generated-map metadata issue: checkpoint ID 13 exists while the next object ID is 12. Play works, but adding another editor object can collide. Both scores are 4/5, with the finding non-blocking for this demo.

**Coordinator actions.** Post the actionable caveat and exact route to 5/5: fix the generator's next-ID calculation, regenerate, and verify that editor insertion receives a unique ID. The user says, “I'm fine with the demo getting 4/5.” Record that acceptance for this PR and leave it idle; do not lower the finding's accuracy or round the score up.

**Result.** No extra rounds chase polish. A later head update still gets a fresh pair, and a genuinely new blocker is not covered by the earlier acceptance. On merge, retire both roles.

**Lesson.** The score reports evidence and remaining issues. It is neither a target the coordinator must force every PR to reach nor permission to conceal accepted limitations. Per-PR acceptance should not silently relax quality for the entire repository.

## 33. Tester crashes, then its obsolete attempt returns

**Before.** #89 generation 6 has a healthy reviewer and tester attempt 1. The tester's tool session fails before launch, with no product failure established. After diagnosing the transient tool failure, the coordinator assigns tester attempt 2 in the same generation. Attempt 1 later sends a completion message.

**Coordinator actions.** Keep the healthy reviewer; this is worker recovery, not a PR update. Revoke attempt 1, verify its resources, and give attempt 2 the same exact snapshot plus partial evidence labeled appropriately. Reject attempt 1's late result because its attempt/worker lease is obsolete, even though generation and SHA match.

**Result.** Only attempt 2 can supply the current tester result. If the same infrastructure error persists through the configured replacement budget, mark testing blocked, preserve the source review, and stop respawning until a relevant condition changes. Unchanged polls do not reset the budget.

**Lesson.** New input replaces both roles; a failed worker replaces that role. A reproduced product failure is a valid completed test result and consumes no infrastructure retry budget. These distinctions prevent both unnecessary source reviews and endless “retry until green” loops.

## 34. Two testers discover a singleton engine MCP

**Before.** Capacity permits pairs for #90 and #91. Both testers have separate worktrees and binaries, but the available MCP control endpoint attaches to one globally active engine session. Tester #91's scene switch would change what #90 is playing.

**Coordinator actions.** Register the MCP session as an exclusive runtime resource. Give #90 the control lease first; #91 can finish independent build/fixture preparation while awaiting it. Alternatively, use independently controlled engine processes/drivers if they truly isolate state, ports, save paths, and input. Do not assume different worktree paths isolate a singleton tool.

**Result.** Only the resource owner sends scene/input/capture commands. After #90 releases input and the session, #91 acquires it and verifies the correct executable/scene before testing. Reviewers can continue source work in parallel. Evidence records which session each capture came from.

**Lesson.** Agent slots and runtime resources are different constraints. Adding more agents cannot increase a singleton's capacity. Concurrent scene changes can produce convincing screenshots and state dumps from the wrong PR unless ownership extends all the way to the control surface.

## 35. Canceled worker's PID now belongs to another process

**Before.** A superseded tester recorded PID 31001 for its local server. The coordinator resumes after a delay. PID 31001 now has a different start time, working directory, and command, belonging to the user's unrelated application. The old worktree still contains useful logs.

**Coordinator actions.** Do not signal PID 31001. Record that the numeric PID was reused and that the old process identity is no longer present. Check whether any other verified owned children/session resources remain. Preserve the logs and release only resources whose ownership/cleanup can be established. If a port remains occupied by an unrelated process, allocate a different port for the next generation.

**Result.** The unrelated app keeps running. The stale worker lease stays revoked, and new work uses isolated resources. Cleanup is recorded precisely rather than claiming that a successful broad kill proved everything stopped.

**Lesson.** Cancellation authority covers owned work, not whatever later occupies its PID or port. Start identity and resource manifests turn shutdown into a targeted action. When identity is uncertain, quarantine or choose a fresh resource instead of guessing.

## 36. The runtime cannot reclaim idle agent handles

**Environment.** Four total slots are available. The coordinator has completed a reviewer/tester pair, but this runtime counts their idle handles against the live-handle quota. The only agent operation is interrupt; it leaves handles allocated. Another PR is queued, and only one slot is free.

**Coordinator actions.** Verify the actual quota semantics rather than assuming “idle” means released. Do not repeatedly spawn a lone worker, invent a `delete_agent` call, or claim a fresh two-agent pair exists. If completed workers can be explicitly reassigned with a reset under this runtime, disclose that they are reused physical handles, issue new identities/contracts, and reject earlier outputs; do not claim fresh independent context. Otherwise keep the new pair queued and explain the runtime limitation.

**Result.** The user gets an accurate capacity status and the saved handoffs. Polling can continue while an active coordinator exists, but ending the turn/session does not create an unattended watcher. If the platform provides no way to sustain the requested operation, state what stopped and how to resume.

**Lesson.** A skill specifies behavior; it cannot manufacture lifecycle APIs, slots, or background persistence. Honest constrained operation is better than simulated autoscaling that leaves stale agents or nonexistent monitoring behind.
