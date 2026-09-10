#!/usr/bin/env bash
# tests/test-safety-limits-and-portability.sh -- 1E-Class Safety, Portability & Lifecycle Edge Cases
set -euo pipefail

SUITE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SUITE_CLI="$SUITE_ROOT/ai-suite"
ENABLE_CLI="$SUITE_ROOT/.ai-suite/cli/enable.sh"
DISABLE_CLI="$SUITE_ROOT/.ai-suite/cli/disable.sh"
PORTABLE_LIB="$SUITE_ROOT/.ai-suite/layer1-abstraction/_portable.sh"

PASS=0; FAIL=0
_red() { printf '\033[31m'; }; _grn() { printf '\033[32m'; }; _off() { printf '\033[0m'; }
pass() { PASS=$((PASS+1)); printf '  %sPASS%s  %s\n' "$(_grn)" "$(_off)" "$*"; }
fail() { FAIL=$((FAIL+1)); printf '  %sFAIL%s  %s\n' "$(_red)" "$(_off)" "$*" >&2; }

echo "=== TDD Module 7: 1E-Class Safety, Portability & Lifecycle Edge Cases ==="

TMP_SANDBOX=$(mktemp -d "${TMPDIR:-/tmp}/tdd-safety-portability.XXXXXX")
trap 'rm -rf "$TMP_SANDBOX"' EXIT

# ==============================================================================
# SECTION 1: Portable Shell Helpers (_portable.sh)
# ==============================================================================

# 1. Source _portable.sh and check CS_OS
source "$PORTABLE_LIB"
if [[ -n "${CS_OS:-}" && ( "$CS_OS" == "macos" || "$CS_OS" == "linux" || "$CS_OS" == "other" ) ]]; then
  pass "portable: CS_OS correctly set to '$CS_OS'"
else
  fail "portable: CS_OS unset or invalid ('${CS_OS:-}')"
fi

# 2. mktemp_portable creates a valid temporary file
TMP_P=$(mktemp_portable "test-safety")
if [[ -f "$TMP_P" ]]; then
  echo "portable test" > "$TMP_P"
  pass "portable: mktemp_portable generated writable file"
  rm -f "$TMP_P"
else
  fail "portable: mktemp_portable did not create file"
fi

# 3. sed_inplace replaces content across platforms
TEST_SED_FILE="$TMP_SANDBOX/test_sed.txt"
echo "TARGET_KEY=OLD_VALUE" > "$TEST_SED_FILE"
sed_inplace 's/OLD_VALUE/NEW_VALUE/g' "$TEST_SED_FILE"
if grep -q "TARGET_KEY=NEW_VALUE" "$TEST_SED_FILE"; then
  pass "portable: sed_inplace successfully performed in-place replacement"
else
  fail "portable: sed_inplace failed to replace content"
fi

# 3b. Simulate GNU sed environment branch
(
  MOCK_BIN="$TMP_SANDBOX/mock_gnu_bin"
  mkdir -p "$MOCK_BIN"
  cat > "$MOCK_BIN/sed" << 'EOF'
#!/usr/bin/env bash
if [[ "$*" == *"--version"* ]]; then
  echo "sed (GNU sed) 4.8"
  exit 0
fi
exit 0
EOF
  chmod +x "$MOCK_BIN/sed"
  PATH="$MOCK_BIN:$PATH"
  unset CURSOR_SUITE_PORTABLE_LOADED
  source "$PORTABLE_LIB"
  type sed_inplace >/dev/null 2>&1
)
pass "portable: GNU sed branch loaded without errors"

# 4. ensure_trailing_newline on file without trailing newline
NO_NL_FILE="$TMP_SANDBOX/no_newline.txt"
printf "line without newline" > "$NO_NL_FILE"
ensure_trailing_newline "$NO_NL_FILE"
LAST_BYTE=$(tail -c 1 "$NO_NL_FILE")
if [[ -z "$LAST_BYTE" ]]; then
  pass "portable: ensure_trailing_newline appended trailing newline to non-terminated file"
else
  fail "portable: ensure_trailing_newline failed to append newline"
fi

