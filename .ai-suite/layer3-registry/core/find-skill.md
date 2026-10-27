---
name: find-skill
description: Discover available AI workflows by capability and explain how to invoke them. Use when the user types find-skill with a keyword or asks which skills are available.
triggers:
  - find-skill
  - find skill
  - search skills
  - what skills do you have
---
# Skill Discovery

## Instructions

1. Inspect the active environment's skill catalog and configured project registry. Prefer that catalog over assumptions about an agent's home directory.
2. Search designated source directories and metadata with `rg --files` and `rg`. If unavailable, use `find` and `grep`, or supported file-list and search tools such as Glob. Batch independent searches with parallel tool calls when supported.
3. Validate frontmatter names, descriptions, triggers, paths, and referenced resources before recommending a skill. Resolve source `.md` files and installed `SKILL.md` layouts through the active registry.
4. Explain the closest matches, when they apply, and how the current agent can invoke them. Identify unsupported tools and provide a supported equivalent.

## Negative Constraints (Must NOT)

- [X] Do not execute a discovered skill unless the user requested the associated work.
- [X] Do not scan outside designated skill locations or assume Cursor tools exist in another agent.
- [X] Do not present missing or invalid skills as available.
