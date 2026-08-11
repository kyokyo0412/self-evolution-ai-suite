#!/usr/bin/env bash
# enable_suite.sh — Activate the .ai-suite/ multi-agent AI framework.
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
#   --agent AGENT    cursor (default) | claude | opencode | continue | roo-code | all
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
#   --uninstall       Delegate to disable_suite.sh (forwards all flags).
#   -h | --help       Print this help.
#
# Portability: macOS (BSD tools) and Linux (GNU tools). Helpers in
# .ai-suite/layer4-evolutionary/validation/_portable.sh handle the BSD/GNU sed and mktemp differences.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUITE_DIR="$SCRIPT_DIR/.ai-suite"
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

HOOK_MARK_START="### AI SUITE AUTO-ENABLE HOOK START ###"
HOOK_MARK_END="### AI SUITE AUTO-ENABLE HOOK END ###"

usage() { sed -n '2,26p' "$0"; exit "${1:-0}"; }

# -- Parse flags --------------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --scope)        SCOPE="${2:?--scope requires project|global|remote}"; shift 2 ;;
    --agent)        AGENT="${2:?--agent requires cursor|claude|opencode|continue|roo-code|all}"; shift 2 ;;
    --project)      PROJECT_PATH="${2:?--project requires a path}"; shift 2 ;;
    --host)         HOST="${2:?--host requires user@host}"; shift 2 ;;
    --remote-path)  REMOTE_PATH="${2:?--remote-path requires a path}"; shift 2 ;;
    --remote-scope) REMOTE_SCOPE="${2:?--remote-scope requires project|global}"; shift 2 ;;
    --domain)       export AI_SUITE_DOMAIN="${2:?--domain requires a domain name}"; shift 2 ;;
    --dry-run)      export AI_SUITE_DRY_RUN=1; shift ;;
    --verify)       VERIFY=1; shift ;;
    --install-hook) INSTALL_HOOK=1; shift ;;
    --shell)        SHELL_TARGETS="${2:?--shell requires auto|zsh|bash|both}"; shift 2 ;;
    --uninstall)    UNINSTALL=1; shift ;;
    -h|--help)      usage 0 ;;
    *)              die "unknown argument: $1" 1 ;;
  esac
done

# -- Validate agent -----------------------------------------------------------
case "$AGENT" in
  cursor|claude|opencode|continue|roo-code|all) ;;
  *) die "Unsupported agent: '$AGENT'. Valid: cursor | claude | opencode | continue | roo-code | all" 1 ;;
esac

case "$SCOPE" in
  project|global|remote) ;;
  *) die "Unsupported scope: '$SCOPE'. Valid: project | global | remote" 1 ;;
esac

# -- Preflight ----------------------------------------------------------------
[[ -d "$SUITE_DIR" ]] || die "missing $SUITE_DIR — is .ai-suite/ next to this script?" 2

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
  exec bash "$SCRIPT_DIR/disable_suite.sh" "${args[@]}"
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
  if [[ ! -f "$rc_file" ]]; then warn "$rc_file not found; creating it"; run touch "$rc_file"; fi
  if grep -Fq "$HOOK_MARK_START" "$rc_file" 2>/dev/null; then
    log "auto-enable hook already in $rc_file — skipping"; return 0
  fi
  [[ "$AI_SUITE_DRY_RUN" == "1" ]] && { printf '[dry-run] would append %s hook to %s\n' "$shell_kind" "$rc_file"; return 0; }
  local suite_root_literal="$SCRIPT_DIR"
  case "$shell_kind" in
    zsh)
      cat <<EOF >> "$rc_file"

$HOOK_MARK_START
# Auto-enable .ai-suite in any git repo entered via cd (zsh chpwd hook).
__ai_suite_chpwd() {
  [[ -d ./.git ]] || return 0
  [[ -d ./.ai-suite ]] && return 0
  [[ -f ./enable_suite.sh ]] && return 0
  if [[ -x "$suite_root_literal/enable_suite.sh" ]]; then
    bash "$suite_root_literal/enable_suite.sh" --scope project --project "\$PWD" >/dev/null 2>&1 \
      && printf '[ai-suite] enabled in %s\n' "\$PWD"
  fi
}
typeset -ga chpwd_functions
chpwd_functions+=(__ai_suite_chpwd)
$HOOK_MARK_END
EOF
      ;;
    bash)
      cat <<EOF >> "$rc_file"

