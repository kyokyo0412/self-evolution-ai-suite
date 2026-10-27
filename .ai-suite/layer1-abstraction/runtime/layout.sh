#!/usr/bin/env bash
# Resolve source and complete installed-agent contexts through one contract.
# SUITE_DIR and SCRIPT_DIR are public outputs consumed by sourcing commands.
# shellcheck disable=SC2034
suite_resolve_layout() {
  local origin="$1" candidate resolved
  for candidate in "$origin/.." "$origin/../.ai-suite" "$origin/.ai-suite" "$origin"; do
    [[ -d "$candidate" ]] || continue
    resolved=$(cd "$candidate" && pwd) || return 2
    if [[ -f "$resolved/layer2-cognitive/memory/core.sh" && -d "$resolved/cli" ]]; then
      SUITE_DIR="$resolved"
      if [[ "${resolved##*/}" == .ai-suite ]]; then
        SCRIPT_DIR="$(cd "$resolved/.." && pwd)" || return 2
      else
        SCRIPT_DIR="$resolved"
      fi
      return 0
    fi
  done
  printf 'Cannot determine complete AI Suite context from %s\n' "$origin" >&2
  return 2
}
