#!/usr/bin/env bash
set -euo pipefail

# test-code-formatting-contracts.sh
# Validates that code formatting & style directives are thoroughly defined across source directives,
# core skills, and deployed rule templates.

CODE_QUALITY_FILE=".ai-suite/layer3-registry/directives/code-quality.md"
AGENT_DIRECTIVES_FILE=".ai-suite/layer3-registry/directives/agent-directives.md"
TDD_TEAM_FILE=".ai-suite/layer3-registry/core/tdd-team.md"
AUTONOMOUS_TEAM_FILE=".ai-suite/layer3-registry/core/autonomous-team.md"
AI_REVIEW_FIX_FILE=".ai-suite/layer3-registry/core/ai-review-fix.md"
PROMPT_COMPILER_FILE=".ai-suite/layer2-cognitive/meta-compiler/prompt-compiler.md"

echo "=== [SDET Contract Gate] Validating Code Formatting Directives ==="

FAILURES=0

check_pattern() {
  local file="$1"
  local pattern="$2"
  local desc="$3"

  if [ ! -f "$file" ]; then
    echo "  [FAIL] File missing: $file ($desc)"
    FAILURES=$((FAILURES + 1))
    return
  fi

  if grep -qiE "$pattern" "$file"; then
    echo "  [PASS] $file -> $desc"
  else
    echo "  [FAIL] $file -> Missing: $desc (pattern: $pattern)"
    FAILURES=$((FAILURES + 1))
  fi
}

echo "1. Checking Code Quality Directive ($CODE_QUALITY_FILE)..."
check_pattern "$CODE_QUALITY_FILE" "gofmt" "Go code aligns to gofmt standard"
check_pattern "$CODE_QUALITY_FILE" "clang-format" "C code adheres to clang-format"
check_pattern "$CODE_QUALITY_FILE" "(empty lines|blank lines|spaces/tabs|spaces or tabs|trailing whitespace)" "No space/tab-only empty lines"
check_pattern "$CODE_QUALITY_FILE" "(unchanged code|only.*(new|chang|modified)|scope)" "Only format changed/new lines, do not format unchanged code"

echo "2. Checking Agent General Directives ($AGENT_DIRECTIVES_FILE)..."
check_pattern "$AGENT_DIRECTIVES_FILE" "gofmt" "Agent directives mention gofmt"
check_pattern "$AGENT_DIRECTIVES_FILE" "clang-format" "Agent directives mention clang-format"
check_pattern "$AGENT_DIRECTIVES_FILE" "(empty lines|trailing whitespace|spaces/tabs|spaces or tabs)" "Agent directives forbid space/tab-only empty lines"
check_pattern "$AGENT_DIRECTIVES_FILE" "(unchanged code|only.*(new|chang|modified))" "Agent directives restrict formatting scope to changed lines"
check_pattern "$AGENT_DIRECTIVES_FILE" "Negative Constraints" "Agent directives negative constraints section exists"

echo "3. Checking Core Code-Generation Skills..."
check_pattern "$TDD_TEAM_FILE" "(gofmt|clang-format|formatting standards|code style)" "tdd-team enforces code formatting standards"
check_pattern "$TDD_TEAM_FILE" "(unchanged code|only.*(new|chang|modified)|empty lines)" "tdd-team enforces selective formatting and clean empty lines"

check_pattern "$AUTONOMOUS_TEAM_FILE" "(gofmt|clang-format|formatting standards|code style)" "autonomous-team enforces code formatting standards"
check_pattern "$AI_REVIEW_FIX_FILE" "(formatting|code style|gofmt|clang-format)" "ai-review-fix enforces code formatting standards"
check_pattern "$PROMPT_COMPILER_FILE" "(formatting|code style|gofmt|clang-format)" "prompt-compiler includes formatting standards in prompt constraints"

echo "=== Summary of Contract Verification ==="
if [ "$FAILURES" -gt 0 ]; then
  echo "FAIL: Total failures: $FAILURES"
  exit 1
fi

echo "PASS: All code formatting contracts successfully verified."
exit 0
