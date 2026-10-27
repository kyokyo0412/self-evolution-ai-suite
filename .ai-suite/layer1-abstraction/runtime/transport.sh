#!/usr/bin/env bash
# Local arrays preserve argv; only these helpers serialize remote shell text.
_SUITE_TRANSPORT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

suite_transport_exec() {
  PYTHONDONTWRITEBYTECODE=1 python3 "$_SUITE_TRANSPORT_DIR/process.py" "$@"
}

suite_validate_host() {
  [[ "$1" =~ ^([a-zA-Z0-9_][a-zA-Z0-9._-]*@)?([a-zA-Z0-9][a-zA-Z0-9.-]*|\[[a-fA-F0-9:]+\])$ ]] || {
    printf 'invalid remote host; use [user@]hostname or an IP address\n' >&2; return 1;
  }
}

suite_validate_agent() {
  case "$1" in
    cursor|claude|opencode|continue|roo-code|codex|all) return 0 ;;
    *) printf 'invalid agent: %q\n' "$1" >&2; return 1 ;;
  esac
}

suite_validate_scope() {
  case "$1" in
    project|global) return 0 ;;
    *) printf 'invalid remote scope: %q\n' "$1" >&2; return 1 ;;
  esac
}

suite_validate_remote_path() {
  [[ -n "$1" && "$1" != -* && "$1" != *[[:cntrl:]]* ]] || {
    printf 'invalid remote path\n' >&2; return 1;
  }
  # Literal remote-root markers are rejected before intentional expansion.
  # shellcheck disable=SC2016
  case "$1" in /|.|'~'|'$HOME') printf 'remote deployment root is too broad\n' >&2; return 1 ;; esac
  case "/$1/" in
    */../*|*/./*) printf 'remote path traversal is not allowed\n' >&2; return 1 ;;
  esac
}

suite_shell_quote() {
  local value="$1" quote="'" escaped="'\"'\"'"
  value="${value//$quote/$escaped}"
  printf "'%s'" "$value"
}

suite_remote_path() {
  suite_validate_remote_path "$1" || return 1
  # These are explicit remote expansion markers, never local expansions.
  # shellcheck disable=SC2016,SC2088
  case "$1" in
    '$HOME/'*) printf '"$HOME"/'; suite_shell_quote "${1#\$HOME/}" ;;
    '~/'*) printf '"$HOME"/'; suite_shell_quote "${1#\~/}" ;;
    *) suite_shell_quote "$1" ;;
  esac
}

suite_remote_command() {
  local path="$1" action="$2" scope="$3" agent="$4" project="${5:-}" domain="${6:-}"
  suite_validate_scope "$scope" && suite_validate_agent "$agent" || return 1
  case "$action" in enable|disable) ;; *) return 1 ;; esac
  printf 'bash '; suite_remote_path "$path/ai-suite" || return 1
  printf ' %s --scope %s --agent %s' "$action" "$scope" "$agent"
  if [[ -n "$project" ]]; then
    suite_validate_remote_path "$project" || return 1
    printf ' --project '; suite_shell_quote "$project"
  fi
  if [[ -n "$domain" ]]; then
    [[ "$domain" =~ ^[a-z0-9][a-z0-9_-]*$ ]] || return 1
    printf ' --domain '; suite_shell_quote "$domain"
  fi
}

suite_rsync_remote() {
  suite_validate_host "$1" || return 1
  printf '%s:' "$1"
  suite_remote_path "$2"
}

suite_sync_deployment() {
  local host="$1" remote="$2" suite="$3" launcher="$4" method="${5:-rsync}"
  local target mkdir_cmd
  target=$(suite_rsync_remote "$host" "$remote/") || return 1
  mkdir_cmd="mkdir -p -- $(suite_remote_path "$remote")" || return 1
  run suite_transport_exec ssh -o BatchMode=yes -o ConnectTimeout=15 "$host" "$mkdir_cmd" || return 1
  case "$method" in
    rsync) run suite_transport_exec rsync -az "$suite" "$launcher" "$target" ;;
    scp) run suite_transport_exec scp -r "$suite" "$launcher" "$target" ;;
    *) printf 'unsupported sync method: %s\n' "$method" >&2; return 1 ;;
  esac
}
