#!/usr/bin/env bash
# ai-suite enable -- Activate the .ai-suite/ multi-agent AI framework.
#
# Three install scopes:
#
#   --scope project  (DEFAULT)
#       Install into THIS workspace (the directory containing this script),
#       or override target with: --project /path/to/repo
#
#   --scope global
#       Install user-globally on THIS machine.
#
#   --scope remote  --host USER@HOST  [--remote-path PATH]  [--remote-scope SCOPE]
#       Deploy to a remote SSH host.
#       Default --remote-path:  $HOME/.ai-suite-deploy  (resolved on remote)
#       Default --remote-scope: global
#
# Agent flags:
#   --agent AGENT    cursor (default) | claude | opencode | continue | roo-code | codex | all
#                    cursor: writes .cursorrules + ~/.cursor/skills/
#                    claude: writes CLAUDE.md
#                    opencode: writes .opencode/instructions.md
#                    continue: writes .continue/prompts/ai-suite.prompt
#                    roo-code: writes .roorules
#                    all:    all supported agents
#
# Common flags:
#   --dry-run         Show what would happen; mutate nothing.
#   --verify          Lint all skill directories and exit.
#   --install-hook    Install a shell auto-enable hook (~/.zshrc / ~/.bashrc).
#   --shell SHELL     auto (default) | zsh | bash | both.
#   --uninstall       Delegate to ai-suite disable (forwards all flags).
#   -h | --help       Print this help.
#
# Portability: macOS (BSD tools) and Linux (GNU tools). Helpers in
# .ai-suite/layer1-abstraction/_portable.sh handles BSD/GNU tool differences.

set -euo pipefail

ORIGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$ORIGIN_DIR/../layer1-abstraction/runtime/layout.sh"
suite_resolve_layout "$ORIGIN_DIR"
META_DIR="$SUITE_DIR/layer4-evolutionary/validation"

# -- Core Library -------------------------------------------------------------
CORE_LIB="$SUITE_DIR/layer2-cognitive/memory/core.sh"
if [[ -f "$CORE_LIB" ]]; then
  # shellcheck source=.ai-suite/layer2-cognitive/memory/core.sh disable=SC1091
  source "$CORE_LIB"
else
  printf '[enable_suite][ERROR] missing %s\n' "$CORE_LIB" >&2; exit 2
fi

export AI_SUITE_LOG_PREFIX="enable_suite"

# -- Defaults -----------------------------------------------------------------
SCOPE="project"
AGENT="cursor"
PROJECT_PATH=""
HOST=""
# shellcheck disable=SC2016  # intentional: literal $HOME resolved on remote
REMOTE_PATH='$HOME/.ai-suite-deploy'
REMOTE_SCOPE="global"
export AI_SUITE_DRY_RUN=0
VERIFY=0
INSTALL_HOOK=0
SHELL_TARGETS="auto"
UNINSTALL=0
SYNC="rsync"

usage() { sed -n '2,36p' "$0"; exit "${1:-0}"; }

# -- Parse flags --------------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --scope)        SCOPE="${2:?--scope requires project|global|remote}"; shift 2 ;;
    --agent)        AGENT="${2:?--agent requires cursor|claude|opencode|continue|roo-code|codex|all}"; shift 2 ;;
    --project)      PROJECT_PATH="${2:?--project requires a path}"; shift 2 ;;
    --host)         HOST="${2:?--host requires user@host}"; shift 2 ;;
    --remote-path)  REMOTE_PATH="${2:?--remote-path requires a path}"; shift 2 ;;
    --remote-scope) REMOTE_SCOPE="${2:?--remote-scope requires project|global}"; shift 2 ;;
    --domain)       export AI_SUITE_DOMAIN="${2:?--domain requires a domain name}"; shift 2 ;;
    --dry-run)      export AI_SUITE_DRY_RUN=1; shift ;;
    --verify)       VERIFY=1; shift ;;
    --install-hook) INSTALL_HOOK=1; shift ;;
    --sync)         SYNC="${2:?--sync requires rsync|scp}"; shift 2 ;;
    --shell)        SHELL_TARGETS="${2:?--shell requires auto|zsh|bash|both}"; shift 2 ;;
    --uninstall)    UNINSTALL=1; shift ;;
    -h|--help)      usage 0 ;;
    *)              die "unknown argument: $1" 1 ;;
  esac
done

# -- Validate agent -----------------------------------------------------------
case "$AGENT" in
  cursor|claude|opencode|continue|roo-code|codex|all) ;;
  *) die "Unsupported agent: '$AGENT'. Valid: cursor | claude | opencode | continue | roo-code | codex | all" 1 ;;
esac

case "$SCOPE" in
  project|global|remote) ;;
  *) die "Unsupported scope: '$SCOPE'. Valid: project | global | remote" 1 ;;
esac

# -- Preflight ----------------------------------------------------------------
[[ -d "$SUITE_DIR" ]] || die "missing $SUITE_DIR -- is .ai-suite/ next to this script?" 2

# -- Source adapters ----------------------------------------------------------
_load_adapter() {
  local name="$1"
  local adapter="$SUITE_DIR/layer1-abstraction/agents/$name/adapter.sh"
  [[ -f "$adapter" ]] || die "adapter not found: $adapter" 2
  # shellcheck disable=SC1090
  source "$adapter"
}

# -- Verify -------------------------------------------------------------------
if [[ "$VERIFY" == "1" ]]; then
  exec bash "$META_DIR/validate-suite.sh"
fi

