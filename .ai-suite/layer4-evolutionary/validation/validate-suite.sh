#!/usr/bin/env bash
# Validate canonical <name>.md sources or installed <name>/SKILL.md capabilities.
# Both entry paths use the same metadata, resource and dependency contracts.
set -uo pipefail
export LC_ALL=C

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUITE_ROOT="$(cd "$HERE/../.." && pwd)"
if [[ -f "$HERE/layer1-abstraction/runtime/registry.py" ]]; then
  SUITE_ROOT="$HERE"
fi
REGISTRY="$SUITE_ROOT/layer1-abstraction/runtime/registry.py"

if [[ $# -eq 0 ]]; then
  PYTHONDONTWRITEBYTECODE=1 python3 "$REGISTRY" validate "$SUITE_ROOT" --agent all
else
  PYTHONDONTWRITEBYTECODE=1 python3 "$REGISTRY" validate-target "$@"
fi
status=$?
if [[ $status -eq 0 ]]; then
  printf "[validate-suite] all capability checks passed, 0 failed\n"
else
  printf "[validate-suite] capability validation failed\n" >&2
fi
exit "$status"
