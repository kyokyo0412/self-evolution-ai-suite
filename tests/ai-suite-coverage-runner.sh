#!/usr/bin/env bash
# ai-suite-coverage-runner.sh -- Non-polluting code coverage test runner for AI Suite
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

COV_LOG="$REPO_ROOT/.coverage_trace.log"
COV_INIT="$REPO_ROOT/.cov_init.sh"

# If reset requested or initial run
if [[ "${1:-}" == "--reset" ]]; then
  rm -f "$COV_LOG"
  shift
fi

touch "$COV_LOG"

cat << 'EOF' > "$COV_INIT"
shopt -s extdebug 2>/dev/null || true
set -T 2>/dev/null || true
if [[ -n "${COV_LOG:-}" ]]; then
  trap 'echo "${BASH_SOURCE[0]}:$LINENO" >> "$COV_LOG"' DEBUG
fi
EOF

export COV_LOG
export BASH_ENV="$COV_INIT"

if [[ $# -gt 0 ]]; then
  echo "Running test under coverage: $*"
  "$@"
else
  echo "No test command specified. Analyzing current coverage..."
fi

rm -f "$COV_INIT"
python3 "$SCRIPT_DIR/ai-suite-coverage-engine.py" "$REPO_ROOT" "$COV_LOG"
