#!/usr/bin/env bash
# run-acceptance-tests.sh — Production-readiness acceptance suite.
#
# Runs every enable/disable variant in a sandbox HOME so the real ~/.cursor/,
# ~/.zshrc, ~/.bashrc are NEVER touched. Verifies actual on-disk state after
# every operation. Exits 0 iff all tests pass.
#
# Usage:  bash .ai-suite/layer4-evolutionary/validation/run-acceptance-tests.sh

set -u
PASS=0
FAIL=0

# Always run from the project root.
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$PROJECT_ROOT"

# Sandbox roots.
SANDBOX="$(mktemp -d "${TMPDIR:-/tmp}/ai-suite-test.XXXXXX")"
FAKE_HOME="$SANDBOX/home"
FAKE_PROJECT="$SANDBOX/project"
mkdir -p "$FAKE_HOME" "$FAKE_PROJECT"
git -C "$FAKE_PROJECT" init -q

# Each test runs in a sub-shell so HOME is overridden without polluting.
sandbox_run() {
  HOME="$FAKE_HOME" bash "$@"
}

reset_sandbox() {
  rm -rf "$FAKE_HOME" "$FAKE_PROJECT"
  mkdir -p "$FAKE_HOME" "$FAKE_PROJECT"
  git -C "$FAKE_PROJECT" init -q
}

# -- assertions ---------------------------------------------------------------
if [[ -t 1 ]]; then
  C_RED=$'\033[31m'
  C_GRN=$'\033[32m'
  C_YEL=$'\033[33m'
  C_OFF=$'\033[0m'
else
  C_RED=''
  C_GRN=''
  C_YEL=''
  C_OFF=''
fi

pass() { PASS=$((PASS+1)); printf '  %sPASS%s  %s\n' "$C_GRN" "$C_OFF" "$*"; }
fail() { FAIL=$((FAIL+1)); printf '  %sFAIL%s  %s\n' "$C_RED" "$C_OFF" "$*" >&2; }
section() { printf '\n%s== %s ==%s\n' "$C_YEL" "$*" "$C_OFF"; }

assert_file()         { [[ -f "$1" ]]        && pass "$2 (exists: $1)"        || fail "$2 (missing: $1)"; }
assert_not_file()     { [[ ! -f "$1" ]]      && pass "$2 (absent: $1)"        || fail "$2 (unexpected: $1)"; }
assert_dir()          { [[ -d "$1" ]]        && pass "$2 (exists: $1)"        || fail "$2 (missing: $1)"; }
assert_not_dir()      { [[ ! -d "$1" ]]      && pass "$2 (absent: $1)"        || fail "$2 (unexpected: $1)"; }
assert_file_contains() {
  local f="$1" needle="$2" label="$3"
  if [[ -f "$f" ]] && grep -Fq "$needle" "$f"; then
    pass "$label"
  else
    fail "$label (expected '$needle' in $f)"
  fi
}
assert_file_not_contains() {
  local f="$1" needle="$2" label="$3"
  if [[ ! -f "$f" ]] || ! grep -Fq "$needle" "$f" 2>/dev/null; then
    pass "$label"
  else
    fail "$label (unexpected '$needle' in $f)"
  fi
}
assert_eq() {
  if [[ "$1" == "$2" ]]; then pass "$3 (=$1)"; else fail "$3 (got '$1', want '$2')"; fi
}
assert_exit_zero() {
  local label="$1"; shift
  if "$@" >/dev/null 2>&1; then pass "$label"; else fail "$label (exit $?)"; fi
}
assert_exit_nonzero() {
  local label="$1"; shift
  if ! "$@" >/dev/null 2>&1; then pass "$label"; else fail "$label (expected non-zero exit)"; fi
}

