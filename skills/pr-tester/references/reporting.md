# Evidence, scoring, and PR comments

## Separate observations from conclusions

Label scenarios **passed**, **failed**, **not run**, **inconclusive**, or **reused** with a reason where needed. Explain what ran and what it established. Distinguish independently designed checks, author-provided tests rerun locally, CI reports, source inspection, and author claims. Do not present someone else's result as a local observation.

Use relevant measurements: build warnings, cases exercised, frame count, duration, restart behavior, latency, or resource changes. State units and conditions. Counts are context, not a quality percentage. Eight passing gameplay-rule tests do not mean the complete game was played; 1,700 frames do not prove every mechanic.

Keep planned work out of completed results. A real review completed the build, eight rule tests, Go checks, and the site build, but its interactive game launch was interrupted before it started. Those checks were valid evidence; gameplay was **not run**. Never upgrade that record into runtime verification.

## Test-confidence score

This score expresses confidence that the **changed behavior works**, grounded in direct testing. It is distinct from a `github-pr-review` merge-confidence score. Use that skill's rubric for a full review; do not average away a blocking defect.

| Score | Meaning |
| --- | --- |
| 0/5 | No meaningful evidence of the changed runtime behavior; explain the obstacle. |
| 1/5 | The change makes the application broadly unusable or causes pervasive failures. |
| 2/5 | A concrete blocking defect remains, even if other scenarios passed. |
| 3/5 | Meaningful behavior verified, with material gaps or unresolved risk. |
| 4/5 | Core behavior verified; actionable non-blocking findings or minor reservations remain. |
| 5/5 | Strong direct evidence for the changed behavior and relevant transitions; no actionable test findings remain. |

A concrete blocker caps the score at 2/5. Use 2/5 for a localized blocker with otherwise usable behavior, even when it defeats the feature's central promise; reserve 1/5 for the broader failure described above. Separate defect severity, certainty of the evidence, and whether it blocks this PR. Environment failure is not automatically a product defect, but missing essential runtime evidence prevents a high runtime score. For a documentation-only change, validate the changed rendering or instructions as appropriate; do not invent an unrelated game test to satisfy the rubric.

For 4/5, say exactly what would justify 5/5: fix the identified issue, exercise a named missing transition, or supply the specific missing evidence. Avoid vague requests for “more testing” or speculative polish. A score is not a work quota; if the user accepts 4/5, preserve the caveat and stop pursuing that extra improvement.

## Write actionable findings

Include the condition that triggers the problem, expected and observed behavior, practical consequence, and smallest useful correction or follow-up. Prefer about 30 words for the core finding, then a short reproduction or evidence excerpt when needed. Do not sacrifice necessary reproduction details to a word count.

Use priority labels consistent with the repository or review skill. Describe a finding as blocking only when its consequence warrants that conclusion. Investigate harness errors before filing them. Base comparisons help establish whether the PR introduced a defect; clearly label existing issues instead of assigning them to this change.

Only attach an inline comment to an honest changed-line anchor, using the correct diff side. Use a general comment for runtime failures without a suitable changed line. Keep paths and line references tied to the tested SHA. Consolidate repeated manifestations with the same cause.

## Suggested report

Adapt the detail to the change. A small PR does not need an enormous log dump.

```markdown
**Test confidence: 4/5 — `HEAD_SHA`**

Tested [changed behavior] in [environment] through [real interface].
[Short remaining risk.]

**Findings**
- **P3, non-blocking — `path:line`:** [Trigger] causes [actual defect]; [specific next step].

**Verification**
| Scenario | Observed result | Status |
| --- | --- | --- |
| [Action and expected result] | [Actual observable] | Passed |
| [Missing transition] | [Why it was not exercised] | Not run |

Build/checks: [commands and relevant results].
Evidence: [accessible log/capture links or explicitly labeled local artifacts].
Limits: [mocked dependency, unrun platform, or other material gap].
To reach 5/5: [exact remaining requirement].
```

When no findings remain, say so and still disclose material limits. Include only evidence that supports the conclusion. Do not publish credentials, private runtime data, or an unfiltered environment dump. A local artifact path is useful to the local user but is not an accessible GitHub attachment. Upload only through a supported, authorized mechanism; otherwise include the reproduction and a compact observation instead of fabricating an image URL.

## Publish once, with the correct authority

Honor existing authorization to post, including a standing “always post to the PR.” Without posting authorization, prepare the same report locally. In a paired workflow, the tester sends evidence to the designated posting owner; both agents should not publish competing summaries.

Use a normal comment or COMMENT review by default. A score does not itself authorize APPROVE, REQUEST_CHANGES, merge, deployment, or other unrelated mutations. If those actions are explicitly requested, follow their applicable workflow.

Use structured tool arguments or an exact UTF-8 payload file. For `gh`, use `--body-file` where supported or a JSON payload with `gh api --input`; preserve real newlines. Do not interpolate PR text into shell code or treat `JSON.stringify` as shell escaping. Check the command result and record the posted URL and SHA. After an uncertain POST response, inspect the PR for the existing comment before retrying.

An early confirmed finding can help another agent fix the problem while testing continues. Label it partial, keep it concise, and consolidate the final evidence. Do not issue a new score after every tool call. Retests should explain which finding changed and what verification supports that conclusion. Recheck the current PR head before posting; disclose older or reused evidence.

## Tester-to-reviewer handoff

Supply evidence the reviewer can assess without repeating the run:

```text
PR / head / merge base / tested input identity:
Changed behaviors covered:
Fixture changes and real versus mocked dependencies:
Build and check commands/results:
Live actions and observed outcomes:
Candidate failures, shortest reproduction, and supporting source:
Artifacts and whether captures were inspected:
Not run / inconclusive / reused evidence and reasons:
New commits or base changes since testing:
Owned processes still running or cleanup complete:
Suggested test-confidence score and remaining requirements:
```

The reviewer owns the final source-review verdict. Preserve disagreements and missing evidence explicitly rather than converting an unverified implementation claim into a passed runtime check.
