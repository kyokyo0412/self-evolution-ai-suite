#!/usr/bin/env bash
# test-codex-full-install-eut.sh - Comprehensive EUT test for Codex full installation and published package isolation
set -euo pipefail

PASS=0
FAIL=0

pass() {
  printf '  [PASS] %s\n' "$1"
  PASS=$((PASS + 1))
}

fail() {
  printf '  [FAIL] %s\n' "$1" >&2
  FAIL=$((FAIL + 1))
}

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SUITE_CLI="$PROJECT_ROOT/ai-suite"

echo "=== Phase 4: Codex Full Installation & Published Package E2E QA Gate ==="

SANDBOX=$(mktemp -d "${TMPDIR:-/tmp}/eut-codex-full.XXXXXX")
trap 'rm -rf "$SANDBOX"' EXIT

PROJ_DIR="$SANDBOX/project"
HOME_DIR="$SANDBOX/home"
mkdir -p "$PROJ_DIR" "$HOME_DIR"

# -------------------------------------------------------------
# Test 1: Project Scope Enable
# -------------------------------------------------------------
echo ""
echo "--- 1. Testing Project-Scope Codex Enable ---"
(
  export HOME="$HOME_DIR"
  bash "$SUITE_CLI" enable --agent codex --scope project --project "$PROJ_DIR" >/dev/null 2>&1
)

if [[ -f "$PROJ_DIR/AGENTS.md" ]] && grep -q "<!-- ai-suite:start -->" "$PROJ_DIR/AGENTS.md"; then
  pass "Project AGENTS.md created with ai-suite block"
else
  fail "Project AGENTS.md missing or missing start sentinel"
fi

for directive_kw in "Agent General Directives" "Master Code Quality" "1E-Class Security Standards" "Production Safety Guardrails" "Chain of Thought & Transparency"; do
  if grep -q "$directive_kw" "$PROJ_DIR/AGENTS.md"; then
    pass "Project AGENTS.md contains $directive_kw"
  else
    fail "Project AGENTS.md missing $directive_kw"
  fi
done

for dir in skills meta templates scripts directives; do
  if [[ -d "$PROJ_DIR/.codex/$dir" ]] && [[ -n "$(ls -A "$PROJ_DIR/.codex/$dir" 2>/dev/null)" ]]; then
    pass "Project .codex/$dir directory populated"
  else
    fail "Project .codex/$dir missing or empty"
  fi
done

PROJ_MD_RULES=0
if [[ -d "$PROJ_DIR/.codex/rules" ]]; then
  PROJ_MD_RULES=$(find "$PROJ_DIR/.codex/rules" -type f \( -name "*.md" -o -name "*.mdc" \) 2>/dev/null | wc -l | tr -d ' ')
fi
if [[ "$PROJ_MD_RULES" -eq 0 ]]; then
  pass "Project .codex/rules has zero markdown files (reserved for Starlark rules)"
else
  fail "Project .codex/rules contains $PROJ_MD_RULES markdown files"
fi

if [[ -d "$PROJ_DIR/.ai-memory/codex/index" ]]; then
  pass "Codex project memory initialized at .ai-memory/codex/index"
else
  fail "Codex project memory not initialized"
fi

# -------------------------------------------------------------
# Test 2: Project Scope Disable
# -------------------------------------------------------------
echo ""
echo "--- 2. Testing Project-Scope Codex Disable ---"
(
  export HOME="$HOME_DIR"
  bash "$SUITE_CLI" disable --agent codex --scope project --project "$PROJ_DIR" >/dev/null 2>&1
)

if grep -q "<!-- ai-suite:start -->" "$PROJ_DIR/AGENTS.md" 2>/dev/null; then
  fail "Project AGENTS.md still contains ai-suite block after disable"
else
  pass "Project AGENTS.md block cleanly removed after disable"
fi

for dir in skills meta templates scripts directives; do
  if [[ -d "$PROJ_DIR/.codex/$dir" ]]; then
    fail "Project .codex/$dir still exists after disable"
  else
    pass "Project .codex/$dir cleanly removed after disable"
  fi
done

if [[ -d "$PROJ_DIR/.codex" ]]; then
  fail "Project .codex directory still exists after disable"
else
  pass "Project .codex directory cleanly removed after disable"
fi

# -------------------------------------------------------------
# Test 3: Global Scope Enable & Disable
# -------------------------------------------------------------
echo ""
echo "--- 3. Testing Global-Scope Codex Enable & Disable ---"
(
  export HOME="$HOME_DIR"
  bash "$SUITE_CLI" enable --agent codex --scope global >/dev/null 2>&1
)

if [[ -f "$HOME_DIR/.codex/AGENTS.md" ]] && grep -q "<!-- ai-suite:start -->" "$HOME_DIR/.codex/AGENTS.md"; then
  pass "Global ~/.codex/AGENTS.md created with ai-suite block"
else
  fail "Global ~/.codex/AGENTS.md missing or missing sentinel"
fi

