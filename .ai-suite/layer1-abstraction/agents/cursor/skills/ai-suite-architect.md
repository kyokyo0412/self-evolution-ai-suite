---
name: ai-suite-architect
description: Design AI Suite artifact placement and integration. Use when choosing capability tiers or integrating skills, rules, directives, and tool schemas into the suite; use prompt-compiler for standalone prompt writing.
triggers:
  - design suite artifacts
  - choose a capability tier
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
- **Invariants**: YAML frontmatter (`name:`, `description:` with `"Use when"`, nonempty string `triggers:` array). Body <= 600 lines. Use native file tools exposed by the active host and equivalent supported fallbacks; do not assume particular tool names.

## Negative Constraints (Must NOT)
- [X] Do not place general skills in agent-specific directories or vice-versa.
- [X] Do not omit 'Use when' from skill frontmatter descriptions.
- [X] Do not emit artifacts without safety preflights for destructive operations.
- [X] **Do not exceed skill line limits**: Never generate skill bodies exceeding 600 lines.
