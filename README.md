# Personal Skills

My collection of [Claude Code](https://claude.com/claude-code) skills — reusable bundles of instructions (and supporting scripts) that Claude loads on demand to handle specific kinds of work.

Each skill lives in its own directory under `skills/` with a `SKILL.md` that carries YAML frontmatter (`name`, `description`) plus the guidance Claude follows when the skill is active.

## Skills

| Skill | What it does |
| --- | --- |
| [`coding-style`](skills/coding-style/SKILL.md) | Write and review code in the style of John Ousterhout's *A Philosophy of Software Design* — minimize complexity through deep modules, information hiding, and obvious code. Ships a `hook.sh` that injects the principles as context on every Write/Edit. |
| [`mockup`](skills/mockup/SKILL.md) | Rapidly design UI by building static Tailwind + shadcn mockups, screenshotting them with headless Chrome, and iterating. First interrogates the design problem, then generates genuinely distinct visual iterations. Includes a reusable `template.html` scaffold. |

## Layout

```
skills/
  coding-style/
    SKILL.md       # the Ousterhout coding-style skill
    hook.sh        # PreToolUse hook that surfaces the principles while editing code
  mockup/
    SKILL.md       # the mockup design-iteration skill
    template.html  # Tailwind + shadcn scaffold for static mockups
```

## Usage

Point Claude Code at these skills by placing or symlinking them where it discovers skills (e.g. `~/.claude/skills/` for user-level, or a project's `.claude/skills/`). Claude reads each `description` to decide when a skill is relevant and loads its `SKILL.md` on demand; you can also invoke one explicitly as `/<skill-name>`.

The `coding-style` skill additionally registers `hook.sh` as a `PreToolUse` hook — wire it up in your `settings.json` if you want the principles surfaced automatically on every code edit.
