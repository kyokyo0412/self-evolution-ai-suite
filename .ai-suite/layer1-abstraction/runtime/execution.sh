#!/usr/bin/env bash
# Shared runtime module; sourced through memory/core.sh.
# -- Logging -----------------------------------------------------------------
_grn() { [[ -t 1 ]] && printf '\033[32m' || true; }
_red() { [[ -t 1 ]] && printf '\033[31m' || true; }
_yel() { [[ -t 1 ]] && printf '\033[33m' || true; }
_off() { [[ -t 1 ]] && printf '\033[0m'  || true; }

# Context prefix allows scripts to set their name (e.g. enable_suite)
AI_SUITE_LOG_PREFIX="${AI_SUITE_LOG_PREFIX:-ai-suite}"

log()  { printf '%s[%s]%s %s\n'     "$(_grn)" "$AI_SUITE_LOG_PREFIX" "$(_off)" "$*"; }
info() { log "$@"; } # alias for log
warn() { printf '%s[%s] WARN:%s %s\n' "$(_yel)" "$AI_SUITE_LOG_PREFIX" "$(_off)" "$*" >&2; }
die()  { printf '%s[%s] ERROR:%s %s\n' "$(_red)" "$AI_SUITE_LOG_PREFIX" "$(_off)" "$*" >&2; exit "${2:-1}"; }

# -- Execution ---------------------------------------------------------------
# If AI_SUITE_DRY_RUN=1, echo the command instead of running it.
run() {
  if [[ "${AI_SUITE_DRY_RUN:-0}" == "1" ]]; then
    printf '[dry-run] %q' "$1"
    local arg
    for arg in "${@:2}"; do
      printf ' %q' "$arg"
    done
    printf '\n'
  else
    if [[ "${AI_SUITE_VERBOSE:-0}" == "1" ]]; then
      info "  + $*"
    fi
    "$@"
  fi
}

run_redirect_append() {
  local file="$1"; shift
  if [[ "${AI_SUITE_DRY_RUN:-0}" == "1" ]]; then
    printf '[dry-run] (append) >> %q\n' "$file"
  else
    "$@" >> "$file"
  fi
}

