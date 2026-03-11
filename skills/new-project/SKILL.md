---
name: new-project
description: Scaffold a new project from the Rocinante Mission Template. Creates the GitHub repo, clones it into ~/projects/, installs dependencies, and sets up a project CLAUDE.md.
argument-hint: "<project-name>"
disable-model-invocation: false
---

Scaffold a new project called **$ARGUMENTS** using the Rocinante Mission Template.

Follow these steps in order:

## 1. Validate input

If no project name was provided (i.e. $ARGUMENTS is empty), stop and ask the user for one.

## 2. Ask visibility preference

Ask the user if they want the repo public or private before proceeding — default to private.

## 3. Create the GitHub repo from the template

```
gh repo create $ARGUMENTS --template gbrettmiller/rocinante-mission-template --clone --private
```

(Substitute `--public` if the user chose public.)

The repo will be cloned into the current directory. Move it to `~/projects/` if needed:
```
mv $ARGUMENTS ~/projects/$ARGUMENTS
```

## 4. Install dependencies

```
cd ~/projects/$ARGUMENTS
pnpm install
```

## 5. Set up environment variables

Copy `.env.example` to `.env`:
```
cp .env.example .env
```

Report which variables need to be filled in (check for `VITE_API_URL` and any others).

## 6. Create a project CLAUDE.md

Create `.claude/CLAUDE.md` in the new project with the following content, substituting the actual project name for $ARGUMENTS:

```markdown
# $ARGUMENTS

A Svelte 5 application built on the Rocinante Mission Template.

## Commands

- Dev server: `pnpm dev` (localhost:5173)
- Build: `pnpm build`
- Unit tests: `pnpm test`
- Acceptance tests: `pnpm test:acceptance`
- All tests: `pnpm test:all`
- Lint: `pnpm lint`
- Quality gate: `pnpm test && pnpm build && pnpm lint`

## Stack

Svelte 5, Vite, Tailwind CSS v4, JavaScript. See global CLAUDE.md for coding conventions.

## Agents

The full agent roster (Alex, Amos, Bobbi, Naomi, Holden, Monica, Peaches, Drummer, Marco, Percy) is defined in `~/.claude/CLAUDE.md`. Delegate to them by name as appropriate for each task.

## Core principles

1. **Tests first** — feature file → review → implementation (ATDD workflow)
2. **No classes** — factory functions only (`const createThing = () => ({ ... })`)
3. **Quality gates** — `pnpm test && pnpm build && pnpm lint` must pass before every commit

## Architecture — five layers

Every feature touches these layers: content → core logic → service (if needed) → UI.

| Layer | Location | Purpose |
|-------|----------|---------|
| UI | `src/` | Svelte 5 components and entry point |
| Business logic | `core/` | Pure JS functions — no framework, no side effects |
| Strings | `content/en.json` | All user-facing copy — no hardcoded text in components |
| Design tokens | `design-system/` | Tailwind v4 `@theme` variables |
| Integrations | `services/` | API wrappers, all fetch/side-effect code |

## Project structure

```
src/
  App.svelte            — App shell
  main.js               — Entry point
  lib/                  — Svelte components

design-system/
  theme.css             — @theme variables (Tailwind v4 tokens)

content/
  en.json               — All user-facing strings

core/
  index.js              — Pure helper functions

services/
  api.js                — API client

features/
  step-definitions/     — Cucumber step definitions
  *.feature             — Gherkin acceptance tests

tests/
  unit/                 — Vitest unit tests
```

## Svelte 5 runes

Use runes for reactivity — no Svelte 4 stores:

```javascript
// State
let count = $state(0)

// Derived
const doubled = $derived(count * 2)

// Side effects
$effect(() => {
  console.log(count)
})
```

## Architecture rules

- UI goes in `src/` — one component per `.svelte` file
- Strings go in `content/en.json` — no hardcoded text in components
- Logic goes in `core/` — pure functions, no side effects, fully testable
- API calls go in `services/` — all external data through services
- Design tokens in `design-system/theme.css` — no raw colour/spacing values in components
- No file should exceed ~200 lines — split if it does

## Do not

- Put API calls in components (use `services/`)
- Hardcode colours or spacing (use `design-system/theme.css` tokens)
- Inline user-facing strings (use `content/en.json`)
- Mix business logic with UI (keep `core/` pure)
- Use classes (use factory functions)
- Write implementation before tests

## Testing

- Unit tests: Vitest, in `tests/unit/`
- Acceptance tests: Cucumber.js, in `features/`
- E2E: Playwright

## Environment variables

`VITE_API_URL` — API base URL (defaults to `/api`).
Access in app via `import.meta.env.VITE_API_URL`.
```

## 7. Confirm and summarise

Report back:
- GitHub repo URL
- Local path: `~/projects/$ARGUMENTS`
- Any `.env` variables that need filling in
- Next step: `cd ~/projects/$ARGUMENTS && pnpm dev`
