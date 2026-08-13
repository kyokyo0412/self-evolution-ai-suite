#!/usr/bin/env bash
# _portable.sh — Cross-platform shell helpers for ai-suite scripts.
#
# Sourced by ai-suite enable and ai-suite disable. Safe to source twice.
# Targets:
#   - macOS (BSD sed / BSD mktemp / Bash 3.2+)
#   - Linux (GNU sed / GNU mktemp / Bash 4+)
#   - Cursor Remote-SSH targets (any modern Linux)
#
# Exports:
#   CS_OS              "macos" | "linux" | "other"
#   sed_inplace        in-place sed that works on both GNU and BSD
#   mktemp_portable    mktemp with an explicit template path (portable across
#                      BSD/GNU `-t` differences)
#   ensure_trailing_newline   append a single \n to <file> if missing

if [[ -z "${CURSOR_SUITE_PORTABLE_LOADED:-}" ]]; then
  CURSOR_SUITE_PORTABLE_LOADED=1

  # -- OS classification (informational; prefer capability checks below) -----
  case "$(uname -s)" in
    Darwin) CS_OS=macos ;;
    Linux)  CS_OS=linux ;;
    *)      CS_OS=other ;;
  esac
  export CS_OS

  # -- sed_inplace <expression> [<expression>...] <file> ---------------------
  # GNU sed accepts `sed -i <expr> <file>`; BSD sed requires `sed -i '' <expr> <file>`.
  # `sed --version` exists on GNU and fails on BSD, which is our discriminator.
  if sed --version >/dev/null 2>&1; then
    sed_inplace() { sed -i "$@"; }
  else
    sed_inplace() { sed -i '' "$@"; }
  fi

  # -- mktemp_portable [<prefix>] -------------------------------------------
  # Avoid the BSD/GNU `-t` divergence: pass a full template path instead.
  mktemp_portable() {
    local prefix="${1:-cursor-suite}"
    mktemp "${TMPDIR:-/tmp}/${prefix}.XXXXXX"
  }

  # -- ensure_trailing_newline <file> ---------------------------------------
  # `$(tail -c1 "$f")` strips a trailing newline if present, so a non-empty
  # result means the last byte is NOT a newline — append one.
  ensure_trailing_newline() {
    local f="$1"
    [[ -s "$f" ]] || return 0
    if [[ -n "$(tail -c1 "$f")" ]]; then
      printf '\n' >> "$f"
    fi
  }
fi
