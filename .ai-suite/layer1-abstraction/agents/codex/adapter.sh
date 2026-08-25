#!/usr/bin/env bash
set -euo pipefail
# .ai-suite/layer1-abstraction/agents/codex/adapter.sh — Codex adapter for ai-suite.
#
# Implements the standard adapter interface.

_CODEX_SENTINEL_START='<!-- ai-suite:start -->'
_CODEX_SENTINEL_END='<!-- ai-suite:end -->'

agent_install_project() {
  local suite_dir="$1" project_dir="$2"
  local file="$project_dir/.codexrules"
  local target_dir="$project_dir/.codex"
  
  agent_uninstall_project "$project_dir" 2>/dev/null || true

  _mirror_skills "$suite_dir" "$target_dir/skills" "codex"
  _mirror_meta "$suite_dir" "$target_dir/meta"

  generate_markdown_block "$suite_dir" "$target_dir" "codex" "$_CODEX_SENTINEL_START" "$_CODEX_SENTINEL_END" >> "$file"
  printf '[codex-adapter] wrote ai-suite block to %s\n' "$file"
}

agent_install_global() {
  local suite_dir="$1"
  local dest_dir="$HOME/.codex"
  local file="$dest_dir/.codexrules"
  mkdir -p "$dest_dir"

  agent_uninstall_global 2>/dev/null || true

  _mirror_skills "$suite_dir" "$dest_dir/skills" "codex"
  _mirror_meta "$suite_dir" "$dest_dir/meta"

  generate_markdown_block "$suite_dir" "$dest_dir" "codex" "$_CODEX_SENTINEL_START" "$_CODEX_SENTINEL_END" >> "$file"
  printf '[codex-adapter] wrote ai-suite block to %s\n' "$file"
}

agent_uninstall_project() {
  local project_dir="$1"
  local target_dir="$project_dir/.codex"
  remove_block_from_file "$project_dir/.codexrules" "$_CODEX_SENTINEL_START" "$_CODEX_SENTINEL_END"
  _remove_skills "$target_dir/skills"
  _remove_meta "$target_dir/meta"
}

agent_uninstall_global() {
  local dest_dir="$HOME/.codex"
  remove_block_from_file "$dest_dir/.codexrules" "$_CODEX_SENTINEL_START" "$_CODEX_SENTINEL_END"
  _remove_skills "$dest_dir/skills"
  _remove_meta "$dest_dir/meta"
}
