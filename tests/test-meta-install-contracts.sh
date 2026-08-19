#!/usr/bin/env bash
# test-meta-install-contracts.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CORE_LIB="$PROJECT_ROOT/.ai-suite/layer2-cognitive/memory/core.sh"

PASS=0; FAIL=0

pass() { printf '  \033[32mPASS\033[0m  %s\n' "$1"; PASS=$((PASS+1)); }
fail() { printf '  \033[31mFAIL\033[0m  %s\n' "$1"; FAIL=$((FAIL+1)); }

source "$CORE_LIB"

echo "=== Contract Tests: Meta Installation ==="

# Test _mirror_meta
SB=$(mktemp -d "${TMPDIR:-/tmp}/meta-contracts.XXXXXX")
trap 'rm -rf "$SB"' EXIT

if type _mirror_meta >/dev/null 2>&1; then
  pass "_mirror_meta function exists"
else
  fail "_mirror_meta function exists"
fi

if type _mirror_skills >/dev/null 2>&1; then
  pass "_mirror_skills function exists"
else
  fail "_mirror_skills function exists"
fi

if type _remove_meta >/dev/null 2>&1; then
  pass "_remove_meta function exists"
else
  fail "_remove_meta function exists"
fi

if type _remove_skills >/dev/null 2>&1; then
  pass "_remove_skills function exists"
else
  fail "_remove_skills function exists"
fi

TOTAL=$((PASS+FAIL))
printf '=== %d passed, %d FAILED out of %d ===\n' "$PASS" "$FAIL" "$TOTAL"
[[ $FAIL -eq 0 ]]
