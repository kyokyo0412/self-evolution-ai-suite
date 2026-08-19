#!/usr/bin/env bash
# test-validate-suite-semantic-contracts.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUITE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
AI_SUITE="$SUITE_ROOT/.ai-suite"
CONTRACTS="$SCRIPT_DIR/validate-suite-semantic-contracts.md"

ERRORS=0
PASSES=0

_red()  { [[ -t 1 ]] && printf '\033[31m' || true; }
_grn()  { [[ -t 1 ]] && printf '\033[32m' || true; }
_off()  { [[ -t 1 ]] && printf '\033[0m'  || true; }

pass() { PASSES=$((PASSES + 1)); printf '  %sPASS%s  %s\n' "$(_grn)" "$(_off)" "$*"; }
fail() { ERRORS=$((ERRORS + 1)); printf '  %sFAIL%s  %s\n' "$(_red)" "$(_off)" "$*" >&2; }

echo "=== Phase 2: Architectural Contracts Validation ==="

if [[ ! -f "$CONTRACTS" ]]; then
  fail "Contracts file missing: $CONTRACTS"
else
  pass "Contracts file exists"
fi

# We check that the contracts file contains the required rules
if grep -q "V1. Frontmatter Triggers" "$CONTRACTS"; then pass "V1 defined"; else fail "V1 missing"; fi
if grep -q "V2. Negative Constraints" "$CONTRACTS"; then pass "V2 defined"; else fail "V2 missing"; fi
if grep -q "V3. Instructions" "$CONTRACTS"; then pass "V3 defined"; else fail "V3 missing"; fi

if [[ "$ERRORS" -eq 0 ]]; then
  printf '\n%s[contracts] %d checks passed, 0 failed%s\n' "$(_grn)" "$PASSES" "$(_off)"
  exit 0
else
  printf '\n%s[contracts] %d passed, %d FAILED%s\n' "$(_red)" "$PASSES" "$ERRORS" "$(_off)" >&2
  exit 1
fi