# ============================================================================
# Test 0 — _portable.sh helpers in isolation
# ============================================================================
section "test 0: portable helpers"
(
  # shellcheck disable=SC1091
  source "$PROJECT_ROOT/.ai-suite/layer1-abstraction/_portable.sh"

  case "$CS_OS" in
    macos|linux|other) pass "CS_OS is set ($CS_OS)" ;;
    *) fail "CS_OS unexpected value: $CS_OS" ;;
  esac

  tmp="$(mktemp_portable selftest)"
  [[ -f "$tmp" ]] && pass "mktemp_portable created file: $tmp" || fail "mktemp_portable failed"
  printf 'hello world\n' > "$tmp"
  sed_inplace 's/world/universe/' "$tmp"
  [[ "$(cat "$tmp")" == "hello universe" ]] \
    && pass "sed_inplace replaced in-file" \
    || fail "sed_inplace did not replace correctly (got: $(cat "$tmp"))"

  # ensure_trailing_newline on a no-newline file
  printf 'no-newline' > "$tmp"
  ensure_trailing_newline "$tmp"
  [[ "$(tail -c1 "$tmp")" == "" ]] \
    && pass "ensure_trailing_newline appended newline" \
    || fail "ensure_trailing_newline did not append (last byte: $(tail -c1 "$tmp" | od -An -c))"

  # idempotent: running again should not add a second \n
  ensure_trailing_newline "$tmp"
  byte_count="$(wc -c < "$tmp" | tr -d ' ')"
  [[ "$byte_count" == "11" ]] \
    && pass "ensure_trailing_newline is idempotent" \
    || fail "ensure_trailing_newline doubled newline (size=$byte_count)"

  # on empty file: noop
  : > "$tmp"
  ensure_trailing_newline "$tmp"
  [[ "$(wc -c < "$tmp" | tr -d ' ')" == "0" ]] \
    && pass "ensure_trailing_newline noop on empty file" \
    || fail "ensure_trailing_newline corrupted empty file"

  rm -f "$tmp"
)

# ============================================================================
# Test 1 — validate-suite.sh against shipped skills
# ============================================================================
section "test 1: validator on shipped skills"
output="$(bash "$PROJECT_ROOT/.ai-suite/layer4-evolutionary/validation/validate-suite.sh" "$PROJECT_ROOT/.ai-suite/layer3-registry/core" 2>&1)"
exit_code=$?
assert_eq "$exit_code" "0" "validator exits 0 on shipped skills"
if grep -q "11 .* PASS\|checks passed, 0 failed" <<< "$output"; then
  pass "validator reports passing summary"
else
  fail "validator summary suspect; last lines: $(echo "$output" | tail -2)"
fi

# ============================================================================
# Test 2 — validator rejects malformed skills
# ============================================================================
section "test 2: validator rejects malformed skills"
FIXTURES="$SANDBOX/fixtures"
mkdir -p "$FIXTURES"

# 2a — no frontmatter at all
cat > "$FIXTURES/no-frontmatter.md" <<EOF
# Just a markdown file with no YAML
EOF
assert_exit_nonzero "validator rejects no-frontmatter" \
  bash "$PROJECT_ROOT/.ai-suite/layer4-evolutionary/validation/validate-suite.sh" "$FIXTURES/no-frontmatter.md"

# 2b — name contains uppercase
cat > "$FIXTURES/Uppercase.md" <<EOF
---
name: Uppercase
description: A test skill. Use when testing.
---
body
EOF
assert_exit_nonzero "validator rejects uppercase name" \
  bash "$PROJECT_ROOT/.ai-suite/layer4-evolutionary/validation/validate-suite.sh" "$FIXTURES/Uppercase.md"

# 2c — name doesn't match basename
cat > "$FIXTURES/mismatch.md" <<EOF
---
name: different-name
description: A test skill. Use when testing.
---
body
EOF
assert_exit_nonzero "validator rejects name != basename" \
  bash "$PROJECT_ROOT/.ai-suite/layer4-evolutionary/validation/validate-suite.sh" "$FIXTURES/mismatch.md"

# 2d — description missing 'Use when'
cat > "$FIXTURES/no-trigger.md" <<EOF
---
name: no-trigger
description: A test skill that omits the trigger phrase.
---
body
EOF
assert_exit_nonzero "validator rejects missing 'Use when'" \
  bash "$PROJECT_ROOT/.ai-suite/layer4-evolutionary/validation/validate-suite.sh" "$FIXTURES/no-trigger.md"

# 2e — valid minimum
cat > "$FIXTURES/minimal-ok.md" <<EOF
---
name: minimal-ok
description: A minimum valid skill. Use when you want to test the validator.
triggers:
  - test validator
---
## Instructions
Do something.
## Negative Constraints
Must not fail.
EOF
assert_exit_zero "validator accepts minimal valid skill" \
  bash "$PROJECT_ROOT/.ai-suite/layer4-evolutionary/validation/validate-suite.sh" "$FIXTURES/minimal-ok.md"

# ============================================================================
# Test 3 — scope=project: full enable -> disable round trip
# ============================================================================
section "test 3: --scope project round trip"
reset_sandbox

