#!/usr/bin/env bash
# .ai-suite/layer1-abstraction/agents/cursor/adapter.sh — Cursor IDE adapter for ai-suite.
#
# Sourced by ai-suite enable and ai-suite disable.
# Implements the standard adapter interface:
#   agent_install_project SUITE_DIR PROJECT_DIR
#   agent_install_global  SUITE_DIR
#   agent_uninstall_project PROJECT_DIR
#   agent_uninstall_global
#
# Cursor reads:
#   Project scope  → <project>/.cursorrules  +  <project>/.cursor/rules/*.mdc
#   Global scope   → ~/.cursor/skills/<name>/SKILL.md
#                    ~/.cursor/rules/*.mdc

# ── Helpers (safe to call even when already uninstalled) ─────────────────────

_CURSOR_BLOCK_START='# >>>>> cursor-ai-suite >>>>>'
_CURSOR_BLOCK_END='# <<<<< cursor-ai-suite <<<<<'

_cursorrules_path() { printf '%s/.cursorrules' "$1"; }
_cursor_rules_dir() { printf '%s/.cursor/rules' "$1"; }
_safety_rule_name="cursor-suite-production-safety.mdc"
_directives_rule_name="cursor-suite-agent-directives.mdc"
_step_action_visibility_rule_name="cursor-suite-step-action-visibility.mdc"
_interactive_workflow_rule_name="cursor-suite-interactive-workflow.mdc"

_deploy_registry_rules() {
  local rules_dir="$1" suite_dir="$2"
  mkdir -p "$rules_dir"
  
  # Deploy directives
  for src in "$suite_dir/layer3-registry/directives/"*.md; do
    [[ -f "$src" ]] || continue
    local filename
    filename=$(basename "$src" .md)
    local dst="$rules_dir/cursor-suite-${filename}.mdc"
    local desc
    desc=$(grep '^# ' "$src" | head -1 | sed 's/^# *//')
    [[ -z "$desc" ]] && desc="AI Suite Directive: $filename"
    {
      printf -- '---\ndescription: %s\nglobs: "*"\nalwaysApply: true\n---\n\n' "$desc"
      cat "$src"
    } > "$dst"
  done

  # Deploy safety
  for src in "$suite_dir/layer3-registry/safety/"*.md; do
    [[ -f "$src" ]] || continue
    local filename
    filename=$(basename "$src" .md)
    local dst="$rules_dir/cursor-suite-${filename}.mdc"
    local desc
    desc=$(grep '^# ' "$src" | head -1 | sed 's/^# *//')
    [[ -z "$desc" ]] && desc="AI Suite Safety: $filename"
    {
      printf -- '---\ndescription: %s\nglobs: "*"\nalwaysApply: true\n---\n\n' "$desc"
      cat "$src"
    } > "$dst"
  done
  
  # Deploy cursor specific rules
  for src in "$suite_dir/layer1-abstraction/agents/cursor/rules/"*.md; do
    [[ -f "$src" ]] || continue
    local filename
    filename=$(basename "$src" .md)
    local dst="$rules_dir/cursor-suite-${filename}.mdc"
    local desc
    desc=$(grep '^# ' "$src" | head -1 | sed 's/^# *//')
    [[ -z "$desc" ]] && desc="AI Suite Cursor Rule: $filename"
    {
      printf -- '---\ndescription: %s\nglobs: "*"\nalwaysApply: true\n---\n\n' "$desc"
      cat "$src"
    } > "$dst"
  done
}

_remove_registry_rules() {
  local rules_dir="$1"
  rm -f "$rules_dir"/cursor-suite-*.mdc
}

