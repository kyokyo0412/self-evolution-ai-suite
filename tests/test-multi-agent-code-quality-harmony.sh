#!/usr/bin/env bash
set -euo pipefail

# test-multi-agent-code-quality-harmony.sh
# Validates that generate_markdown_block embeds the enhanced code quality,
# resource lifecycle, and anti-hardcoding directives across all supported non-cursor agents.

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SUITE_DIR="$PROJECT_ROOT/.ai-suite"
CORE_LIB="$SUITE_DIR/layer2-cognitive/memory/core.sh"

source "$CORE_LIB"

PASS=0
FAIL=0

pass() {
  PASS=$((PASS + 1))
  printf '  \033[32mPASS\033[0m %s\n' "$1"
}

fail() {
  FAIL=$((FAIL + 1))
  printf '  \033[31mFAIL\033[0m %s\n' "$1" >&2
}

echo "=== [SDET Contract Gate] Validating Multi-Agent Code Quality Directive Harmony ==="

AGENTS=("claude" "codex" "opencode" "continue" "roo-code")

for agent in "${AGENTS[@]}"; do
  TMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/test-harmony-${agent}.XXXXXX")
  trap 'rm -rf "$TMP_DIR"' EXIT

  mkdir -p "$TMP_DIR/meta" "$TMP_DIR/skills"

  OUTPUT=$(generate_markdown_block "$SUITE_DIR" "$TMP_DIR" "$agent" "<!-- start -->" "<!-- end -->")

  if echo "$OUTPUT" | grep -qiE "Strict Resource Lifecycle & Leak Prevention" && \
     echo "$OUTPUT" | grep -qiE "Language-Specific Robustness Standards" && \
     echo "$OUTPUT" | grep -qiE "Deterministic Resource & Subprocess Management" && \
     echo "$OUTPUT" | grep -qiE "Dynamic Test Assertions & Anti-Hardcoding Rigor" && \
     echo "$OUTPUT" | grep -qiE "Resource Lifecycle Determinism"; then
    pass "Agent $agent: generated markdown block embeds all enhanced code quality directives"
  else
    fail "Agent $agent: generated markdown block missing one or more enhanced code quality directives"
  fi

  rm -rf "$TMP_DIR"
done

echo "Summary: $PASS passed, $FAIL failed"
if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
exit 0
