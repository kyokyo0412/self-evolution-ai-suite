#!/usr/bin/env bash
# Shared adapter lifecycle. All mutations pass through managed_artifacts.py.

_suite_agent_layout() {
  local agent="$1" scope="$2"
  case "$agent" in
    cursor) SUITE_AGENT_DIR=.cursor; SUITE_INSTRUCTION=.cursorrules ;;
    claude) SUITE_AGENT_DIR=.claude; SUITE_INSTRUCTION=CLAUDE.md ;;
    codex) SUITE_AGENT_DIR=.codex; SUITE_INSTRUCTION=AGENTS.md ;;
    continue) SUITE_AGENT_DIR=.continue; SUITE_INSTRUCTION=.continue/prompts/ai-suite.prompt ;;
    roo-code) SUITE_AGENT_DIR=.roo; SUITE_INSTRUCTION=.roorules ;;
    opencode) SUITE_AGENT_DIR=.opencode; SUITE_INSTRUCTION=.opencode/instructions.md ;;
    *) printf '[lifecycle] ERROR: unsupported agent %s\n' "$agent" >&2; return 1 ;;
  esac
  if [[ "$scope" == global ]]; then
    case "$agent" in
      claude) SUITE_INSTRUCTION=.claude/CLAUDE.md ;;
      codex) SUITE_INSTRUCTION=.codex/AGENTS.md ;;
      roo-code) SUITE_INSTRUCTION=.roo/.roorules ;;
      opencode) SUITE_AGENT_DIR=.config/opencode; SUITE_INSTRUCTION=.config/opencode/instructions.md ;;
    esac
  fi
  SUITE_BLOCK_START='<!-- ai-suite:start -->'
  SUITE_BLOCK_END='<!-- ai-suite:end -->'
  if [[ "$agent" == cursor ]]; then
    SUITE_BLOCK_START='# >>>>> cursor-ai-suite >>>>>'
    SUITE_BLOCK_END='# <<<<< cursor-ai-suite <<<<<'
  fi
}

_suite_stage_agent() {
  local suite="$1" stage="$2" agent="$3"
  local target="$stage/$SUITE_AGENT_DIR"
  _mirror_skills "$suite" "$target/skills" "$agent" || return
  _mirror_meta "$suite" "$target/meta" || return
  _mirror_templates "$suite" "$target/templates" "$agent" || return
  _mirror_scripts "$suite" "$target/scripts" "$agent" || return
  if [[ "$agent" == cursor ]]; then
    _deploy_registry_rules "$target/rules" "$suite" || return
  elif [[ "$agent" == codex ]]; then
    _mirror_directives "$suite" "$target/directives" "$agent" || return
  fi
}

_suite_instruction() {
  local suite="$1" target="$2" agent="$3"
  if [[ "$agent" == continue ]]; then
    printf 'name: AI Suite\ndescription: AI Suite framework skills\n---\n'
  fi
  generate_markdown_block "$suite" "$target" "$agent" "$SUITE_BLOCK_START" "$SUITE_BLOCK_END"
}

_suite_artifact_command() {
  local action="$1" root="$2"; shift 2
  python3 -B "$_AI_SUITE_RUNTIME_DIR/managed_artifacts.py" "$action" \
    --root "$root" --manifest "$SUITE_AGENT_DIR/.ai-suite-manifest.json" \
    --start "$SUITE_BLOCK_START" --end "$SUITE_BLOCK_END" "$@"
}

_suite_preflight_memory() {
  local suite="$1" agent="$2" scope="$3" root="$4"
  if [[ -z "${AI_MEMORY_PROJECT_DIR:-}" ]]; then
    python3 -B "$_AI_SUITE_RUNTIME_DIR/managed_blocks.py" --check-path "$root" .ai-memory || return
  fi
  if [[ -z "${AI_MEMORY_GLOBAL_DIR:-}" ]]; then
    python3 -B "$_AI_SUITE_RUNTIME_DIR/managed_blocks.py" --check-path "$HOME" .ai-suite/memory || return
  fi
  export AI_MEMORY_PROJECT_DIR="${AI_MEMORY_PROJECT_DIR:-$root/.ai-memory}"
  export AI_MEMORY_GLOBAL_DIR="${AI_MEMORY_GLOBAL_DIR:-$HOME/.ai-suite/memory}"
  # shellcheck source=/dev/null
  source "$suite/layer2-cognitive/memory/memory.sh"
  ai_memory_validate_roots "$agent" "$scope"
}