HOME="$FAKE_HOME" bash "$PROJECT_ROOT/enable_suite.sh" --scope project --project "$FAKE_PROJECT" >/dev/null
assert_file        "$FAKE_PROJECT/.cursorrules"                                              "enable: .cursorrules created"
assert_file_contains "$FAKE_PROJECT/.cursorrules" "# >>>>> cursor-ai-suite >>>>>"  "enable: cursorrules has START marker"
assert_file_contains "$FAKE_PROJECT/.cursorrules" "# <<<<< cursor-ai-suite <<<<"    "enable: cursorrules has END marker"
assert_file        "$FAKE_PROJECT/.cursor/rules/cursor-suite-production-safety.mdc"          "enable: safety .mdc deployed"
assert_file_contains "$FAKE_PROJECT/.cursor/rules/cursor-suite-production-safety.mdc" \
                   "alwaysApply: true"                                                       "enable: .mdc has alwaysApply:true"
assert_file_contains "$FAKE_PROJECT/.cursor/rules/cursor-suite-production-safety.mdc" \
                   "Refuse-by-Default Patterns"                                              "enable: .mdc has body content"

assert_file        "$FAKE_PROJECT/.cursor/rules/cursor-suite-agent-directives.mdc"           "enable: directives .mdc deployed"
assert_file_contains "$FAKE_PROJECT/.cursor/rules/cursor-suite-agent-directives.mdc" \
                   "alwaysApply: true"                                                       "enable: directives .mdc has alwaysApply:true"
assert_file_contains "$FAKE_PROJECT/.cursor/rules/cursor-suite-agent-directives.mdc" \
                   "Leave \`git commit\` to the user"                                          "enable: directives .mdc has git commit rule"
assert_file_contains "$FAKE_PROJECT/.cursor/rules/cursor-suite-agent-directives.mdc" \
                   "Provide a summary"                                                       "enable: directives .mdc has summary rule"
assert_file_contains "$FAKE_PROJECT/.cursor/rules/cursor-suite-agent-directives.mdc" \
                   "Actual Verification Required"                                            "enable: directives .mdc has verification rule"

HOME="$FAKE_HOME" bash "$PROJECT_ROOT/disable_suite.sh" --scope project --project "$FAKE_PROJECT" >/dev/null
assert_file_not_contains "$FAKE_PROJECT/.cursorrules" "# >>>>> cursor-ai-suite >>>>>" \
                                                                                              "disable: marker removed"
assert_not_file    "$FAKE_PROJECT/.cursor/rules/cursor-suite-production-safety.mdc"           "disable: safety .mdc removed"
assert_not_file    "$FAKE_PROJECT/.cursor/rules/cursor-suite-agent-directives.mdc"            "disable: directives .mdc removed"
ls -la "$FAKE_PROJECT/.cursor/rules" 2>/dev/null || true
assert_not_dir     "$FAKE_PROJECT/.cursor/rules"                                              "disable: empty .cursor/rules cleaned up"
assert_not_dir     "$FAKE_PROJECT/.cursor"                                                    "disable: empty .cursor cleaned up"

# ============================================================================
# Test 4 — scope=project: idempotency (enable x2, disable x2)
# ============================================================================
section "test 4: --scope project idempotency"
reset_sandbox

HOME="$FAKE_HOME" bash "$PROJECT_ROOT/enable_suite.sh" --scope project --project "$FAKE_PROJECT" >/dev/null
HOME="$FAKE_HOME" bash "$PROJECT_ROOT/enable_suite.sh" --scope project --project "$FAKE_PROJECT" >/dev/null
marker_count="$(grep -c "# >>>>> cursor-ai-suite >>>>>" "$FAKE_PROJECT/.cursorrules")"
assert_eq "$marker_count" "1" "enable x2 leaves exactly 1 marker block"

HOME="$FAKE_HOME" bash "$PROJECT_ROOT/disable_suite.sh" --scope project --project "$FAKE_PROJECT" >/dev/null
HOME="$FAKE_HOME" bash "$PROJECT_ROOT/disable_suite.sh" --scope project --project "$FAKE_PROJECT" >/dev/null
assert_file_not_contains "$FAKE_PROJECT/.cursorrules" "# >>>>> cursor-ai-suite >>>>>" \
                                                                                              "disable x2 still has no marker"