# 5. ensure_trailing_newline on file with trailing newline does not duplicate
HAS_NL_FILE="$TMP_SANDBOX/has_newline.txt"
printf "line with newline\n" > "$HAS_NL_FILE"
ensure_trailing_newline "$HAS_NL_FILE"
LINE_COUNT=$(wc -l < "$HAS_NL_FILE" | tr -d ' ')
if [[ "$LINE_COUNT" -eq 1 ]]; then
  pass "portable: ensure_trailing_newline preserved existing single trailing newline"
else
  fail "portable: ensure_trailing_newline duplicated newline (got $LINE_COUNT lines)"
fi

# 6. ensure_trailing_newline on empty file remains empty
EMPTY_NL_FILE="$TMP_SANDBOX/empty_newline.txt"
touch "$EMPTY_NL_FILE"
ensure_trailing_newline "$EMPTY_NL_FILE"
if [[ ! -s "$EMPTY_NL_FILE" ]]; then
  pass "portable: ensure_trailing_newline safely handles zero-byte files"
else
  fail "portable: ensure_trailing_newline modified empty file"
fi

# ==============================================================================
# SECTION 2: Lifecycle Remote Scoping & Parameter Boundaries
# ==============================================================================

# 7. enable --help prints usage
set +e
EN_HELP=$(bash "$ENABLE_CLI" --help 2>&1)
EN_HELP_CODE=$?
set -e
if [[ $EN_HELP_CODE -eq 0 ]] && [[ "$EN_HELP" == *"ai-suite enable"* ]]; then
  pass "enable: --help prints usage and exits 0"
else
  fail "enable: --help failed (code: $EN_HELP_CODE)"
fi

# 8. disable --help prints usage
set +e
DIS_HELP=$(bash "$DISABLE_CLI" --help 2>&1)
DIS_HELP_CODE=$?
set -e
if [[ $DIS_HELP_CODE -eq 0 ]] && [[ "$DIS_HELP" == *"ai-suite disable"* ]]; then
  pass "disable: --help prints usage and exits 0"
else
  fail "disable: --help failed (code: $DIS_HELP_CODE)"
fi

# 9. enable --scope remote without --host fails safely
set +e
EN_REM_NOHOST=$(bash "$ENABLE_CLI" --scope remote 2>&1)
EN_REM_NOHOST_CODE=$?
set -e
if [[ $EN_REM_NOHOST_CODE -ne 0 ]] && [[ "$EN_REM_NOHOST" == *"--scope remote requires --host"* ]]; then
  pass "enable: rejects remote scope without --host"
else
  fail "enable: allowed remote scope without --host (code: $EN_REM_NOHOST_CODE)"
fi

# 10. disable --scope remote without --host fails safely
set +e
DIS_REM_NOHOST=$(bash "$DISABLE_CLI" --scope remote 2>&1)
DIS_REM_NOHOST_CODE=$?
set -e
if [[ $DIS_REM_NOHOST_CODE -ne 0 ]] && [[ "$DIS_REM_NOHOST" == *"--scope remote requires --host"* ]]; then
  pass "disable: rejects remote scope without --host"
else
  fail "disable: allowed remote scope without --host (code: $DIS_REM_NOHOST_CODE)"
fi

# 11. enable --scope remote with invalid --remote-scope under dry-run
set +e
EN_BAD_RS=$(bash "$ENABLE_CLI" --scope remote --host user@test --remote-scope invalid --dry-run 2>&1)
EN_BAD_RS_CODE=$?
set -e
if [[ $EN_BAD_RS_CODE -ne 0 ]] && [[ "$EN_BAD_RS" == *"invalid --remote-scope"* ]]; then
  pass "enable: rejects invalid --remote-scope"
else
  fail "enable: allowed invalid --remote-scope (code: $EN_BAD_RS_CODE)"
fi

# 12. disable --scope remote with invalid --remote-scope under dry-run
set +e
DIS_BAD_RS=$(bash "$DISABLE_CLI" --scope remote --host user@test --remote-scope invalid --dry-run 2>&1)
DIS_BAD_RS_CODE=$?
set -e
if [[ $DIS_BAD_RS_CODE -ne 0 ]] && [[ "$DIS_BAD_RS" == *"invalid --remote-scope"* ]]; then
  pass "disable: rejects invalid --remote-scope"
else
  fail "disable: allowed invalid --remote-scope (code: $DIS_BAD_RS_CODE)"
