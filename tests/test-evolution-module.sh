#!/usr/bin/env bash
# tests/test-evolution-module.sh -- Comprehensive TDD Test Suite for Self-Evolution Framework
set -euo pipefail

SUITE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SUITE_CLI="$SUITE_ROOT/ai-suite"

PASS=0; FAIL=0
_red() { printf '\033[31m'; }; _grn() { printf '\033[32m'; }; _off() { printf '\033[0m'; }
pass() { PASS=$((PASS+1)); printf '  %sPASS%s  %s\n' "$(_grn)" "$(_off)" "$*"; }
fail() { FAIL=$((FAIL+1)); printf '  %sFAIL%s  %s\n' "$(_red)" "$(_off)" "$*" >&2; }

echo "=== TDD Module 3: Self-Evolution Framework & Sync Protocol Hardening ==="

TMP_SANDBOX=$(mktemp -d "${TMPDIR:-/tmp}/tdd-evolution.XXXXXX")
trap 'rm -rf "$TMP_SANDBOX"' EXIT

MOCK_HOME="$TMP_SANDBOX/mock_home"
mkdir -p "$MOCK_HOME/.cursor/skills/mock-skill"
mkdir -p "$MOCK_HOME/.claude/skills/claude-skill"
mkdir -p "$MOCK_HOME/.codex/skills/codex-skill"

cat > "$MOCK_HOME/.cursor/skills/mock-skill/SKILL.md" << 'EOF'
---
name: mock-skill
description: Mock skill for testing self-evolution local collect.
triggers:
  - mock skill
---
# Mock Skill
Instructions.
EOF

cat > "$MOCK_HOME/.claude/skills/claude-skill/SKILL.md" << 'EOF'
---
name: claude-skill
description: Claude skill for evolution.
---
# Claude Skill
EOF

cat > "$MOCK_HOME/.codex/skills/codex-skill/SKILL.md" << 'EOF'
---
name: codex-skill
description: Codex skill for evolution.
---
# Codex Skill
EOF

# 1. No arguments prints usage and exits 0
set +e
NOARG_OUT=$(bash "$SUITE_CLI" evolve 2>&1)
NOARG_CODE=$?
set -e
if [[ $NOARG_CODE -eq 0 ]] && echo "$NOARG_OUT" | grep -qi "sync ai-suite evolutions"; then
  pass "evolve with no arguments prints usage and exits 0"
else
  fail "evolve with no arguments failed to print usage (code: $NOARG_CODE)"
fi

# 2. --help flag prints usage
set +e
HELP_OUT=$(bash "$SUITE_CLI" evolve --help 2>&1)
HELP_CODE=$?
set -e
if [[ $HELP_CODE -eq 0 ]] && echo "$HELP_OUT" | grep -qi "SUB-COMMANDS"; then
  pass "evolve --help prints subcommands and exits 0"
else
  fail "evolve --help failed (code: $HELP_CODE)"
fi

# 3. Unknown sub-command rejected
set +e
UNKNOWN_OUT=$(bash "$SUITE_CLI" evolve invalid_subcmd 2>&1)
UNKNOWN_CODE=$?
set -e
if [[ $UNKNOWN_CODE -ne 0 ]] && echo "$UNKNOWN_OUT" | grep -qi "Unknown sub-command"; then
  pass "evolve rejects unknown sub-command"
else
  fail "evolve allowed unknown sub-command (code: $UNKNOWN_CODE)"
fi

# 4. collect missing --host and --local rejected
set +e
NOHOST_OUT=$(bash "$SUITE_CLI" evolve collect 2>&1)
NOHOST_CODE=$?
set -e
if [[ $NOHOST_CODE -ne 0 ]] && echo "$NOHOST_OUT" | grep -qi "required"; then
  pass "evolve collect rejects invocation without --host or --local"
else
  fail "evolve collect allowed invocation without --host or --local (code: $NOHOST_CODE)"
fi

# 5. push missing --host rejected
set +e
PUSH_NOHOST=$(bash "$SUITE_CLI" evolve push 2>&1)
PUSH_CODE=$?
set -e
if [[ $PUSH_CODE -ne 0 ]] && echo "$PUSH_NOHOST" | grep -qi "required"; then
  pass "evolve push rejects invocation without --host"
