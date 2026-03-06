# Setup

## Prerequisites

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) installed and authenticated
- `jq` installed (required by PostToolUse hooks for JSON parsing)
  - macOS: `brew install jq`
  - Linux: `apt install jq` or `yum install jq`

## Install

1. Clone the repository:

   ```bash
   git clone <repo-url> agentic-scrum-team
   ```

2. Copy `.claude/` into your target project:

   ```bash
   cp -r agentic-scrum-team/.claude/ /path/to/your-project/.claude/
   ```

3. Start Claude Code:

   ```bash
   cd /path/to/your-project
   claude
   ```

Claude automatically loads `CLAUDE.md` on startup. Agent and skill files are loaded on demand as tasks require them.

Three PostToolUse hooks activate automatically on every file write or edit:

- `js-fp-review.sh` — warns on array mutations and impure patterns in JS/TS files
- `token-efficiency-review.sh` — warns when files exceed recommended size limits
- `eval-compliance-check.sh` — warns when agent or command files are missing required structural elements; emits targeted doc-sync reminders for config and general repo changes

Hooks are advisory only — they never block writes.

## Plugins

Two plugins are enabled by default in `.claude/settings.json`:

- `skill-creator` — create and improve skills, run performance benchmarks
- `claude-code-setup` — analyze a codebase and recommend Claude Code automations

## Verify

After starting Claude Code, the Orchestrator pipeline is active. Submit any natural language request to confirm the system is working:

```text
> What agents are available on this team?
```
