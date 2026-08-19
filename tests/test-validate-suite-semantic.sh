#!/usr/bin/env bash
# test-validate-suite-semantic.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SUITE_ROOT="$PROJECT_ROOT/.ai-suite"
VALIDATOR="$PROJECT_ROOT/.ai-suite/layer4-evolutionary/validation/validate-suite.sh"

ERRORS=0
PASSES=0

_red()  { [[ -t 1 ]] && printf '\033[31m' || true; }
_grn()  { [[ -t 1 ]] && printf '\033[32m' || true; }
_off()  { [[ -t 1 ]] && printf '\033[0m'  || true; }

pass() { PASSES=$((PASSES + 1)); printf '  %sPASS%s  %s\n' "$(_grn)" "$(_off)" "$*"; }
fail() { ERRORS=$((ERRORS + 1)); printf '  %sFAIL%s  %s\n' "$(_red)" "$(_off)" "$*" >&2; }

echo "=== Phase 3: TDD Implementation Loop (Semantic Validation) ==="

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

# Helper to create a test skill
create_skill() {
  local file="$1"
  local content="$2"
  echo "$content" > "$TMP_DIR/$file"
}

# 1. Missing triggers
create_skill "missing-triggers.md" "---
name: missing-triggers
description: Use when you want to test missing triggers.
---
# Missing Triggers
## Instructions
Do something.
## Negative Constraints
Must not do anything bad.
"

# 2. Missing constraints
create_skill "missing-constraints.md" "---
name: missing-constraints
description: Use when you want to test missing constraints.
triggers:
  - test missing constraints
---
# Missing Constraints
## Instructions
Do something.
"

# 3. Missing instructions
create_skill "missing-instructions.md" "---
name: missing-instructions
description: Use when you want to test missing instructions.
triggers:
  - test missing instructions
---
# Missing Instructions
## Negative Constraints
Must not do anything bad.
"

# 4. Perfect skill
create_skill "perfect-skill.md" "---
name: perfect-skill
description: Use when you want to test a perfect skill.
triggers:
  - test perfect skill
---
# Perfect Skill
## Instructions
Do something.
## Negative Constraints
Must not do anything bad.
"

echo "--- Test 1: Missing Triggers ---"
out1=$(bash "$VALIDATOR" "$TMP_DIR/missing-triggers.md" 2>&1 || true)
if echo "$out1" | grep -q "missing 'triggers:'"; then
  pass "Validator rejected missing triggers"
else
  fail "Validator did NOT reject missing triggers. Output: $out1"
fi

echo "--- Test 2: Missing Constraints ---"
out2=$(bash "$VALIDATOR" "$TMP_DIR/missing-constraints.md" 2>&1 || true)
if echo "$out2" | grep -qi -E "missing.*(negative constraints|safety)"; then
  pass "Validator rejected missing constraints"
else
  fail "Validator did NOT reject missing constraints. Output: $out2"
fi

echo "--- Test 3: Missing Instructions ---"
out3=$(bash "$VALIDATOR" "$TMP_DIR/missing-instructions.md" 2>&1 || true)
if echo "$out3" | grep -qi -E "missing.*(instructions|workflow|role|context)"; then
  pass "Validator rejected missing instructions"
else
  fail "Validator did NOT reject missing instructions. Output: $out3"
fi

echo "--- Test 4: Perfect Skill ---"
out4=$(bash "$VALIDATOR" "$TMP_DIR/perfect-skill.md" 2>&1 || true)
if echo "$out4" | grep -q "0 failed"; then
  pass "Validator accepted perfect skill"
else
  fail "Validator did NOT accept perfect skill. Output: $out4"
fi

if [[ "$ERRORS" -eq 0 ]]; then
  printf '\n%s[semantic-tests] %d checks passed, 0 failed%s\n' "$(_grn)" "$PASSES" "$(_off)"
  exit 0
else
  printf '\n%s[semantic-tests] %d passed, %d FAILED%s\n' "$(_red)" "$PASSES" "$ERRORS" "$(_off)" >&2
  exit 1
fi
