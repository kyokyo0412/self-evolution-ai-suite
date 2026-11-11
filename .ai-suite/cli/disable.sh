#!/usr/bin/env bash
# ai-suite disable -- Cleanly deactivate the .ai-suite/ multi-agent framework.
#
# Symmetric to ai-suite enable.
#
#   --scope project [--project PATH] [--agent cursor|claude|opencode|continue|roo-code|codex|all]
#       Remove the activation block / CLAUDE.md block from the project.
#
#   --scope global [--agent cursor|claude|opencode|continue|roo-code|codex|all]
#       Remove user-global install.
#
#   --scope remote --host USER@HOST [--remote-path PATH] [--remote-scope SCOPE]
#       ssh into the remote and run ai-suite disable there.
#       Default --remote-path:  $HOME/.ai-suite-deploy  (resolved on remote)
#       Default --remote-scope: global
#
#   --uninstall-hook
#       Remove the auto-enable hook from ~/.zshrc and/or ~/.bashrc.
#   --shell SHELL  auto | zsh | bash | both  (default auto).
#   --dry-run      Preview only.
#   --agent-root-alias PATH  Pin an existing global Cursor/Codex directory symlink.

set -euo pipefail

ORIGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$ORIGIN_DIR/../layer1-abstraction/runtime/layout.sh"
suite_resolve_layout "$ORIGIN_DIR"

# -- Core Library -------------------------------------------------------------
CORE_LIB="$SUITE_DIR/layer2-cognitive/memory/core.sh"
if [[ -f "$CORE_LIB" ]]; then
  # shellcheck source=.ai-suite/layer2-cognitive/memory/core.sh disable=SC1091
  source "$CORE_LIB"
else
  printf '[disable_suite][ERROR] missing %s\n' "$CORE_LIB" >&2; exit 2
fi

export AI_SUITE_LOG_PREFIX="disable_suite"

SCOPE="project"
AGENT="cursor"
PROJECT_PATH=""
HOST=""
# shellcheck disable=SC2016  # intentional: literal $HOME resolved on remote
REMOTE_PATH='$HOME/.ai-suite-deploy'
REMOTE_SCOPE="global"
export AI_SUITE_DRY_RUN=0
UNINSTALL_HOOK=0
SHELL_TARGETS="auto"
AI_SUITE_AGENT_ROOT_ALIAS=""

HOOK_MARK_START="### AI SUITE AUTO-ENABLE HOOK START ###"

usage() { sed -n '2,22p' "$0"; exit "${1:-0}"; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --scope)         SCOPE="${2:?--scope requires project|global|remote}"; shift 2 ;;
    --agent)         AGENT="${2:?--agent requires cursor|claude|opencode|continue|roo-code|codex|all}"; shift 2 ;;
    --project)       PROJECT_PATH="${2:?--project requires a path}"; shift 2 ;;
    --host)          HOST="${2:?--host requires user@host}"; shift 2 ;;
    --remote-path)   REMOTE_PATH="${2:?--remote-path requires a path}"; shift 2 ;;
    --remote-scope)  REMOTE_SCOPE="${2:?--remote-scope requires project|global}"; shift 2 ;;
    --agent-root-alias) AI_SUITE_AGENT_ROOT_ALIAS="${2:?--agent-root-alias requires a physical directory}"; shift 2 ;;
    --dry-run)       export AI_SUITE_DRY_RUN=1; shift ;;
    --uninstall-hook) UNINSTALL_HOOK=1; shift ;;
    --shell)         SHELL_TARGETS="${2:?--shell requires auto|zsh|bash|both}"; shift 2 ;;
    -h|--help)       usage 0 ;;
    *)               die "unknown argument: $1" 1 ;;
  esac
done

case "$AGENT" in
  cursor|claude|opencode|continue|roo-code|codex|all) ;;
  *) die "Unsupported agent: '$AGENT'. Valid: cursor | claude | opencode | continue | roo-code | codex | all" 1 ;;
esac

case "$SCOPE" in
  project|global|remote) ;;
  *) die "Unsupported scope: '$SCOPE'. Valid: project | global | remote" 1 ;;
esac
alias_scope="$SCOPE"
[[ "$SCOPE" != remote ]] || alias_scope="$REMOTE_SCOPE"
suite_validate_agent_root_alias "$AGENT" "$alias_scope" "$AI_SUITE_AGENT_ROOT_ALIAS" || exit 1

_load_adapter() {
  local name="$1"
  local adapter="$SUITE_DIR/layer1-abstraction/agents/$name/adapter.sh"
  [[ -f "$adapter" ]] || die "adapter not found: $adapter" 2
  # shellcheck disable=SC1090
  source "$adapter"
}

