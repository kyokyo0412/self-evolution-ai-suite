#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUITE_DIR="$(cd "$SCRIPT_DIR/../.ai-suite" && pwd)"
SKILL_FILE="$SUITE_DIR/layer2-cognitive/meta-compiler/prompt-enhancer.md"

echo "Running prompt-enhancer architecture contract tests..."
fails=0

assert_exists() {
  if [[ ! -f "$1" ]]; then
    echo "FAIL: Missing file $1"
    fails=$((fails + 1))
  else
    echo "PASS: Found file $1"
  fi
}

assert_grep() {
  local pattern="$1"
  local file="$2"
  local msg="$3"
  if ! grep -qE -- "$pattern" "$file"; then
    echo "FAIL: $msg"
    fails=$((fails + 1))
  else
    echo "PASS: $msg"
  fi
}

assert_exists "$SKILL_FILE"

if [[ -f "$SKILL_FILE" ]]; then
  assert_grep "^name: prompt-enhancer" "$SKILL_FILE" "Has name: prompt-enhancer in frontmatter"
  assert_grep "^description: " "$SKILL_FILE" "Has description in frontmatter"
  assert_grep "^triggers:" "$SKILL_FILE" "Has triggers array in frontmatter"
  assert_grep "- enhance prompt" "$SKILL_FILE" "Has 'enhance prompt' trigger"
  assert_grep "- compile prompt" "$SKILL_FILE" "Has 'compile prompt' trigger"
  assert_grep "[Oo]bjective" "$SKILL_FILE" "Has objective structure section"
  assert_grep "[Cc]ontext" "$SKILL_FILE" "Has context structure section"
  assert_grep "Context Aggregator" "$SKILL_FILE" "Has Context Aggregator section"
  assert_grep "---START EXECUTABLE PROMPT---" "$SKILL_FILE" "Has START EXECUTABLE PROMPT block format"
fi

if [[ $fails -gt 0 ]]; then
  echo "Contracts failed: $fails errors"
  exit 1
fi

echo "All contracts passed."
exit 0