$HOOK_MARK_START
# Auto-enable .ai-suite in any git repo entered via cd (bash PROMPT_COMMAND hook).
__ai_suite_chpwd() {
  [[ -d ./.git ]] || return 0
  [[ -d ./.ai-suite ]] && return 0
  [[ -f ./enable_suite.sh ]] && return 0
  if [[ -x "$suite_root_literal/enable_suite.sh" ]]; then
    command bash "$suite_root_literal/enable_suite.sh" --scope project --project "\$PWD" >/dev/null 2>&1 \
      && printf '[ai-suite] enabled in %s\n' "\$PWD"
  fi
}
__ai_suite_prompt() {
  if [[ "\$PWD" != "\${__AI_SUITE_LAST_PWD:-}" ]]; then
    __AI_SUITE_LAST_PWD="\$PWD"
    __ai_suite_chpwd
  fi
}
PROMPT_COMMAND="__ai_suite_prompt\${PROMPT_COMMAND:+; \$PROMPT_COMMAND}"
$HOOK_MARK_END
EOF
      ;;
    *) die "unknown shell_kind: $shell_kind" 1 ;;
  esac
  log "installed $shell_kind auto-enable hook in $rc_file"
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
      fi
      
      # Isolation check: Do not install into the AI suite source repository itself
      if [[ -d "$target/.ai-suite/layer4-evolutionary" ]]; then
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
  run chmod +x "$META_DIR/validate-suite.sh"
  log "running validator ..."
  if bash "$META_DIR/validate-suite.sh" >/dev/null 2>&1; then
    log "validation passed."
  else
    warn "validation FAILED. Run: bash $META_DIR/validate-suite.sh"
  fi
}

# -- Remote scope (agent-agnostic: rsync the whole suite then run enable) -----
do_remote_scope() {
  [[ -n "$HOST" ]] || die "--scope remote requires --host USER@HOST" 1
  command -v ssh >/dev/null || die "ssh not found in PATH" 1

  local SYNC
  command -v rsync >/dev/null && SYNC="rsync" || SYNC="scp"

  log "scope=remote agent=$AGENT host=$HOST remote-path=$REMOTE_PATH remote-scope=$REMOTE_SCOPE"

  if [[ "$REMOTE_PATH" == '$HOME/.ai-suite-deploy' ]]; then
    run ssh "$HOST" 'if [ -d "$HOME/.ai-suite/.ai-suite" ] && [ ! -d "$HOME/.ai-suite/.git" ]; then echo "Cleaning up old deployment directory $HOME/.ai-suite..."; rm -rf "$HOME/.ai-suite"; fi'
  fi

  run ssh "$HOST" "mkdir -p \"$REMOTE_PATH\""

  if [[ "$SYNC" == "rsync" ]]; then
    run rsync -az --delete \
        "$SUITE_DIR" \
        "$SCRIPT_DIR/enable_suite.sh" \
        "$SCRIPT_DIR/disable_suite.sh" \
        "$SCRIPT_DIR/evolve_suite.sh" \
        "$HOST:\"$REMOTE_PATH\"/"
  else
    run scp -r \
        "$SUITE_DIR" \
        "$SCRIPT_DIR/enable_suite.sh" \
        "$SCRIPT_DIR/disable_suite.sh" \
        "$SCRIPT_DIR/evolve_suite.sh" \
        "$HOST:\"$REMOTE_PATH\"/"
  fi

  local remote_cmd
  case "$REMOTE_SCOPE" in
    project)
      if [[ -n "$PROJECT_PATH" ]]; then
        local q_proj
        q_proj="'$(printf '%s' "$PROJECT_PATH" | sed "s/'/'\\\\''/g")'"
        remote_cmd="bash \"$REMOTE_PATH/enable_suite.sh\" --scope project --project $q_proj --agent $AGENT"
      else
        remote_cmd="bash \"$REMOTE_PATH/enable_suite.sh\" --scope project --agent $AGENT"
      fi
      ;;
    global)
      remote_cmd="bash \"$REMOTE_PATH/enable_suite.sh\" --scope global --agent $AGENT"
      ;;
    *) die "invalid --remote-scope: $REMOTE_SCOPE (project|global)" 1 ;;
  esac
  
  if [[ -n "${AI_SUITE_DOMAIN:-}" ]]; then
    local q_dom
    q_dom="'$(printf '%s' "$AI_SUITE_DOMAIN" | sed "s/'/'\\\\''/g")'"
    remote_cmd="$remote_cmd --domain $q_dom"
  fi

  log "ssh $HOST -> $remote_cmd"
  run ssh "$HOST" "$remote_cmd"
  log "done. Disable: bash $SCRIPT_DIR/disable_suite.sh --scope remote --host \"$HOST\" --remote-path \"$REMOTE_PATH\""
}

# -- Dispatch -----------------------------------------------------------------
[[ "$AI_SUITE_DRY_RUN" == "1" ]] && log "** dry-run mode — no changes will be written **"

if [[ "$SCOPE" == "remote" ]]; then
  do_remote_scope
else
  case "$AGENT" in
    cursor|claude|opencode|continue|roo-code) do_install_for_agent "$AGENT" ;;
    all)
      for a in cursor claude opencode continue roo-code; do
        do_install_for_agent "$a"
      done ;;
  esac
  do_validate
fi
