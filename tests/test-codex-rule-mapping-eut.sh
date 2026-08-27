#!/usr/bin/env bash
# tests/test-codex-rule-mapping-eut.sh
# End-to-End User Testing (EUT) for Codex Rule-to-Prompt Mapping
# Verifies clean Markdown in AGENTS.md, .codex/rules/*.md, and published package.

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

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SUITE_CLI="$REPO_ROOT/ai-suite"
WORK_DIR=$(mktemp -d -t codex-rule-map-eut-XXXXXX)
trap 'rm -rf "$WORK_DIR"' EXIT

echo "=== Phase 4: Codex Rule-to-Prompt Mapping E2E QA Gate ==="

# ---------------------------------------------------------
# Test 1: Project-Scope Rule Mapping & Formatting
# ---------------------------------------------------------
echo ""
echo "--- 1. Testing Project-Scope Codex Rule Mapping ---"
PROJ_DIR="$WORK_DIR/test_project"
mkdir -p "$PROJ_DIR"
bash "$SUITE_CLI" enable --agent codex --scope project --project "$PROJ_DIR" >/dev/null

if [[ -f "$PROJ_DIR/AGENTS.md" ]]; then
  pass "Project AGENTS.md created"
else
  fail "Project AGENTS.md missing"
fi

if grep -q "# AI Suite Directives & Rules" "$PROJ_DIR/AGENTS.md"; then
  pass "Project AGENTS.md contains structured directives & rules section"
else
  fail "Project AGENTS.md missing structured directives & rules section"
fi

if grep -E -q '^(alwaysApply:|globs:)' "$PROJ_DIR/AGENTS.md"; then
  fail "Project AGENTS.md contains raw YAML frontmatter lines"
else
  pass "Project AGENTS.md free of raw YAML frontmatter"
fi

MDC_COUNT=0
if [[ -d "$PROJ_DIR/.codex/rules" ]]; then
  MDC_COUNT=$(find "$PROJ_DIR/.codex/rules" -type f \( -name "*.md" -o -name "*.mdc" \) 2>/dev/null | wc -l | tr -d ' ')
fi
if [[ "$MDC_COUNT" -eq 0 ]]; then
  pass "Project .codex/rules contains zero markdown files (reserved for Starlark rules)"
else
  fail "Project .codex/rules contains $MDC_COUNT markdown files"
fi

# ---------------------------------------------------------
# Test 2: Global-Scope Rule Mapping & Formatting
# ---------------------------------------------------------
echo ""
echo "--- 2. Testing Global-Scope Codex Rule Mapping ---"
GLOBAL_HOME="$WORK_DIR/fake_home"
mkdir -p "$GLOBAL_HOME"
HOME="$GLOBAL_HOME" bash "$SUITE_CLI" enable --agent codex --scope global >/dev/null

if [[ -f "$GLOBAL_HOME/.codex/AGENTS.md" ]]; then
  pass "Global AGENTS.md created"
else
  fail "Global AGENTS.md missing"
fi

if grep -E -q '^(alwaysApply:|globs:)' "$GLOBAL_HOME/.codex/AGENTS.md"; then
  fail "Global AGENTS.md contains raw YAML frontmatter lines"
else
  pass "Global AGENTS.md free of raw YAML frontmatter"
fi

GLOBAL_MDC_COUNT=0
if [[ -d "$GLOBAL_HOME/.codex/rules" ]]; then
  GLOBAL_MDC_COUNT=$(find "$GLOBAL_HOME/.codex/rules" -type f \( -name "*.md" -o -name "*.mdc" \) 2>/dev/null | wc -l | tr -d ' ')
fi
if [[ "$GLOBAL_MDC_COUNT" -eq 0 ]]; then
  pass "Global ~/.codex/rules contains zero markdown files (reserved for Starlark rules)"
else
  fail "Global ~/.codex/rules contains $GLOBAL_MDC_COUNT markdown files"
fi

# Clean up global
HOME="$GLOBAL_HOME" bash "$SUITE_CLI" disable --agent codex --scope global >/dev/null
if [[ ! -d "$GLOBAL_HOME/.codex/rules" ]]; then
  pass "Global ~/.codex/rules cleanly removed after disable"
else
  fail "Global ~/.codex/rules still exists after disable"
fi

# ---------------------------------------------------------
# Test 3: Published Package Rule Mapping & Domain Isolation
# ---------------------------------------------------------
echo ""
echo "--- 3. Testing Published Package Rule Mapping for Codex ---"
bash "$REPO_ROOT/.ai-suite/cli/publish.sh" >/dev/null

EXTRACT_DIR="$WORK_DIR/extracted"
mkdir -p "$EXTRACT_DIR"
tar -xzf "$REPO_ROOT/ai-suite-package.tar.gz" -C "$EXTRACT_DIR"
rm -f "$REPO_ROOT/ai-suite-package.tar.gz"

PKG_ROOT=$(find "$EXTRACT_DIR" -maxdepth 1 -mindepth 1 -type d | head -n 1)
PUB_PROJ="$WORK_DIR/pub_project"
mkdir -p "$PUB_PROJ"

(
  cd "$PKG_ROOT"
  bash "$PKG_ROOT/ai-suite" enable --agent codex --scope project --project "$PUB_PROJ" >/dev/null
)

if [[ -f "$PUB_PROJ/AGENTS.md" ]]; then
  pass "Published package: AGENTS.md created"
else
  fail "Published package: AGENTS.md missing"
fi

if grep -E -q '^(alwaysApply:|globs:)' "$PUB_PROJ/AGENTS.md"; then
  fail "Published package: AGENTS.md contains raw YAML frontmatter"
else
  pass "Published package: AGENTS.md free of raw YAML frontmatter"
fi

PUB_MDC_COUNT=0
if [[ -d "$PUB_PROJ/.codex/rules" ]]; then
  PUB_MDC_COUNT=$(find "$PUB_PROJ/.codex/rules" -type f \( -name "*.md" -o -name "*.mdc" \) 2>/dev/null | wc -l | tr -d ' ')
fi
if [[ "$PUB_MDC_COUNT" -eq 0 ]]; then
  pass "Published package: .codex/rules contains zero .mdc files"
else
  fail "Published package: .codex/rules contains $PUB_MDC_COUNT .mdc files"
fi

PUB_LEAKS=$(grep -riE "vmware|broadcom" "$PUB_PROJ" 2>/dev/null || true)
if [[ -z "$PUB_LEAKS" ]]; then
  pass "Zero VMware/Broadcom references in published package Codex installation (leak count: 0)"
else
  fail "Found VMware/Broadcom references in published package Codex installation: $PUB_LEAKS"
fi

# Clean up project
bash "$SUITE_CLI" disable --agent codex --scope project --project "$PROJ_DIR" >/dev/null
if [[ ! -d "$PROJ_DIR/.codex" ]]; then
  pass "Project .codex directory cleanly removed after disable"
else
  fail "Project .codex directory still exists after disable"
fi

echo ""
echo "=== Phase 4 Rule Mapping QA Gate Summary: $PASSED passed, $FAILED failed ==="
if [[ "$FAILED" -gt 0 ]]; then
  exit 1
fi
