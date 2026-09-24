---
name: migrate-to-skills
description: Convert Cursor rules (.mdc) and slash commands to Agent Skills format. Use when migrating rules or commands to .cursor/skills/ directories.
disable-model-invocation: true
triggers:
  - migrate-to-skills
---
# Migrate Rules and Slash Commands to Skills

Guides migrating Cursor rules (`.cursor/rules/*.mdc`) and legacy slash commands (`.cursor/commands/*.md`) into standard Agent Skills directories.

## Target Structure
- **Destination:** `.cursor/skills/<skill-name>/SKILL.md` (or user scope `~/.cursor/skills/<skill-name>/SKILL.md`).
- **Verbatim Rule Body:** Preserve the exact markdown body without paraphrasing.

## Migration Mapping
1. **From `.cursor/rules/<name>.mdc`:**
   - Migrate rules that define `description` without restrictive `globs` or `alwaysApply: true`.
   - Add YAML frontmatter `name: <name>` and `description: <desc>`.
   - Retain body text verbatim.
2. **From `.cursor/commands/<name>.md`:**
   - Convert plain markdown commands into `SKILL.md`.
   - Add frontmatter with `name: <name>` and descriptive `description: ... Use when ...`.

## Instructions & Migration Workflow

1. **Discovery:** Scan workspace for candidates in `.cursor/rules/` and `.cursor/commands/`. (Ignore `~/.cursor/skills-cursor/`).
2. **Directory Creation:** For each candidate, create `.cursor/skills/<name>/`.
3. **Write `SKILL.md`:** Write formatted YAML frontmatter + original body.
4. **Cleanup:** Delete migrated original files upon user verification.

## Negative Constraints (Must NOT)
- [X] **Do not alter command/rule body text**: Copy instructions verbatim.
- [X] **Do not touch system skills**: Never modify `~/.cursor/skills-cursor/`.
- [X] **Do not migrate global always-apply rules**: Keep persistent rules in `.cursor/rules/`.
