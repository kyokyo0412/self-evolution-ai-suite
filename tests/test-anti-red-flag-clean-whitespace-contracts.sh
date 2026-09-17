#!/usr/bin/env bash
set -euo pipefail

# test-anti-red-flag-clean-whitespace-contracts.sh
# Validates whitespace cleanliness across all AI suite registry directives and core skills,
# and verifies idempotency of clean_empty_lines_whitespace.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SUITE_DIR="$ROOT_DIR/.ai-suite"

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

echo "=== [SDET Contract Gate] Validating Anti-Red-Flag Clean Whitespace Standards ==="

# 1. Check all markdown files in .ai-suite for whitespace-only blank lines
DIRTY_FILES=()
while IFS= read -r f; do
  if grep -n '^[[:space:]]\+$' "$f" >/dev/null 2>&1; then
    DIRTY_FILES+=("$f")
  fi
done < <(find "$SUITE_DIR" -type f -name "*.md")

if [[ ${#DIRTY_FILES[@]} -eq 0 ]]; then
  pass "All markdown files in .ai-suite have clean empty lines (zero whitespace-only lines)"
else
  fail "Found whitespace-only lines in: ${DIRTY_FILES[*]}"
fi

# 2. Check source _portable.sh has clean_empty_lines_whitespace
source "$SUITE_DIR/layer1-abstraction/_portable.sh"
if type clean_empty_lines_whitespace >/dev/null 2>&1; then
  pass "clean_empty_lines_whitespace helper is defined in _portable.sh"
else
  fail "clean_empty_lines_whitespace helper not defined"
fi

# 3. Test clean_empty_lines_whitespace idempotency
TMP_FILE=$(mktemp)
printf "line 1\n  \t  \nline 2\n\t\t\nline 3\n" > "$TMP_FILE"
clean_empty_lines_whitespace "$TMP_FILE"
HASH1=$(shasum -a 256 "$TMP_FILE" | awk '{print $1}')
clean_empty_lines_whitespace "$TMP_FILE"
HASH2=$(shasum -a 256 "$TMP_FILE" | awk '{print $1}')
rm -f "$TMP_FILE"

if [[ "$HASH1" == "$HASH2" ]]; then
  pass "clean_empty_lines_whitespace is strictly idempotent"
else
  fail "clean_empty_lines_whitespace is not idempotent ($HASH1 vs $HASH2)"
fi

# 4. Check all test scripts in tests/test-*.sh have clean empty lines
DIRTY_TESTS=()
for t in "$ROOT_DIR"/tests/test-*.sh; do
  [[ -f "$t" ]] || continue
  if grep -n '^[[:space:]]\+$' "$t" >/dev/null 2>&1; then
    DIRTY_TESTS+=("$(basename "$t")")
  fi
done

if [[ ${#DIRTY_TESTS[@]} -eq 0 ]]; then
  pass "All test scripts in tests/test-*.sh have clean empty lines"
else
  fail "Found whitespace-only lines in test scripts: ${DIRTY_TESTS[*]}"
fi

echo "Summary: $PASS passed, $FAIL failed"
if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
exit 0