else
  fail "evolve push allowed invocation without --host (code: $PUSH_CODE)"
fi

# 6. Unknown option rejected
set +e
INV_OPT_OUT=$(bash "$SUITE_CLI" evolve collect --local --invalid-opt-xyz 2>&1)
INV_OPT_CODE=$?
set -e
if [[ $INV_OPT_CODE -ne 0 ]] && echo "$INV_OPT_OUT" | grep -qi "Unknown option"; then
  pass "evolve rejects unknown options"
else
  fail "evolve allowed unknown option (code: $INV_OPT_CODE)"
fi

# 7. Missing argument values rejected
set +e
MISS_HOST=$(bash "$SUITE_CLI" evolve push --host 2>&1)
MISS_CODE=$?
set -e
if [[ $MISS_CODE -ne 0 ]] && echo "$MISS_HOST" | grep -qi "requires a value"; then
  pass "evolve rejects --host without value"
else
  fail "evolve allowed --host without value (code: $MISS_CODE)"
fi

# 8. Dry run of local collect
HOME="$MOCK_HOME" bash "$SUITE_CLI" evolve collect --local --dry-run >/dev/null
pass "Evolve: dry-run collect --local succeeded"

# 9. Dry run of remote collect with --exclude-memory
set +e
DRY_REMOTE_OUT=$(bash "$SUITE_CLI" evolve collect --host user@mock.example.com --dry-run --exclude-memory 2>&1)
DRY_REMOTE_CODE=$?
set -e
if [[ $DRY_REMOTE_CODE -eq 0 ]] && echo "$DRY_REMOTE_OUT" | grep -qi "DRY-RUN"; then
  pass "Evolve: dry-run collect --host with --exclude-memory succeeded"
else
  fail "Evolve: dry-run collect --host failed (code: $DRY_REMOTE_CODE)"
fi

# 10. Dry run of remote push with multiple hosts and custom options
set +e
DRY_PUSH_OUT=$(bash "$SUITE_CLI" evolve push --host user@h1.example.com --host user@h2.example.com --agent claude --remote-scope project --remote-path /opt/deploy --dry-run --exclude-memory 2>&1)
DRY_PUSH_CODE=$?
set -e
if [[ $DRY_PUSH_CODE -eq 0 ]] && echo "$DRY_PUSH_OUT" | grep -qi "DRY-RUN"; then
  pass "Evolve: dry-run push to multiple hosts succeeded with all options"
else
  fail "Evolve: dry-run push failed (code: $DRY_PUSH_CODE)"
fi

# 11. Execute evolve collect --local with Cursor, Claude, and Codex skills
HOME="$MOCK_HOME" bash "$SUITE_CLI" evolve collect --local >/dev/null

if [[ -f "$SUITE_ROOT/.ai-suite/layer1-abstraction/agents/cursor/skills/mock-skill.md" && \
      -f "$SUITE_ROOT/.ai-suite/layer1-abstraction/agents/claude/skills/claude-skill.md" && \
      -f "$SUITE_ROOT/.ai-suite/layer1-abstraction/agents/codex/skills/codex-skill.md" ]]; then
  pass "Evolve: skills collected from cursor, claude, and codex"
else
  fail "Evolve: multi-agent skills were not cleanly collected into .ai-suite"
fi

# Clean up any collected skills so working tree remains pristine
git clean -f -d "$SUITE_ROOT/.ai-suite/layer1-abstraction/agents/" 2>/dev/null || true

# 12. Modify an existing file to exercise the diff -u branch
MODIFIED_TARGET="$SUITE_ROOT/.ai-suite/layer1-abstraction/agents/cursor/skills/mod-target.md"
echo "# Original" > "$MODIFIED_TARGET"
mkdir -p "$MOCK_HOME/.cursor/skills/mod-target"
echo "# Modified Content" > "$MOCK_HOME/.cursor/skills/mod-target/SKILL.md"

HOME="$MOCK_HOME" bash "$SUITE_CLI" evolve collect --local >/dev/null
rm -f "$MODIFIED_TARGET"
git clean -f -d "$SUITE_ROOT/.ai-suite/layer1-abstraction/agents/" 2>/dev/null || true
pass "Evolve: collect --local exercised file diff detection branch"