# ============================================================================
# Test 5 — scope=project: pre-existing .cursorrules content is preserved
# ============================================================================
section "test 5: existing .cursorrules content preserved"
reset_sandbox
printf '# Existing user rule\nDo not delete me.\n' > "$FAKE_PROJECT/.cursorrules"

HOME="$FAKE_HOME" bash "$PROJECT_ROOT/enable_suite.sh" --scope project --project "$FAKE_PROJECT" >/dev/null
assert_file_contains "$FAKE_PROJECT/.cursorrules" "Do not delete me." "enable: pre-existing line preserved"

HOME="$FAKE_HOME" bash "$PROJECT_ROOT/disable_suite.sh" --scope project --project "$FAKE_PROJECT" >/dev/null
assert_file_contains "$FAKE_PROJECT/.cursorrules" "Do not delete me." "disable: pre-existing line still preserved"
assert_file_not_contains "$FAKE_PROJECT/.cursorrules" "# >>>>> cursor-ai-suite >>>>>" \
                                                                       "disable: marker block gone"

# ============================================================================
# Test 6 — scope=project: stray .cursorrules DIRECTORY is repaired
# ============================================================================
section "test 6: stray empty .cursorrules directory repaired"
reset_sandbox
mkdir -p "$FAKE_PROJECT/.cursorrules"

HOME="$FAKE_HOME" bash "$PROJECT_ROOT/enable_suite.sh" --scope project --project "$FAKE_PROJECT" >/dev/null 2>&1
assert_file        "$FAKE_PROJECT/.cursorrules"      "stray dir replaced by file"
assert_file_contains "$FAKE_PROJECT/.cursorrules" "# >>>>> cursor-ai-suite >>>>>" \
                                                     "stray dir: marker now present in file"
HOME="$FAKE_HOME" bash "$PROJECT_ROOT/disable_suite.sh" --scope project --project "$FAKE_PROJECT" >/dev/null

# Non-empty .cursorrules dir should be REFUSED.
reset_sandbox
mkdir -p "$FAKE_PROJECT/.cursorrules"
printf 'unexpected\n' > "$FAKE_PROJECT/.cursorrules/junk"
out="$(HOME="$FAKE_HOME" bash "$PROJECT_ROOT/enable_suite.sh" --scope project --project "$FAKE_PROJECT" 2>&1)"
exit_code=$?
[[ "$exit_code" -ne 0 ]] \
  && pass "non-empty .cursorrules dir causes non-zero exit" \
  || fail "non-empty .cursorrules dir DID NOT fail (exit=$exit_code, out=$out)"

# ============================================================================
# Test 7 — scope=project against a path with SPACES
# ============================================================================
section "test 7: path with spaces"
rm -rf "$FAKE_HOME" "$SANDBOX/proj with space"
mkdir -p "$FAKE_HOME" "$SANDBOX/proj with space"
git -C "$SANDBOX/proj with space" init -q

HOME="$FAKE_HOME" bash "$PROJECT_ROOT/enable_suite.sh" --scope project --project "$SANDBOX/proj with space" >/dev/null 2>&1
exit_code=$?
assert_eq "$exit_code" "0" "enable with path containing spaces exit=0"
assert_file        "$SANDBOX/proj with space/.cursorrules"  "spaces path: .cursorrules created"
assert_file        "$SANDBOX/proj with space/.cursor/rules/cursor-suite-production-safety.mdc" \
                                                            "spaces path: .mdc deployed"
assert_file        "$SANDBOX/proj with space/.cursor/rules/cursor-suite-agent-directives.mdc" \
                                                            "spaces path: directives .mdc deployed"

HOME="$FAKE_HOME" bash "$PROJECT_ROOT/disable_suite.sh" --scope project --project "$SANDBOX/proj with space" >/dev/null 2>&1
assert_file_not_contains "$SANDBOX/proj with space/.cursorrules" "# >>>>> cursor-ai-suite >>>>>" \
                                                            "spaces path: disable removed marker"
assert_not_file    "$SANDBOX/proj with space/.cursor/rules/cursor-suite-production-safety.mdc" \
                                                            "spaces path: .mdc removed"
assert_not_file    "$SANDBOX/proj with space/.cursor/rules/cursor-suite-agent-directives.mdc" \
                                                            "spaces path: directives .mdc removed"

# ============================================================================
# Test 8 — scope=global round trip with isolated HOME
# ============================================================================
section "test 8: --scope global round trip (sandbox HOME)"
reset_sandbox

