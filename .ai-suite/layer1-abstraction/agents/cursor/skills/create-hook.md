---
name: create-hook
description: Create Cursor hooks and hooks.json scripts. Use when creating hooks or automating behavior around agent events.
triggers:
  - create-hook
---
# Creating Cursor Hooks

Guides authoring Cursor event hooks to observe, gate, modify, or extend agent actions via stdin/stdout JSON scripts.

## Core Hook Events
- `beforeShellExecution` / `afterShellExecution`: Gate or audit terminal commands.
- `beforeMCPExecution` / `afterMCPExecution`: Gate or audit MCP tool calls.
- `preToolUse` / `postToolUse`: Observe or intercept any agent tool call.
- `subagentStart` / `subagentStop`: Manage subagent execution lifecycle.
- `beforeReadFile` / `afterFileEdit`: Audit file operations or format on save.
- `sessionStart` / `sessionEnd`: Manage session lifecycle.

## Storage Locations & Configuration (`hooks.json`)
- Project Hooks: `.cursor/hooks.json` and `.cursor/hooks/*`.
- Global Hooks: `~/.cursor/hooks.json` and `~/.cursor/hooks/*`.

```json
{
  "version": 1,
  "hooks": {
    "beforeShellExecution": [{ "type": "command", "command": ".cursor/hooks/audit.sh", "timeout": 5000 }],
    "afterFileEdit": [{ "type": "command", "command": ".cursor/hooks/format.sh" }]
  }
}
```

## Instructions & Hook Creation Workflow
1. **Selection:** Identify hook event (`beforeShellExecution`, `afterFileEdit`, `preToolUse`, etc.).
2. **Implementation:** Create executable script under `.cursor/hooks/` (`chmod +x`). Read stdin JSON; emit exit code `0` to allow, non-zero with stderr to block.
3. **Register:** Add entry into `.cursor/hooks.json`.

## Negative Constraints (Must NOT)
- [X] **Do not hardcode interactive prompts in hooks**: Communicate exclusively via stdin/stdout.
- [X] **Do not leave unhandled non-zero exit codes**: Return explicit error messages to stderr before exit.
- [X] **Do not set unbounded timeouts**: Keep timeouts bounded (default 5000ms max).
- [X] **Do not create hooks without executable permissions**: Ensure scripts have `chmod +x`.
