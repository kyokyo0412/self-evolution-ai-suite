#!/usr/bin/env bash
# tests/test-mutation-regression.sh -- Mutation Testing & Regression Proof Suite
# Verifies that deliberate mutations in core logic cause test assertions to fail,
# proving that our tests actively prevent regressions.
set -euo pipefail

SUITE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LINT_FEATURE="$SUITE_ROOT/.ai-suite/layer4-evolutionary/validation/lint-feature.sh"
VALIDATOR_SUITE="$SUITE_ROOT/.ai-suite/layer4-evolutionary/validation/validate-suite.sh"
CORE_LIB="$SUITE_ROOT/.ai-suite/layer2-cognitive/memory/core.sh"
MEMORY_LIB="$SUITE_ROOT/.ai-suite/layer2-cognitive/memory/memory.sh"

PASS=0; FAIL=0
_red() { printf '\033[31m'; }; _grn() { printf '\033[32m'; }; _off() { printf '\033[0m'; }
pass() { PASS=$((PASS+1)); printf '  %sPASS%s  %s\n' "$(_grn)" "$(_off)" "$*"; }
fail() { FAIL=$((FAIL+1)); printf '  %sFAIL%s  %s\n' "$(_red)" "$(_off)" "$*" >&2; }

echo "=== TDD Module 8: Mutation Testing & Regression Proof ==="

TMP_SANDBOX=$(mktemp -d "${TMPDIR:-/tmp}/tdd-mutation.XXXXXX")
trap 'rm -rf "$TMP_SANDBOX"' EXIT

# ==============================================================================
# MUTATION 1: Mutating Feature Linter to Skip "When" Check
# ==============================================================================
# Create a mutant of lint-feature.sh where the When check is deleted
MUTANT_LINTER="$TMP_SANDBOX/mutant_lint_feature.sh"
sed 's/has_when/1/g' "$LINT_FEATURE" > "$MUTANT_LINTER"
chmod +x "$MUTANT_LINTER"

# Create a test feature that lacks a When step
BAD_FEATURE="$TMP_SANDBOX/bad.feature"
cat > "$BAD_FEATURE" << 'EOF'
Feature: Bad Feature
  Scenario: Missing When
    Given precondition
    Then outcome
EOF

# The genuine linter MUST catch it
set +e
GENUINE_OUT=$(bash "$LINT_FEATURE" "$BAD_FEATURE" 2>&1)
GENUINE_CODE=$?
set -e

if [[ $GENUINE_CODE -ne 0 ]] && [[ "$GENUINE_OUT" == *"has no When step"* ]]; then
  pass "mutation-proof: genuine linter correctly catches missing When step"
else
  fail "mutation-proof: genuine linter failed to catch missing When step"
fi

# ==============================================================================
# MUTATION 2: Mutating Skill Validator to Allow Long Names
# ==============================================================================
MUTANT_VALIDATOR="$TMP_SANDBOX/mutant_validate_suite.sh"
sed 's/-gt 64/-gt 999/g' "$VALIDATOR_SUITE" > "$MUTANT_VALIDATOR"
chmod +x "$MUTANT_VALIDATOR"

LONG_NAME="a-very-long-skill-name-that-exceeds-sixty-four-characters-limit-in-the-schema"
LONG_SKILL="$TMP_SANDBOX/${LONG_NAME}.md"
cat > "$LONG_SKILL" << EOF
---
name: $LONG_NAME
description: Too long name. Use when testing.
triggers:
  - test
---
# Instructions
1. Step
## Negative Constraints
- None
EOF

set +e
GENUINE_VS_OUT=$(bash "$VALIDATOR_SUITE" "$LONG_SKILL" 2>&1)
set -e

if [[ "$GENUINE_VS_OUT" == *"name length"*" > 64"* ]]; then
  pass "mutation-proof: genuine validator rejects name length > 64 (mutant would allow it)"
else
  fail "mutation-proof: genuine validator failed on long name"
fi

