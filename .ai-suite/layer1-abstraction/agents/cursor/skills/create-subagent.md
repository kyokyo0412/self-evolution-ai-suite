---
name: create-subagent
description: Create custom subagents for specialized AI tasks. Use when configuring task-specific agents, code reviewers, or custom subagents.
disable-model-invocation: true
triggers:
  - create-subagent
---
# Creating Custom Subagents

Guides authoring specialized Cursor subagents with isolated context windows, dedicated system prompts, and tool permissions.

## Storage Locations & Configuration
- Project Subagents: `.cursor/agents/<name>.md`
- User Subagents: `~/.cursor/agents/<name>.md`

```markdown
---
name: specialized-agent-name
description: Explicit capability and triggers. Use proactively when <task>.
---

# Specialized Agent Persona
System instructions defining role, boundaries, reasoning patterns, and tool guidelines.
```

## Instructions & Subagent Creation Workflow
1. **Scope:** Choose project scope (`.cursor/agents/`) or user scope (`~/.cursor/agents/`).
2. **Definition:** Author bounded system prompt tailored to domain.
3. **Verification:** Confirm description includes triggers and "proactively" for automated delegation.

## Negative Constraints (Must NOT)
- [X] **Do not write ambiguous descriptions**: State exact triggers and domain boundaries.
- [X] **Do not mix agent formats**: Always adhere to YAML frontmatter + markdown system prompt.
- [X] **Do not duplicate existing global agents**: Ensure unique naming within workspace scope.
