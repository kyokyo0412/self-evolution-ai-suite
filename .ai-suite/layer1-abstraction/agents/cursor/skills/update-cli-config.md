---
name: update-cli-config
description: View and modify Cursor CLI configuration settings in cli-config.json. Use when changing CLI preferences, approval modes, or permissions.
metadata:
  surfaces:
    - cli
triggers:
  - update-cli-config
---
# Cursor CLI Configuration

View and modify Cursor CLI settings stored in `~/.cursor/cli-config.json`.

## Config Hierarchy
- Global config: `~/.cursor/cli-config.json`.
- Project overrides: `.cursor/cli.json` files walked from repo root to cwd.

## Key Settings
- `permissions`: Allowed/denied tool call patterns (`allow: ["Shell(**)", "Mcp(...)"]`).
- `approvalMode`: `"allowlist"` (prompt) or non-allowlist (auto-approve all).
- `sandbox`: Container/sandbox execution options (`mode: "disabled" | "enabled"`, `networkAccess`).
- `editor`: `vimMode` (boolean), `defaultBehavior` (`"ide"` | `"agent"`).
- `attribution`: Git commit attribution and co-authorship.

## Instructions
Read `~/.cursor/cli-config.json`, apply modifications, and write back valid JSON. Restart CLI for changes to take effect.

## Negative Constraints (Must NOT)
- [X] Do not write invalid JSON syntax to `cli-config.json`.
- [X] Do not persist project-level overrides back into the user's global configuration.
