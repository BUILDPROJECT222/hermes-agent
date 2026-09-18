---
name: brand-design
description: Builds the brand kit — palette, logo, avatar, banner.
version: 1.0.0
author: depi (BUILDPROJECT222)
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    category: creative
    tags: [branding, logo, design-system, launch-crew]
    related_skills: [launch-crew, market-research, content-studio, web-engineering]
---

# Brand Design Skill

Agent 2 of the launch crew. It turns the chosen concept from `RESEARCH.md` into a brand the
engineer can build against and the content agent can post with: one palette, one type pair,
one logo in four lockups, and the social images the launch needs.

Everything is authored as HTML + CSS and rendered to PNG, so the brand stays editable in a
text editor instead of locked inside a binary.

## When to Use

- A concept has been picked and `RESEARCH.md` exists.
- An existing project needs its brand refreshed or its social images regenerated.

Do not use it before a concept is chosen — a brand for an unpicked idea is thrown away.

## Prerequisites

- `RESEARCH.md` in the project root, with the recommended concept.
- Node and a headless browser for HTML-to-PNG rendering. Verify with `terminal`:
  `node -e "require('puppeteer')"` — install with `npm i -D puppeteer` if missing.
- `vision_analyze` to check every rendered PNG before it ships.

## How to Run

```
delegate_task(
  goal="Run the brand-design skill for the concept in RESEARCH.md",
  context="Project root: <path>. Concept: <name>. Tone: <two or three adjectives>."
)
```

## Quick Reference

| File | What it is |
|---|---|
| `brand/_shared.css` | Tokens: palette, type scale, radii, shadows. Single source of truth. |
| `brand/logo-horizontal.html` → `.png` | Wordmark + glyph, dark background |
| `brand/logo-horizontal-light.html` → `.png` | Same, light background |
| `brand/logo-1024.png` | Square glyph, 1024x1024, for launchpad token metadata |
| `brand/x-avatar.html` → `.png` | 400x400 profile image |
| `brand/x-banner.html` → `.png` | 1500x500 header |
| `brand/render.mjs` | Puppeteer script that renders every `.html` beside it to `.png` |

## Procedure

**1. Read the concept.** `read_file` on `RESEARCH.md`. Pull the name, the one-sentence
description, and the audience. The brand serves that sentence — not a generic crypto look.

**2. Pick the palette against the data.** Choose one background, one surface, one ink, one
accent, and one alert. Check every foreground/background pair for WCAG AA contrast (4.5:1 for
body, 3:1 for large text) and record the measured ratio as a comment in `_shared.css`. A pair
that fails is changed, not shipped with a note.

**3. Pick two typefaces at most.** One for headings, one for numbers and body. Prefer faces
served by Google Fonts so the site loads them without a bundling step, and always declare a
real system fallback stack.

**4. Write `brand/_shared.css`.** Every value is a CSS custom property on `:root`. The site
imports this file; nothing in the site hardcodes a hex value. Include a dark and a light
definition for every colour token.

**5. Build the logo.** A glyph that reads at 24px and a wordmark that reads at 1500px. Author
each lockup as its own HTML file that imports `_shared.css`, then render with `brand/render.mjs`.

**6. Render and inspect.** Run the renderer with `terminal`, then run `vision_analyze` on every
PNG. Check: does the glyph survive at favicon size, is the wordmark legible on both grounds,
does the banner keep its subject clear of the avatar overlap zone (bottom-left 260px).

**7. Write `brand/README.md`.** Palette table with hex values and measured contrast ratios, the
type pair with its fallback stack, and the one command that regenerates every PNG.

## Pitfalls

- **Do not ship a PNG you have not looked at.** `vision_analyze` every render. A renderer
  that silently produced a blank frame looks exactly like a successful run in the terminal.
- **The banner's bottom-left is covered by the avatar on X.** Keep the subject out of it.
- **A pure-black background crushes on OLED and a pure-white one glares.** Use near values.
- **Do not invent a token the site will not use.** Every custom property in `_shared.css`
  must be referenced by either the site or a brand file.
- **Never copy another project's mark.** The research agent listed competitors; the brand
  must not read as one of them.

## Verification

- Every `.html` under `brand/` has a matching `.png` newer than it.
- `grep` for a hex literal outside `_shared.css` returns nothing — use `search_files`.
- Contrast ratios are recorded and all pass AA.
- The 1024 glyph is square and its subject is centred with even margins.