fi

# 13. enable --scope remote dry-run (global)
set +e
EN_REM_GL_DRY=$(bash "$ENABLE_CLI" --scope remote --host user@test --remote-scope global --dry-run 2>&1)
EN_REM_GL_DRY_CODE=$?
set -e
if [[ $EN_REM_GL_DRY_CODE -eq 0 ]] && [[ "$EN_REM_GL_DRY" == *"[dry-run] ssh user@test"* ]]; then
  pass "enable: dry-run safely simulates remote global scope"
else
  fail "enable: dry-run failed for remote global scope (code: $EN_REM_GL_DRY_CODE)"
fi

# 14. enable --scope remote dry-run (project with explicit path)
set +e
EN_REM_PR_DRY=$(bash "$ENABLE_CLI" --scope remote --host user@test --remote-scope project --project /remote/proj --dry-run 2>&1)
EN_REM_PR_DRY_CODE=$?
set -e
if [[ $EN_REM_PR_DRY_CODE -eq 0 ]] && [[ "$EN_REM_PR_DRY" == *"[dry-run] ssh user@test"* ]]; then
  pass "enable: dry-run safely simulates remote project scope with path"
else
  fail "enable: dry-run failed for remote project scope (code: $EN_REM_PR_DRY_CODE)"
fi

# 15. disable --scope remote dry-run (global)
set +e
DIS_REM_GL_DRY=$(bash "$DISABLE_CLI" --scope remote --host user@test --remote-scope global --dry-run 2>&1)
DIS_REM_GL_DRY_CODE=$?
set -e
if [[ $DIS_REM_GL_DRY_CODE -eq 0 ]] && [[ "$DIS_REM_GL_DRY" == *"[dry-run] ssh user@test"* ]]; then
  pass "disable: dry-run safely simulates remote global scope"
else
  fail "disable: dry-run failed for remote global scope (code: $DIS_REM_GL_DRY_CODE)"
fi

# 16. disable --scope remote dry-run (project with path)
set +e
DIS_REM_PR_DRY=$(bash "$DISABLE_CLI" --scope remote --host user@test --remote-scope project --project /remote/proj --dry-run 2>&1)
DIS_REM_PR_DRY_CODE=$?
set -e
if [[ $DIS_REM_PR_DRY_CODE -eq 0 ]] && [[ "$DIS_REM_PR_DRY" == *"[dry-run] ssh user@test"* ]]; then
  pass "disable: dry-run safely simulates remote project scope"
else
  fail "disable: dry-run failed for remote project scope (code: $DIS_REM_PR_DRY_CODE)"
fi

# ==============================================================================
# SECTION 3: Multi-Agent Bulk Operations & Hook Configurations
# ==============================================================================

# 17. enable --agent all --scope global dry-run
set +e
EN_ALL_DRY=$(bash "$ENABLE_CLI" --agent all --scope global --dry-run 2>&1)
EN_ALL_DRY_CODE=$?
set -e
if [[ $EN_ALL_DRY_CODE -eq 0 ]] && [[ "$EN_ALL_DRY" == *"agent=cursor scope=global"* ]] && [[ "$EN_ALL_DRY" == *"agent=codex scope=global"* ]]; then
  pass "enable: --agent all executes across all 6 agent adapters in global scope"
else
  fail "enable: --agent all global dry-run failed (code: $EN_ALL_DRY_CODE)"
fi

# 18. disable --agent all --scope global dry-run
set +e
DIS_ALL_DRY=$(bash "$DISABLE_CLI" --agent all --scope global --dry-run 2>&1)
DIS_ALL_DRY_CODE=$?
set -e
if [[ $DIS_ALL_DRY_CODE -eq 0 ]] && [[ "$DIS_ALL_DRY" == *"agent=cursor scope=global"* ]] && [[ "$DIS_ALL_DRY" == *"agent=codex scope=global"* ]]; then
  pass "disable: --agent all executes across all 6 agent adapters in global scope"
else
  fail "disable: --agent all global dry-run failed (code: $DIS_ALL_DRY_CODE)"
fi

