#!/usr/bin/env bash
# ai-suite publish -- Package declared public runtime artifacts.
set -euo pipefail
ORIGIN_DIR="${AI_SUITE_PUBLISH_ORIGIN_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
if [[ "${1:-}" =~ ^(-h|--help|help)$ ]]; then
  printf '%s\n' 'Usage: ai-suite publish [--dry-run]' 'Build a validated domain-free standalone package.'
  exit 0
fi
if [[ $# -gt 0 && ( $# != 1 || "$1" != --dry-run ) ]]; then
  printf 'Unknown publish option: %s\n' "$1" >&2
  exit 1
fi
HELPER="$ORIGIN_DIR/../layer1-abstraction/runtime/package.py"
# Source CLI is .ai-suite/cli; installed publisher is meta/scripts.
[[ -f "$HELPER" ]] || { printf 'publish runtime not found: %s\n' "$HELPER" >&2; exit 2; }
command -v python3 >/dev/null || { printf 'python3 is required\n' >&2; exit 2; }
PYTHONDONTWRITEBYTECODE=1 python3 "$HELPER" "$ORIGIN_DIR" "$@"
