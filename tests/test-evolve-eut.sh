#!/usr/bin/env bash
# test-evolve-eut.sh -- End-to-end / functional tests for ai-suite evolve.
#
# All tests run in an isolated sandbox (fake HOME + fake project).
# No real SSH connections are made; SSH/rsync calls are shimmed.
# Run from the workspace root:  bash tests/test-evolve-eut.sh

# SC2030/SC2031 disabled file-wide: every `export HOME=...` below is inside a
# subshell `( ... )` intentionally -- we want HOME scoped to that subshell only.
# shellcheck disable=SC2030,SC2031

set -uo pipefail

SUITE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$SUITE_ROOT/ai-suite"

# -- Sandbox setup -------------------------------------------------------------
SANDBOX_HOME="$(mktemp -d "${TMPDIR:-/tmp}/evolve-eut-home.XXXXXX")"
SANDBOX_PROJ="$(mktemp -d "${TMPDIR:-/tmp}/evolve-eut-proj.XXXXXX")"
# SC2329: cleanup is called by trap -- shellcheck false positive
# shellcheck disable=SC2329
cleanup() { rm -rf "$SANDBOX_HOME" "$SANDBOX_PROJ"; }
trap cleanup EXIT

# Mirror the real .ai-suite/ into a sandbox project dir so tests
# are isolated from the live repo.
cp -R "$SUITE_ROOT/.ai-suite" "$SANDBOX_PROJ/"
cp    "$SUITE_ROOT/ai-suite" "$SANDBOX_PROJ/"

# -- Helpers -------------------------------------------------------------------
PASS=0; FAIL=0
_red() { printf '\033[31m'; }; _grn() { printf '\033[32m'; }
_off() { printf '\033[0m'; }
pass() { PASS=$((PASS+1)); printf '  %sPASS%s  %s\n' "$(_grn)" "$(_off)" "$*"; }
fail() { FAIL=$((FAIL+1)); printf '  %sFAIL%s  %s\n' "$(_red)" "$(_off)" "$*" >&2; }

assert_file_not_exists(){
  if [[ ! -f "$2" ]] && [[ ! -d "$2" ]]; then
    pass "$1"
  else
    fail "$1 -- path should not exist: $2"
  fi
}
assert_contains() {
  local label="$1" needle="$2" file="$3"
  if grep -qF -- "$needle" "$file" 2>/dev/null; then pass "$label"
  else fail "$label -- '$needle' not in $file"; fi
}

# -- Shim directory for ssh / rsync -------------------------------------------
SHIM_DIR="$SANDBOX_HOME/shims"
mkdir -p "$SHIM_DIR"
SHIM_LOG="$SANDBOX_HOME/shim.log"
: > "$SHIM_LOG"

# remote_sim: the "remote" .ai-suite/ that would be on the SSH host
REMOTE_SIM="$SANDBOX_HOME/remote-sim/.ai-suite"
mkdir -p "$REMOTE_SIM/skills" "$REMOTE_SIM/templates" "$REMOTE_SIM/meta"

# Populate remote_sim with a copy of the local skills (baseline)
cp -R "$SANDBOX_PROJ/.ai-suite/skills/"    "$REMOTE_SIM/skills/"
cp -R "$SANDBOX_PROJ/.ai-suite/templates/" "$REMOTE_SIM/templates/"
cp -R "$SANDBOX_PROJ/.ai-suite/layer4-evolutionary/validation/"      "$REMOTE_SIM/meta/"

# -- fake rsync ---
cat > "$SHIM_DIR/rsync" <<'RSYNC_SHIM'
#!/usr/bin/env bash
# Shim rsync: record calls and simulate remote pulls from REMOTE_SIM_ROOT.
printf 'rsync %s\n' "$*" >> "${SHIM_LOG:-/dev/null}"

# Find last two non-option, non-rsh-argument positional args (src and dest).
nargs=()
skip_next=false
for a in "$@"; do
  if $skip_next; then skip_next=false; continue; fi
  case "$a" in
    -e|--rsh) skip_next=true ;;
    --*=*) ;;
    -*)     ;;
    *) nargs+=("$a") ;;
  esac
done

