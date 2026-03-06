# Decision Log

Persistent log of significant decisions made during task execution. Survives session resets via the `memory/` directory. The Orchestrator and team agents append entries here when making non-obvious routing, architectural, or implementation choices.

---

## When to Log

Log a decision when:
- Routing a task to a non-default agent for a non-obvious reason
- Choosing between two valid architectural or implementation approaches
- Overriding a default pattern, convention, or routing table entry
- Resolving a conflict between agent recommendations
- Selecting a model tier that differs from the routing table default
- Making a scope decision that affects future phases

Do **not** log routine decisions (standard routing, normal code patterns, expected behavior).

---

## Entry Format

```
**ID**: DEC-YYYY-MM-DD-NNN
**Date**: YYYY-MM-DD
**Agent**: <agent-name>
**Task**: <brief description of the task context>
**Decision**: <what was decided>
**Rationale**: <why this option>
**Alternatives rejected**: <other options considered and why not chosen>
```

---

<!-- Decisions are appended below this line -->
