# Runtime playbooks

Read the sections relevant to the changed behavior. Select the smallest setup that reaches the real implementation and lets you observe the promised outcome.

## UI and browser

Launch the branch's application and reach the affected page or screen. Use the browser or native UI to perform the changed interaction. Calling the backing API alone cannot verify that a button, form, shortcut, or visual treatment works. APIs or MCP state inspection can prepare a fixture and confirm effects after the interaction.

Check the transitions implicated by the change: submitting, navigating back, reopening, reloading, resizing, or showing an error. Choose these from the feature rather than running an unrelated UI checklist. For persistence claims, observe a fresh read after the appropriate reload or restart.

For visual findings, inspect the actual capture and, when useful, computed styles and layout. A removed class does not establish that its styling disappeared: a more specific or broader selector may still apply. One real review found painted artwork still pixelated because `.screen img` and `.lightbox img` retained `image-rendering: pixelated` after the dedicated class was removed.

Record the viewport and relevant interaction state with captures. Report missing assets, visual corruption, or console errors only when they are connected to the affected behavior. Screenshots prove appearance at that moment; pair them with interaction/state evidence for functional claims.

## Servers and APIs

Start an isolated instance using the branch's documented command and actual built artifact. Use a temporary database, namespace, save directory, or seeded test account where needed. Capture startup output and establish readiness before testing requests.

For each meaningful request, verify the response status and body plus the consequence the contract promises: a stored record, an emitted event, a second client's state, or data after restart. A success response and empty error log do not prove the effect occurred. Inspect relevant logs when requests fail or asynchronous work needs corroboration.

Exercise the changed contract's important boundary: malformed input, duplicate submission, disconnect/reconnect, ordering, authorization, or restart, as relevant. Avoid a universal server checklist. If an external dependency is mocked, disclose which behavior remains unverified. Use local fixtures for messages, payments, and production data unless the user has authorized the real external action.

## Command-line tools and developer tooling

Execute the built command from the intended revision with a representative fixture. Check exit status, meaningful stdout/stderr, output files, and the next consumer where applicable. A compiler or generator that emits a file is not proven correct until the relevant output semantics are checked.

For source-analysis tools, distinguish executable syntax from inert strings, comments, and templates. A previous diagnostic test needed to catch a missing action inside an executable template expression while leaving quoted help text alone. Test the actual syntax boundary changed by the PR, not only the easiest literal case.

## Games and engines

For a new engine feature, build a small game or scene against the branch that reaches the production API and systems. Use a supplied demo when it already provides the right integration. Pure rule tests complement this; they cannot establish rendering, collision integration, input dispatch, persistence, or gameplay.

Choose explicit invariants. Examples from real runs:

- Jump through a one-way platform, land on top, then drop through it.
- Remain grounded while crossing a slope; verify a moving lift carries the player once.
- Attach to a cable, move along it, release, and resume gravity.
- Distinguish an enemy stomp from a side hit; observe death and respawn.
- Collect an item, see the HUD change, exhaust lives, and restart with the intended state.

Use real input for the feature and inspect live state through MCP, the engine's driver, debug output, or an API. State injection can create a checkpoint or fixture; disclose it and do not inject the outcome being claimed. Use seeds, controlled frame steps, and bounded predicates when available. Release held keys between scenarios. Select entities by stable ID, tag, or a verified property; array order is not an identity contract.

Discover the runtime's actual serialized schema. Script getters need not exist in state dumps. For example, a grounded condition might be serialized as a collision direction rather than `onGround`. Also check whether events or callbacks update on the current frame or the following phase before declaring a stale-state bug. A failed harness assumption is not a product defect.

Use the real renderer for visual claims and inspect captured frames. A null renderer can validate simulation but not appearance. A hidden window using a real GPU renderer may support genuine captures; establish which mode is running rather than relying on the word “headless.” Verify game assets actually loaded, including fonts and textures.

### Optional example: a frame-stepped game driver

An engine may expose commands resembling this Journeyman session. Read the checked-out driver's documentation first; these commands are not a portable API:

```text
step 30
state session tag=Kage TransformComponent VelocityComponent
down ArrowRight
until tag=Kage TransformComponent.x > 1975 max 60
up ArrowRight
down Space
until session.holding >= 1 max 100
up Space
capture /scratch/test/cable.png
```

In that environment, interactive input needed a PTY or a kept-open pipe; otherwise EOF terminated the game before commands arrived. `JM_DRIVE=1`, an explicit engine executable, and per-run save paths supported isolated runs. `JM_HEADLESS=1` could use a hidden real-GL window for captures. Verify these details against the current checkout rather than assuming they remain unchanged.

Use checkpoints or deep links to reach a later feature instead of repeatedly playing the whole route. A death followed by a correct respawn is useful coverage, not a failed test to erase. Record exploratory failures honestly, including whether the harness or actual product caused them.

## Generated assets and data

Run the generator when it is part of the changed contract. Compare deterministic outputs by bytes, or normalize semantics when irrelevant serialization varies. Check that rendered art and collision geometry agree. For editor-consumed data, check cross-field invariants such as unique object IDs and the next available ID; playable output can still break on the next editor operation.

## Process ownership and interrupted execution

Record the process/session ID, port, artifact directory, and launch command. A timed-out tool can leave a live process. Inspect its state and logs before launching another copy; an empty artifact directory may mean it never started. Distinguish those cases in the report.

Shut down owned processes gracefully and verify they exited. Do not use broad process-name kills that could terminate another agent's engine or server. Keep useful logs and captures, and report any intentionally retained process with its address and purpose.
