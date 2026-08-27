#!/usr/bin/env bash
set -euo pipefail
# .ai-suite/layer1-abstraction/agents/continue/adapter.sh -- VS Code Continue adapter for ai-suite.
#
# Implements the standard adapter interface.

_continue_content() {
  local suite_dir="$1"
  local target_dir="$2"

  cat <<HEADER
name: AI Suite
description: AI Suite framework skills
---
HEADER

  generate_markdown_block "$suite_dir" "$target_dir" "continue" "" ""
}

agent_install_project() {
  local suite_dir="$1" project_dir="$2"
  local dest_dir="$project_dir/.continue/prompts"
  local target_dir="$project_dir/.continue"
  mkdir -p "$dest_dir"
  local file="$dest_dir/ai-suite.prompt"
  
  _mirror_skills "$suite_dir" "$target_dir/skills" "continue"
  _mirror_meta "$suite_dir" "$target_dir/meta"

  _continue_content "$suite_dir" "$target_dir" > "$file"
  printf '[continue-adapter] wrote prompt to %s\n' "$file"
}

agent_install_global() {
  local suite_dir="$1"
  local dest_dir="$HOME/.continue/prompts"
  local target_dir="$HOME/.continue"
  mkdir -p "$dest_dir"
  local file="$dest_dir/ai-suite.prompt"

  _mirror_skills "$suite_dir" "$target_dir/skills" "continue"
  _mirror_meta "$suite_dir" "$target_dir/meta"

  _continue_content "$suite_dir" "$target_dir" > "$file"
  printf '[continue-adapter] wrote prompt to %s\n' "$file"
}

agent_uninstall_project() {
  local project_dir="$1"
  local target_dir="$project_dir/.continue"
  rm -f "$project_dir/.continue/prompts/ai-suite.prompt"
  _remove_skills "$target_dir/skills"
  _remove_meta "$target_dir/meta"
  if [[ -d "$project_dir/.continue/prompts" ]] && [[ -z "$(ls -A "$project_dir/.continue/prompts" 2>/dev/null)" ]]; then
    rmdir "$project_dir/.continue/prompts" 2>/dev/null || true
  fi
  if [[ -d "$target_dir" ]] && [[ -z "$(ls -A "$target_dir" 2>/dev/null)" ]]; then
    rmdir "$target_dir" 2>/dev/null || true
  fi
}

agent_uninstall_global() {
  local target_dir="$HOME/.continue"
  rm -f "$HOME/.continue/prompts/ai-suite.prompt"
  _remove_skills "$target_dir/skills"
  _remove_meta "$target_dir/meta"
  if [[ -d "$HOME/.continue/prompts" ]] && [[ -z "$(ls -A "$HOME/.continue/prompts" 2>/dev/null)" ]]; then
    rmdir "$HOME/.continue/prompts" 2>/dev/null || true
  fi
  if [[ -d "$target_dir" ]] && [[ -z "$(ls -A "$target_dir" 2>/dev/null)" ]]; then
    rmdir "$target_dir" 2>/dev/null || true
  fi
}