# -- Uninstall ----------------------------------------------------------------
if [[ "$UNINSTALL" == "1" ]]; then
  args=( --scope "$SCOPE" --agent "$AGENT" )
  [[ -n "$PROJECT_PATH" ]]     && args+=( --project "$PROJECT_PATH" )
  [[ -n "$HOST" ]]             && args+=( --host "$HOST" --remote-path "$REMOTE_PATH" --remote-scope "$REMOTE_SCOPE" )
  [[ "$SHELL_TARGETS" != auto ]] && args+=( --shell "$SHELL_TARGETS" )
  [[ "$AI_SUITE_DRY_RUN" == "1" ]]          && args+=( --dry-run )
  exec bash "$SCRIPT_DIR/ai-suite" disable "${args[@]}"
fi

# -- Hook install (early exit) ------------------------------------------------
resolve_shell_targets() {
  case "$SHELL_TARGETS" in
    zsh)  echo "zsh" ;;
    bash) echo "bash" ;;
    both) echo "zsh bash" ;;
    auto)
      local result=""
      [[ -f "$HOME/.zshrc"  ]] && result="$result zsh"
      [[ -f "$HOME/.bashrc" ]] && result="$result bash"
      if [[ -z "$result" ]]; then
        case "${SHELL##*/}" in
          zsh)  result="zsh" ;;
          bash) result="bash" ;;
          *)    result="zsh bash" ;;
        esac
      fi
      # shellcheck disable=SC2086
      echo "$result" ;;
    *) die "invalid --shell: $SHELL_TARGETS (auto|zsh|bash|both)" 1 ;;
  esac
}

install_hook_in() {
  local shell_kind="$1" rc_file="$2"
  if [[ "$AI_SUITE_DRY_RUN" == 1 ]]; then
    printf '[dry-run] would install %s hook in %s\n' "$shell_kind" "$rc_file"
    return 0
  fi
  PYTHONDONTWRITEBYTECODE=1 python3 "$SUITE_DIR/layer1-abstraction/runtime/hooks.py" \
    install "$shell_kind" "$rc_file" "$SCRIPT_DIR/ai-suite"
}

if [[ "$INSTALL_HOOK" == "1" ]]; then
  targets="$(resolve_shell_targets)"
  for sh in $targets; do
    case "$sh" in
      zsh)  install_hook_in zsh  "$HOME/.zshrc" ;;
      bash) install_hook_in bash "$HOME/.bashrc" ;;
    esac
  done
  exit 0
fi

# -- Per-agent install helpers ------------------------------------------------
do_install_for_agent() {
  local agent_name="$1"
  _load_adapter "$agent_name"

  case "$SCOPE" in
    project)
      local target
      if [[ -n "$PROJECT_PATH" ]]; then
        [[ -d "$PROJECT_PATH" ]] || die "project path not found: $PROJECT_PATH" 2
        target="$(cd "$PROJECT_PATH" && pwd)"
      else
        target="$SCRIPT_DIR"
        [[ "$SUITE_DIR" != "$SCRIPT_DIR" ]] || target="$PWD"
      fi
      
      # Isolation check: Do not install into the AI suite source repository itself
      if [[ -d "$target/.ai-suite/layer4-evolutionary" || ( -d "$target/cli" && -f "$target/layer2-cognitive/memory/core.sh" ) ]]; then
        die "Cannot install --scope project into the AI suite source repository itself. Use --scope global for development, or use scripts/clean_dev_env.sh to clean up." 1
      fi

      log "agent=$agent_name scope=project target=$target"
      if [[ "$AI_SUITE_DRY_RUN" == "1" ]]; then
        printf '[dry-run] would call agent_install_project %s %s\n' "$SUITE_DIR" "$target"
      else
        agent_install_project "$SUITE_DIR" "$target"
      fi
      ;;
    global)
      log "agent=$agent_name scope=global"
      if [[ "$AI_SUITE_DRY_RUN" == "1" ]]; then
        printf '[dry-run] would call agent_install_global %s\n' "$SUITE_DIR"
      else
        agent_install_global "$SUITE_DIR"
      fi
      ;;
  esac
}

# -- Validate + post-install --------------------------------------------------
do_validate() {
  log "running validator ..."
  bash "$META_DIR/validate-suite.sh" >/dev/null || return 1
  log "validation passed."
}

# -- Remote scope (agent-agnostic: rsync the whole suite then run enable) -----
do_remote_scope() {
  [[ -n "$HOST" ]] || die "--scope remote requires --host USER@HOST" 1
  # shellcheck source=/dev/null
  source "$SUITE_DIR/layer1-abstraction/runtime/transport.sh"
  suite_validate_host "$HOST" && suite_validate_remote_path "$REMOTE_PATH" || return 1
  local remote_cmd
  remote_cmd=$(suite_remote_command "$REMOTE_PATH" enable "$REMOTE_SCOPE" "$AGENT" "$PROJECT_PATH" "${AI_SUITE_DOMAIN:-}") || return 1
  case "$SYNC" in rsync|scp) ;; *) die "invalid --sync: $SYNC" 1 ;; esac
  suite_registry_validate "$SUITE_DIR" "$AGENT" || return 1
  suite_sync_deployment "$HOST" "$REMOTE_PATH" "$SUITE_DIR" "$SCRIPT_DIR/ai-suite" "$SYNC" || return 1
  run suite_transport_exec ssh -o BatchMode=yes -o ConnectTimeout=15 "$HOST" "$remote_cmd"
}

# -- Dispatch -----------------------------------------------------------------
[[ "$AI_SUITE_DRY_RUN" == "1" ]] && log "** dry-run mode -- no changes will be written **"

if [[ "$SCOPE" == "remote" ]]; then
  do_remote_scope
else
  do_validate
  case "$AGENT" in
    cursor|claude|opencode|continue|roo-code|codex) do_install_for_agent "$AGENT" ;;
    all)
      for a in cursor claude opencode continue roo-code codex; do
        do_install_for_agent "$a"
      done ;;
  esac
fi
