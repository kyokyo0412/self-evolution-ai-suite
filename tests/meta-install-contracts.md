# Meta Installation Contracts

## 1. Core Library (`core.sh`)
- Add `_mirror_meta(suite_dir, meta_dest)`: Copies all files from `$suite_dir/meta/` to `$meta_dest/`.
- Add `_mirror_skills(suite_dir, skills_dest, agent_name)`: Copies all discovered skills to `$skills_dest/`. (Move this from cursor adapter to core.sh).
- Add `_remove_meta(meta_dest)`: Removes the copied meta files.
- Add `_remove_skills(suite_dir, skills_dest)`: Removes the copied skills.

## 2. Cursor Adapter (`layer1-abstraction/agents/cursor/adapter.sh`)
- `agent_install_project`: Calls `_mirror_meta` to `.cursor/meta`. Updates `.cursorrules` to point to `.cursor/meta`.
- `agent_install_global`: Calls `_mirror_meta` to `~/.cursor/meta`. Updates `~/.cursorrules` to point to `~/.cursor/meta`.
- `agent_uninstall_project`: Calls `_remove_meta` on `.cursor/meta`.
- `agent_uninstall_global`: Calls `_remove_meta` on `~/.cursor/meta`.

## 3. Claude Adapter (`agents/claude/adapter.sh`)
- `agent_install_project`: Calls `_mirror_skills` and `_mirror_meta` to `.claude/skills` and `.claude/meta`. Updates `CLAUDE.md` to point to these paths.
- `agent_install_global`: Calls `_mirror_skills` and `_mirror_meta` to `~/.claude/skills` and `~/.claude/meta`. Updates `~/.claude/CLAUDE.md` to point to these paths.
- `agent_uninstall_project`: Calls `_remove_skills` and `_remove_meta` on `.claude/skills` and `.claude/meta`.
- `agent_uninstall_global`: Calls `_remove_skills` and `_remove_meta` on `~/.claude/skills` and `~/.claude/meta`.

## 4. Other Adapters (opencode, continue, roo-code, codex)
- Same pattern as Claude Adapter.
  - opencode: `.opencode/skills`, `.opencode/meta`
  - continue: `.continue/skills`, `.continue/meta`
  - roo-code: `.roo/skills`, `.roo/meta`
  - codex: `.codex/skills`, `.codex/meta`

## 5. Backward Compatibility (Legacy Cleanup)
- **Mandatory Constraint:** When an agent's standard configuration path evolves or changes (e.g., from a flat file `.opencode.md` to a directory `.opencode/`), the `agent_uninstall_project` and `agent_uninstall_global` functions MUST include logic to detect and remove the legacy paths. This prevents stale configurations from corrupting user setups.