for dir in skills meta templates scripts directives; do
  if [[ -d "$HOME_DIR/.codex/$dir" ]] && [[ -n "$(ls -A "$HOME_DIR/.codex/$dir" 2>/dev/null)" ]]; then
    pass "Global ~/.codex/$dir directory populated"
  else
    fail "Global ~/.codex/$dir missing or empty"
  fi
done

GLOBAL_MD_RULES=0
if [[ -d "$HOME_DIR/.codex/rules" ]]; then
  GLOBAL_MD_RULES=$(find "$HOME_DIR/.codex/rules" -type f \( -name "*.md" -o -name "*.mdc" \) 2>/dev/null | wc -l | tr -d ' ')
fi
if [[ "$GLOBAL_MD_RULES" -eq 0 ]]; then
  pass "Global ~/.codex/rules has zero markdown files (reserved for Starlark rules)"
else
  fail "Global ~/.codex/rules contains $GLOBAL_MD_RULES markdown files"
fi

(
  export HOME="$HOME_DIR"
  bash "$SUITE_CLI" disable --agent codex --scope global >/dev/null 2>&1
)

for dir in skills meta templates scripts directives; do
  if [[ -d "$HOME_DIR/.codex/$dir" ]]; then
    fail "Global ~/.codex/$dir still exists after disable"
  else
    pass "Global ~/.codex/$dir cleanly removed after disable"
  fi
done

if grep -q "<!-- ai-suite:start -->" "$HOME_DIR/.codex/AGENTS.md" 2>/dev/null; then
  fail "Global AGENTS.md still contains ai-suite block after disable"
else
  pass "Global AGENTS.md block cleanly removed after disable"
fi

# -------------------------------------------------------------
# Test 4: Published Package Installation & Zero Domain Leakage
# -------------------------------------------------------------
echo ""
echo "--- 4. Testing Published Package Installation for Codex ---"
PKG_TARBALL="$SANDBOX/ai-suite-package.tar.gz"
(
  cd "$PROJECT_ROOT"
  bash "$PROJECT_ROOT/.ai-suite/cli/publish.sh" >/dev/null 2>&1
)
mv "$PROJECT_ROOT/ai-suite-package.tar.gz" "$PKG_TARBALL"

EXTRACT_DIR="$SANDBOX/pkg_extracted"
mkdir -p "$EXTRACT_DIR"
tar -xzf "$PKG_TARBALL" -C "$EXTRACT_DIR"

PKG_ROOT="$EXTRACT_DIR/ai-suite-package"
PUBLISH_PROJ="$SANDBOX/published_proj"
mkdir -p "$PUBLISH_PROJ"

(
  export HOME="$HOME_DIR"
  bash "$PKG_ROOT/ai-suite" enable --agent codex --scope project --project "$PUBLISH_PROJ" >/dev/null 2>&1
)

if [[ -f "$PUBLISH_PROJ/AGENTS.md" ]] && grep -q "<!-- ai-suite:start -->" "$PUBLISH_PROJ/AGENTS.md"; then
  pass "Published package: AGENTS.md created"
else
  fail "Published package: AGENTS.md missing"
fi

for dir in skills meta templates scripts directives; do
  if [[ -d "$PUBLISH_PROJ/.codex/$dir" ]] && [[ -n "$(ls -A "$PUBLISH_PROJ/.codex/$dir" 2>/dev/null)" ]]; then
    pass "Published package: .codex/$dir populated"
  else
    fail "Published package: .codex/$dir missing or empty"
  fi
done

PUB_MD_RULES=0
if [[ -d "$PUBLISH_PROJ/.codex/rules" ]]; then
  PUB_MD_RULES=$(find "$PUBLISH_PROJ/.codex/rules" -type f \( -name "*.md" -o -name "*.mdc" \) 2>/dev/null | wc -l | tr -d ' ')
fi
if [[ "$PUB_MD_RULES" -eq 0 ]]; then
  pass "Published package: .codex/rules has zero markdown files (reserved for Starlark rules)"
else
  fail "Published package: .codex/rules contains $PUB_MD_RULES markdown files"
fi

# Verify zero vmware / broadcom domain leaks in published package framework and installed files
DOMAIN_LEAKS_COUNT=$(grep -riE "vmware|broadcom" "$PKG_ROOT/.ai-suite" "$PUBLISH_PROJ" 2>/dev/null || true)
if [[ -n "$DOMAIN_LEAKS_COUNT" ]]; then
  LEAK_LINES=$(echo "$DOMAIN_LEAKS_COUNT" | wc -l | tr -d ' ')
else
  LEAK_LINES=0
fi

if [[ "$LEAK_LINES" -eq 0 ]]; then
  pass "Zero VMware/Broadcom domain references found in published package framework or installed Codex agent (leak count: 0)"
else
  fail "Found $LEAK_LINES VMware/Broadcom domain references in published package framework or installed files"
fi

echo ""
echo "=== Phase 4 QA Gate Summary: $PASS passed, $FAIL failed ==="
if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
exit 0
