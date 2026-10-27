---
name: create-skill
description: Create Cursor Agent Skills. Use when authoring a new Cursor skill or structuring SKILL.md files; use create-hook for hook scripts and configuration.
triggers:
  - create-skill
---
# Creating Skills in Cursor

Guides authoring effective Agent Skills for Cursor. Skills are structured markdown directories teaching the agent specialized workflows, team standards, and tool sequences.

## Skill File Structure
- `skill-name/SKILL.md`: Main instructions with frontmatter.
- Sibling reference files (`reference.md`, `examples.md`): One level deep.
- Deterministic utility scripts: `scripts/*.sh` (chmod +x).

### Frontmatter Schema
```yaml
---
name: skill-name
description: Brief description (WHAT and WHEN). Use when <trigger conditions>.
disable-model-invocation: true
triggers:
  - skill-name
---
```
- `name`: Lowercase, numbers, hyphens only. Max 64 chars. Must match directory/file basename.
- `description`: Third-person imperative. Max 1024 chars. Must include `Use when`.

## Instructions & Skill Creation Workflow
1. **Discovery:** Define task scope (`~/.cursor/skills/` vs `.cursor/skills/`) and trigger conditions.
2. **Design:** Formulate skill name and high-density description with `Use when`.
3. **Implementation:** Create `<target_dir>/<skill-name>/SKILL.md` with YAML frontmatter, workflow, and negative constraints `[X]`.
4. **Verification:** Ensure SKILL.md <= 500 lines and zero space/tab empty lines. Resolve the suite validator from the installed meta directory or repository and run `bash <resolved-validator> <target_dir>/<skill-name>/SKILL.md`; installed identity is the containing skill directory. Verify declared resources exist. If the validator is unavailable, perform the checks directly and report that limitation.

## Negative Constraints (Must NOT)
- [X] **Do not create skills in reserved directories**: Never write to `~/.cursor/skills-cursor/`.
- [X] **Do not write verbose conversational padding**: Exclude encyclopedic tutorials or generic explanations.
- [X] **Do not exceed 500 lines in SKILL.md**: Keep instructions lean and use progressive disclosure.
- [X] **Do not use Windows-style path separators**: Always use Unix forward slashes (`/`).
- [X] **Do not omit Negative Constraints**: Every skill must define explicit safety boundaries.
- [X] **Do not break established workflows**: Preserve existing workspace capabilities and triggers.
