#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CORE_LIB="$SCRIPT_DIR/../.ai-suite/layer2-cognitive/memory/core.sh"

export AI_SUITE_LOG_PREFIX="test"

echo "Running Core Lib Tests..."

# Test log functions exist
source "$CORE_LIB"

if ! type log >/dev/null 2>&1; then
    echo "FAILED: log function not defined"
    exit 1
fi

if ! type warn >/dev/null 2>&1; then
    echo "FAILED: warn function not defined"
    exit 1
fi

if ! type die >/dev/null 2>&1; then
    echo "FAILED: die function not defined"
    exit 1
fi

# Test Dry Run
AI_SUITE_DRY_RUN=1
DRY_OUT=$(run echo "hello world")
if [[ "$DRY_OUT" != "[dry-run] echo hello\ world" ]]; then
    echo "FAILED: run in dry-run mode produced: $DRY_OUT"
    exit 1
fi

# Test regular run
AI_SUITE_DRY_RUN=0
REG_OUT=$(run echo "hello world")
if [[ "$REG_OUT" != "hello world" ]]; then
    echo "FAILED: run in regular mode produced: $REG_OUT"
    exit 1
fi

echo "All Core Lib Tests PASSED."
exit 0
