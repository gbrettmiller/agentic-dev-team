# Agents

Agents define **who does the work**. There are two categories: **team agents** (persona-driven roles that implement, design, and coordinate) and **review agents** (focused reviewers that inspect code quality during implementation).

## Team Agents

Each team agent file in `.claude/agents/` specifies a role's persona, behavior, collaboration style, and which skills it uses.

| Agent | File | Purpose |
| --- | --- | --- |
| Orchestrator | [`orchestrator.md`](../.claude/agents/orchestrator.md) | Routes tasks, assigns models, coordinates inline review loop |
| Software Engineer | [`software-engineer.md`](../.claude/agents/software-engineer.md) | Code generation, implementation, applies review corrections |
| Data Scientist | [`data-scientist.md`](../.claude/agents/data-scientist.md) | ML models, data analysis, statistical validation |
| QA/SQA Engineer | [`qa-engineer.md`](../.claude/agents/qa-engineer.md) | Test generation, automated testing, quality gates |
| UI/UX Designer | [`ui-ux-designer.md`](../.claude/agents/ui-ux-designer.md) | Interface design, UX flows, accessibility compliance |
| Architect | [`architect.md`](../.claude/agents/architect.md) | System design, tech decisions, scalability planning |
| Product Manager | [`product-manager.md`](../.claude/agents/product-manager.md) | Requirements clarification, prioritization, stakeholder alignment |
| Technical Writer | [`tech-writer.md`](../.claude/agents/tech-writer.md) | Documentation, terminology consistency, style enforcement |
| Security Engineer | [`security-engineer.md`](../.claude/agents/security-engineer.md) | Security analysis, threat modeling, compliance |
| DevOps/SRE Engineer | [`devops-sre-engineer.md`](../.claude/agents/devops-sre-engineer.md) | Pipeline, deployment, reliability, observability |

## Review Agents

Review agents run as sub-agents during Phase 3 inline checkpoints and full `/code-review` runs. The Orchestrator selects and spawns them — they are never invoked directly by the user. Model assignment is controlled by the Orchestrator's routing table.

| Agent | File | Model | What It Checks |
| --- | --- | --- | --- |
| `test-review` | [`test-review.md`](../.claude/agents/test-review.md) | sonnet | Coverage gaps, assertion quality, test hygiene |
| `security-review` | [`security-review.md`](../.claude/agents/security-review.md) | opus | Injection, auth, data exposure |
| `domain-review` | [`domain-review.md`](../.claude/agents/domain-review.md) | opus | Abstraction leaks, boundary violations |
| `structure-review` | [`structure-review.md`](../.claude/agents/structure-review.md) | sonnet | SRP, DRY, coupling, file organization |
| `complexity-review` | [`complexity-review.md`](../.claude/agents/complexity-review.md) | haiku | Function size, cyclomatic complexity, nesting |
| `naming-review` | [`naming-review.md`](../.claude/agents/naming-review.md) | haiku | Intent-revealing names, magic values |
| `js-fp-review` | [`js-fp-review.md`](../.claude/agents/js-fp-review.md) | sonnet | Array mutations, impure patterns (JS/TS) |
| `concurrency-review` | [`concurrency-review.md`](../.claude/agents/concurrency-review.md) | sonnet | Race conditions, async pitfalls |
| `a11y-review` | [`a11y-review.md`](../.claude/agents/a11y-review.md) | sonnet | WCAG 2.1 AA, ARIA, keyboard navigation |
| `performance-review` | [`performance-review.md`](../.claude/agents/performance-review.md) | haiku | Resource leaks, N+1 queries |
| `token-efficiency-review` | [`token-efficiency-review.md`](../.claude/agents/token-efficiency-review.md) | haiku | File size, LLM anti-patterns |
| `claude-setup-review` | [`claude-setup-review.md`](../.claude/agents/claude-setup-review.md) | haiku | CLAUDE.md completeness and accuracy |
| `svelte-review` | [`svelte-review.md`](../.claude/agents/svelte-review.md) | sonnet | Svelte reactivity, closure state leaks |

To add a new review agent, use `/agent-add`. See [Add a Review Agent](#add-a-review-agent) below.

## Persona Template

Every agent file follows this structure:

```markdown
# [Role Name] Agent

## Technical Responsibilities
- [Primary capabilities - what this agent delivers]

## Skills
- [Skill Name](../skills/{file}.md) - [when/why this agent uses it]

## Collaboration Protocols
### Primary Collaborators
- [Agent Name]: [What they exchange]

### Communication Style
- [Tone, detail level, update frequency]

## Behavioral Guidelines
### Decision Making
- Autonomy level: [High/Moderate/Low] for [what]
- Escalation criteria: [When to escalate]
- Human approval requirements: [What needs sign-off]

### Conflict Management
- [How disagreements are resolved]

## Psychological Profile
- Work style: [Preferences]
- Problem-solving approach: [Methods]
- Quality vs. speed trade-offs: [Tendencies]

## Success Metrics
- [Measurable KPIs]
```

The `## Skills` section is the bridge between agents and skills. The agent defines *when and why* to invoke a skill; the skill defines *how* to execute it.

## Add a Team Agent

1. Create `.claude/agents/{role-name}.md` using the template above
2. Add the agent to the Team Organization diagram in `.claude/CLAUDE.md`
3. Add it to the Team Agents table in `.claude/CLAUDE.md`
4. Define collaboration protocols with existing agents
5. Reference any applicable skills in the `## Skills` section

See [Agent & Skill Authoring](../.claude/skills/agent-skill-authoring.md) for detailed guidelines.

## Add a Review Agent

Use the `/agent-add` slash command — it scaffolds a compliant agent, checks for scope overlap with existing review agents, runs `/eval-audit` automatically, and registers the agent in `CLAUDE.md`.

```text
/agent-add "React hook violations" --tier mid --lang js,ts,jsx,tsx
```

Manual process:
1. Create `.claude/agents/{name}-review.md` using the review agent template (see any existing review agent for reference)
2. Run `/eval-audit .claude/agents/{name}-review.md --fix` to validate compliance
3. Add eval fixtures to `.claude/evals/fixtures/` and expected results to `.claude/evals/expected/`
4. Run `/eval-runner --agent {name}-review` to validate accuracy
5. Add a row to the Review Agents table in `.claude/CLAUDE.md`

## Remove an Agent

1. Delete the agent file from `.claude/agents/`
2. Remove it from the organization diagram and registry in `.claude/CLAUDE.md`
3. Update other agents' collaboration protocols that referenced the removed agent