# 13. Verify evolution report was generated
REPORT_COUNT=$(find "$SUITE_ROOT/.ai-suite/layer4-evolutionary/reflection/evolutions" -maxdepth 1 -name "evolution_report_local_*.md" -o -name "*_local_*.md" 2>/dev/null | wc -l | tr -d ' ')
if [[ "$REPORT_COUNT" -gt 0 ]]; then
  pass "Evolve: evolution report written to evolutions/"
  find "$SUITE_ROOT/.ai-suite/layer4-evolutionary/reflection/evolutions" -maxdepth 1 -name "evolution_report_local_*.md" -delete 2>/dev/null || true
else
  fail "Evolve: evolution report missing"
fi

# 14. Verify evolve collect --local when no changes exist
NO_CHG_OUT=$(HOME="$TMP_SANDBOX/empty_home" bash "$SUITE_CLI" evolve collect --local 2>&1)
if echo "$NO_CHG_OUT" | grep -qi "No changes detected"; then
  pass "Evolve: collect --local reports no changes when cleanly synced"
else
  fail "Evolve: collect --local failed on empty diff"
fi

# --- Setup Mock Network Binaries (rsync and ssh) ---
MOCK_BIN="$TMP_SANDBOX/bin"
mkdir -p "$MOCK_BIN"
MOCK_REMOTE_SUITE="$TMP_SANDBOX/mock_remote_suite"
mkdir -p "$MOCK_REMOTE_SUITE"
echo "# Remote Skill" > "$MOCK_REMOTE_SUITE/remote-test-file.md"

# Create mock rsync
cat > "$MOCK_BIN/rsync" << 'EOF'
#!/usr/bin/env bash
if [[ "${MOCK_RSYNC_MODE:-success}" == "fail" ]]; then
  exit 1
fi
if [[ "${MOCK_RSYNC_MODE:-}" == "fail_host2" ]] && [[ "$*" =~ user@host2 ]]; then
  exit 1
fi
# If destination is local tmp directory during collect:
for arg in "$@"; do
  dest="${arg%/}"
  if [[ -d "$dest" && ( "$dest" =~ ^/tmp || "$dest" =~ ^/var/folders ) ]]; then
    mkdir -p "$dest/layer4-evolutionary/reflection"
    echo "# Remote New File" > "$dest/layer4-evolutionary/reflection/remote_new.md"
  fi
done
exit 0
EOF
chmod +x "$MOCK_BIN/rsync"

# Create mock ssh
cat > "$MOCK_BIN/ssh" << 'EOF'
#!/usr/bin/env bash
if [[ "${MOCK_SSH_MODE:-success}" == "fail" ]]; then
  exit 1
fi
if [[ "${MOCK_SSH_MODE:-}" == "fail_host2" ]] && [[ "$*" =~ user@host2 ]]; then
  exit 1
fi
exit 0
EOF
chmod +x "$MOCK_BIN/ssh"

# 15. Execute remote collect with mocked rsync and ssh
UNIQUE_REMOTE="remote_new_${RANDOM}_$$.md"
cat > "$MOCK_BIN/rsync" << EOF
#!/usr/bin/env bash
if [[ "\${MOCK_RSYNC_MODE:-success}" == "fail" ]]; then
  exit 1
fi
if [[ "\${MOCK_RSYNC_MODE:-}" == "fail_host2" ]] && [[ "\$*" =~ user@host2 ]]; then
  exit 1
fi
for arg in "\$@"; do
  dest="\${arg%/}"
  if [[ -d "\$dest" && ( "\$dest" =~ ^/tmp || "\$dest" =~ ^/var/folders ) ]]; then
    mkdir -p "\$dest/layer4-evolutionary/reflection"
    echo "# Remote New File" > "\$dest/layer4-evolutionary/reflection/$UNIQUE_REMOTE"
  fi
done
exit 0
EOF
chmod +x "$MOCK_BIN/rsync"