HOME="$FAKE_HOME" bash "$PROJECT_ROOT/enable_suite.sh" --scope global >/dev/null
assert_dir         "$FAKE_HOME/.cursor/skills"                                          "global: skills dir created"
  assert_file        "$FAKE_HOME/.cursor/skills/tdd-team/SKILL.md"                        "global: tdd-team mirrored"
assert_file        "$FAKE_HOME/.cursor/rules/cursor-suite-production-safety.mdc"        "global: safety rule deployed to ~/.cursor/rules"
assert_file        "$FAKE_HOME/.cursor/rules/cursor-suite-agent-directives.mdc"         "global: directives rule deployed to ~/.cursor/rules"
# Count: dynamically derived from source dirs so adding any skill never breaks this test
EXPECTED_SKILL_COUNT="$(find "$PROJECT_ROOT/.ai-suite/layer3-registry/core" \
    "$PROJECT_ROOT/.ai-suite/layer4-evolutionary/merging" \
    "$PROJECT_ROOT/.ai-suite/layer2-cognitive/meta-compiler" \
    "$PROJECT_ROOT/.ai-suite/layer1-abstraction/agents/cursor/skills" \
    "$PROJECT_ROOT/.ai-suite/layer3-registry/domains"/*/skills \
    -maxdepth 1 -name '*.md' -type f 2>/dev/null | wc -l | tr -d ' ')"
skill_count="$(find "$FAKE_HOME/.cursor/skills" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
assert_eq "$skill_count" "$EXPECTED_SKILL_COUNT" "global: $EXPECTED_SKILL_COUNT skill mirrors present"

# Idempotency
HOME="$FAKE_HOME" bash "$PROJECT_ROOT/enable_suite.sh" --scope global >/dev/null
skill_count2="$(find "$FAKE_HOME/.cursor/skills" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
assert_eq "$skill_count2" "$EXPECTED_SKILL_COUNT" "global: re-enable still $EXPECTED_SKILL_COUNT mirrors (idempotent)"

HOME="$FAKE_HOME" bash "$PROJECT_ROOT/disable_suite.sh" --scope global >/dev/null
  assert_not_dir     "$FAKE_HOME/.cursor/skills/tdd-team"                           "global: mirrors removed after disable"
assert_not_file    "$FAKE_HOME/.cursor/rules/cursor-suite-production-safety.mdc"        "global: safety rule removed"
assert_not_file    "$FAKE_HOME/.cursor/rules/cursor-suite-agent-directives.mdc"         "global: directives rule removed"

# ============================================================================
# Test 9 — install-hook + uninstall-hook (zsh, bash, both, auto)
# ============================================================================
section "test 9: --install-hook variants"

for sh_flag in zsh bash both; do
  reset_sandbox
  HOME="$FAKE_HOME" bash "$PROJECT_ROOT/enable_suite.sh" --install-hook --shell "$sh_flag" >/dev/null
  case "$sh_flag" in
    zsh)
      assert_file_contains "$FAKE_HOME/.zshrc"  "### AI SUITE AUTO-ENABLE HOOK START ###" "hook --shell zsh: zshrc has marker"
      assert_file_not_contains "$FAKE_HOME/.bashrc" "### AI SUITE AUTO-ENABLE HOOK START ###" "hook --shell zsh: bashrc absent"
      ;;
    bash)
      assert_file_contains "$FAKE_HOME/.bashrc" "### AI SUITE AUTO-ENABLE HOOK START ###" "hook --shell bash: bashrc has marker"
      assert_file_not_contains "$FAKE_HOME/.zshrc" "### AI SUITE AUTO-ENABLE HOOK START ###" "hook --shell bash: zshrc absent"
      ;;
    both)
      assert_file_contains "$FAKE_HOME/.zshrc"  "### AI SUITE AUTO-ENABLE HOOK START ###" "hook --shell both: zshrc has marker"
      assert_file_contains "$FAKE_HOME/.bashrc" "### AI SUITE AUTO-ENABLE HOOK START ###" "hook --shell both: bashrc has marker"
      ;;
  esac

  # Idempotency
  HOME="$FAKE_HOME" bash "$PROJECT_ROOT/enable_suite.sh" --install-hook --shell "$sh_flag" >/dev/null
  for rc in zshrc bashrc; do
    [[ -f "$FAKE_HOME/.$rc" ]] || continue
    count="$(grep -c "### AI SUITE AUTO-ENABLE HOOK START ###" "$FAKE_HOME/.$rc")"
    assert_eq "$count" "1" "hook --shell $sh_flag: $rc has exactly 1 marker after re-enable"
  done

  HOME="$FAKE_HOME" bash "$PROJECT_ROOT/disable_suite.sh" --uninstall-hook --shell "$sh_flag" >/dev/null
  for rc in zshrc bashrc; do
    [[ -f "$FAKE_HOME/.$rc" ]] || continue
    assert_file_not_contains "$FAKE_HOME/.$rc" "### AI SUITE AUTO-ENABLE HOOK START ###" \
                                                                                              "hook --shell $sh_flag: $rc marker removed"
  done
