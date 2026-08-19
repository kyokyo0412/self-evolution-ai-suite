#!/usr/bin/env bash
set -euo pipefail

echo "[TEST] Running Auto-Evolution EUT..."

export TEST_WS=$(mktemp -d)
export APP_WS=$(mktemp -d)
trap 'rm -rf "$TEST_WS" "$APP_WS"' EXIT

cd "$TEST_WS"
cp -R "$OLDPWD/.ai-suite" ./
cp "$OLDPWD/ai-suite" ./

./ai-suite enable --agent all --scope project --project "$APP_WS"

cd "$APP_WS"
grep -q "Auto-Evolution Directive" .cursorrules || { echo "FAIL: cursorrules missing directive"; exit 1; }
grep -q "Auto-Evolution Directive" CLAUDE.md || { echo "FAIL: CLAUDE.md missing directive"; exit 1; }
grep -q "Auto-Evolution Directive" .roorules || { echo "FAIL: roorules missing directive"; exit 1; }
grep -q "Auto-Evolution Directive" .opencode/instructions.md || { echo "FAIL: opencode instructions missing directive"; exit 1; }

echo "PASS: EUT Auto-Evolution validated."