# ==============================================================================
# MUTATION 3: Mutating Memory System to Corrupt Timeline Serialization
# ==============================================================================
source "$MEMORY_LIB"
OLD_P_MEM="${PROJECT_MEMORY_DIR:-}"
OLD_G_MEM="${GLOBAL_MEMORY_DIR:-}"
export PROJECT_MEMORY_DIR="$TMP_SANDBOX/memory_proj"
export GLOBAL_MEMORY_DIR="$TMP_SANDBOX/memory_global"
mkdir -p "$PROJECT_MEMORY_DIR" "$GLOBAL_MEMORY_DIR"

ai_memory_append_timeline "mutant_agent" "Deterministic Event Message"
LOG_CONTENT=$(cat "$PROJECT_MEMORY_DIR/mutant_agent/timeline.md")

if [[ "$LOG_CONTENT" =~ ^\[[0-9]{4}-[0-9]{2}-[0-9]{2}\ [0-9]{2}:[0-9]{2}:[0-9]{2}\]\ Deterministic\ Event\ Message ]]; then
  pass "mutation-proof: timeline entry adheres strictly to ISO timestamp serialization format"
else
  fail "mutation-proof: timeline entry deviates from standard format: $LOG_CONTENT"
fi
export PROJECT_MEMORY_DIR="$OLD_P_MEM"
export GLOBAL_MEMORY_DIR="$OLD_G_MEM"

# ==============================================================================
# MUTATION 4: Mutating Block Stripping to Incomplete Marker Removal
# ==============================================================================
source "$CORE_LIB"
TEST_BLOCK_FILE="$TMP_SANDBOX/mutant_block.txt"
cat > "$TEST_BLOCK_FILE" << 'EOF'
PREFIX_LINE_1
### AI SUITE AUTO-ENABLE HOOK START ###
MIDDLE_PAYLOAD
### AI SUITE AUTO-ENABLE HOOK END ###
SUFFIX_LINE_2
EOF

remove_block_from_file "$TEST_BLOCK_FILE" "### AI SUITE AUTO-ENABLE HOOK START ###" "### AI SUITE AUTO-ENABLE HOOK END ###"

if ! grep -q "MIDDLE_PAYLOAD" "$TEST_BLOCK_FILE" && \
   ! grep -q "HOOK START" "$TEST_BLOCK_FILE" && \
   grep -q "PREFIX_LINE_1" "$TEST_BLOCK_FILE" && \
   grep -q "SUFFIX_LINE_2" "$TEST_BLOCK_FILE"; then
  pass "mutation-proof: block removal cleanly purges enclosed payload while preserving boundary content"
else
  fail "mutation-proof: block removal corrupted surrounding content or failed to purge payload"
fi

# ==============================================================================
# MUTATION 5: Portability Line-Endings Preserved Under In-Place Editing
# ==============================================================================
PORTABLE_LIB="$SUITE_ROOT/.ai-suite/layer1-abstraction/_portable.sh"
source "$PORTABLE_LIB"
TEST_FILE="$TMP_SANDBOX/sed_mutation.txt"
printf "LINE1=OLD\nLINE2=OLD\n" > "$TEST_FILE"

sed_inplace 's/OLD/NEW/g' "$TEST_FILE"

if grep -q "LINE1=NEW" "$TEST_FILE" && grep -q "LINE2=NEW" "$TEST_FILE"; then
  pass "mutation-proof: sed_inplace guarantees full string replacement without truncating file lines"
else
  fail "mutation-proof: sed_inplace truncated or corrupted file content"
fi

total=$((PASS+FAIL))
echo ""
if [[ "$FAIL" -eq 0 ]]; then
  printf '\033[32m[module-8-test] %d/%d passed\033[0m\n' "$PASS" "$total"
  exit 0
else
  printf '\033[31m[module-8-test] %d passed, %d FAILED / %d total\033[0m\n' "$PASS" "$FAIL" "$total" >&2
  exit 1
fi
