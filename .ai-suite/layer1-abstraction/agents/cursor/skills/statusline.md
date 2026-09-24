---
name: statusline
description: Configure custom status line in Cursor CLI. Use when customizing status line, CLI prompt footer, or adding session context.
triggers:
  - statusline
---
# CLI Status Line Configuration

Guides configuring custom status line indicators above the Cursor CLI prompt using commands executed on conversation updates.

## Configuration (`~/.cursor/cli-config.json`)
```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.cursor/statusline.sh",
    "padding": 2,
    "updateIntervalMs": 300,
    "timeoutMs": 2000
  }
}
```

## Instructions & Setup Workflow
1. **Script:** Create lightweight script (`~/.cursor/statusline.sh`) parsing stdin JSON context via `jq` (`chmod +x`).
2. **Registration:** Update `~/.cursor/cli-config.json` with `statusLine` configuration.
3. **Verification:** Test by piping sample JSON into script.

## Negative Constraints (Must NOT)
- [X] **Do not block the statusline command**: Keep script execution lightweight (< 300ms) to avoid CLI stutter.
- [X] **Do not omit chmod +x**: Ensure statusline scripts have execution permissions.
- [X] **Do not emit multi-line output without explicit formatting**: Status lines are rendered in a compact horizontal bar.
