#!/usr/bin/env bash
set -euo pipefail

# test-code-formatting-unit.sh
# Unit tests for code formatting directives, trailing whitespace checks,
# and markdown block generation across agent adapters.

echo "=== [SDET Unit Gate] Running Code Formatting Unit Tests ==="

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SUITE_DIR="$ROOT_DIR/.ai-suite"

# 1. Check no trailing whitespace / spaces on blank lines in the directive files
echo "1. Checking directive files for whitespace-only blank lines..."
DIRECTIVE_FILES=(
  "$SUITE_DIR/layer3-registry/directives/code-quality.md"
  "$SUITE_DIR/layer3-registry/directives/agent-directives.md"
  "$SUITE_DIR/layer3-registry/core/tdd-team.md"
  "$SUITE_DIR/layer3-registry/core/autonomous-team.md"
  "$SUITE_DIR/layer3-registry/core/ai-review-fix.md"
  "$SUITE_DIR/layer2-cognitive/meta-compiler/prompt-compiler.md"
)

for file in "${DIRECTIVE_FILES[@]}"; do
  if grep -n '^[[:space:]]\+$' "$file" >/dev/null; then
    echo "  [FAIL] $file has whitespace-only empty lines!"
    exit 1
  fi
  echo "  [PASS] Clean empty lines in $(basename "$file")"
done

# 2. Test generate_markdown_block outputs formatting directives
echo "2. Testing markdown block generator..."
source "$SUITE_DIR/layer1-abstraction/_portable.sh"
source "$SUITE_DIR/layer2-cognitive/memory/core.sh"

TMP_OUTPUT=$(mktemp)
generate_markdown_block "$SUITE_DIR" "$TMP_OUTPUT" "codex" "<!-- test-start -->" "<!-- test-end -->" > "$TMP_OUTPUT"

if ! grep -qi "gofmt" "$TMP_OUTPUT"; then
  echo "  [FAIL] generate_markdown_block missing gofmt directive"
  rm -f "$TMP_OUTPUT"
  exit 1
fi

if ! grep -qi "clang-format" "$TMP_OUTPUT"; then
  echo "  [FAIL] generate_markdown_block missing clang-format directive"
  rm -f "$TMP_OUTPUT"
  exit 1
fi

if ! grep -qi "trivial empty lines" "$TMP_OUTPUT" && ! grep -qi "empty lines" "$TMP_OUTPUT"; then
  echo "  [FAIL] generate_markdown_block missing empty lines directive"
  rm -f "$TMP_OUTPUT"
  exit 1
fi

if ! grep -qi "unchanged code" "$TMP_OUTPUT"; then
  echo "  [FAIL] generate_markdown_block missing unchanged code directive"
  rm -f "$TMP_OUTPUT"
  exit 1
fi
rm -f "$TMP_OUTPUT"
echo "  [PASS] Markdown block generation verified with formatting directives."

# 3. Test deploy simulation via dry run
echo "3. Testing deployment simulation..."
TMP_PROJ=$(mktemp -d)
mkdir -p "$TMP_PROJ"
export AI_SUITE_DRY_RUN=1
bash "$ROOT_DIR/ai-suite" enable --scope project --agent cursor --target "$TMP_PROJ" >/dev/null 2>&1 || true

if [ -f "$TMP_PROJ/.cursor/rules/cursor-suite-code-quality.mdc" ]; then
  grep -qi "gofmt" "$TMP_PROJ/.cursor/rules/cursor-suite-code-quality.mdc" || { echo "  [FAIL] deployed code-quality.mdc missing gofmt"; rm -rf "$TMP_PROJ"; exit 1; }
  grep -qi "clang-format" "$TMP_PROJ/.cursor/rules/cursor-suite-code-quality.mdc" || { echo "  [FAIL] deployed code-quality.mdc missing clang-format"; rm -rf "$TMP_PROJ"; exit 1; }
  grep -qi "unchanged code" "$TMP_PROJ/.cursor/rules/cursor-suite-code-quality.mdc" || { echo "  [FAIL] deployed code-quality.mdc missing unchanged code"; rm -rf "$TMP_PROJ"; exit 1; }
  echo "  [PASS] Project-level deployed rule contains code formatting directives."
fi

rm -rf "$TMP_PROJ"

echo "PASS: All unit tests passed successfully."
exit 0
