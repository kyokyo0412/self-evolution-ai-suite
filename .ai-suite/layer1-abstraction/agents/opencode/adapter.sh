#!/usr/bin/env bash
set -euo pipefail
# .ai-suite/layer1-abstraction/agents/opencode/adapter.sh -- OpenCode adapter for ai-suite.
#
# Implements the standard adapter interface:
#   agent_install_project SUITE_DIR PROJECT_DIR
#   agent_install_global  SUITE_DIR
#   agent_uninstall_project PROJECT_DIR
#   agent_uninstall_global

_OPENCODE_SENTINEL_START='<!-- ai-suite:start -->'
_OPENCODE_SENTINEL_END='<!-- ai-suite:end -->'

agent_install_project() {
  local suite_dir="$1" project_dir="$2"
  local target_dir="$project_dir/.opencode"
  local file="$target_dir/instructions.md"
  
  agent_uninstall_project "$project_dir" 2>/dev/null || true

  mkdir -p "$target_dir"
  _mirror_skills "$suite_dir" "$target_dir/skills" "opencode"
  _mirror_meta "$suite_dir" "$target_dir/meta"
  _mirror_templates "$suite_dir" "$target_dir/templates" "opencode"
  _mirror_scripts "$suite_dir" "$target_dir/scripts" "opencode"

  generate_markdown_block "$suite_dir" "$target_dir" "opencode" "$_OPENCODE_SENTINEL_START" "$_OPENCODE_SENTINEL_END" >> "$file"
  printf '[opencode-adapter] wrote ai-suite block to %s\n' "$file"
}

agent_install_global() {
  local suite_dir="$1"
  local dest_dir="$HOME/.config/opencode"
  local file="$dest_dir/instructions.md"
  mkdir -p "$dest_dir"

  agent_uninstall_global 2>/dev/null || true

  _mirror_skills "$suite_dir" "$dest_dir/skills" "opencode"
  _mirror_meta "$suite_dir" "$dest_dir/meta"
  _mirror_templates "$suite_dir" "$dest_dir/templates" "opencode"
  _mirror_scripts "$suite_dir" "$dest_dir/scripts" "opencode"

  generate_markdown_block "$suite_dir" "$dest_dir" "opencode" "$_OPENCODE_SENTINEL_START" "$_OPENCODE_SENTINEL_END" >> "$file"
  printf '[opencode-adapter] wrote ai-suite block to %s\n' "$file"
}

agent_uninstall_project() {
  local project_dir="$1"
  local target_dir="$project_dir/.opencode"
  remove_block_from_file "$target_dir/instructions.md" "$_OPENCODE_SENTINEL_START" "$_OPENCODE_SENTINEL_END"
  _remove_skills "$target_dir/skills"
  _remove_meta "$target_dir/meta"
  _remove_templates "$target_dir/templates"
  _remove_scripts "$target_dir/scripts"
  
  # Clean up legacy path
  remove_block_from_file "$project_dir/.opencode.md" "$_OPENCODE_SENTINEL_START" "$_OPENCODE_SENTINEL_END" 2>/dev/null || true
  if [[ -d "$target_dir" ]] && [[ -z "$(ls -A "$target_dir" 2>/dev/null)" ]]; then
    rmdir "$target_dir" 2>/dev/null || true
  fi
}

agent_uninstall_global() {
  local dest_dir="$HOME/.config/opencode"
  remove_block_from_file "$dest_dir/instructions.md" "$_OPENCODE_SENTINEL_START" "$_OPENCODE_SENTINEL_END"
  _remove_skills "$dest_dir/skills"
  _remove_meta "$dest_dir/meta"
  _remove_templates "$dest_dir/templates"
  _remove_scripts "$dest_dir/scripts"
  
  # Also try to clean up legacy path if it exists
  local legacy_dir="$HOME/.opencode"
  remove_block_from_file "$legacy_dir/instructions.md" "$_OPENCODE_SENTINEL_START" "$_OPENCODE_SENTINEL_END" 2>/dev/null || true
  _remove_skills "$legacy_dir/skills" 2>/dev/null || true
  _remove_meta "$legacy_dir/meta" 2>/dev/null || true
  _remove_templates "$legacy_dir/templates" 2>/dev/null || true
  _remove_scripts "$legacy_dir/scripts" 2>/dev/null || true
}
