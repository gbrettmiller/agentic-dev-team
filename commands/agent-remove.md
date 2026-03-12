---
name: agent-remove
description: >-
  Remove an agent from the system — deletes the agent file, cleans up all
  registry entries, removes cross-references, and updates documentation.
  Use when the user says "remove the X agent", "delete X-review", "retire
  the X role", or "we no longer need X". Handles both team agents and review
  agents. Always confirms before deleting.
argument-hint: "<agent-name> [--dry]"
user-invocable: true
allowed-tools: Read, Edit, Bash(rm *), Bash(ls *), Bash(git rm *), Bash(grep -r *), Glob, Grep
---

# Agent Remove

Role: implementation. This skill removes an agent and all its references
from the system — it does not modify agent behavior or content.

You have been invoked with the `/agent-remove` skill. Fully remove a named
agent and update all required documentation.

## Implementation constraints

1. **Offer deprecation first.** Before deleting, ask the user whether they
   want to deprecate or delete. Deprecation is the default for `active`
   agents — it preserves history while removing the agent from routing.
   Deletion is permanent and requires explicit confirmation.
2. **Confirm before deleting.** Always show the user what will be removed
   and wait for confirmation before any destructive action.
3. **Detect agent type first.** Review agents (declare `Model tier:`) and
   team agents (declare persona sections) require different cleanup paths.
4. **Remove all references.** An agent that is deleted but still referenced
   in other files leaves the system in an inconsistent state.
5. **Always update documentation.** Documentation steps are mandatory.
   Invoke the tech-writer persona to review updated docs before reporting
   completion.
6. **Be concise.** Report only what changed. No narration of each step.

## Parse Arguments

Arguments: $ARGUMENTS

Required: agent name (`$0`) — the filename stem without `.md`
(e.g., `js-fp-review`, `security-engineer`)

Optional:

- `--dry`: Show what would be removed without making changes

## Steps

### 1. Locate agent file

Verify `.claude/agents/<name>.md` exists. If not, list all agent files
and report that the named agent was not found.

### 2. Detect agent type

Read `.claude/agents/<name>.md`:

- If it declares `Model tier:` → **review agent**
- Otherwise → **team agent**

### 3. Offer deprecation vs. deletion

If the agent has `status: active`, present the user with two options:

```text
Agent: <name> (<type>) — currently active

Options:
  [D] Deprecate — sets status: deprecated in frontmatter and registry.
      Removes the agent from routing. File and history preserved.
      Use when replacing with a newer agent or temporarily disabling.

  [X] Delete   — permanently removes the agent file, registry entry,
      eval fixtures, and all documentation references.
      Use when the capability is no longer needed.

Choice (D/X):
```

If the user chooses **deprecation**, skip to the Deprecation path below.
If the user chooses **deletion** (or the agent is already `deprecated` or
`draft`), continue with the deletion path.

#### Deprecation path

1. In `agents/<name>.md`, change `status: active` → `status: deprecated`
   (add `deprecated-by: agents/<replacement-name>` if a replacement exists)
2. In `registry/agents/<name>.json`, change `"lifecycle": "active"` →
   `"lifecycle": "deprecated"`
3. In `registry/index.json`, update the entry's `"lifecycle"` to
   `"deprecated"`
4. Report:
   ```text
   Agent deprecated: <name>
   status: deprecated (removed from routing)
   File preserved: agents/<name>.md
   Registry updated: registry/agents/<name>.json
   ```
   Stop here — documentation cleanup is not required for deprecation.

### 4. Show deletion plan

Display a confirmation prompt listing every action that will be taken:

```text
Remove agent: <name> (<type>)

Files to delete:
  - .claude/agents/<name>.md
  [review agents only]
  - .claude/evals/fixtures/<name>-* (if any)
  - .claude/evals/expected/<name>-* (if any)

Registry entries to remove:
  - registry/agents/<name>.json
  - registry/index.json: entry with id "agents/<name>"
  - .claude/CLAUDE.md: <table row>
  [team agents only]
  - docs/team-structure.md: <diagram node and edges>

Documentation to update:
  - docs/agent_info.md: remove table row
  [team agents only]
  - .claude/agents/orchestrator.md: Model Routing Table row (if present)
  - Other agent files referencing <name> in collaboration protocols

Proceed? (yes to continue)
```

If `--dry` was passed, display the plan and stop without waiting for
confirmation.

### 4. Remove agent file

```bash
git rm .claude/agents/<name>.md
```

If not in a git repository, use `rm`.

### 5. Clean up eval artifacts (review agents only)

Search for and remove matching eval fixtures and expected files:

```bash
ls .claude/evals/fixtures/ | grep <name>
ls .claude/evals/expected/ | grep <name>
```

Remove each matching file with `git rm` (or `rm` if not in git).

### 6. Remove registry entry

Delete `registry/agents/<name>.json` with `git rm` (or `rm` if not in git).

Remove the corresponding entry from the `entries` array in
`registry/index.json`.

### 7. Update .claude/CLAUDE.md

- Remove the agent's row from the appropriate table (Team Agents or
  Review Agents)
- Remove the agent from the Orchestrator Model Routing Table if it has
  an explicit row
- Remove the agent from the Slash Commands Registry if listed

### 8. Update .claude/agents/orchestrator.md (team agents only)

- Remove from the Model Routing Table if explicitly listed
- Remove from the Inline Review Checkpoint table (if listed as a
  triggered agent)

### 9. Update cross-references in other agent files

Search for references to the removed agent:

```bash
grep -r "<name>" .claude/agents/ --include="*.md" -l
```

For each file found, remove or update:
- Collaboration protocol entries that name the removed agent
- Skills section references (if a team agent was referenced as a skill)

### 10. Update docs/agent_info.md

- Remove the agent's row from the Team Agents or Review Agents table
- If removing a team agent, remove any "Primary Collaborators" references
  in prose sections

### 11. Update docs/team-structure.md (team agents only)

Remove the agent node and all its edges from both Mermaid diagrams.

Example: removing `SecE[Security Engineer]`:
- Remove the node declaration line
- Remove all edges involving `SecE` (`SecE <--> AR`, `SecE <--> QA`, etc.)

### 12. Tech-writer review

Invoke the tech-writer persona to review all modified documentation files
for accuracy and consistency before reporting completion. Specifically check:

- No dangling references to the removed agent remain in any doc
- Tables are consistent across CLAUDE.md and docs/
- Mermaid diagrams render correctly (no orphaned edges)

### 13. Report

```text
Agent removed: <name> (<type>)

Deleted:
  - .claude/agents/<name>.md
  - registry/agents/<name>.json
  [+ eval files if any]

Updated:
  - registry/index.json
  - .claude/CLAUDE.md
  - docs/agent_info.md
  [+ orchestrator.md, team-structure.md, cross-references as applicable]

Tech-writer review: PASS

Documentation is consistent.
```
