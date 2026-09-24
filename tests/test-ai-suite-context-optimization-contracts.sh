#!/usr/bin/env bash
# tests/test-ai-suite-context-optimization-contracts.sh
# Validates structural contracts, size budgets, and zero-defect quality
# across all AI suite skills, directives, and rules.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

PASS=0
FAIL=0

_red() { printf '\033[31m'; }
_grn() { printf '\033[32m'; }
_off() { printf '\033[0m'; }

pass() {
  PASS=$((PASS + 1))
  printf '  %sPASS%s %s\n' "$(_grn)" "$(_off)" "$*"
}

fail() {
  FAIL=$((FAIL + 1))
  printf '  %sFAIL%s %s\n' "$(_red)" "$(_off)" "$*" >&2
}

echo "=== [SDET Contract Gate] AI Suite Context Optimization & Token Reduction ==="

# Check 1: Directives Structural & Keyword Preservation
DIRECTIVES_DIR="$REPO_ROOT/.ai-suite/layer3-registry/directives"
for d in "$DIRECTIVES_DIR"/*.md; do
  [[ -f "$d" ]] || continue
  base=$(basename "$d")

  if grep -q '^# ' "$d"; then
    pass "$base: Top-level title present"
  else
    fail "$base: Missing top-level title"
  fi

  if grep -qiE '^##+ (Negative Constraints|Refuse-by-Default)' "$d"; then
    pass "$base: Negative Constraints section present"
  else
    fail "$base: Missing Negative Constraints section"
  fi

  if grep -qE '^\- \[[xX]\]' "$d"; then
    pass "$base: Checkbox negative constraints [X] present"
  else
    fail "$base: Missing [X] negative constraint entries"
  fi
done

# Check 2: Core Keywords in agent-directives and code-quality
AGENT_DIRECTIVES="$DIRECTIVES_DIR/agent-directives.md"
CODE_QUALITY="$DIRECTIVES_DIR/code-quality.md"

for kw in "git commit" "summary" "ReadLints" "gofmt" "clang-format" "gitreview" "temporary files" "Dynamic test assertions"; do
  if grep -qi "$kw" "$AGENT_DIRECTIVES"; then
    pass "agent-directives.md: Preserves essential directive keyword '$kw'"
  else
    fail "agent-directives.md: Missing critical keyword '$kw'"
  fi
done

for kw in "50 lines" "Defensive Programming" "1E-Class" "gofmt" "clang-format" "gitreview" "defer" "Anti-Hardcoding"; do
  if grep -qi "$kw" "$CODE_QUALITY"; then
    pass "code-quality.md: Preserves essential standard keyword '$kw'"
  else
    fail "code-quality.md: Missing critical keyword '$kw'"
  fi
done

# Check 3: Clean Empty Lines & Gitreview Red-Flag Prevention
# No file under directives, safety, or core skills may contain space/tab-only empty lines
WHITESPACE_FAILS=0
while IFS= read -r f; do
  if grep -n '^[[:space:]]\+$' "$f" >/dev/null 2>&1; then
    fail "$f: Contains space/tab-only whitespace empty lines (gitreview red flag)"
    WHITESPACE_FAILS=$((WHITESPACE_FAILS + 1))
  fi
done < <(find "$REPO_ROOT/.ai-suite/layer3-registry" "$REPO_ROOT/.ai-suite/layer1-abstraction/agents/cursor" -name "*.md" -o -name "*.mdc")

if [[ $WHITESPACE_FAILS -eq 0 ]]; then
  pass "All registry directives, rules, and skills have 100% clean whitespace on empty lines"
fi

# Check 4: Validate-suite executes with zero errors
if bash "$REPO_ROOT/.ai-suite/layer4-evolutionary/validation/validate-suite.sh" >/dev/null 2>&1; then
  pass "validate-suite.sh reports 0 errors across all skills"
else
  fail "validate-suite.sh reported validation errors"
fi

echo "Summary: $PASS passed, $FAIL failed"
if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
exit 0
