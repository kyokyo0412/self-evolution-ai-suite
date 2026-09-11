#!/usr/bin/env bash
# ai-suite-coverage-runner.sh -- Non-polluting code coverage test runner for AI Suite
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

COV_LOG="$REPO_ROOT/.coverage_trace.log"
COV_INIT="$REPO_ROOT/.cov_init.sh"
SUMMARY_FILE="$REPO_ROOT/.coverage_summary.txt"

cleanup() {
  rm -f "$COV_INIT" "$COV_LOG" "$SUMMARY_FILE"
}
trap cleanup EXIT INT TERM

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
  echo "No test command specified. Running full suite..."
  bash "$REPO_ROOT/tests/test-ai-suite-cli.sh" >/dev/null 2>&1 || true
  bash "$REPO_ROOT/tests/test-all-agents-eut.sh" >/dev/null 2>&1 || true
  bash "$REPO_ROOT/tests/test-evolution-module.sh" >/dev/null 2>&1 || true
  bash "$REPO_ROOT/tests/test-enable-disable-module.sh" >/dev/null 2>&1 || true
  bash "$REPO_ROOT/tests/test-publish-module.sh" >/dev/null 2>&1 || true
  bash "$REPO_ROOT/tests/test-memory-system-eut.sh" >/dev/null 2>&1 || true
  bash "$REPO_ROOT/tests/test-workflow-manage-publish.sh" >/dev/null 2>&1 || true
  bash "$REPO_ROOT/tests/test-chaos-and-validation.sh" >/dev/null 2>&1 || true
  bash "$REPO_ROOT/tests/test-concurrency-isolation.sh" >/dev/null 2>&1 || true
  bash "$REPO_ROOT/tests/test-cursor-adapter-enable-pruning-contracts.sh" >/dev/null 2>&1 || true
  bash "$REPO_ROOT/tests/test-mutation-regression.sh" >/dev/null 2>&1 || true
  bash "$REPO_ROOT/tests/test-interactive-workflow-cleanup.sh" >/dev/null 2>&1 || true
  bash "$REPO_ROOT/tests/test-safety-limits-and-portability.sh" >/dev/null 2>&1 || true
  bash "$REPO_ROOT/.ai-suite/layer4-evolutionary/validation/validate-requirements.sh" >/dev/null 2>&1 || true
  bash "$REPO_ROOT/.ai-suite/layer4-evolutionary/validation/lint-feature.sh" "$REPO_ROOT/tests/test-unified-workflow.feature" >/dev/null 2>&1 || true
  bash "$REPO_ROOT/.ai-suite/layer4-evolutionary/validation/validate-suite.sh" >/dev/null 2>&1 || true
  python3 "$REPO_ROOT/tests/test_bugzilla_suite.py" >/dev/null 2>&1 || true
fi

rm -f "$COV_INIT"
python3 "$SCRIPT_DIR/ai-suite-coverage-engine.py" "$REPO_ROOT" "$COV_LOG"
rm -f "$COV_LOG"
