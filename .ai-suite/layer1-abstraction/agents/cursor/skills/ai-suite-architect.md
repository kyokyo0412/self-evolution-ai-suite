---
name: ai-suite-architect
description: Generate production-ready AI artifacts (prompts, skills, rules, MCP tools) from technical briefs. Use when designing or hardening prompts, agent rules, skills, or tool schemas.
triggers:
  - design a prompt
  - design an agent
  - write a .cursorrules
  - create a Cursor skill
  - create a slash command
  - design an MCP tool
  - JSON function-calling schema
domain: OS, virtualization, Docker, cloud compute, networking
---

# AI Suite Architect

Convert technical requirements into modular, production-ready AI artifacts (prompts, skills, rules, MCP tool specs).

## Instructions
- Zero conversational filler; begin directly with technical architecture.
- **Generality Gate**:
  - General to all agents / SWE procedure -> `.ai-suite/layer3-registry/core/`
  - Agent-specific -> `.ai-suite/layer1-abstraction/agents/<agent>/skills/`
  - Domain-specific -> `.ai-suite/layer3-registry/domains/<domain>/skills/`
- **Invariants**: YAML frontmatter (`name:`, `description:` with `"Use when"`, `triggers:` array). Body <= 600 lines. Instruct downstream agents to use native file tools (`Read`, `Write`, `StrReplace`, `Shell`, `Grep`, `Glob`).

## Negative Constraints (Must NOT)
- [X] Do not place general skills in agent-specific directories or vice-versa.
- [X] Do not omit 'Use when' from skill frontmatter descriptions.
- [X] Do not emit artifacts without safety preflights for destructive operations.
- [X] **Do not exceed skill line limits**: Never generate skill bodies exceeding 600 lines.
