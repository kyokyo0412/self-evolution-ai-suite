#!/bin/bash

# Tests to ensure the adapter.sh explicitly adds CRITICAL RULE ENFORCEMENT
# and globs: "*" to the deployed rules.

set -e

ADAPTER_FILE=".ai-suite/layer1-abstraction/agents/cursor/adapter.sh"

if [ ! -f "$ADAPTER_FILE" ]; then
    echo "FAIL: $ADAPTER_FILE not found!"
    exit 1
fi

if ! grep -q "CRITICAL RULE ENFORCEMENT" "$ADAPTER_FILE"; then
    echo "FAIL: $ADAPTER_FILE does not contain CRITICAL RULE ENFORCEMENT block."
    exit 1
fi

if ! grep -q "globs: \"\*\"" "$ADAPTER_FILE"; then
    echo "FAIL: $ADAPTER_FILE does not use globs: \"*\" for deployed rules."
    exit 1
fi

echo "PASS: $ADAPTER_FILE mandates global rule enforcement."
exit 0
