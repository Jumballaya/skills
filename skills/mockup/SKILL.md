---
name: mockup
description: Rapidly design UI by building static Tailwind + shadcn mockups, screenshotting them headless, and showing the user — then iterating. Two phases: first interrogate the design problem with small terse questions until fully understood, then generate genuinely distinct visual iterations (never the same idea twice). Use when the user wants to mock up, explore, or compare UI designs for a component/page/modal, or says "design this", "mock this up", "show me some options", "/mockup".
---

# Mockup

Design UI fast by **rendering it, not describing it**. Build a static HTML mockup with Tailwind + shadcn styling, screenshot it with headless Chrome, and show the user the image. Iterate.

This runs **outside any product repo** — mockups are throwaway. Default scratch dir: `/tmp/mockup-<slug>/`. Never write mockup files into the user's project.

There are two phases and you MUST NOT skip the first.

---

## Phase 1 — Understand (gate: do not build yet)

The first mockup is only as good as the brief. Interrogate before drawing.

Ask **small, concise** questions. Sacrifice grammar for concision. One idea per question. Use the `AskUserQuestion` tool when the answer is a choice; plain text when it's open. Batch 2–4 related questions, then wait.

Keep asking until you can state, in one line each:
- **Problem** — what's broken / missing in the current UX?
- **Surface** — component? modal? page? which one?
- **Want** — what does the user explicitly want (if anything specific)?
- **Don't-want** — what they reject. *Always ask this explicitly* — it's the strongest signal and the cheapest to get wrong.
- **Prior art** — anything already tried/seen that a new idea must NOT duplicate.
- **Constraints** — design system, brand, density, must-fit content, audience.

Good questions are tiny:
- "Modal, inline panel, or full page?"
- "What do you NOT want to see?"
- "Light, dark, or match a brand?"
- "Most important thing the user does here?"
- "Anything you've already rejected?"

Do not start building until the brief is solid. If the user says "just go," build once, then treat their reaction as the rest of the brief. A clarifying question is a question — get the answer before acting on scope.

When the brief is clear, restate it in ~3 lines and move to Phase 2.

---

## Phase 2 — Iterate (distinct every time)

Each iteration is one static HTML file → one screenshot → shown to the user → ask for direction.

**The core rule: never ship the same idea twice.** Re-skins of a prior mockup are failures. Before building each round, name the *mechanism* out loud (to yourself) and confirm it belongs to a pattern family you haven't used.

Keep a running **ledger** of what's been shown (pattern family + one-line gist). Pattern families to rotate through — pick an UNUSED one each round:

- **List / dropdown / combobox** — select from a menu, optional search
- **Descriptive cards / radio rows** — stacked options each with icon + explainer
- **Segmented control / tabs** — pick a mode, content swaps below
- **Tile / gallery grid** — scannable visual tiles (avatars, thumbnails)
- **Spatial / diagram** — the layout IS the metaphor (rings, map, timeline, graph)
- **Conversational** — a chat / wizard asks and the user taps replies
- **Skeuomorphic / object** — render the thing as a physical object (card, pass, ticket, switch)
- **Inline / natural-language** — an editable sentence or token ("let [X] use [Y]")
- **Direct-manipulation** — drag between buckets, sliders, canvas

If asked for "wildly different," jump families hard (e.g. from cards → spatial → skeuomorphic), don't just restyle.

Each round:
1. State the family + the one-line idea, and how it differs from prior rounds.
2. Build the HTML (see Recipe). Reuse `template.html` as the scaffold.
3. Screenshot it. `Read` the PNG so you actually see it — catch layout bugs before the user does.
4. Show the user: the file path + a tight explanation of the idea and *why it fits the brief* (especially the don't-wants). No fluff.
5. Ask what to push on, or for the next direction.

Apply the user's standing prefs: terse, answer what's asked, no recaps.

---

## Recipe — Tailwind + shadcn static mockup

The point of static HTML is zero build step: Tailwind via Play CDN, shadcn look via design-token CSS vars + shadcn's class patterns. Copy `template.html` and fill the body.

**Scaffold** (in `template.html`): the shadcn light-theme CSS variables on `:root`, the matching `tailwind.config` color map (`hsl(var(--x))`), and the radius scale. Build the mockup body using shadcn idioms:
- Dialog: `rounded-lg border border-border bg-card shadow-xl`, header/footer split by `border-t`.
- Inputs: `h-9 rounded-md border border-input bg-background px-3 text-sm shadow-sm`.
- Primary button: `bg-primary text-primary-foreground`; secondary: `border border-input bg-background`.
- Muted text: `text-muted-foreground`; selected state: `border-2 border-primary` or `ring-2 ring-ring`.
- Icons: inline lucide SVGs (24×24, `stroke-width="2"`, `stroke="currentColor"`).
Match real brand marks where it sells the mock (e.g. a provider logo).

**Screenshot** with headless Chrome. The `--virtual-time-budget` is essential — it lets the CDN finish applying Tailwind before capture, otherwise you get an unstyled shot:

```
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless=new --disable-gpu --hide-scrollbars \
  --force-device-scale-factor=2 \
  --run-all-compositor-stages-before-draw --virtual-time-budget=6000 \
  --window-size=W,H \
  --screenshot=/tmp/mockup-<slug>/shotN.png \
  "file:///tmp/mockup-<slug>/idxN.html"
```

Notes:
- `--force-device-scale-factor=2` → crisp 2× retina capture.
- Size `--window-size` to the design; trim whitespace by matching H to content. Center the artifact on a `bg-muted/40` body so it reads like a real screen.
- After capture, `Read` the PNG. If it looks unstyled, the CDN didn't apply — raise `--virtual-time-budget` or re-run.
- Verify Chrome path first (`ls "/Applications/Google Chrome.app/..."`); on Linux try `google-chrome`/`chromium`.

Keep each iteration in its own numbered file (`idx1.html`, `shot1.png`, …) so the user can compare and you keep the ledger straight.
