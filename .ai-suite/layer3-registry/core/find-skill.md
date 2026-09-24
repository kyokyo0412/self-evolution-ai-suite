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
1. **Trigger:** Activate when the user invokes `find-skill [keyword]` or asks for capabilities.
2. **Search:** Use `Glob` and semantic exploration across skill directories (`.ai-suite/`, `.cursor/skills/`).
3. **Presentation:** Present matching skills (Title, Description, Triggers/Context Tags).
4. **Explanation:** Explain how to apply the workflow using Golden Prompts or Usage Instructions.

## Negative Constraints (Must NOT)
- [X] Do not execute the skill automatically; only present and explain it.
- [X] Do not search outside designated skill directories.
- [X] Do not output executable scripts or Python code to perform the search; handle natively via tool calls.