done

# Auto-detection: when only .zshrc exists, auto should pick zsh
reset_sandbox
touch "$FAKE_HOME/.zshrc"   # exists but no bashrc
HOME="$FAKE_HOME" bash "$PROJECT_ROOT/enable_suite.sh" --install-hook --shell auto >/dev/null
assert_file_contains "$FAKE_HOME/.zshrc"  "### AI SUITE AUTO-ENABLE HOOK START ###" "hook auto: picked zshrc"
[[ -f "$FAKE_HOME/.bashrc" ]] && fail "hook auto: created bashrc when only zshrc existed" \
                              || pass "hook auto: did NOT create bashrc"

# ============================================================================
# Test 10 — pre-existing user content in .zshrc preserved
# ============================================================================
section "test 10: pre-existing .zshrc content preserved across hook install/uninstall"
reset_sandbox
printf 'export PATH=$PATH:/my/bin\n# my zsh setup\n' > "$FAKE_HOME/.zshrc"

HOME="$FAKE_HOME" bash "$PROJECT_ROOT/enable_suite.sh" --install-hook --shell zsh >/dev/null
assert_file_contains "$FAKE_HOME/.zshrc" "export PATH=" "hook install: PATH line preserved"
assert_file_contains "$FAKE_HOME/.zshrc" "# my zsh setup" "hook install: comment preserved"

HOME="$FAKE_HOME" bash "$PROJECT_ROOT/disable_suite.sh" --uninstall-hook --shell zsh >/dev/null
assert_file_contains "$FAKE_HOME/.zshrc" "export PATH=" "hook uninstall: PATH line still present"

# ============================================================================
# Test 11 — --verify on shipped skills
# ============================================================================
section "test 11: --verify"
assert_exit_zero "enable_suite.sh --verify passes" \
  bash "$PROJECT_ROOT/enable_suite.sh" --verify

# ============================================================================
# Test 12 — --uninstall delegation reaches disable_suite.sh
# ============================================================================
section "test 12: --uninstall delegation"
reset_sandbox
HOME="$FAKE_HOME" bash "$PROJECT_ROOT/enable_suite.sh" --scope project --project "$FAKE_PROJECT" >/dev/null
HOME="$FAKE_HOME" bash "$PROJECT_ROOT/enable_suite.sh" --scope project --project "$FAKE_PROJECT" --uninstall >/dev/null
assert_file_not_contains "$FAKE_PROJECT/.cursorrules" "# >>>>> cursor-ai-suite >>>>>" \
                                                                                              "--uninstall delegation removed marker"
assert_not_file    "$FAKE_PROJECT/.cursor/rules/cursor-suite-production-safety.mdc"           "--uninstall delegation removed .mdc"
assert_not_file    "$FAKE_PROJECT/.cursor/rules/cursor-suite-agent-directives.mdc"            "--uninstall delegation removed directives .mdc"

# ============================================================================
# Test 13 — regression: --scope remote keeps $HOME literal in ssh command.
#
# Bug history: an earlier `run() { eval "$@"; }` caused a second round of shell
# expansion, which expanded $HOME to the LOCAL user's home instead of leaving
# it for the remote shell. Catch any regression by intercepting ssh with a
# recorder and asserting the command argv contains literal "$HOME" with NO
# expansion.
# ============================================================================
section "test 13: --scope remote preserves literal \$HOME in ssh argv"
RECORDER="$SANDBOX/ssh_recorder"
RECORDER_LOG="$SANDBOX/ssh_recorder.log"
cat > "$RECORDER" <<'EOF'
#!/usr/bin/env bash
# Fake ssh: append argv to log and exit 0.
{ printf 'argv:'; for a in "$@"; do printf ' <%s>' "$a"; done; printf '\n'; } >> "$RECORDER_LOG"
exit 0
EOF
chmod +x "$RECORDER"
: > "$RECORDER_LOG"