_suite_apply_install() {
  local suite="$1" root="$2" agent="$3" scope="$4" temporary="$5"
  # shellcheck disable=SC2016 # Positional arguments expand in the child Bash process.
  _suite_artifact_command install "$root" --stage "$temporary/stage" \
    --instruction "$SUITE_INSTRUCTION" --block "$temporary/block" \
    --post-command bash -c 'source "$1"; if [[ "$2" == global ]]; then ai_memory_init_global "$3"; else ai_memory_init "$3"; fi' \
    suite-memory "$suite/layer2-cognitive/memory/memory.sh" "$scope" "$agent"
}

suite_agent_install() (
  set -euo pipefail
  local agent="$1" suite="$2" scope="$3" root="$4"
  command -v python3 >/dev/null || { printf '[lifecycle] ERROR: Python 3 is required\n' >&2; exit 1; }
  _suite_agent_layout "$agent" "$scope"
  if [[ "${AI_SUITE_DRY_RUN:-0}" == 1 ]]; then
    printf '[dry-run] would install managed %s artifacts in %s\n' "$agent" "$root"
    exit 0
  fi
  suite_registry_validate "$suite" "$agent"
  _suite_preflight_memory "$suite" "$agent" "$scope" "$root"
  SUITE_INSTALL_TEMP=$(mktemp -d "${TMPDIR:-/tmp}/suite-install.XXXXXX")
  trap 'rm -rf "$SUITE_INSTALL_TEMP"' EXIT
  mkdir "$SUITE_INSTALL_TEMP/stage"
  _suite_stage_agent "$suite" "$SUITE_INSTALL_TEMP/stage" "$agent" "$root" >&2
  _suite_instruction "$suite" "$root/$SUITE_AGENT_DIR" "$agent" > "$SUITE_INSTALL_TEMP/block"
  _suite_apply_install "$suite" "$root" "$agent" "$scope" "$SUITE_INSTALL_TEMP"
  printf '[%s-adapter] %s install done: %s\n' "$agent" "$scope" "$root"
)

suite_agent_uninstall() (
  set -euo pipefail
  local agent="$1" scope="$2" root="$3"
  command -v python3 >/dev/null || { printf '[lifecycle] ERROR: Python 3 is required\n' >&2; exit 1; }
  _suite_agent_layout "$agent" "$scope"
  if [[ "${AI_SUITE_DRY_RUN:-0}" == 1 ]]; then
    printf '[dry-run] would remove owned %s artifacts in %s\n' "$agent" "$root"
    exit 0
  fi
  _suite_artifact_command remove "$root"
  _suite_legacy_notice "$agent" "$root"
  printf '[%s-adapter] %s uninstall done: %s\n' "$agent" "$scope" "$root"
)

_suite_legacy_notice() {
  local agent="$1" root="$2" legacy=''
  case "$agent" in
    codex) legacy="$root/.codexrules" ;;
    opencode) legacy="$root/.opencode.md" ;;
  esac
  if [[ -n "$legacy" && -e "$legacy" ]]; then
    printf '[lifecycle] retaining unowned legacy instructions for explicit migration: %s\n' "$legacy" >&2
  fi
}

remove_block_from_file() {
  python3 -B "$_AI_SUITE_RUNTIME_DIR/managed_blocks.py" "$@"
}

# Legacy removal APIs conservatively retain destinations without ownership data.
_remove_unowned_destination() {
  [[ ! -e "$1" ]] || printf '[lifecycle] retaining unowned legacy destination: %s\n' "$1" >&2
}

_remove_skills() { _remove_unowned_destination "$1"; }
_remove_rules() { _remove_unowned_destination "$1"; }
_remove_directives() { _remove_unowned_destination "$1"; }
_remove_templates() { _remove_unowned_destination "$1"; }
_remove_scripts() { _remove_unowned_destination "$1"; }
_remove_meta() { _remove_unowned_destination "$1"; }
