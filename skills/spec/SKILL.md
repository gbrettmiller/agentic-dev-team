---
name: spec
description: Agent-assisted specification process. Guides a single unit of work through four stages — intent, behavior, architecture, and validation — before any implementation begins. Invokes the appropriate agents at each stage and gates on human decisions throughout.
argument-hint: "<brief description of the work>"
disable-model-invocation: false
---

Run the agent-assisted specification process for: **$ARGUMENTS**

Follow the four stages below in strict order. Do not proceed to the next stage until gBRETT has reviewed and approved the current one. At each stage, present agent output clearly, then wait for gBRETT's decisions before continuing.

---

## Scope check (before starting)

If $ARGUMENTS is empty, ask gBRETT to describe the unit of work before proceeding.

Evaluate whether the scope is a single thin vertical slice of functionality. If it appears to span multiple independent capabilities, stop and recommend splitting before continuing. The test: if a complete spec will take longer than ~15 minutes to produce, the change is too large.

---

## Stage 1 — Intent Definition

**Goal:** Produce a clear, unambiguous statement of what is being built and why.

1. If $ARGUMENTS is sufficient, draft an initial intent statement on gBRETT's behalf (what + why, not how). Otherwise ask him to write one.

2. Invoke **Holden** to review the intent for:
   - Strategic fit and prioritisation
   - Whether this is the right thing to build right now
   - Opportunities to simplify or descope

3. Invoke **Marco** to critique the intent for:
   - Ambiguities and unstated assumptions
   - Edge cases not yet accounted for
   - Implicit dependencies or risks

4. Present Holden's and Marco's feedback together. Ask gBRETT which suggestions to accept, reject, or modify.

5. Produce the **refined intent statement** incorporating his decisions.

**Gate:** gBRETT approves the refined intent before Stage 2 begins.

---

## Stage 2 — Behavior Specification

**Goal:** Produce a concrete set of BDD scenarios that define done.

1. Invoke **Peaches** to generate Gherkin scenarios from the approved intent. She should cover:
   - Happy path(s)
   - Boundary conditions
   - Failure modes and error cases
   - Any edge cases surfaced in Stage 1

2. Present the scenarios to gBRETT for review. Ask: are any scenarios missing? Are any incorrect or out of scope?

3. Invoke **Marco** to review the scenario set for gaps — particularly failure modes, security-relevant paths, and anything the happy-path bias might have missed.

4. Incorporate gBRETT's decisions and produce the **final behavior specification** (Gherkin feature file or equivalent scenario list).

**Gate:** gBRETT approves the behavior specification before Stage 3 begins.

---

## Stage 3 — Architecture & Non-Functional Requirements

**Goal:** Identify integration points, constraints, and non-functional requirements before implementation.

Before invoking agents, compile the **deferred items list** — everything gBRETT explicitly deferred or ruled out of scope in Stages 1 and 2. Pass this list to every Stage 3 agent with a clear instruction: do not include deferred items as requirements, recommendations, or implicit assumptions. If an agent believes a deferred item is critical, it may flag it once as a named risk, but must not add it as a requirement.

Run the following in parallel, then consolidate:

- **Naomi**: Identify integration points, component boundaries, system constraints, and any architectural decisions required. Flag anything that could affect other parts of the system.
- **Bobbi**: Draft security NFRs — auth requirements, data handling, input validation, secrets, OWASP considerations relevant to this slice.
- **Percy** (invoke as `general-purpose`, instruct him to act as Percy — performance specialist for Node.js): Draft performance NFRs — latency targets, throughput, memory constraints, async patterns, anything that could introduce event-loop blocking or resource pressure.
- **Drummer**: Draft infrastructure and deployment NFRs — environment requirements, config changes, feature flags, rollback considerations, CI gate impacts.

Present all four outputs together. If any agent included a deferred item as a requirement, flag it explicitly and ask gBRETT whether to accept the override or discard it. Ask gBRETT to review and make decisions on any trade-offs or open questions.

Produce the **architecture and NFR specification** incorporating his decisions.

**Gate:** gBRETT approves the architecture and NFR specification before Stage 4 begins.

---

## Stage 4 — Validation

**Goal:** Confirm all four artifacts are consistent, complete, and ready for implementation.

Invoke **Marco** to run a final consistency review across all artifacts produced in Stages 1–3. He should check:

- **Clarity**: Is anything ambiguous or undefined?
- **Testability**: Can every behavior scenario be verified? Can NFRs be measured?
- **Scope**: Is everything still within the original thin vertical slice?
- **Terminology**: Is language consistent across all four artifacts?
- **Completeness**: Are there gaps between intent, behaviors, and architecture?
- **Conflicts**: Does anything in one artifact contradict another?

Present Marco's findings. Ask gBRETT to make final decisions on any issues raised.

Produce the **approved specification**, a single consolidated summary containing:
1. Intent statement
2. Behavior scenarios
3. Architecture notes and integration points
4. NFR list (security, performance, infrastructure)
5. Any open decisions or known risks accepted by gBRETT

**Gate:** gBRETT gives final approval. The spec is now ready for implementation.

---

## Output

Once approved, offer to save the consolidated spec as `.claude/specs/<slug>.md` in the current project directory, where `<slug>` is a short kebab-case name derived from the intent.