# Also need a fake rsync to avoid touching the real network.
RECORDER_RSYNC="$SANDBOX/rsync_recorder"
cat > "$RECORDER_RSYNC" <<'EOF'
#!/usr/bin/env bash
{ printf 'rsync:'; for a in "$@"; do printf ' <%s>' "$a"; done; printf '\n'; } >> "$RECORDER_LOG"
exit 0
EOF
chmod +x "$RECORDER_RSYNC"

# Put the fakes first in PATH.
SHIM_PATH="$SANDBOX/shims"
mkdir -p "$SHIM_PATH"
ln -sf "$RECORDER"       "$SHIM_PATH/ssh"
ln -sf "$RECORDER_RSYNC" "$SHIM_PATH/rsync"

reset_sandbox
HOME="$FAKE_HOME" \
  PATH="$SHIM_PATH:$PATH" \
  RECORDER_LOG="$RECORDER_LOG" \
  bash "$PROJECT_ROOT/enable_suite.sh" --scope remote --host nobody@example.invalid >/dev/null 2>&1

if grep -Fq '$HOME/.ai-suite' "$RECORDER_LOG"; then
  pass "remote ssh argv contains literal \$HOME (no local expansion)"
else
  fail "remote ssh argv MISSING literal \$HOME — local expansion regression. log: $(cat "$RECORDER_LOG")"
fi

if grep -Fq "/Users/$(whoami)/.ai-suite" "$RECORDER_LOG" 2>/dev/null \
   || grep -Fq "$FAKE_HOME/.ai-suite" "$RECORDER_LOG"; then
  fail "remote ssh argv contains LOCALLY-EXPANDED \$HOME path — bug regression"
else
  pass "remote ssh argv does NOT contain locally-expanded \$HOME"
fi

# ============================================================================
# Test 13b — regression: --scope remote with spaces in --remote-path
# ============================================================================
section "test 13b: --scope remote with spaces in --remote-path"
: > "$RECORDER_LOG"
reset_sandbox

HOME="$FAKE_HOME" \
  PATH="$SHIM_PATH:$PATH" \
  RECORDER_LOG="$RECORDER_LOG" \
  bash "$PROJECT_ROOT/enable_suite.sh" --scope remote --host nobody@example.invalid --remote-path "/var/tmp/path with space" >/dev/null 2>&1

if grep -Fq '"/var/tmp/path with space/enable_suite.sh"' "$RECORDER_LOG" || grep -Fq "'/var/tmp/path with space/enable_suite.sh'" "$RECORDER_LOG" || grep -Fq "/var/tmp/path\ with\ space" "$RECORDER_LOG"; then
  pass "remote ssh argv correctly quotes --remote-path with spaces"
else
  fail "remote ssh argv MISSING quotes for --remote-path with spaces. log: $(cat "$RECORDER_LOG")"
fi

# ============================================================================
# Test 14 — invalid args fail cleanly with non-zero exit
# ============================================================================
section "test 13: invalid args fail with non-zero exit"
assert_exit_nonzero "unknown flag rejected"           bash "$PROJECT_ROOT/enable_suite.sh" --no-such-flag
assert_exit_nonzero "bad scope rejected"              bash "$PROJECT_ROOT/enable_suite.sh" --scope wat
assert_exit_nonzero "bad shell rejected"              bash "$PROJECT_ROOT/enable_suite.sh" --install-hook --shell fish
assert_exit_nonzero "missing --host on remote scope"  bash "$PROJECT_ROOT/enable_suite.sh" --scope remote
assert_exit_nonzero "nonexistent --project path"      bash "$PROJECT_ROOT/enable_suite.sh" --scope project --project /no/such/place

# ============================================================================
# Cleanup + summary
# ============================================================================
rm -rf "$SANDBOX"

printf '\n'
total=$((PASS + FAIL))
if [[ "$FAIL" -eq 0 ]]; then
  printf '%s[acceptance] %d/%d passed, 0 FAILED%s\n' "$C_GRN" "$PASS" "$total" "$C_OFF"
  exit 0
else
  printf '%s[acceptance] %d passed, %d FAILED (of %d)%s\n' "$C_RED" "$PASS" "$FAIL" "$total" "$C_OFF" >&2
  exit 1
fi
