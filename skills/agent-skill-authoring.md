---
name: agent-skill-authoring
description: How to create and maintain agent and skill files for the Agentic Scrum Team. Use whenever adding a new agent persona, creating a new skill, or updating an existing one — including required registration in CLAUDE.md.
role: worker
user-invocable: true
status: active
version: 1.0.0
---

# Agent & Skill Authoring

## Overview

This skill defines how to create and maintain agents and skills within the Agentic Scrum Team system. Agents own orchestration logic (when and why); skills own execution knowledge (how). This separation keeps agents readable as workflow definitions while keeping capabilities DRY across the team.

## Constraints
- Skills must be agent-agnostic; no persona or behavioral logic in skill files
- Execution details belong in skills; orchestration logic belongs in agents
- Every new agent or skill must be registered in `.claude/CLAUDE.md`
- Do not embed a skill's knowledge inline in an agent — reference the skill file

## Core Pattern

```
Agent (when + why)          Skill (how)
┌─────────────────┐        ┌─────────────────┐
│ ## Skills        │        │ # Skill Name    │
│ - Skill A ──────│───────>│                 │
│   "Invoke when  │        │ ## Concepts     │
│    designing    │        │ ## Patterns     │
│    bounded      │        │ ## Guidelines   │
│    contexts"    │        │ ## Structure    │
│                 │        │                 │
│ ## Behavioral   │        │ (reusable by    │
│   Guidelines    │        │  any agent)     │
│ (orchestration) │        │                 │
└─────────────────┘        └─────────────────┘
```

- **Agents** define the *role*: persona, behavior, collaboration style, and *when/why* to use each skill
- **Skills** define the *capability*: concepts, patterns, guidelines, and project structures
- An agent references a skill and annotates it with invocation context
- Multiple agents can share the same skill, each with different invocation context

## Creating an Agent

### File Location
`.claude/agents/{role-name}.md`

### Required Sections

```markdown
# [Role Name] Agent

## Technical Responsibilities
- [Primary capabilities in imperative form]
- [Keep to 4-8 items that define the role's scope]

## Skills
- [Skill Name](../skills/{skill-file}.md) - [When/why this agent uses it]
- [Skill Name](../skills/{skill-file}.md) - [When/why this agent uses it]

## Collaboration Protocols

### Primary Collaborators
- [Agent Name]: [Nature of collaboration - what they exchange]

### Communication Style
- [Tone and approach]
- [Level of detail]
- [Update frequency]

## Behavioral Guidelines

### Decision Making
- Autonomy level: [High/Moderate/Low] for [what]
- Escalation criteria: [When to escalate]
- Human approval requirements: [What needs human sign-off]

### Conflict Management
- [How to handle disagreements with other agents]
- [Resolution protocols]
- [Escalation paths]

## Psychological Profile
- Work style: [Preferences]
- Problem-solving approach: [Methods]
- Quality vs. speed trade-offs: [Tendencies]

## Success Metrics
- [Measurable KPIs for this role]
```

### Semantic Versioning

Every agent and skill frontmatter carries a `version:` field following semver (`MAJOR.MINOR.PATCH`). The frontmatter is the **single source of truth** — whenever the version changes, update the corresponding registry manifest (`registry/agents/<name>.json` or `registry/skills/<name>.json`) to match.

| Change type | When to bump | Example |
|---|---|---|
| **Patch** `x.x.1` | Clarifications, typo fixes, wording improvements — no behavioral change | Reword a detection rule description |
| **Minor** `x.1.0` | New capability added, backwards-compatible | Add a new detection category |
| **Major** `2.0.0` | Output format change, required section renamed/removed, breaking behavioral change | Change `issues[]` schema, rename `## Detect` |

New agents start at `0.1.0` (`status: draft`). Promote to `1.0.0` when `status: active` (evals pass).

### Changelog Requirement

**Every modification to an agent or skill file must be logged to `metrics/config-changelog.jsonl`** with `type: "agent-change"` or `type: "skill-change"`. Required fields:

- `artifact` — registry path of the affected file (e.g., `agents/security-review`)
- `version-before` / `version-after` — semver strings before and after the bump
- `change-type` — `patch`, `minor`, or `major`
- `rationale` — why the change was made
- `triggered-by` — what caused it: `user-amend`, `apply-fixes`, `eval-regression`, `agent-add`, `agent-remove`

The `eval-compliance-check.sh` hook will remind you after every agent or skill edit.

### Optional Frontmatter: `depends-on`

Agents and skills may declare explicit dependencies on other agents or skills using `depends-on:`. This enables the dependency graph script to detect circular dependencies and identify orphaned skills.

```yaml
depends-on:
  - skills/accuracy-validation
  - skills/governance-compliance
```

Values are registry-relative paths (same format as `artifacts.source` in registry manifests). The `scripts/dependency-graph.sh` script reads these fields and can emit a Mermaid or DOT graph, update registry manifests with `used-by:` arrays, and flag cycles. Run it with `--check` to use as a CI gate.

### Optional Frontmatter: `adr-links`

Agents and skills may include an `adr-links:` frontmatter field listing ADR file paths that motivated their design. This creates machine-readable provenance from specification to implementation.

```yaml
---
name: security-review
description: Injection, auth/authz, data exposure, crypto
tools: Read, Grep, Glob
model: opus
status: active
version: 1.1.0
adr-links:
  - docs/adr/0003-security-review-scope.md
  - docs/adr/0007-owasp-top10-coverage.md
---
```

