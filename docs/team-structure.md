# Team Organization

## Team Agents

```mermaid
graph TD
    CO[Orchestrator] --> SE[Software Engineer]
    CO --> DS[Data Scientist]
    CO --> AR[Architect]
    CO --> QA[QA/SQA Engineer]
    CO --> UX[UI/UX Designer]
    CO --> PM[Product Manager]
    CO --> TW[Technical Writer]
    CO --> SecE[Security Engineer]
    CO --> DO[DevOps/SRE Engineer]

    SE <--> QA
    SE <--> AR
    SE <--> UX
    DS <--> SE
    PM <--> CO
    AR <--> SE
    TW <--> PM
    TW <--> SE
    SecE <--> AR
    SecE <--> QA
    DO <--> AR
    DO <--> SE
    DO <--> SecE
```

## Review Agent Dispatch (Phase 3 Inline Checkpoints)

The orchestrator selects review agents based on what changed in each unit of work.

```mermaid
flowchart LR
    CO[Orchestrator\nModel Routing] -->|JS/TS functions| R1[complexity-review\nhaiku]
    CO -->|JS/TS functions| R2[naming-review\nhaiku]
    CO -->|JS/TS functions| R3[js-fp-review\nsonnet]
    CO -->|Test files| R4[test-review\nsonnet]
    CO -->|API / auth| R5[security-review\nopus]
    CO -->|Domain logic| R6[domain-review\nopus]
    CO -->|UI components| R7[a11y-review\nsonnet]
    CO -->|All changes| R8[structure-review\nsonnet]

    R1 & R2 & R3 & R4 & R5 & R6 & R7 & R8 --> AGG{Aggregate\nFindings}
    AGG -->|pass / warn| CONT([Continue])
    AGG -->|fail| FB[Correction Context\n→ Coding Agent]
    FB -->|max 2 iterations| AGG
    FB -->|still fail after 2| HU([Escalate to Human])
```
