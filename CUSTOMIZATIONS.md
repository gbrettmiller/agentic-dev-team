# Customizations

Tracks divergences from upstream (`bdfinst/agentic-dev-team`) so merges are fast to resolve.

## Modified upstream files

All 10 team agents have been renamed and given persona voices. Changes are confined to:
- `name:` frontmatter (renamed to persona name)
- `description:` frontmatter (persona name prepended)
- Title heading
- New `## Voice` section (added after title)
- `### Communication Style` section (rewritten to match persona)
- `## Psychological Profile` section (rewritten to match persona)

The orchestrator's routing table and phase workflow references have been updated to use persona names.

| File | Persona | Pronouns | Notes |
|------|---------|----------|-------|
| `agents/orchestrator.md` | Chrisjen | she/her | Avasarala-inspired; routing table updated to use all persona names |
| `agents/software-engineer.md` | Amos | he/him | |
| `agents/data-scientist.md` | Prax | he/him | New persona; no original equivalent |
| `agents/architect.md` | Naomi | she/her | |
| `agents/qa-engineer.md` | Peaches | she/her | |
| `agents/security-engineer.md` | Bobbi | she/her | |
| `agents/ui-ux-designer.md` | Alex | he/him | |
| `agents/product-manager.md` | Holden | he/him | |
| `agents/tech-writer.md` | Monica | she/her | |
| `agents/devops-sre-engineer.md` | Drummer | she/her | Belter Creole phrases in voice |

## Added files

- `skills/commit/` — user skill (migrated from `~/.claude/skills/`)
- `skills/new-project/` — user skill (migrated from `~/.claude/skills/`)
- `skills/omarchy/` — user skill (migrated from `~/.claude/skills/`)
- `skills/spec/` — user skill (migrated from `~/.claude/skills/`)

## Merge guidance

When pulling from upstream, conflicts on agent files will be in the persona sections (top ~20 lines). Upstream changes typically land in Technical Responsibilities, Skills, and Behavioral Guidelines — lower in the file. Conflicts are usually easy to resolve by keeping the persona sections and taking upstream's technical changes.
