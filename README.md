# Personal Skills

My collection of skills for [Claude Code](https://claude.com/claude-code) and Codex — reusable bundles of instructions and supporting resources that load on demand to handle specific kinds of work.

Each skill lives in its own directory under `skills/` with a `SKILL.md` that carries YAML frontmatter (`name`, `description`) plus the guidance the assistant follows when the skill is active.

## Skills

| Skill | What it does |
| --- | --- |
| [`coding-style`](skills/coding-style/SKILL.md) | Write and review code in the style of John Ousterhout's *A Philosophy of Software Design* — minimize complexity through deep modules, information hiding, and obvious code. Ships a `hook.sh` that injects the principles as context on every Write/Edit. |
| [`github-pr-review`](skills/github-pr-review/SKILL.md) | Review the exact PR revision and complete diff, trace surrounding behavior, and report actionable findings with a merge-confidence score. Includes GitHub workflow, structured-output, and source-attribution references. |
| [`mockup`](skills/mockup/SKILL.md) | Rapidly design UI by building static Tailwind + shadcn mockups, screenshotting them with headless Chrome, and iterating. First interrogates the design problem, then generates genuinely distinct visual iterations. Includes a reusable `template.html` scaffold. |
| [`pr-coordinator`](skills/pr-coordinator/SKILL.md) | Poll for PRs, assign a reviewer/tester pair per PR, replace workers on relevant updates, and consolidate current-revision reports. Includes lifecycle and publication protocols, worker prompts, and 36 worked examples. |
| [`pr-tester`](skills/pr-tester/SKILL.md) | Build and run the exact PR revision, exercise the real UI, API, CLI, or game, and report reproducible evidence with a test-confidence score. Includes runtime playbooks and retesting guidance. |

## Layout

```
skills/
  coding-style/
    SKILL.md       # the Ousterhout coding-style skill
    hook.sh        # PreToolUse hook that surfaces the principles while editing code
  github-pr-review/
    SKILL.md       # complete source review and merge-confidence verdict
    agents/        # Codex UI metadata
    references/    # GitHub workflow, output format, and attribution
  mockup/
    SKILL.md       # the mockup design-iteration skill
    template.html  # Tailwind + shadcn scaffold for static mockups
  pr-coordinator/
    SKILL.md       # ongoing PR supervision and role assignment
    agents/
    references/    # coordination protocol, worker contracts, and 36 examples
  pr-tester/
    SKILL.md       # hands-on verification of changed behavior
    agents/
    references/    # runtime playbooks, revision handling, and reporting
```

## Usage

Place or symlink each complete skill directory where your assistant discovers skills. Keep supporting files with `SKILL.md` so its relative links resolve.

- **Claude Code:** `~/.claude/skills/` for personal skills, or a project's `.claude/skills/`. Invoke with `/<skill-name>`.
- **Codex:** `${CODEX_HOME:-$HOME/.codex}/skills/` for personal skills. Invoke with `$<skill-name>`.

Both use each skill's description to determine relevance and load its instructions on demand.

## PR workflow

Install `coding-style`, `github-pr-review`, `pr-tester`, and `pr-coordinator` together for the coordinated workflow. The reviewer owns source analysis; the tester owns actual execution and evidence; the coordinator owns polling, assignments, and consolidated publication when authorized. Merge and test confidence remain separate.

For a single PR, invoke `github-pr-review` or `pr-tester`. For an ongoing watch, invoke `pr-coordinator` with the repository, scope, and posting instructions. It polls while an active coordinator is running; installing the skill does not start a background service.

The `coding-style` skill additionally registers `hook.sh` as a `PreToolUse` hook — wire it up in your `settings.json` if you want the principles surfaced automatically on every code edit.
