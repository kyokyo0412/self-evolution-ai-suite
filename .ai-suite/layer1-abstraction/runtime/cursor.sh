#!/usr/bin/env bash
# Cursor-specific rule rendering; other adapters never receive interactive rules.
_CURSOR_BLOCK_START='# >>>>> cursor-ai-suite >>>>>'
_CURSOR_BLOCK_END='# <<<<< cursor-ai-suite <<<<<'

_cursorrules_path() { printf '%s/.cursorrules' "$1"; }
_cursor_rules_dir() { printf '%s/.cursor/rules' "$1"; }

_deploy_cursor_rule_directory() {
  local source_dir="$1" rules_dir="$2" source_file filename description always_apply
  [[ -d "$source_dir" ]] || return 0
  for source_file in "$source_dir"/*.md; do
    [[ -f "$source_file" ]] || continue
    filename=$(basename "$source_file" .md)
    description=$(sed -n 's/^# *//p' "$source_file" | head -1)
    always_apply=false
    case "$filename" in
      agent-directives|primary-rule|production-safety|interactive-workflow) always_apply=true ;;
    esac
    if [[ -e "$rules_dir/cursor-suite-${filename}.mdc" ]]; then
      printf '[cursor] ERROR: rule destination collision: %s\n' "$filename" >&2
      return 1
    fi
    {
      printf -- '---\ndescription: %s\nglobs: ""\nalwaysApply: %s\n---\n\n' "$description" "$always_apply"
      cat "$source_file"
    } > "$rules_dir/cursor-suite-${filename}.mdc"
  done
}

_deploy_registry_rules() {
  local rules_dir="$1" suite="$2" relative domain source_file
  mkdir -p "$rules_dir"
  for relative in layer3-registry/directives layer3-registry/safety \
    layer1-abstraction/agents/cursor/rules; do
    _deploy_cursor_rule_directory "$suite/$relative" "$rules_dir"
  done
  for domain in "$suite"/layer3-registry/domains/*; do
    [[ -d "$domain" ]] || continue
    [[ -z "${AI_SUITE_DOMAIN:-}" || "$(basename "$domain")" == "$AI_SUITE_DOMAIN" ]] || continue
    for source_file in "$domain/rules/"*; do
      [[ -f "$source_file" ]] || continue
      _suite_copy_resource "$source_file" "$rules_dir/$(basename "$source_file")" || return
    done
  done
}

_remove_registry_rules() { _remove_unowned_destination "$1"; }
_remove_cursorrules_block() {
  remove_block_from_file "$1" "$_CURSOR_BLOCK_START" "$_CURSOR_BLOCK_END"
}
_append_cursorrules_block() {
  generate_markdown_block "$2" "$3/.cursor" cursor "$_CURSOR_BLOCK_START" "$_CURSOR_BLOCK_END" >> "$1"
}
_append_cursorrules_global_block() {
  generate_markdown_block "$1" "$HOME/.cursor" cursor "$_CURSOR_BLOCK_START" "$_CURSOR_BLOCK_END" >> "$HOME/.cursorrules"
}

