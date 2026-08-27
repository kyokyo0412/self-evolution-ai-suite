#!/usr/bin/env bash
# tests/test-codex-starlark-rules-eut.sh
# End-to-End User Testing (EUT) for Codex Starlark Rules vs AGENTS.md Markdown Migration

set -euo pipefail

PASSED=0
FAILED=0

pass() {
  echo "  [PASS] $1"
  PASSED=$((PASSED + 1))
}

fail() {
  echo "  [FAIL] $1"
  FAILED=$((FAILED + 1))
}

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SUITE_CLI="$PROJECT_ROOT/ai-suite"
SANDBOX=$(mktemp -d "${TMPDIR:-/tmp}/eut-codex-starlark.XXXXXX")
trap 'rm -rf "$SANDBOX"' EXIT

echo "=== Phase 4: Codex Starlark Rules vs AGENTS.md Migration E2E QA Gate ==="

PROJ_DIR="$SANDBOX/project"
HOME_DIR="$SANDBOX/home"
mkdir -p "$PROJ_DIR" "$HOME_DIR"

# -------------------------------------------------------------
# 1. Project-Scope Installation & Prompt Migration
# -------------------------------------------------------------
echo ""
echo "--- 1. Testing Project Scope Installation & Prompt Migration ---"
(
  export HOME="$HOME_DIR"
  bash "$SUITE_CLI" enable --agent codex --scope project --project "$PROJ_DIR" >/dev/null 2>&1
)

if [[ -f "$PROJ_DIR/AGENTS.md" ]] && grep -q "<!-- ai-suite:start -->" "$PROJ_DIR/AGENTS.md"; then
  pass "Project AGENTS.md created with managed ai-suite block"
else
  fail "Project AGENTS.md missing"
fi

if grep -q "## AI Suite Directives & Rules" "$PROJ_DIR/AGENTS.md"; then
  pass "Project AGENTS.md contains structured ## AI Suite Directives & Rules section"
else
  fail "Project AGENTS.md missing directives & rules section"
fi

for directive_kw in "Agent General Directives" "Master Code Quality" "1E-Class Security Standards" "Production Safety Guardrails"; do
  if grep -q "$directive_kw" "$PROJ_DIR/AGENTS.md"; then
    pass "Project AGENTS.md inlines: $directive_kw"
  else
    fail "Project AGENTS.md missing inlined: $directive_kw"
  fi
done

if grep -E -q '^(alwaysApply:|globs:)' "$PROJ_DIR/AGENTS.md"; then
  fail "Project AGENTS.md contains raw YAML frontmatter headers"
else
  pass "Project AGENTS.md cleanly stripped of YAML frontmatter headers"
fi

