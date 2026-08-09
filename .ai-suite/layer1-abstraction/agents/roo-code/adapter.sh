#!/usr/bin/env bash
# .ai-suite/layer1-abstraction/agents/roo-code/adapter.sh — VS Code Roo Code adapter for ai-suite.
#
# Implements the standard adapter interface.

_ROO_SENTINEL_START='<!-- ai-suite:start -->'
_ROO_SENTINEL_END='<!-- ai-suite:end -->'

agent_install_project() {
  local suite_dir="$1" project_dir="$2"
  local file="$project_dir/.roorules"
  local target_dir="$project_dir/.roo"
  
  agent_uninstall_project "$project_dir" 2>/dev/null || true

  _mirror_skills "$suite_dir" "$target_dir/skills" "roo-code"
  _mirror_meta "$suite_dir" "$target_dir/meta"

  generate_markdown_block "$suite_dir" "$target_dir" "roo-code" "$_ROO_SENTINEL_START" "$_ROO_SENTINEL_END" >> "$file"
  printf '[roo-code-adapter] wrote ai-suite block to %s\n' "$file"
}

agent_install_global() {
  local suite_dir="$1"
  local dest_dir="$HOME/.roo"
  local file="$dest_dir/.roorules"
  mkdir -p "$dest_dir"

  agent_uninstall_global 2>/dev/null || true

  _mirror_skills "$suite_dir" "$dest_dir/skills" "roo-code"
  _mirror_meta "$suite_dir" "$dest_dir/meta"

  generate_markdown_block "$suite_dir" "$dest_dir" "roo-code" "$_ROO_SENTINEL_START" "$_ROO_SENTINEL_END" >> "$file"
  printf '[roo-code-adapter] wrote ai-suite block to %s\n' "$file"
}

agent_uninstall_project() {
  local project_dir="$1"
  local target_dir="$project_dir/.roo"
  remove_block_from_file "$project_dir/.roorules" "$_ROO_SENTINEL_START" "$_ROO_SENTINEL_END"
  _remove_skills "$target_dir/skills"
  _remove_meta "$target_dir/meta"
}

agent_uninstall_global() {
  local dest_dir="$HOME/.roo"
  remove_block_from_file "$dest_dir/.roorules" "$_ROO_SENTINEL_START" "$_ROO_SENTINEL_END"
  _remove_skills "$dest_dir/skills"
  _remove_meta "$dest_dir/meta"
}
