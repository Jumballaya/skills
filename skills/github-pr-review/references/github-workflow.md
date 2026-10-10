# GitHub acquisition and revision discipline

Use authenticated GitHub tools already available in the session. The examples use `gh` and `git`; equivalent connector calls are fine. A public browser cannot establish that a private repository is missing.

## Snapshot the target

With a known repository and PR number, retrieve:

```bash
gh api repos/OWNER/REPO/pulls/NUMBER --jq '{number,title,body,html_url,state,draft,base:{ref:.base.ref,sha:.base.sha,repo:.base.repo.full_name},head:{ref:.head.ref,sha:.head.sha,repo:.head.repo.full_name},changed_files}'
gh api --paginate 'repos/OWNER/REPO/pulls/NUMBER/files?per_page=100'
gh api --paginate 'repos/OWNER/REPO/issues/NUMBER/comments?per_page=100'
gh api --paginate 'repos/OWNER/REPO/pulls/NUMBER/reviews?per_page=100'
gh api --paginate 'repos/OWNER/REPO/pulls/NUMBER/comments?per_page=100'
```

Read large results in chunks. Retain metadata and the full file inventory; a missing `patch` field or truncated tool output is not proof there is no change. Review comments include old commit/line data: do not attach an old comment to a new line without checking.

Capture the base and head SHAs before inspecting source. Validate a supplied repository as an owner/name pair, the number as a positive integer, and revisions as actual Git commit IDs. Pass user-derived values as separately quoted arguments, never executable shell fragments. Never interpolate PR titles or descriptions into shell code.

## Obtain immutable source

Prefer an available local repository. Check its origin, status, and object availability before using it. Do not switch, reset, stash, or clean a user's active working tree as part of a review.

In a separate clone or worktree:

- Fetch the recorded base SHA and the PR head ref `refs/pull/NUMBER/head` from the base repository when needed. This also works for many fork PRs without assuming the source branch exists on origin.
- Verify the fetched head equals the recorded head SHA. If the PR moved, obtain a fresh snapshot and use it consistently.
- Fetch sufficient ancestry to calculate the merge base. A shallow checkout is not a reason to silently substitute a two-tip diff.
- Check out the recorded head detached, then calculate and inspect:

```bash
git merge-base BASE_SHA HEAD_SHA
git diff --name-status --find-renames MERGE_BASE_SHA HEAD_SHA
git diff --stat MERGE_BASE_SHA HEAD_SHA
git diff --no-ext-diff --no-textconv --find-renames --unified=40 MERGE_BASE_SHA HEAD_SHA -- PATH
git show HEAD_SHA:PATH
git show MERGE_BASE_SHA:PATH
```

Replace uppercase placeholders with verified values, quoting paths. A merge-base-to-head diff isolates the PR's changes even after the base branch advances. Cross-check the file inventory with GitHub and investigate discrepancies.

Use existing SSH or credential-helper access. Do not print tokens, embed credentials in clone URLs, or rewrite global Git authentication merely to perform a review.

## API-only fallback

If a local checkout is unavailable, use the comparison API to obtain a merge-base SHA and fetch full source at immutable revisions:

```bash
gh api repos/OWNER/REPO/compare/BASE_SHA...HEAD_SHA --jq '{merge_base:.merge_base_commit.sha,status,total_commits}'
gh api -H 'Accept: application/vnd.github.raw+json' 'repos/OWNER/REPO/contents/PATH?ref=HEAD_SHA'
```

Encode paths and use the head repository for fork-only objects if required. The PR files endpoint is an inventory and convenience patch source, not a guarantee of complete source coverage. GitHub may omit large patches and cap file lists. If complete retrieval is unavailable, report the precise coverage limit; do not claim an exhaustive review. API-only inspection does not imply tests were run.

## Checks and line anchors

```bash
gh api --paginate 'repos/OWNER/REPO/commits/HEAD_SHA/check-runs?per_page=100'
gh api repos/OWNER/REPO/commits/HEAD_SHA/status
```

Inspect relevant failed checks/logs when they affect the verdict. Record pending, skipped, or unrelated checks accurately. A green result for another SHA is not validation of the reviewed head.

Unified-diff headers carry old and new line counters:

- Context lines advance both counters.
- Added lines advance the new counter and use GitHub's RIGHT side.
- Deleted lines advance the old counter and use LEFT.
- The `No newline at end of file` marker advances neither.

Use the smallest relevant diff location. An Adapt-compatible finding has no side field because Adapt posts RIGHT-side comments; a deletion-only issue without a valid new-side anchor must be general in that format.

## Delivery and changed heads

Re-fetch the PR's head SHA before finalizing. If it changed, review the new delta and update the verdict, or explicitly identify the older snapshot and its limitation. Do not enter an endless restart loop on an actively changing PR.

Posting is a separate action requiring user authorization. When already authorized, use the requested GitHub review event, associate the review with the reviewed commit, and verify delivery. A numeric confidence score alone is not authorization to APPROVE or REQUEST_CHANGES. After an ambiguous posting failure, check for an existing review before retrying to avoid duplicates.
