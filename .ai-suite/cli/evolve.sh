#!/usr/bin/env bash
# ai-suite evolve -- collect or push evolutions without losing pending input.
set -euo pipefail
ORIGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$ORIGIN_DIR/../layer1-abstraction/runtime/layout.sh"
suite_resolve_layout "$ORIGIN_DIR"
SUITE_ROOT="$SCRIPT_DIR"
if [[ ! -f "$SUITE_DIR/layer2-cognitive/memory/core.sh" ]]; then
  printf '[evolve] ERROR: core.sh not found\n' >&2
  exit 2
fi
# shellcheck source=/dev/null
source "$SUITE_DIR/layer2-cognitive/memory/core.sh"
# shellcheck source=/dev/null
source "$SUITE_DIR/layer1-abstraction/runtime/transport.sh"
export AI_SUITE_LOG_PREFIX=evolve AI_SUITE_DRY_RUN=0
HOSTS=()
COLLECT_LOCAL=0
EXCLUDE_MEMORY=0
# shellcheck disable=SC2016
REMOTE_PATH='$HOME/.ai-suite-deploy'
REMOTE_SCOPE=global
AGENT=cursor
AGENT_SELECTED=0
EVOLUTION_HELPER="$SUITE_DIR/layer1-abstraction/runtime/evolution.py"

usage() {
  printf '%s\n' 'ai-suite evolve -- sync ai-suite evolutions' \
    'USAGE: ai-suite evolve collect [--local] [--host USER@HOST ...] [options]' \
    '       ai-suite evolve push --host USER@HOST ... [options]' \
    'SUB-COMMANDS: collect, push' \
    'OPTIONS: --remote-path PATH --remote-scope global|project --agent AGENT' \
    '         --exclude-memory --dry-run --help' \
    'Collection retains differing files for semantic merge; existing local files are preserved.' \
    'Exit codes: 0 success/pending review; 1 invalid input; 3 all hosts failed; 10 partial failure.'
}

parse_options() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --local) COLLECT_LOCAL=1; shift ;;
      --exclude-memory) EXCLUDE_MEMORY=1; shift ;;
      --dry-run) export AI_SUITE_DRY_RUN=1; shift ;;
      --help|-h) usage; exit 0 ;;
      --host|--remote-path|--remote-scope|--agent)
        [[ $# -ge 2 && -n "$2" ]] || die "$1 requires a value" 1
        case "$1" in
          --host) HOSTS+=("$2") ;;
          --remote-path) REMOTE_PATH="$2" ;;
          --remote-scope) REMOTE_SCOPE="$2" ;;
          --agent) AGENT="$2"; AGENT_SELECTED=1 ;;
        esac
        shift 2 ;;
      *) die "Unknown option: $1" 1 ;;
    esac
  done
}

validate_options() {
  suite_validate_agent "$AGENT" && suite_validate_scope "$REMOTE_SCOPE" || return 1
  suite_validate_remote_path "$REMOTE_PATH" || return 1
  local host
  for host in "${HOSTS[@]:-}"; do
    [[ -z "$host" ]] || suite_validate_host "$host" || return 1
  done
  if [[ ${#HOSTS[@]} -eq 0 && ( "$COLLECT_LOCAL" == 0 || "$SUBCMD" == push ) ]]; then
    die "--host or --local is required (push requires --host)" 1
  fi
  [[ "$SUBCMD" != push || "$COLLECT_LOCAL" == 0 ]] || die "push does not support --local" 1
}

collect_one() (
  local origin="$1" temporary remote
  temporary=$(mktemp -d "${TMPDIR:-/tmp}/suite-collect.XXXXXX")
  trap 'rm -r -- "$temporary"' EXIT
  if [[ "$origin" == local:* ]]; then
    PYTHONDONTWRITEBYTECODE=1 python3 "$EVOLUTION_HELPER" snapshot "$SUITE_DIR" "$temporary" --agent "${origin#local:}" || return 1
  else
    remote=$(suite_rsync_remote "$origin" "$REMOTE_PATH/.ai-suite/") || return 1
    local options=(-az)
    if [[ "$EXCLUDE_MEMORY" == 1 ]]; then
      options+=(--exclude=/memory/ --exclude=/.ai-memory/)
    fi
    suite_transport_exec rsync "${options[@]}" -e 'ssh -o BatchMode=yes -o ConnectTimeout=10' "$remote" "$temporary/" || return 1
  fi
  PYTHONDONTWRITEBYTECODE=1 python3 "$EVOLUTION_HELPER" collect "$SUITE_DIR" "$temporary" --origin "$origin"
)

do_collect() {
  if [[ "$AI_SUITE_DRY_RUN" == 1 ]]; then
    info "[DRY-RUN] collect from ${HOSTS[*]:-local}; no files were modified."
    return 0
  fi
  local host agent failed=0 total=0
  if [[ "$COLLECT_LOCAL" == 1 ]]; then
    local agents=(cursor claude opencode continue roo-code codex)
    [[ "$AGENT_SELECTED" == 0 || "$AGENT" == all ]] || agents=("$AGENT")
    for agent in "${agents[@]}"; do
      total=$((total + 1))
      collect_one "local:$agent" || failed=$((failed + 1))
    done
  fi
  for host in "${HOSTS[@]:-}"; do
    [[ -n "$host" ]] || continue
    total=$((total + 1))
    collect_one "$host" || failed=$((failed + 1))
  done
  info 'Review retained changes with git diff and git status; commit manually after resolution.'
  [[ "$failed" == 0 ]] && return 0
  [[ "$failed" == "$total" ]] && return 3
  return 10
}

push_one() {
  local host="$1" remote command launcher mkdir_cmd
  remote=$(suite_rsync_remote "$host" "$REMOTE_PATH/.ai-suite/") || return 1
  launcher=$(suite_rsync_remote "$host" "$REMOTE_PATH/") || return 1
  command=$(suite_remote_command "$REMOTE_PATH" enable "$REMOTE_SCOPE" "$AGENT") || return 1
  mkdir_cmd="mkdir -p -- $(suite_remote_path "$REMOTE_PATH")"
  local options=(-az --exclude=/layer4-evolutionary/reflection/pending/)
  [[ "$EXCLUDE_MEMORY" != 1 ]] || options+=(--exclude=/memory/ --exclude=/.ai-memory/)
  run suite_transport_exec ssh -o BatchMode=yes -o ConnectTimeout=15 "$host" "$mkdir_cmd" || return 1
  run suite_transport_exec rsync -az "$SUITE_ROOT/ai-suite" "$launcher" || return 1
  run suite_transport_exec rsync "${options[@]}" -e 'ssh -o BatchMode=yes -o ConnectTimeout=10' "$SUITE_DIR/" "$remote" || return 1
  run suite_transport_exec ssh -o BatchMode=yes -o ConnectTimeout=15 "$host" "$command"
}

do_push() {
  local host failed=0
  for host in "${HOSTS[@]}"; do
    push_one "$host" || failed=$((failed + 1))
  done
  [[ "$AI_SUITE_DRY_RUN" != 1 ]] || info '[DRY-RUN] complete -- no hosts were modified.'
  [[ "$failed" == 0 ]] && return 0
  [[ "$failed" == "${#HOSTS[@]}" ]] && return 3
  return 10
}

if [[ $# == 0 ]]; then usage; exit 0; fi
case "$1" in
  collect|push) SUBCMD="$1"; shift ;;
  --help|-h) usage; exit 0 ;;
  *) die "Unknown sub-command: $1" 1 ;;
esac
parse_options "$@"
validate_options
case "$SUBCMD" in collect) do_collect ;; push) do_push ;; esac
