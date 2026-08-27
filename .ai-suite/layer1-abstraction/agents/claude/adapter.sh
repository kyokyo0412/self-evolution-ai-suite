#!/usr/bin/env bash
set -euo pipefail
# .ai-suite/layer1-abstraction/agents/claude/adapter.sh -- Claude Code adapter for ai-suite.
#
# Sourced by ai-suite enable and ai-suite disable.
# Implements the standard adapter interface:
#   agent_install_project SUITE_DIR PROJECT_DIR
#   agent_install_global  SUITE_DIR
#   agent_uninstall_project PROJECT_DIR
#   agent_uninstall_global
#
# Claude Code reads CLAUDE.md files for project context.
# Project scope  -> PROJECT_DIR/CLAUDE.md
# Global scope   -> ~/.claude/CLAUDE.md

_CLAUDE_SENTINEL_START='<!-- ai-suite:start -->'
_CLAUDE_SENTINEL_END='<!-- ai-suite:end -->'

agent_install_project() {
  local suite_dir="$1" project_dir="$2"
  local claude_file="$project_dir/CLAUDE.md"
  local target_dir="$project_dir/.claude"

  # Remove existing block (idempotent)
  agent_uninstall_project "$project_dir" 2>/dev/null || true

  _mirror_skills "$suite_dir" "$target_dir/skills" "claude"
  _mirror_meta "$suite_dir" "$target_dir/meta"

  # Append the block
  generate_markdown_block "$suite_dir" "$target_dir" "claude" "$_CLAUDE_SENTINEL_START" "$_CLAUDE_SENTINEL_END" >> "$claude_file"
  printf '[claude-adapter] wrote ai-suite block to %s\n' "$claude_file"
}

agent_install_global() {
  local suite_dir="$1"
  local claude_dir="$HOME/.claude"
  local claude_file="$claude_dir/CLAUDE.md"
  mkdir -p "$claude_dir"

  agent_uninstall_global 2>/dev/null || true

  _mirror_skills "$suite_dir" "$claude_dir/skills" "claude"
  _mirror_meta "$suite_dir" "$claude_dir/meta"

  generate_markdown_block "$suite_dir" "$claude_dir" "claude" "$_CLAUDE_SENTINEL_START" "$_CLAUDE_SENTINEL_END" >> "$claude_file"
  printf '[claude-adapter] wrote ai-suite block to %s\n' "$claude_file"
}

agent_uninstall_project() {
  local project_dir="$1"
  local claude_file="$project_dir/CLAUDE.md"
  local target_dir="$project_dir/.claude"
  remove_block_from_file "$claude_file" "$_CLAUDE_SENTINEL_START" "$_CLAUDE_SENTINEL_END"
  _remove_skills "$target_dir/skills"
  _remove_meta "$target_dir/meta"
  if [[ -d "$target_dir" ]] && [[ -z "$(ls -A "$target_dir" 2>/dev/null)" ]]; then
    rmdir "$target_dir" 2>/dev/null || true
  fi
}

agent_uninstall_global() {
  local claude_dir="$HOME/.claude"
  local claude_file="$claude_dir/CLAUDE.md"
  remove_block_from_file "$claude_file" "$_CLAUDE_SENTINEL_START" "$_CLAUDE_SENTINEL_END"
  _remove_skills "$claude_dir/skills"
  _remove_meta "$claude_dir/meta"
  if [[ -d "$claude_dir" ]] && [[ -z "$(ls -A "$claude_dir" 2>/dev/null)" ]]; then
    rmdir "$claude_dir" 2>/dev/null || true
  fi
}