# -- Hook uninstall -----------------------------------------------------------
resolve_hook_targets() {
  case "$SHELL_TARGETS" in
    zsh)  echo "zsh" ;;
    bash) echo "bash" ;;
    both) echo "zsh bash" ;;
    auto)
      local result=""
      [[ -f "$HOME/.zshrc"  ]] && grep -qF "$HOOK_MARK_START" "$HOME/.zshrc"  2>/dev/null && result="$result zsh"
      [[ -f "$HOME/.bashrc" ]] && grep -qF "$HOOK_MARK_START" "$HOME/.bashrc" 2>/dev/null && result="$result bash"
      # shellcheck disable=SC2086
      echo "$result" ;;
    *) die "invalid --shell: $SHELL_TARGETS (auto|zsh|bash|both)" 1 ;;
  esac
}

_strip_hook_from() {
  local rc_file="$1"
  [[ -f "$rc_file" ]] || return 0
  if ! grep -qF "$HOOK_MARK_START" "$rc_file" 2>/dev/null; then
    log "no hook found in $rc_file -- skipping"; return 0
  fi
  [[ "$AI_SUITE_DRY_RUN" == "1" ]] && { printf '[dry-run] would strip hook from %s\n' "$rc_file"; return 0; }
  local kind
  case "$rc_file" in *.zshrc) kind=zsh ;; *) kind=bash ;; esac
  PYTHONDONTWRITEBYTECODE=1 python3 "$SUITE_DIR/layer1-abstraction/runtime/hooks.py" \
    remove "$kind" "$rc_file" "$SCRIPT_DIR/ai-suite"
  log "removed auto-enable hook from $rc_file"
}

if [[ "$UNINSTALL_HOOK" == "1" ]]; then
  targets="$(resolve_hook_targets)"
  for sh in $targets; do
    case "$sh" in
      zsh)  _strip_hook_from "$HOME/.zshrc" ;;
      bash) _strip_hook_from "$HOME/.bashrc" ;;
    esac
  done
  exit 0
fi

# -- Per-agent uninstall ------------------------------------------------------
do_uninstall_for_agent() {
  local agent_name="$1"
  _load_adapter "$agent_name"

  case "$SCOPE" in
    project)
      local target
      if [[ -n "$PROJECT_PATH" ]]; then
        [[ -d "$PROJECT_PATH" ]] || { warn "project path not found: $PROJECT_PATH"; return 0; }
        target="$(cd "$PROJECT_PATH" && pwd)"
      else
        target="$SCRIPT_DIR"
        [[ "$SUITE_DIR" != "$SCRIPT_DIR" ]] || target="$PWD"
      fi
      log "agent=$agent_name scope=project target=$target"
      if [[ "$AI_SUITE_DRY_RUN" == "1" ]]; then
        printf '[dry-run] would call agent_uninstall_project %s %s\n' "$target" "$SUITE_DIR"
      else
        agent_uninstall_project "$target" "$SUITE_DIR"
      fi
      ;;
    global)
      log "agent=$agent_name scope=global"
      if [[ "$AI_SUITE_DRY_RUN" == "1" ]]; then
        printf '[dry-run] would call agent_uninstall_global\n'
      else
        agent_uninstall_global "$SUITE_DIR"
      fi
      ;;
  esac
}

# -- Remote scope -------------------------------------------------------------
do_remote_scope() {
  [[ -n "$HOST" ]] || die "--scope remote requires --host USER@HOST" 1
  # shellcheck source=/dev/null
  source "$SUITE_DIR/layer1-abstraction/runtime/transport.sh"
  suite_validate_host "$HOST" && suite_validate_remote_path "$REMOTE_PATH" || return 1
  local remote_cmd
  remote_cmd=$(suite_remote_command "$REMOTE_PATH" disable "$REMOTE_SCOPE" "$AGENT" "$PROJECT_PATH" "" "$AI_SUITE_AGENT_ROOT_ALIAS") || return 1
  run suite_transport_exec ssh -o BatchMode=yes -o ConnectTimeout=15 "$HOST" "$remote_cmd"
}

# -- Dispatch -----------------------------------------------------------------
[[ "$AI_SUITE_DRY_RUN" == "1" ]] && log "** dry-run mode -- no changes will be written **"

if [[ "$SCOPE" == "remote" ]]; then
  do_remote_scope
else
  case "$AGENT" in
    cursor|claude|opencode|continue|roo-code|codex) do_uninstall_for_agent "$AGENT" ;;
    all)
      for a in cursor claude opencode continue roo-code codex; do
        do_uninstall_for_agent "$a"
      done ;;
  esac
fi
log "done."