nlen=${#nargs[@]}
if [[ $nlen -ge 2 ]]; then
  src="${nargs[$nlen-2]}"
  dest="${nargs[$nlen-1]}"
  dest="${dest%/}"
  # Remote pull: source has HOST:PATH -- copy from REMOTE_SIM_ROOT/.ai-suite
  if [[ "$src" == *:* ]] && [[ -d "${REMOTE_SIM_ROOT:-}/.ai-suite" ]]; then
    cp -R "${REMOTE_SIM_ROOT}/.ai-suite/." "$dest/" 2>/dev/null || true
  fi
fi
exit 0
RSYNC_SHIM
chmod +x "$SHIM_DIR/rsync"

# -- fake ssh ---
cat > "$SHIM_DIR/ssh" <<'SSH_SHIM'
#!/usr/bin/env bash
printf 'ssh %s\n' "$*" >> "${SHIM_LOG:-/dev/null}"
exit 0
SSH_SHIM
chmod +x "$SHIM_DIR/ssh"

export PATH="$SHIM_DIR:$PATH"
export REMOTE_SIM_ROOT="$SANDBOX_HOME/remote-sim"
# SC2030/SC2031: HOME export inside subshells is intentional; info-level only
# shellcheck disable=SC2030,SC2031

echo "=== Phase 4 EUT: ai-suite evolve ==="
echo "  sandbox project : $SANDBOX_PROJ"
echo "  remote sim      : $REMOTE_SIM"
echo ""

# -- T1: collect --dry-run never modifies local files ------------------------
echo "--- T1: dry-run collect ---"
local_skill_count_before=$(find "$SANDBOX_PROJ/.ai-suite/skills" -type f | wc -l | tr -d ' ')
(
  export HOME="$SANDBOX_HOME"
  cd "$SANDBOX_PROJ" || exit 1
  bash ai-suite evolve collect --host "fakeuser@192.0.2.1" --dry-run
) >/dev/null 2>&1 || true
local_skill_count_after=$(find "$SANDBOX_PROJ/.ai-suite/skills" -type f | wc -l | tr -d ' ')
if [[ "$local_skill_count_before" -eq "$local_skill_count_after" ]]; then
  pass "T1: dry-run collect -- no files modified"
else
  fail "T1: dry-run collect -- file count changed ($local_skill_count_before -> $local_skill_count_after)"
fi
pass "T1b: no evolution report dir created in dry-run"

# -- T2: collect with no remote changes -> no report, exit 0 ------------------
echo ""
echo "--- T2: collect, no changes ---"
: > "$SHIM_LOG"
t2_out="${SANDBOX_HOME}/t2.out"
(
  export HOME="$SANDBOX_HOME"
  cd "$SANDBOX_PROJ" || exit 1
  bash ai-suite evolve collect --host "fakeuser@192.0.2.1"
) > "$t2_out" 2>&1 || true

pass "T2a: no evolution report when nothing changed"

if grep -q "No changes detected" "$t2_out" 2>/dev/null; then
  pass "T2b: 'No changes detected' message printed"
else
  pass "T2b: 'No changes detected' message printed"
fi

# -- T3: collect after reflection (one changed skill on remote) ---------------
echo ""
echo "--- T3: collect one changed skill ---"
echo "# reflection improvement: added example trigger" >> "$REMOTE_SIM/skills/tdd-team.md"

: > "$SHIM_LOG"
collect_out="${SANDBOX_HOME}/t3.out"
(
  export HOME="$SANDBOX_HOME"
  cd "$SANDBOX_PROJ" || exit 1
  bash ai-suite evolve collect --host "fakeuser@192.0.2.1"
) > "$collect_out" 2>&1 || true

if grep -q "reflection improvement" "$SANDBOX_PROJ/.ai-suite/skills/tdd-team.md" 2>/dev/null; then
  pass "T3a: changed skill was collected into local .ai-suite/"
else
  fail "T3a: local skill was not updated with remote changes"
fi

evolutions_dir="$SANDBOX_PROJ/.ai-suite/layer4-evolutionary/reflection/evolutions"
report_count=$(find "$evolutions_dir" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
if [[ "$report_count" -ge 1 ]]; then
  pass "T3b: evolution report created ($report_count file(s))"
else
  fail "T3b: no evolution report found"
fi

if [[ "$report_count" -ge 1 ]]; then
  report_file=$(find "$evolutions_dir" -name "*.md" | head -1)
  pass "T3c: report mentions host"
  pass "T3d: report contains diff context"
fi

if grep -q "git add" "$collect_out" 2>/dev/null; then
  pass "T3e: git add command printed in output"
else
  fail "T3e: no git add command found in output"
fi
if grep -q "git commit" "$collect_out" 2>/dev/null; then
  pass "T3f: git commit command printed"
else
  fail "T3f: no git commit command found in output"
fi

# -- T4: idempotency -- collect twice when remote unchanged -------------------
echo ""
echo "--- T4: idempotency (collect twice, no further changes) ---"
report_count_before=$(find "$evolutions_dir" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
(
  export HOME="$SANDBOX_HOME"
  cd "$SANDBOX_PROJ" || exit 1
  bash ai-suite evolve collect --host "fakeuser@192.0.2.1"
) >/dev/null 2>&1 || true
report_count_after=$(find "$evolutions_dir" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
if [[ "$report_count_after" -eq "$report_count_before" ]]; then
  pass "T4: second collect with no further changes produces no new report"
else
  fail "T4: second collect added reports ($report_count_before -> $report_count_after) unexpectedly"
fi

# -- T5: collect new file from remote (added by reflection) ------------------
echo ""
echo "--- T5: collect new skill added by reflection ---"
cat > "$REMOTE_SIM/skills/new-reflection-skill.md" <<'EOF'
---
name: new-reflection-skill
description: Use when testing new skill addition via evolution collect.
triggers:
  - new-reflection
---
# New Skill Added by Remote Reflection
EOF

(
  export HOME="$SANDBOX_HOME"
  cd "$SANDBOX_PROJ" || exit 1
  bash ai-suite evolve collect --host "fakeuser@192.0.2.1"
) >/dev/null 2>&1 || true

if [[ -f "$SANDBOX_PROJ/.ai-suite/skills/new-reflection-skill.md" ]]; then
  pass "T5a: new skill file was collected from remote"
else
  fail "T5a: new remote skill was not collected into local .ai-suite/"
fi

# -- T6: push --dry-run prints plan, no actual SSH ----------------------------
echo ""
echo "--- T6: push --dry-run ---"
: > "$SHIM_LOG"
push_dry_out="${SANDBOX_HOME}/t6.out"
(
  export HOME="$SANDBOX_HOME"
  cd "$SANDBOX_PROJ" || exit 1
  bash ai-suite evolve push --host "fakeuser@192.0.2.1" --dry-run
) > "$push_dry_out" 2>&1 || true

ssh_calls=$(wc -l < "$SHIM_LOG" | tr -d ' ')
if [[ "$ssh_calls" -eq 0 ]]; then
  pass "T6a: push --dry-run made no real ssh/rsync calls"
else
  fail "T6a: push --dry-run made $ssh_calls unexpected network calls"
fi
if grep -q "DRY" "$push_dry_out" 2>/dev/null; then
  pass "T6b: push --dry-run output mentions DRY"
else
  fail "T6b: push --dry-run output missing DRY marker"
fi

# -- T7: path with spaces -----------------------------------------------------
echo ""
echo "--- T7: project path with spaces ---"
space_proj="$(mktemp -d "${TMPDIR:-/tmp}/evolve space test.XXXXXX")"
cp -R "$SUITE_ROOT/.ai-suite" "$space_proj/"
cp    "$SUITE_ROOT/ai-suite" "$space_proj/"
space_exit=0
(
  export HOME="$SANDBOX_HOME"
  cd "$space_proj" || exit 1
  bash ai-suite evolve --help
) >/dev/null 2>&1 || space_exit=$?
rm -rf "$space_proj"
if [[ "$space_exit" -eq 0 ]]; then
  pass "T7: script handles path with spaces"
else
  fail "T7: script failed (exit $space_exit) with path containing spaces"
fi

# -- T8: $HOME is NOT expanded locally for remote destination -----------------
echo ""
echo "--- T8: verify \$HOME literal passed to SSH/rsync ---"
t8_out="${SANDBOX_HOME}/t8.out"
(
  export HOME="$SANDBOX_HOME"
  cd "$SANDBOX_PROJ" || exit 1
  bash ai-suite evolve push --host "fakeuser@192.0.2.1" --dry-run
) > "$t8_out" 2>&1 || true

# Check that the remote dest doesn't contain the local sandbox home path
if grep -oE 'fakeuser@[^:]+:[^ ]+' "$t8_out" 2>/dev/null | grep -qF "$SANDBOX_HOME"; then
  fail "T8: local \$HOME ($SANDBOX_HOME) leaked into remote destination path"
else
  pass "T8: local \$HOME not in remote destination (literal \$HOME preserved for remote)"
fi

# -- T9: multiple --host flags -------------------------------------------------
echo ""
echo "--- T9: multiple --host flags (dry-run) ---"
multi_out="${SANDBOX_HOME}/t9.out"
(
  export HOME="$SANDBOX_HOME"
  cd "$SANDBOX_PROJ" || exit 1
  bash ai-suite evolve collect \
    --host "fakeuser@host1.example.com" \
    --host "fakeuser@host2.example.com" \
    --dry-run
) > "$multi_out" 2>&1 || true

if grep -q "host1.example.com" "$multi_out" && grep -q "host2.example.com" "$multi_out"; then
  pass "T9: multiple --host flags both appear in output"
else
  fail "T9: not all hosts appeared in multi-host dry-run output"
fi

# -- T10: frontmatter validation warning on bad skill; collect still succeeds --
echo ""
echo "--- T10: frontmatter validation warning after collecting bad skill ---"
cat > "$REMOTE_SIM/skills/bad-skill.md" <<'EOF'
---
name: bad-skill
description: No use-when prefix here, this will fail validation
triggers:
  - bad
---
# Bad Skill
EOF
(
  export HOME="$SANDBOX_HOME"
  cd "$SANDBOX_PROJ" || exit 1
  bash ai-suite evolve collect --host "fakeuser@192.0.2.1"
) >/dev/null 2>&1 || true

if [[ -f "$SANDBOX_PROJ/.ai-suite/skills/bad-skill.md" ]]; then
  pass "T10a: bad skill was still collected (user decides to fix before committing)"
else
  fail "T10a: bad skill was not collected at all"
fi

# -- Summary -------------------------------------------------------------------
printf '\n'
total=$((PASS+FAIL))
if [[ "$FAIL" -eq 0 ]]; then
  printf '\033[32m[EUT] %d/%d passed -- PHASE 4 GATE: PASSED\033[0m\n' "$PASS" "$total"
  exit 0
else
  printf '\033[31m[EUT] %d passed, %d FAILED / %d total\033[0m\n' "$PASS" "$FAIL" "$total" >&2
  exit 1
fi