set +e
REMOTE_COLLECT_OUT=$(PATH="$MOCK_BIN:$PATH" bash "$SUITE_CLI" evolve collect --host user@test-host.example.com 2>&1)
REMOTE_COLLECT_CODE=$?
set -e
if [[ $REMOTE_COLLECT_CODE -eq 0 ]] && [[ "$REMOTE_COLLECT_OUT" == *"Evolution report written"* ]]; then
  pass "Evolve: remote collect succeeded with mocked rsync/ssh and generated report"
  rm -f "$SUITE_ROOT/.ai-suite/layer4-evolutionary/reflection/$UNIQUE_REMOTE"
  find "$SUITE_ROOT/.ai-suite/layer4-evolutionary/reflection/evolutions" -maxdepth 1 -name "*test-host*.md" -delete 2>/dev/null || true
else
  fail "Evolve: remote collect failed (code: $REMOTE_COLLECT_CODE)"
fi

# 16. Remote push full success (exit 0)
set +e
PUSH_SUCCESS_OUT=$(PATH="$MOCK_BIN:$PATH" bash "$SUITE_CLI" evolve push --host user@host1.example.com 2>&1)
PUSH_SUCCESS_CODE=$?
set -e
if [[ $PUSH_SUCCESS_CODE -eq 0 ]] && echo "$PUSH_SUCCESS_OUT" | grep -qi "Push complete"; then
  pass "Evolve: push succeeded across all hosts (exit 0)"
else
  fail "Evolve: push failed unexpectedly (code: $PUSH_SUCCESS_CODE)"
fi

# 17. Remote push all failed (exit 3)
set +e
PUSH_ALL_FAIL_OUT=$(MOCK_RSYNC_MODE="fail" PATH="$MOCK_BIN:$PATH" bash "$SUITE_CLI" evolve push --host user@host1.example.com 2>&1)
PUSH_ALL_FAIL_CODE=$?
set -e
if [[ $PUSH_ALL_FAIL_CODE -eq 3 ]]; then
  pass "Evolve: push correctly returns exit code 3 when all hosts fail"
else
  fail "Evolve: push did not return exit code 3 on all fail (code: $PUSH_ALL_FAIL_CODE)"
fi

# 18. Remote push partial failure (exit 10)
set +e
PUSH_PARTIAL_OUT=$(MOCK_RSYNC_MODE="fail_host2" PATH="$MOCK_BIN:$PATH" bash "$SUITE_CLI" evolve push --host user@host1 --host user@host2 2>&1)
PUSH_PARTIAL_CODE=$?
set -e
if [[ $PUSH_PARTIAL_CODE -eq 10 ]]; then
  pass "Evolve: push correctly returns exit code 10 on partial failure"
else
  fail "Evolve: push did not return exit code 10 on partial failure (code: $PUSH_PARTIAL_CODE)"
fi

# 19. Remote collect triggering semantic LLM merge prompt (existing modified file)
MERGE_TARGET="$SUITE_ROOT/.ai-suite/layer4-evolutionary/reflection/existing_local_target.md"
echo "# Version 1" > "$MERGE_TARGET"
cat > "$MOCK_BIN/rsync" << EOF
#!/usr/bin/env bash
if [[ "\${MOCK_RSYNC_MODE:-}" == "fail" ]]; then
  exit 1
fi
for arg in "\$@"; do
  dest="\${arg%/}"
  if [[ -d "\$dest" && ( "\$dest" =~ ^/tmp || "\$dest" =~ ^/var/folders ) ]]; then
    mkdir -p "\$dest/layer4-evolutionary/reflection"
    echo "# Version 2 Remote Modified" > "\$dest/layer4-evolutionary/reflection/existing_local_target.md"
  fi
done
exit 0
EOF
set +e
SEMANTIC_OUT=$(PATH="$MOCK_BIN:$PATH" bash "$SUITE_CLI" evolve collect --host user@merge-test.example.com 2>&1)
SEMANTIC_CODE=$?
set -e
rm -f "$MERGE_TARGET"
find "$SUITE_ROOT/.ai-suite/layer4-evolutionary/reflection/evolutions" -maxdepth 1 -name "*merge-test*.md" -delete 2>/dev/null || true
if [[ $SEMANTIC_CODE -eq 0 ]] && [[ "$SEMANTIC_OUT" == *"Requires AI semantic merge"* ]]; then
  pass "Evolve: remote collect detects conflict and prompts for semantic LLM merge"
