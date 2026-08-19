#!/usr/bin/env bash
# test-meta-install-eut.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ENABLE="$PROJECT_ROOT/ai-suite"

PASS=0; FAIL=0

pass() { printf '  \033[32mPASS\033[0m  %s\n' "$1"; PASS=$((PASS+1)); }
fail() { printf '  \033[31mFAIL\033[0m  %s\n' "$1"; FAIL=$((FAIL+1)); }

make_sandbox() { mktemp -d "${TMPDIR:-/tmp}/meta-eut.XXXXXX"; }

echo "=== EUT: Meta Installation ==="

# Scenario 1: Global install for cursor copies meta files
SB1=$(make_sandbox); trap 'rm -rf "$SB1"' EXIT
(
  export HOME="$SB1"
  bash "$ENABLE" enable --agent cursor --scope global 2>/dev/null
)
if [[ -d "$SB1/.cursor/meta" ]]; then pass "S1a ~/.cursor/meta exists"
else fail "S1a ~/.cursor/meta exists"; fi

if [[ -f "$SB1/.cursor/meta/reflection-protocol.md" ]]; then pass "S1b reflection-protocol.md exists"
else fail "S1b reflection-protocol.md exists"; fi

if grep -q '\.cursor/meta' "$SB1/.cursorrules" 2>/dev/null; then pass "S1c ~/.cursorrules references ~/.cursor/meta"
else fail "S1c ~/.cursorrules references ~/.cursor/meta"; fi

# Scenario 2: Project install for cursor copies meta files
SB2=$(make_sandbox); trap 'rm -rf "$SB2"' EXIT
PROJ2="$SB2/myproj"; mkdir -p "$PROJ2"
(
  export HOME="$SB2"
  bash "$ENABLE" enable --agent cursor --scope project --project "$PROJ2" 2>/dev/null
)
if [[ -d "$PROJ2/.cursor/meta" ]]; then pass "S2a <project>/.cursor/meta exists"
else fail "S2a <project>/.cursor/meta exists"; fi

if [[ -f "$PROJ2/.cursor/meta/reflection-protocol.md" ]]; then pass "S2b reflection-protocol.md exists"
else fail "S2b reflection-protocol.md exists"; fi

if grep -q '\.cursor/meta' "$PROJ2/.cursorrules" 2>/dev/null; then pass "S2c <project>/.cursorrules references <project>/.cursor/meta"
else fail "S2c <project>/.cursorrules references <project>/.cursor/meta"; fi

# Scenario 3: Global install for claude copies meta and skills files
SB3=$(make_sandbox); trap 'rm -rf "$SB3"' EXIT
(
  export HOME="$SB3"
  bash "$ENABLE" enable --agent claude --scope global 2>/dev/null
)
if [[ -d "$SB3/.claude/meta" ]]; then pass "S3a ~/.claude/meta exists"
else fail "S3a ~/.claude/meta exists"; fi

if [[ -d "$SB3/.claude/skills" ]]; then pass "S3b ~/.claude/skills exists"
else fail "S3b ~/.claude/skills exists"; fi

if grep -q '\.claude/meta' "$SB3/.claude/CLAUDE.md" 2>/dev/null; then pass "S3c CLAUDE.md references ~/.claude/meta"
else fail "S3c CLAUDE.md references ~/.claude/meta"; fi

if grep -q '\.claude/skills' "$SB3/.claude/CLAUDE.md" 2>/dev/null; then pass "S3d CLAUDE.md references ~/.claude/skills"
else fail "S3d CLAUDE.md references ~/.claude/skills"; fi

# Scenario 4: Project install for claude copies meta and skills files
SB4=$(make_sandbox); trap 'rm -rf "$SB4"' EXIT
PROJ4="$SB4/myproj"; mkdir -p "$PROJ4"
(
  export HOME="$SB4"
  bash "$ENABLE" enable --agent claude --scope project --project "$PROJ4" 2>/dev/null
)
if [[ -d "$PROJ4/.claude/meta" ]]; then pass "S4a <project>/.claude/meta exists"
else fail "S4a <project>/.claude/meta exists"; fi

if [[ -d "$PROJ4/.claude/skills" ]]; then pass "S4b <project>/.claude/skills exists"
else fail "S4b <project>/.claude/skills exists"; fi

if grep -q '\.claude/meta' "$PROJ4/CLAUDE.md" 2>/dev/null; then pass "S4c CLAUDE.md references <project>/.claude/meta"
else fail "S4c CLAUDE.md references <project>/.claude/meta"; fi

if grep -q '\.claude/skills' "$PROJ4/CLAUDE.md" 2>/dev/null; then pass "S4d CLAUDE.md references <project>/.claude/skills"
else fail "S4d CLAUDE.md references <project>/.claude/skills"; fi

TOTAL=$((PASS+FAIL))
printf '=== %d passed, %d FAILED out of %d ===\n' "$PASS" "$FAIL" "$TOTAL"
[[ $FAIL -eq 0 ]]
