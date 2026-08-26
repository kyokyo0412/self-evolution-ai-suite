# Template: Prompt-Request Brief (Hand-Off to `ai-suite-architect` / `prompt-developer`)

**Purpose:** The minimum-viable structured brief that hands the `ai-suite-architect` or `prompt-developer` skill enough information to emit a production-ready artifact without playing 20-questions. Fill in `[BRACKETS]`.

---

# Prompt-Request Brief

## Project Context
`[e.g. "Building a custom Linux hypervisor with Docker control plane and gVisor sandboxing"]`

## Desired Artifact
Choose one (or describe a hybrid):
- A `.cursorrules` file
- A Cursor slash command / `.cursor-suite/skills/<file>.md`
- An MCP tool / JSON function-calling schema
- A reusable engineered prompt
- An autonomous agent definition

`[Insert specific deliverable here]`

## Core Objective
`[Describe exactly what the artifact must achieve. Be concrete -- e.g. "When a developer types /audit-net inside Cursor, it must inspect /proc/net/, identify open ports, cross-reference against /etc/services, and emit a JSON report."]`

## Specific Constraints
- `[e.g. "Must prioritize memory safety"]`
- `[e.g. "Only use bash and standard Linux utilities -- no Python"]`
- `[e.g. "JSON must adhere to OpenAI function-calling specs"]`
- `[e.g. "MUST NOT run any destructive command without explicit user confirmation"]`

## Validation Criteria
`[How will I know the artifact works? 1-2 concrete tests, e.g. "running `/audit-net` on a host with sshd listening must include port 22 in the JSON output".]`

---

The AI will respond using the four-section output structure defined in `ai-suite-architect.md`:
1. Architecture & Strategy
2. The Artifact
3. Integration & Usage Guide
4. Validation & Edge Cases