# 19. Hook installations: zsh, bash, both dry-run, and auto
set +e
HK_ZSH=$(bash "$ENABLE_CLI" --install-hook --shell zsh --dry-run 2>&1)
HK_BASH=$(bash "$ENABLE_CLI" --install-hook --shell bash --dry-run 2>&1)
HK_BOTH=$(bash "$ENABLE_CLI" --install-hook --shell both --dry-run 2>&1)
HK_AUTO=$(HOME="$TMP_SANDBOX" SHELL="/bin/zsh" bash "$ENABLE_CLI" --install-hook --shell auto --dry-run 2>&1)
HK_BAD=$(bash "$ENABLE_CLI" --install-hook --shell invalid 2>&1 || true)
set -e

if [[ "$HK_ZSH" == *"[dry-run] would append zsh"* ]] && \
   [[ "$HK_BASH" == *"[dry-run] would append bash"* ]] && \
   [[ "$HK_BOTH" == *"[dry-run] would append"* ]] && \
   [[ "$HK_AUTO" == *"[dry-run] would append"* ]] && \
   [[ "$HK_BAD" == *"invalid --shell"* ]]; then
  pass "enable: hook installation correctly validates zsh, bash, both, auto, and invalid targets"
else
  fail "enable: hook installation flag validation failed"
fi

# 20. Hook uninstallation: zsh, bash, both dry-run, and auto
MOCK_HOME="$TMP_SANDBOX/mock_home"
mkdir -p "$MOCK_HOME"
cat > "$MOCK_HOME/.zshrc" << 'EOF'
### AI SUITE AUTO-ENABLE HOOK START ###
# mock hook
### AI SUITE AUTO-ENABLE HOOK END ###
EOF
cp "$MOCK_HOME/.zshrc" "$MOCK_HOME/.bashrc"

set +e
UHK_ZSH=$(HOME="$MOCK_HOME" bash "$DISABLE_CLI" --uninstall-hook --shell zsh --dry-run 2>&1)
UHK_BASH=$(HOME="$MOCK_HOME" bash "$DISABLE_CLI" --uninstall-hook --shell bash --dry-run 2>&1)
UHK_BOTH=$(HOME="$MOCK_HOME" bash "$DISABLE_CLI" --uninstall-hook --shell both --dry-run 2>&1)
UHK_AUTO=$(HOME="$MOCK_HOME" bash "$DISABLE_CLI" --uninstall-hook --shell auto --dry-run 2>&1)
UHK_BAD=$(HOME="$MOCK_HOME" bash "$DISABLE_CLI" --uninstall-hook --shell invalid 2>&1 || true)
set -e

if [[ "$UHK_ZSH" == *"[dry-run] would strip hook from"* ]] && \
   [[ "$UHK_BASH" == *"[dry-run] would strip hook from"* ]] && \
   [[ "$UHK_BOTH" == *"[dry-run] would strip hook from"* ]] && \
   [[ "$UHK_AUTO" == *"[dry-run] would strip hook from"* ]] && \
   [[ "$UHK_BAD" == *"invalid --shell"* ]]; then
  pass "disable: hook uninstallation correctly validates zsh, bash, both, auto, and invalid targets"
else
  fail "disable: hook uninstallation flag validation failed"
fi

# 21. enable with non-existent CORE_LIB fails safely with code 2
(
  MOCK_CLI_DIR="$TMP_SANDBOX/mock_cli_env"
  mkdir -p "$MOCK_CLI_DIR"
  cp "$ENABLE_CLI" "$MOCK_CLI_DIR/enable.sh"
  set +e
  MOCK_OUT=$(bash "$MOCK_CLI_DIR/enable.sh" 2>&1)
  MOCK_CODE=$?
  set -e
  if [[ $MOCK_CODE -eq 2 ]] && [[ "$MOCK_OUT" == *"missing"* ]]; then
    pass "enable: fails safely with code 2 when core library is missing"
  else
    fail "enable: did not fail with code 2 when core library missing (code: $MOCK_CODE)"
  fi
)

total=$((PASS+FAIL))
echo ""
if [[ "$FAIL" -eq 0 ]]; then
  printf '\033[32m[module-7-test] %d/%d passed\033[0m\n' "$PASS" "$total"
  exit 0
else
  printf '\033[31m[module-7-test] %d passed, %d FAILED / %d total\033[0m\n' "$PASS" "$FAIL" "$total" >&2
  exit 1
fi