_append_cursorrules_block() {
  local cursorrules="$1" suite_dir="$2" project_dir="$3"
  local meta_dir="$project_dir/.cursor/meta"
  local core_skills_dir="$project_dir/.cursor/skills"
  cat >> "$cursorrules" <<BLOCK

$_CURSOR_BLOCK_START
## AI Suite — always active

Skills location: $core_skills_dir
Meta / protocols: $meta_dir

Before each task, check if a skill in the above directories matches the request.
Match on "Use when …" in each skill's description, then follow its instructions.

Reflection: When the user types "Run Reflection", "Reflect on the last task",
"Improve the suite", or "运行反思", follow the Reflection Protocol at:
$meta_dir/reflection-protocol.md

Proactive Resolution:
When you encounter an issue or are given a problem, you must proactively resolve it. Analyze the environment and the problem, devise a strategy, and attempt to implement it. If an initial attempt fails, explore alternative approaches from various angles. Engage in an iterative process of analysis, action, and experimentation until the problem is resolved, and report the details. These enhancements must not compromise existing mechanisms, such as the evolution system.
Never-Give-Up Spirit: When explicitly instructed not to give up on a task, you must persist—exhausting all possible solutions and making repeated attempts—to complete the assigned task. The single most critical constraint during this persistent execution is the absolute prohibition against damaging the production environment. Otherwise, it should run as normal mode.

Auto-Evolution Directive:
If a task required more than 1 attempt, or involved complex design changes, you MUST automatically execute the Reflection Protocol ($meta_dir/reflection-protocol.md) at the end of the task, without waiting for the user to ask.

CRITICAL RULE ENFORCEMENT:
You MUST strictly adhere to ALL rules defined in \`.cursor/rules/\` and \`~/.cursor/rules/\` (or any \`.mdc\` files). Before executing any task, you MUST review these rules and ensure your actions comply with them. Ignoring these rules is strictly prohibited.

Memory System:
The AI suite has a file-based memory system to store project indexes and task history.
When starting a task, review the project memory in .ai-memory/cursor/index/ and global history memory in ~/.ai-suite/memory/cursor/tasks/.
If you learn new facts or complete a task, update the memory using the bash functions in .ai-suite/layer2-cognitive/memory/memory.sh or by directly editing the files.
$_CURSOR_BLOCK_END
BLOCK
}

_append_cursorrules_global_block() {
  local suite_dir="$1"
  local cursorrules="$HOME/.cursorrules"
  local meta_dir="$HOME/.cursor/meta"
  local skills_dest="$HOME/.cursor/skills"

  [[ -f "$cursorrules" ]] || touch "$cursorrules"
  # Idempotent: remove any existing block before re-adding
  _remove_cursorrules_block "$cursorrules"
  cat >> "$cursorrules" <<BLOCK

$_CURSOR_BLOCK_START
## AI Suite — always active (global install)

Skills location: $skills_dest
Meta / protocols: $meta_dir

Before each task, check if a skill in the above directory matches the request.
Match on "Use when …" in each skill's SKILL.md description, then follow its instructions.

Reflection: When the user types "Run Reflection", "Reflect on the last task",
"Improve the suite", or "运行反思", follow the Reflection Protocol at:
$meta_dir/reflection-protocol.md

Proactive Resolution:
When you encounter an issue or are given a problem, you must proactively resolve it. Analyze the environment and the problem, devise a strategy, and attempt to implement it. If an initial attempt fails, explore alternative approaches from various angles. Engage in an iterative process of analysis, action, and experimentation until the problem is resolved, and report the details. These enhancements must not compromise existing mechanisms, such as the evolution system.
Never-Give-Up Spirit: When explicitly instructed not to give up on a task, you must persist—exhausting all possible solutions and making repeated attempts—to complete the assigned task. The single most critical constraint during this persistent execution is the absolute prohibition against damaging the production environment. Otherwise, it should run as normal mode.

Auto-Evolution Directive:
If a task required more than 1 attempt, or involved complex design changes, you MUST automatically execute the Reflection Protocol ($meta_dir/reflection-protocol.md) at the end of the task, without waiting for the user to ask.

CRITICAL RULE ENFORCEMENT:
You MUST strictly adhere to ALL rules defined in \`.cursor/rules/\` and \`~/.cursor/rules/\` (or any \`.mdc\` files). Before executing any task, you MUST review these rules and ensure your actions comply with them. Ignoring these rules is strictly prohibited.

Memory System:
The AI suite has a file-based memory system to store project indexes and task history.
When starting a task, review the project memory in .ai-memory/cursor/index/ and global history memory in ~/.ai-suite/memory/cursor/tasks/.
If you learn new facts or complete a task, update the memory using the bash functions in .ai-suite/layer2-cognitive/memory/memory.sh or by directly editing the files.
$_CURSOR_BLOCK_END
BLOCK
}

_remove_cursorrules_block() {
  local cursorrules="$1"
  remove_block_from_file "$cursorrules" "$_CURSOR_BLOCK_START" "$_CURSOR_BLOCK_END"
}


# ── Adapter interface ─────────────────────────────────────────────────────────

agent_install_project() {
  local suite_dir="$1" project_dir="$2"
  local cursorrules; cursorrules=$(_cursorrules_path "$project_dir")
  local rules_dir; rules_dir=$(_cursor_rules_dir "$project_dir")
  local skills_dest="$project_dir/.cursor/skills"
  local meta_dest="$project_dir/.cursor/meta"

  # Ensure .cursorrules is a file (not a stray directory)
  if [[ -d "$cursorrules" ]]; then
    if [[ -z "$(ls -A "$cursorrules")" ]]; then
      rm -rf "$cursorrules"
    else
      printf '[cursor-adapter] ERROR: %s is a non-empty directory\n' "$cursorrules" >&2
      return 1
    fi
  fi
  [[ -f "$cursorrules" ]] || touch "$cursorrules"

  # Remove existing block first (idempotent)
  _remove_cursorrules_block "$cursorrules"
  _append_cursorrules_block "$cursorrules" "$suite_dir" "$project_dir"
  _deploy_registry_rules "$rules_dir" "$suite_dir"
  
  # Mirror skills and meta to project .cursor
  _mirror_skills "$suite_dir" "$skills_dest" "cursor"
  _mirror_templates "$suite_dir" "$project_dir/.cursor/templates" "cursor"
  _mirror_scripts "$suite_dir" "$project_dir/.cursor/scripts" "cursor"
  _mirror_meta "$suite_dir" "$meta_dest"
  _mirror_rules "$suite_dir" "$rules_dir" "cursor"

  # Auto-initialize memory system
  if [[ -f "$suite_dir/layer2-cognitive/memory/memory.sh" ]]; then
    SUITE_DIR="$suite_dir" source "$suite_dir/layer2-cognitive/memory/memory.sh"
    ai_memory_init "cursor"
  fi

  printf '[cursor-adapter] project install done: %s\n' "$project_dir"
}

agent_install_global() {
  local suite_dir="$1"
  local skills_dest="$HOME/.cursor/skills"
  local meta_dest="$HOME/.cursor/meta"

  # Mirror skills and meta
  _mirror_skills "$suite_dir" "$skills_dest" "cursor"
  _mirror_templates "$suite_dir" "$HOME/.cursor/templates" "cursor"
  _mirror_scripts "$suite_dir" "$HOME/.cursor/scripts" "cursor"
  _mirror_meta "$suite_dir" "$meta_dest"
  _mirror_rules "$suite_dir" "$HOME/.cursor/rules" "cursor"

  # Write global ~/.cursorrules block so the AI knows about the suite
  _append_cursorrules_global_block "$suite_dir"

  # Deploy production-safety rule globally
  local global_rules_dir="$HOME/.cursor/rules"
  _deploy_registry_rules "$global_rules_dir" "$suite_dir"

  # Auto-initialize memory system
  if [[ -f "$suite_dir/layer2-cognitive/memory/memory.sh" ]]; then
    SUITE_DIR="$suite_dir" source "$suite_dir/layer2-cognitive/memory/memory.sh"
    ai_memory_init "cursor"
  fi

  printf '[cursor-adapter] global install done\n'
}

agent_uninstall_project() {
  local project_dir="$1"
  local suite_dir="$2"
  local cursorrules; cursorrules=$(_cursorrules_path "$project_dir")
  local rules_dir; rules_dir=$(_cursor_rules_dir "$project_dir")
  local skills_dest="$project_dir/.cursor/skills"
  local meta_dest="$project_dir/.cursor/meta"

  _remove_cursorrules_block "$cursorrules"
  _remove_registry_rules "$rules_dir"
  
  _remove_skills "$skills_dest"
  _remove_meta "$meta_dest"
  _remove_rules "$rules_dir" "$suite_dir"
  
  if [[ -d "$project_dir/.cursor/templates" ]]; then rm -rf "$project_dir/.cursor/templates"; fi
  if [[ -d "$project_dir/.cursor/scripts" ]]; then rm -rf "$project_dir/.cursor/scripts"; fi
  
  # Clean up empty .cursor/rules, .cursor/skills, .cursor/meta, and .cursor dirs
  if [[ -d "$skills_dest" ]] && [[ -z "$(ls -A "$skills_dest" 2>/dev/null)" ]]; then
    rmdir "$skills_dest" 2>/dev/null || true
  fi
  if [[ -d "$meta_dest" ]] && [[ -z "$(ls -A "$meta_dest" 2>/dev/null)" ]]; then
    rmdir "$meta_dest" 2>/dev/null || true
  fi
  if [[ -d "$rules_dir" ]] && [[ -z "$(ls -A "$rules_dir" 2>/dev/null)" ]]; then
    rmdir "$rules_dir" 2>/dev/null || true
  fi
  local cursor_dir="$project_dir/.cursor"
  if [[ -d "$cursor_dir" ]] && [[ -z "$(ls -A "$cursor_dir" 2>/dev/null)" ]]; then
    rmdir "$cursor_dir" 2>/dev/null || true
  fi

  printf '[cursor-adapter] project uninstall done: %s\n' "$project_dir"
}

agent_uninstall_global() {
  local suite_dir="${1:-}"
  local skills_dest="$HOME/.cursor/skills"
  local meta_dest="$HOME/.cursor/meta"
  
  _remove_skills "$skills_dest"
  _remove_meta "$meta_dest"
  _remove_rules "$HOME/.cursor/rules" "$suite_dir"
  if [[ -d "$HOME/.cursor/templates" ]]; then rm -rf "$HOME/.cursor/templates"; fi
  if [[ -d "$HOME/.cursor/scripts" ]]; then rm -rf "$HOME/.cursor/scripts"; fi
  
  # Remove the global ~/.cursorrules block
  local global_cr="$HOME/.cursorrules"
  [[ -f "$global_cr" ]] && _remove_cursorrules_block "$global_cr"
  _remove_registry_rules "$HOME/.cursor/rules"
  printf '[cursor-adapter] global uninstall done\n'
}
