#!/usr/bin/env bash
# Compatibility facade for source and installed AI Suite runtime layouts.
set -euo pipefail

if [[ -z "${AI_SUITE_CORE_LOADED:-}" ]]; then
  _CORE_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  _AI_SUITE_RUNTIME_DIR=""
  for _runtime_candidate in \
    "$_CORE_LIB_DIR/../../layer1-abstraction/runtime" \
    "$_CORE_LIB_DIR/../layer1-abstraction/runtime" \
    "$_CORE_LIB_DIR/../meta/layer1-abstraction/runtime"; do
    if [[ -f "$_runtime_candidate/execution.sh" ]]; then
      _AI_SUITE_RUNTIME_DIR="$(cd "$_runtime_candidate" && pwd)"
      break
    fi
  done
  if [[ -z "$_AI_SUITE_RUNTIME_DIR" ]]; then
    printf '[core] ERROR: AI Suite runtime modules were not installed\n' >&2
    return 2
  fi
  # shellcheck source=/dev/null
  source "$_AI_SUITE_RUNTIME_DIR/../_portable.sh"
  for _runtime_module in execution registry-validation registry mirroring rendering cursor lifecycle; do
    # shellcheck source=/dev/null
    source "$_AI_SUITE_RUNTIME_DIR/$_runtime_module.sh"
  done
  AI_SUITE_CORE_LOADED=1
fi
