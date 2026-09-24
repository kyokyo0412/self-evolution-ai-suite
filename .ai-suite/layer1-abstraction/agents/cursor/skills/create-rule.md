---
name: create-rule
description: Create Cursor rules for persistent AI guidance. Use when adding coding standards, project conventions, or RULE.md files.
triggers:
  - create-rule
---
# Creating Cursor Rules

Guides authoring persistent Cursor rules (`.cursor/rules/*.mdc`) providing project standards, architecture rules, and file-pattern behaviors.

## Storage Locations & Configuration
- Project Rules: `.cursor/rules/<name>.mdc`
- User Rules: `~/.cursor/rules/<name>.mdc`

```markdown
---
description: Clear summary of rule purpose and constraints
globs: "**/*.{ts,tsx}"     # File glob patterns (omit if alwaysApply: true)
alwaysApply: false         # Set true for persistent global enforcement
---

# Rule Title
Actionable instructions, quality standards, and negative constraints.
```

## Instructions & Rule Creation Workflow
1. **Scope:** Determine whether rule applies globally (`alwaysApply: true`) or file-specifically (`globs`).
2. **Draft Content:** Structure into Purpose, Core Conventions, and Negative Constraints (`- [X] Do not...`).
3. **Save & Test:** Write file to `.cursor/rules/<name>.mdc` and verify rule applies to relevant editor files.

## Negative Constraints (Must NOT)
- [X] **Do not mix scopes inconsistently**: If `alwaysApply: true`, do not set restrictive globs.
- [X] **Do not create ambiguous glob patterns**: Test glob pattern syntax against repository layout.
- [X] **Do not write monolithic rules**: Decompose complex guidelines into focused, modular rule files.