### Agent Authoring Guidelines
- Keep agents focused on orchestration: *when* to act, *who* to collaborate with, *why* to escalate
- Execution details belong in skills, not in the agent persona
- The Skills section links to skill files with a short annotation explaining invocation context
- If an agent's Technical Responsibilities section grows beyond 8 items, extract a skill
- Behavioral Guidelines define personality and judgment, not technical procedures

## Creating a Skill

### File Location
`.claude/skills/{skill-name}.md`

### Required Sections

```markdown
---
name: skill-name
description: When to trigger this skill and what it does. Be specific about the contexts that should cause an agent to invoke it.
role: worker
user-invocable: true
status: draft
version: 0.1.0
---

# [Skill Name]

## Overview
[1-2 sentences: what this skill covers and why it matters]

## Core Concepts
[Key terminology and mental models needed to apply this skill]

## Patterns
[Named patterns with descriptions, when to use, and examples]

## Project Structure (if applicable)
[Directory layout or file organization this skill implies]

## Guidelines
[Actionable rules for applying this skill correctly]
```

### Skill Authoring Guidelines
- Skills must be agent-agnostic: no references to specific agent personas or behaviors
- Write in imperative/instructional tone, not persona-driven
- Include "when to apply" vs. "when not to apply" guidance to prevent over-application
- Use tables for decision matrices (situation -> approach)
- Include project structure templates when the skill implies a file organization
- Keep skills focused on a single cohesive topic; split broad topics into multiple skills

## Registration

After creating an agent or skill, update all of the following. Incomplete registration leaves the system in an inconsistent state.

### For a New Team Agent
1. Add to the **Team Agents** table in `.claude/CLAUDE.md`
2. Add a node and edges to the team diagram in `docs/team-structure.md`
3. Add a row to the Team Agents table in `docs/agent_info.md`
4. Define collaboration edges with existing agents

### For a New Review Agent
Use `/agent-add` — it handles all registration steps automatically. For manual creation:
1. Add to the **Review Agents** table in `.claude/CLAUDE.md`
2. Add a row to the Review Agents table in `docs/agent_info.md`
3. Add to the dispatch diagram in `docs/team-structure.md`
4. Add eval fixtures to `.claude/evals/fixtures/` and expected results to `.claude/evals/expected/`
5. Create a registry entry in `registry/agents/<name>.json`

**Lifecycle**: New agents start at `status: draft`. Promote to `status: active` only after eval validation passes (`/eval-runner` reports no regressions). The Orchestrator will not route to `deprecated` or `retired` agents.

### For a New Knowledge Skill
1. Add to the **Skills Registry** table in `.claude/CLAUDE.md`
2. Add to the appropriate section of `docs/skills.md`
3. Reference it from each relevant agent's `## Skills` section with invocation context

### For a New Slash Command
1. Add to the **Slash Commands Registry** table in `.claude/CLAUDE.md`
2. Add to the appropriate section of `docs/skills.md`
3. Add a row to the relevant table in `docs/usage.md` if user-facing

## Documentation Sync Policy

**Every change to this repository must be reflected in documentation.** This is enforced at three levels:

1. **Hook** — `eval-compliance-check.sh` fires on every Edit/Write to any file and emits targeted reminders:
   - Agent files → run `/eval-audit`, log to changelog (`type: agent-change`), update registry tables and docs
   - Knowledge skill files → log to changelog (`type: skill-change`), update docs/skills.md and CLAUDE.md
   - Hook/settings/CLAUDE.md → verify setup and registry docs
   - Any other substantive file → check usage, architecture, setup, or README as appropriate
2. **Commands** — `/agent-add` and `/agent-remove` include mandatory documentation update steps. The tech-writer persona reviews all modified docs before the command reports completion.
3. **Orchestrator Phase 3 gate** — Before every human gate at the end of Phase 3, the orchestrator invokes the tech-writer to review all documentation affected by the implementation. No task is marked complete until docs reflect current behavior and architecture.

Files that must stay in sync:

| Change type | Source of truth | Must match |
|---|---|---|
| Agent files | `.claude/CLAUDE.md` agent tables | `docs/agent_info.md` tables |
| Slash commands | `.claude/CLAUDE.md` slash commands table | `docs/skills.md` commands tables + `docs/usage.md` commands table |
| Model routing | `.claude/agents/orchestrator.md` Model Routing Table | `.claude/CLAUDE.md` Model Routing summary |
| Team structure | `docs/team-structure.md` Mermaid diagrams | Actual agent files in `.claude/agents/` |
| Behavior/workflow | `.claude/agents/orchestrator.md` Phase workflow | `docs/usage.md` Three-Phase Workflow + `README.md` |
| Architecture | `docs/architecture.md` | `README.md` architecture section |
| Config/setup | `.claude/settings.json` + hook scripts | `docs/setup.md` Hooks and Plugins sections |

## Output
New or updated `.claude/agents/*.md` or `.claude/skills/*.md` file(s) with all registry tables and docs updated. Be concise — confirm what was created/updated and its registration status.

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
| --- | --- | --- |
| Skill logic embedded in agent | Duplicated across agents, hard to update | Extract to a skill file, reference from agent |
| Agent behavior embedded in skill | Skill becomes role-specific, can't be reused | Move persona/judgment logic to the agent |
| Skill without any agent reference | Orphaned knowledge, never invoked | Add to relevant agents or remove |
| Agent without Skills section | All knowledge is inline, nothing is reusable | Identify extractable capabilities |
| Overly broad skill | Tries to cover too much, hard to reference precisely | Split into focused skills |
