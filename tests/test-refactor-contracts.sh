#!/usr/bin/env bash
set -uo pipefail

SUITE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AI_SUITE="$SUITE_ROOT/.ai-suite"

PASS=0
FAIL=0

_red()  { [[ -t 1 ]] && printf '\033[31m' || true; }
_grn()  { [[ -t 1 ]] && printf '\033[32m' || true; }
_off()  { [[ -t 1 ]] && printf '\033[0m'  || true; }

pass() { PASS=$((PASS+1)); printf '  %sPASS%s  %s\n' "$(_grn)" "$(_off)" "$*"; }
fail() { FAIL=$((FAIL+1)); printf '  %sFAIL%s  %s\n' "$(_red)" "$(_off)" "$*"; }

dir_exists()  { if [[ -d "$2" ]]; then pass "$1"; else fail "$1 -- dir not found: $2"; fi; }
file_exists() { if [[ -f "$2" ]]; then pass "$1"; else fail "$1 -- file not found: $2"; fi; }

echo "=== Phase 2 Contract Tests: .ai-suite/ refactoring ==="
echo ""
echo "--- D1: root directory ---"
dir_exists "D1a: .ai-suite/ exists"                   "$AI_SUITE"

echo ""
echo "--- D2/D3: tier directories ---"
dir_exists "D2a: layer3-registry/core/"               "$AI_SUITE/layer3-registry/core"
dir_exists "D2b: layer1-abstraction/agents/cursor/skills/" "$AI_SUITE/layer1-abstraction/agents/cursor/skills"
dir_exists "D2c: layer1-abstraction/agents/claude/"   "$AI_SUITE/layer1-abstraction/agents/claude"
dir_exists "D3a: layer2-cognitive/templates/"         "$AI_SUITE/layer2-cognitive/templates"
dir_exists "D4:  layer4-evolutionary/validation/"     "$AI_SUITE/layer4-evolutionary/validation"

echo ""
echo "--- CS: core skills ---"
file_exists "CS1: tdd-team.md"           "$AI_SUITE/layer3-registry/core/tdd-team.md"
file_exists "CS2: codebase-deepdoc.md"   "$AI_SUITE/layer3-registry/core/codebase-deepdoc.md"

echo ""
echo "--- AS: cursor agent skills ---"
file_exists "AS1: ai-suite-architect.md" "$AI_SUITE/layer1-abstraction/agents/cursor/skills/ai-suite-architect.md"
file_exists "AS2: prompt-developer.md"   "$AI_SUITE/layer1-abstraction/agents/cursor/skills/prompt-developer.md"

echo ""
echo "--- AS: cursor skills absent from core/ ---"
if [[ ! -f "$AI_SUITE/layer3-registry/core/ai-suite-architect.md" ]]; then
  pass "AS3: ai-suite-architect not in layer3-registry/core/ (correct)"
else
  fail "AS3: ai-suite-architect incorrectly placed in layer3-registry/core/"
fi

echo ""
echo "--- core templates ---"
file_exists "CT1: codebase-deepdoc-brief.md"  "$AI_SUITE/layer2-cognitive/templates/codebase-deepdoc-brief.md"

echo ""
echo "--- meta scripts ---"
file_exists "M1: _portable.sh"           "$AI_SUITE/layer1-abstraction/_portable.sh"
file_exists "M2: validate-suite.sh"      "$AI_SUITE/layer4-evolutionary/validation/validate-suite.sh"
file_exists "M3: reflection-protocol.md" "$AI_SUITE/layer4-evolutionary/reflection/reflection-protocol.md"
file_exists "M4: production-safety.md"   "$AI_SUITE/layer3-registry/safety/production-safety.md"

echo ""
echo "--- adapter files ---"
file_exists "AD1: cursor adapter"  "$AI_SUITE/layer1-abstraction/agents/cursor/adapter.sh"
file_exists "AD2: claude adapter"  "$AI_SUITE/layer1-abstraction/agents/claude/adapter.sh"

echo ""
total=$((PASS + FAIL))
if [[ "$FAIL" -eq 0 ]]; then
  printf '\033[32m[contract-test] %d passed, 0 failed\033[0m\n' "$PASS"
  exit 0
else
  printf '\033[31m[contract-test] %d passed, %d FAILED / %d total\033[0m\n' "$PASS" "$FAIL" "$total" >&2
  exit 1
fi
