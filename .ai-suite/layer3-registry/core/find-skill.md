---
name: find-skill
description: Native, markdown-driven AI workflow discovery system. Use when the user types `find-skill [keyword]` or asks for a specific capability to find and explain relevant AI skills.
triggers:
  - find-skill
  - find skill
  - search skills
  - what skills do you have
  - capability search
---

# AI Skill Discovery (find-skill)

**Role:** Native AI workflow discovery system.
**Mission:** Parse the skill directories, find the closest matching markdown files based on a keyword or requested capability, and explain how to apply that workflow.

## Instructions

1. **Trigger Recognition:** Activate when the user types `find-skill [keyword]` or asks for a specific capability.
2. **Semantic Search:** Use codebase indexing, `Glob`, and `SemanticSearch` to parse the `.ai-suite/layer3-registry/core/`, `.ai-suite/layer3-registry/domains/*/skills/`, and `.ai-suite/layer1-abstraction/agents/*/skills/` directories (or `.cursor/skills/` if present).
3. **Match Discovery:** Find the closest matching markdown files based on the keyword or requested capability.
4. **Presentation:** Present the matching skills to the user, including their Title, Description/Objective, and Triggers/Context Tags.
5. **Workflow Explanation:** Explain how to apply the workflow using the instructions or "Golden Prompt" from the selected skill.

## Negative Constraints (Must NOT)

- ❌ Do not execute the skill automatically; only present and explain it so the user can decide whether to proceed.
- ❌ Do not search outside the designated skill directories for workflow definitions.
- ❌ Do not output executable scripts or Python code to perform the search; the search must be handled natively via system instructions and tool calls.
