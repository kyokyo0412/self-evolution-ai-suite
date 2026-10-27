# Template: Prompt-Request Brief

**Purpose:** Give the available prompt compiler or artifact workflow a scoped request. Cursor-only `ai-suite-architect` or `prompt-developer` may assist when installed and relevant; other agents use their supported equivalents.

## Context and artifact

- **Project/revision:** `[repository and relevant verified source paths]`
- **Deliverable:** `[reusable prompt | SKILL.md | scoped rule | tool specification]`
- **Objective and audience:** `[concrete behavior and intended user/agent]`
- **Scope and authority:** `[allowed files, exclusions, whether implementation is authorized]`

## Constraints and acceptance

- **Applicable rules:** `[project rules, compatibility, memory safety/resource cleanup, dynamic assertions, and tool/resource limits when relevant]`
- **Known facts and unknowns:** `[source-backed contracts; unresolved essential context]`
- **Validation:** `[observable success/failure cases and available commands]`
- **Output:** `[chat or authorized project-relative file]`

Use `prompt-compiler` Draft prompt mode for a prompt artifact. Use Inline analysis mode only as support for already-authorized implementation. Do not put credentials in the brief or invent unavailable tools.
