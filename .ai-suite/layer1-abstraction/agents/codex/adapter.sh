#!/usr/bin/env bash
set -euo pipefail
# .ai-suite/layer1-abstraction/agents/codex/adapter.sh -- Codex adapter for ai-suite.
#
# Implements the standard adapter interface:
#   agent_install_project SUITE_DIR PROJECT_DIR
#   agent_install_global  SUITE_DIR
#   agent_uninstall_project PROJECT_DIR [SUITE_DIR]
#   agent_uninstall_global [SUITE_DIR]
#
# Codex reads AGENTS.md files for project and global context:
#   Project scope -> PROJECT_DIR/AGENTS.md + PROJECT_DIR/.codex/{skills,meta,templates,scripts,directives}
#   Global scope  -> ~/.codex/AGENTS.md + ~/.codex/{skills,meta,templates,scripts,directives}
# Note: .codex/rules is reserved for native Codex Starlark-syntax execution rules and is never populated with Markdown prompt rules.

_CODEX_SENTINEL_START='<!-- ai-suite:start -->'
_CODEX_SENTINEL_END='<!-- ai-suite:end -->'

agent_install_project() {
  local suite_dir="$1" project_dir="$2"
  local file="$project_dir/AGENTS.md"
  local target_dir="$project_dir/.codex"
  
  agent_uninstall_project "$project_dir" "$suite_dir" 2>/dev/null || true

  mkdir -p "$target_dir"
  _mirror_skills "$suite_dir" "$target_dir/skills" "codex"
  _mirror_meta "$suite_dir" "$target_dir/meta"
  _mirror_templates "$suite_dir" "$target_dir/templates" "codex"
  _mirror_scripts "$suite_dir" "$target_dir/scripts" "codex"
  _mirror_directives "$suite_dir" "$target_dir/directives" "codex"

  # Auto-initialize memory system
  mkdir -p "$project_dir/.ai-memory/codex/index"
  mkdir -p ~/.ai-suite/memory/codex/tasks
  if [[ -f "$suite_dir/layer2-cognitive/memory/memory.sh" ]]; then
    SUITE_DIR="$suite_dir" source "$suite_dir/layer2-cognitive/memory/memory.sh"
    ai_memory_init "codex" 2>/dev/null || true
  fi

  generate_markdown_block "$suite_dir" "$target_dir" "codex" "$_CODEX_SENTINEL_START" "$_CODEX_SENTINEL_END" >> "$file"
  printf '[codex-adapter] wrote ai-suite block to %s\n' "$file"
}

agent_install_global() {
  local suite_dir="$1"
  local dest_dir="$HOME/.codex"
  local file="$dest_dir/AGENTS.md"
  mkdir -p "$dest_dir"

  agent_uninstall_global "$suite_dir" 2>/dev/null || true

  _mirror_skills "$suite_dir" "$dest_dir/skills" "codex"
  _mirror_meta "$suite_dir" "$dest_dir/meta"
  _mirror_templates "$suite_dir" "$dest_dir/templates" "codex"
  _mirror_scripts "$suite_dir" "$dest_dir/scripts" "codex"
  _mirror_directives "$suite_dir" "$dest_dir/directives" "codex"

  # Auto-initialize memory system
  mkdir -p ~/.ai-suite/memory/codex/tasks
  if [[ -f "$suite_dir/layer2-cognitive/memory/memory.sh" ]]; then
    SUITE_DIR="$suite_dir" source "$suite_dir/layer2-cognitive/memory/memory.sh"
    ai_memory_init "codex" 2>/dev/null || true
  fi

  generate_markdown_block "$suite_dir" "$dest_dir" "codex" "$_CODEX_SENTINEL_START" "$_CODEX_SENTINEL_END" >> "$file"
  printf '[codex-adapter] wrote ai-suite block to %s\n' "$file"
}

agent_uninstall_project() {
  local project_dir="$1"
  local suite_dir="${2:-}"
  local target_dir="$project_dir/.codex"
  remove_block_from_file "$project_dir/AGENTS.md" "$_CODEX_SENTINEL_START" "$_CODEX_SENTINEL_END"
  remove_block_from_file "$project_dir/.codexrules" "$_CODEX_SENTINEL_START" "$_CODEX_SENTINEL_END" 2>/dev/null || true
  _remove_skills "$target_dir/skills"
  _remove_meta "$target_dir/meta"
  _remove_templates "$target_dir/templates"
  _remove_scripts "$target_dir/scripts"
  _remove_directives "$target_dir/directives"

  if [[ -d "$target_dir" ]] && [[ -z "$(ls -A "$target_dir" 2>/dev/null)" ]]; then
    rmdir "$target_dir" 2>/dev/null || true
  fi
  printf '[codex-adapter] project uninstall done: %s\n' "$project_dir"
}

agent_uninstall_global() {
  local suite_dir="${1:-}"
  local dest_dir="$HOME/.codex"
  remove_block_from_file "$dest_dir/AGENTS.md" "$_CODEX_SENTINEL_START" "$_CODEX_SENTINEL_END"
  remove_block_from_file "$dest_dir/.codexrules" "$_CODEX_SENTINEL_START" "$_CODEX_SENTINEL_END" 2>/dev/null || true
  _remove_skills "$dest_dir/skills"
  _remove_meta "$dest_dir/meta"
  _remove_templates "$dest_dir/templates"
  _remove_scripts "$dest_dir/scripts"
  _remove_directives "$dest_dir/directives"

  if [[ -d "$dest_dir" ]] && [[ -z "$(ls -A "$dest_dir" 2>/dev/null)" ]]; then
    rmdir "$dest_dir" 2>/dev/null || true
  fi
  printf '[codex-adapter] global uninstall done\n'
}
