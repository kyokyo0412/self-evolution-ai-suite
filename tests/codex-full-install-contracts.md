# Codex Full Installation Architecture & Interface Contracts

## 1. Overview
The Codex adapter integrates the AI Suite with OpenAI Codex environments by configuring both the primary instruction file (`AGENTS.md`) and the supporting file-based artifact directories under `.codex/` (or `~/.codex/` for global scope).

## 2. Interface Contracts

### 2.1 Adapter API (`.ai-suite/layer1-abstraction/agents/codex/adapter.sh`)
- `agent_install_project(suite_dir, project_dir)`:
  - Writes/updates `$project_dir/AGENTS.md` with full directives and safety rules
  - Mirrors skills to `$project_dir/.codex/skills/`
  - Mirrors meta to `$project_dir/.codex/meta/`
  - Mirrors templates & prompt briefs to `$project_dir/.codex/templates/`
  - Mirrors scripts to `$project_dir/.codex/scripts/`
  - Mirrors rules & safety guardrails to `$project_dir/.codex/rules/`
  - Mirrors directives to `$project_dir/.codex/directives/`
  - Initializes file memory for `codex`
- `agent_install_global(suite_dir)`:
  - Writes/updates `~/.codex/AGENTS.md`
  - Mirrors all components to `~/.codex/{skills,meta,templates,scripts,rules,directives}/`
  - Initializes global file memory for `codex`
- `agent_uninstall_project(project_dir, [suite_dir])`:
  - Strips sentinel block from `AGENTS.md` and legacy `.codexrules`
  - Removes `.codex/{skills,meta,templates,scripts,rules,directives}/`
  - Cleans up empty `.codex/` directory
- `agent_uninstall_global([suite_dir])`:
  - Strips sentinel block from `~/.codex/AGENTS.md` and legacy `~/.codex/.codexrules`
  - Removes `~/.codex/{skills,meta,templates,scripts,rules,directives}/`
  - Cleans up empty `~/.codex/` directory

### 2.2 Core Library Extensions (`.ai-suite/layer2-cognitive/memory/core.sh`)
- `_mirror_directives(suite_dir, dest, [agent_name])`: copies directives & safety files
- `_remove_directives(dest)`: removes directory
- `_remove_templates(dest)`: removes directory
- `_remove_scripts(dest)`: removes directory
- `_mirror_rules`: encompasses directives, safety, and core rules into rules directory
- Dynamic Assertions: all test assertions MUST compute expected file counts dynamically (no hardcoded integers).
