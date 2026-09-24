---
name: update-cursor-settings
description: Modify Cursor and VSCode editor preferences in settings.json. Use when updating user settings, themes, keybindings, or editor configuration.
metadata:
  surfaces:
    - ide
triggers:
  - update-cursor-settings
---
# Updating Cursor Settings

Guides updating Cursor and VSCode user preferences in `settings.json`.

## Settings Locations
- **macOS:** `~/Library/Application Support/Cursor/User/settings.json`
- **Linux:** `~/.config/Cursor/User/settings.json`
- **Windows:** `%APPDATA%\Cursor\User\settings.json`

## Common Preference Keys
- Editor: `editor.fontSize`, `editor.tabSize`, `editor.formatOnSave`, `editor.wordWrap`.
- Workbench: `workbench.colorTheme`, `workbench.iconTheme`.
- AI/Cursor: keys prefixed with `cursor.` or `aipopup.`.

## Instructions & Settings Modification Workflow

1. **Read Existing File:** Always read current `settings.json` before applying modifications.
2. **Preserve Untouched Configs:** Only add or update the explicitly targeted keys.
3. **Parse & Format:** Parse JSON (preserving valid comments if needed), apply updates, and format with standard 2-space indentation.
4. **Validation:** Ensure valid JSON syntax to prevent editor initialization errors.

## Negative Constraints (Must NOT)
- [X] **Do not overwrite existing settings file blindly**: Always merge updates into existing settings.
- [X] **Do not introduce malformed JSON syntax**: Ensure JSON is valid before saving.
- [X] **Do not modify unrelated user settings**: Restrict edits strictly to requested configuration keys.