# Confirm .codex/rules contains zero markdown prompt rules
if [[ -d "$PROJ_DIR/.codex/rules" ]]; then
  MD_COUNT=$(find "$PROJ_DIR/.codex/rules" -type f \( -name "*.md" -o -name "*.mdc" \) 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$MD_COUNT" -eq 0 ]]; then
    pass "Project .codex/rules has zero markdown files (reserved for Starlark rules)"
  else
    fail "Project .codex/rules contains $MD_COUNT markdown files"
  fi
else
  pass "Project .codex/rules contains zero markdown prompt rules"
fi

# Confirm skills, meta, templates, scripts, directives are populated
for dir in skills meta templates scripts directives; do
  if [[ -d "$PROJ_DIR/.codex/$dir" ]] && [[ -n "$(ls -A "$PROJ_DIR/.codex/$dir" 2>/dev/null)" ]]; then
    pass "Project .codex/$dir directory populated"
  else
    fail "Project .codex/$dir missing or empty"
  fi
done

# -------------------------------------------------------------
# 2. Global-Scope Installation & Prompt Migration
# -------------------------------------------------------------
echo ""
echo "--- 2. Testing Global Scope Installation & Prompt Migration ---"
(
  export HOME="$HOME_DIR"
  bash "$SUITE_CLI" enable --agent codex --scope global >/dev/null 2>&1
)

if [[ -f "$HOME_DIR/.codex/AGENTS.md" ]] && grep -q "<!-- ai-suite:start -->" "$HOME_DIR/.codex/AGENTS.md"; then
  pass "Global ~/.codex/AGENTS.md created with managed block"
else
  fail "Global ~/.codex/AGENTS.md missing"
fi

if grep -E -q '^(alwaysApply:|globs:)' "$HOME_DIR/.codex/AGENTS.md"; then
  fail "Global AGENTS.md contains raw YAML frontmatter headers"
else
  pass "Global AGENTS.md cleanly stripped of YAML frontmatter headers"
fi

if [[ -d "$HOME_DIR/.codex/rules" ]]; then
  GLOBAL_MD_COUNT=$(find "$HOME_DIR/.codex/rules" -type f \( -name "*.md" -o -name "*.mdc" \) 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$GLOBAL_MD_COUNT" -eq 0 ]]; then
    pass "Global ~/.codex/rules has zero markdown files (reserved for Starlark rules)"
  else
    fail "Global ~/.codex/rules contains $GLOBAL_MD_COUNT markdown files"
  fi
else
  pass "Global ~/.codex/rules contains zero markdown prompt rules"
fi

# -------------------------------------------------------------
# 3. Uninstallation
# -------------------------------------------------------------
echo ""
echo "--- 3. Testing Uninstallation ---"
(
  export HOME="$HOME_DIR"
  bash "$SUITE_CLI" disable --agent codex --scope project --project "$PROJ_DIR" >/dev/null 2>&1
  bash "$SUITE_CLI" disable --agent codex --scope global >/dev/null 2>&1
)

if ! grep -q "<!-- ai-suite:start -->" "$PROJ_DIR/AGENTS.md" 2>/dev/null; then
  pass "Project AGENTS.md block cleanly removed"
else
  fail "Project AGENTS.md still has ai-suite block"
fi

if ! grep -q "<!-- ai-suite:start -->" "$HOME_DIR/.codex/AGENTS.md" 2>/dev/null; then
  pass "Global AGENTS.md block cleanly removed"
else
  fail "Global AGENTS.md still has ai-suite block"
fi

# -------------------------------------------------------------
# 4. Published Package Zero Domain Leakage
# -------------------------------------------------------------
echo ""
echo "--- 4. Testing Published Package Installation ---"
(
  cd "$PROJECT_ROOT"
  bash "$PROJECT_ROOT/.ai-suite/cli/publish.sh" >/dev/null 2>&1
)
PKG_TAR="$SANDBOX/ai-suite-package.tar.gz"
mv "$PROJECT_ROOT/ai-suite-package.tar.gz" "$PKG_TAR"

EXTRACT_DIR="$SANDBOX/pkg_test"
mkdir -p "$EXTRACT_DIR"
tar -xzf "$PKG_TAR" -C "$EXTRACT_DIR"

PUB_PROJ="$SANDBOX/pub_proj"
mkdir -p "$PUB_PROJ"
(
  export HOME="$HOME_DIR"
  bash "$EXTRACT_DIR/ai-suite-package/ai-suite" enable --agent codex --scope project --project "$PUB_PROJ" >/dev/null 2>&1
)

if [[ -f "$PUB_PROJ/AGENTS.md" ]] && grep -q "<!-- ai-suite:start -->" "$PUB_PROJ/AGENTS.md"; then
  pass "Published package: AGENTS.md created"
else
  fail "Published package: AGENTS.md missing"
fi

PUB_LEAKS=$(grep -riE "vmware|broadcom" "$PUB_PROJ" 2>/dev/null || true | wc -l | tr -d ' ')
if [[ "$PUB_LEAKS" -eq 0 ]]; then
  pass "Zero VMware/Broadcom references in published package Codex installation"
else
  fail "Found $PUB_LEAKS VMware/Broadcom references in published package"
fi

echo ""
echo "=== Phase 4 QA Gate Summary: $PASSED passed, $FAILED failed ==="
if [[ "$FAILED" -gt 0 ]]; then
  exit 1
fi
