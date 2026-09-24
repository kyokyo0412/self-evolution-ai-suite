---
name: local-suite
description: Manage local ai-suite lifecycle installation and removal. Use when installing, enabling globally, removing, or checking status of local ai-suite.
triggers:
  - enable ai suite
  - install ai suite
  - local ai suite
  - disable ai suite
  - remove ai suite
  - push evolution
  - push the evolution
  - update ai suite
  - collect evolution from local
  - collect local
---

# Local Suite -- AI-Prompted Local Lifecycle Manager

Manages the AI suite lifecycle across project and global scopes on the local machine using natural language commands.

## Operational Modes
- **Enable / Update:** `bash ai-suite enable --scope [project|global] --agent [cursor|codex|all]`
- **Disable / Remove:** `bash ai-suite disable --scope [project|global]`
- **Collect Local:** Scans `~/.cursor/skills/` and syncs modified skills back to `.ai-suite/`.

## Instructions & Lifecycle Execution Workflow
1. Identify target operation and scope.
2. Execute command via `bash ai-suite [enable|disable] [options]`.
3. Validate suite after collection (`bash .ai-suite/layer4-evolutionary/validation/validate-suite.sh`).

## Negative Constraints (Must NOT)
- [X] **Do not modify files outside `.ai-suite`**: Keep lifecycle changes strictly confined to framework paths unless explicitly requested.
- [X] **Do not run destructive deletions during disable**: Uninstaller must only remove files deployed by the AI suite.
- [X] **Do not skip validation after evolution collection**: Always run `validate-suite.sh` after collecting evolutions.