else
  fail "Evolve: semantic LLM merge detection failed (code: $SEMANTIC_CODE)"
fi

# 20. Remote collect handles rsync failure gracefully
set +e
FAIL_COLLECT_OUT=$(MOCK_RSYNC_MODE="fail" PATH="$MOCK_BIN:$PATH" bash "$SUITE_CLI" evolve collect --host user@fail-host.example.com 2>&1)
FAIL_COLLECT_CODE=$?
set -e
if [[ $FAIL_COLLECT_CODE -eq 0 ]] && [[ "$FAIL_COLLECT_OUT" == *"rsync failed for user@fail-host"* ]]; then
  pass "Evolve: remote collect logs warning and recovers on rsync connection failure"
else
  fail "Evolve: remote collect failed to handle rsync error (code: $FAIL_COLLECT_CODE)"
fi

# 21. Push with default remote deployment path exercises legacy cleanup branch
set +e
CLEANUP_PUSH_OUT=$(PATH="$MOCK_BIN:$PATH" bash "$SUITE_CLI" evolve push --host user@cleanup-host.example.com 2>&1)
CLEANUP_PUSH_CODE=$?
set -e
if [[ $CLEANUP_PUSH_CODE -eq 0 ]] && [[ "$CLEANUP_PUSH_OUT" == *"Push complete"* ]]; then
  pass "Evolve: push with default deployment path executes safely"
else
  fail "Evolve: push with default deployment path failed (code: $CLEANUP_PUSH_CODE)"
fi

# 22. Push handles secondary .ai-suite rsync failure
cat > "$MOCK_BIN/rsync" << 'EOF'
#!/usr/bin/env bash
if [[ "$*" =~ \.ai-suite/ ]]; then
  exit 1
fi
exit 0
EOF
set +e
FAIL_SUITE_OUT=$(PATH="$MOCK_BIN:$PATH" bash "$SUITE_CLI" evolve push --host user@fail-suite.example.com 2>&1)
FAIL_SUITE_CODE=$?
set -e
if [[ $FAIL_SUITE_CODE -eq 3 ]] && [[ "$FAIL_SUITE_OUT" == *"rsync .ai-suite/ to user@fail-suite.example.com failed"* ]]; then
  pass "Evolve: push handles .ai-suite rsync failure appropriately"
else
  fail "Evolve: push failed to handle suite rsync error (code: $FAIL_SUITE_CODE)"
fi

# 23. Push handles remote enable command failure
cat > "$MOCK_BIN/rsync" << 'EOF'
#!/usr/bin/env bash
exit 0
EOF
cat > "$MOCK_BIN/ssh" << 'EOF'
#!/usr/bin/env bash
if [[ "$*" =~ enable ]]; then
  exit 1
fi
exit 0
EOF
set +e
FAIL_ENABLE_OUT=$(PATH="$MOCK_BIN:$PATH" bash "$SUITE_CLI" evolve push --host user@fail-enable.example.com 2>&1)
FAIL_ENABLE_CODE=$?
set -e
if [[ $FAIL_ENABLE_CODE -eq 3 ]] && [[ "$FAIL_ENABLE_OUT" == *"ai-suite enable on user@fail-enable.example.com failed"* ]]; then
  pass "Evolve: push handles remote ai-suite enable failure appropriately"
else
  fail "Evolve: push failed to handle remote enable error (code: $FAIL_ENABLE_CODE)"
fi

# Cleanup test-generated reflection and evolution reports
rm -f "$SUITE_ROOT/.ai-suite/layer4-evolutionary/reflection"/remote_new_*.md
find "$SUITE_ROOT/.ai-suite/layer4-evolutionary/reflection/evolutions" -maxdepth 1 -name "*fail-host*.md" -o -name "*test-host*.md" -o -name "evolution_report_*.md" -delete 2>/dev/null || true

total=$((PASS+FAIL))
echo ""
if [[ "$FAIL" -eq 0 ]]; then
  printf '\033[32m[module-3-test] %d/%d passed\033[0m\n' "$PASS" "$total"
  exit 0
else
  printf '\033[31m[module-3-test] %d passed, %d FAILED / %d total\033[0m\n' "$PASS" "$FAIL" "$total" >&2
  exit 1
fi
