#!/usr/bin/env bash
# tests/test-memory-system-eut.sh -- Comprehensive unit and integration tests for AI Suite Memory System
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

PASS=0
FAIL=0

pass() { PASS=$((PASS + 1)); printf '  \033[32mPASS\033[0m  %s\n' "$*"; }
fail() { FAIL=$((FAIL + 1)); printf '  \033[31mFAIL\033[0m  %s\n' "$*" >&2; }

echo "=== Comprehensive AI Suite Memory System EUT ==="

SANDBOX=$(mktemp -d "${TMPDIR:-/tmp}/memory-eut.XXXXXX")
trap 'rm -rf "$SANDBOX"' EXIT

export HOME="$SANDBOX/home"
export AI_MEMORY_PROJECT_DIR="$SANDBOX/project/.ai-memory"
export AI_MEMORY_GLOBAL_DIR="$SANDBOX/home/.ai-suite/memory"

mkdir -p "$HOME" "$SANDBOX/project"

# Source the real repository memory script
MEMORY_LIB="$REPO_ROOT/.ai-suite/layer2-cognitive/memory/memory.sh"
[[ -f "$MEMORY_LIB" ]] || { echo "Fatal: missing $MEMORY_LIB" >&2; exit 2; }

# shellcheck source=.ai-suite/layer2-cognitive/memory/memory.sh
SUITE_DIR="$REPO_ROOT/.ai-suite" source "$MEMORY_LIB"

AGENT="test_agent"

# 1. ai_memory_init error path
set +e
ERR_OUT=$(ai_memory_init "" 2>&1)
ERR_CODE=$?
set -e
if [[ $ERR_CODE -ne 0 ]] && echo "$ERR_OUT" | grep -qi "agent_name is required"; then
  pass "ai_memory_init requires agent_name"
else
  fail "ai_memory_init did not reject empty agent_name (code: $ERR_CODE)"
fi

# 2. ai_memory_init happy path
ai_memory_init "$AGENT"
if [[ -d "$AI_MEMORY_PROJECT_DIR/$AGENT/index" && -d "$AI_MEMORY_GLOBAL_DIR/$AGENT/tasks" ]]; then
  pass "ai_memory_init created index and task directories"
else
  fail "ai_memory_init failed to create directories"
fi

# 3. Index save & load
ai_memory_save_index "$AGENT" "high-level" "Project High Level Architecture"
INDEX_VAL=$(ai_memory_load_index "$AGENT" "high-level")
if [[ "$INDEX_VAL" == "Project High Level Architecture" ]]; then
  pass "ai_memory_save_index and ai_memory_load_index match"
else
  fail "ai_memory_load_index mismatch: got '$INDEX_VAL'"
fi

# Load nonexistent index returns empty
EMPTY_INDEX=$(ai_memory_load_index "$AGENT" "nonexistent_level")
if [[ -z "$EMPTY_INDEX" ]]; then
  pass "ai_memory_load_index on nonexistent file returns empty"
else
  fail "ai_memory_load_index on nonexistent file returned content"
fi

# 4. Tasks save, list, and load
ai_memory_save_task "$AGENT" "task-42" "Task 42 execution notes"
TASKS=$(ai_memory_list_tasks "$AGENT")
if echo "$TASKS" | grep -q "task-42"; then
  pass "ai_memory_list_tasks found saved task"
  TASK_FILENAME=$(echo "$TASKS" | grep "task-42" | head -n 1)
  LOADED_TASK=$(ai_memory_load_task "$AGENT" "$TASK_FILENAME")
  if [[ "$LOADED_TASK" == "Task 42 execution notes" ]]; then
    pass "ai_memory_load_task loaded exact task content"
  else
    fail "ai_memory_load_task content mismatch: '$LOADED_TASK'"
  fi
else
  fail "ai_memory_list_tasks did not list task-42"
fi

# Load nonexistent task
EMPTY_TASK=$(ai_memory_load_task "$AGENT" "nonexistent_task.md")
if [[ -z "$EMPTY_TASK" ]]; then
  pass "ai_memory_load_task on nonexistent file returns empty"
else
  fail "ai_memory_load_task on nonexistent file returned content"
fi

# 5. Important memory save, append, load
ai_memory_save_important "$AGENT" "Rule 1: Always verify in sandbox"
ai_memory_append_important "$AGENT" "Rule 2: No production changes"
IMPORTANT_VAL=$(ai_memory_load_important "$AGENT")
if echo "$IMPORTANT_VAL" | grep -q "Rule 1" && echo "$IMPORTANT_VAL" | grep -q "Rule 2"; then
  pass "ai_memory_save_important and append_important correctly preserved"
else
  fail "ai_memory_load_important missing appended content: '$IMPORTANT_VAL'"
fi

# 6. Layer memory save, load, list
ai_memory_save_layer "$AGENT" "domain_rules" "Strict 1E-Class Safety"
ai_memory_save_layer "$AGENT" "network_topo" "Mesh network topology"
LAYER_VAL=$(ai_memory_load_layer "$AGENT" "domain_rules")
if [[ "$LAYER_VAL" == "Strict 1E-Class Safety" ]]; then
  pass "ai_memory_save_layer and load_layer match"
else
  fail "ai_memory_load_layer mismatch: '$LAYER_VAL'"
fi

LAYERS=$(ai_memory_list_layers "$AGENT")
if echo "$LAYERS" | grep -q "domain_rules" && echo "$LAYERS" | grep -q "network_topo"; then
  pass "ai_memory_list_layers listed all layer keys"
else
  fail "ai_memory_list_layers incomplete: '$LAYERS'"
fi

EMPTY_LAYER=$(ai_memory_load_layer "$AGENT" "nonexistent_layer")
if [[ -z "$EMPTY_LAYER" ]]; then
  pass "ai_memory_load_layer on nonexistent layer returns empty"
else
  fail "ai_memory_load_layer returned content for nonexistent layer"
fi

# 7. Timeline memory append and read
ai_memory_append_timeline "$AGENT" "Phase 1 complete"
ai_memory_append_timeline "$AGENT" "Phase 2 in progress"
TIMELINE_VAL=$(ai_memory_read_timeline "$AGENT")
if echo "$TIMELINE_VAL" | grep -q "Phase 1 complete" && echo "$TIMELINE_VAL" | grep -q "Phase 2 in progress"; then
  pass "ai_memory_append_timeline and read_timeline match"
else
  fail "ai_memory_read_timeline mismatch: '$TIMELINE_VAL'"
fi

# 8. Masking functionality
ai_memory_mask "$AGENT" "on"
if [[ -f "$AI_MEMORY_PROJECT_DIR/$AGENT/.masked" && -f "$AI_MEMORY_GLOBAL_DIR/$AGENT/.masked" ]]; then
  pass "ai_memory_mask on created mask files"
else
  fail "ai_memory_mask on failed to create mask files"
fi

# Under mask, reading returns empty
M_INDEX=$(ai_memory_load_index "$AGENT" "high-level")
M_TASK=$(ai_memory_load_task "$AGENT" "$TASK_FILENAME")
M_IMP=$(ai_memory_load_important "$AGENT")
M_LAYER=$(ai_memory_load_layer "$AGENT" "domain_rules")
M_TIME=$(ai_memory_read_timeline "$AGENT")

if [[ -z "$M_INDEX" && -z "$M_TASK" && -z "$M_IMP" && -z "$M_LAYER" && -z "$M_TIME" ]]; then
  pass "All memory readers return empty when masked"
else
  fail "Memory leak during masking: index='$M_INDEX', task='$M_TASK', imp='$M_IMP', layer='$M_LAYER', time='$M_TIME'"
fi

# Unmask
ai_memory_mask "$AGENT" "off"
if [[ ! -f "$AI_MEMORY_PROJECT_DIR/$AGENT/.masked" && ! -f "$AI_MEMORY_GLOBAL_DIR/$AGENT/.masked" ]]; then
  pass "ai_memory_mask off removed mask files"
else
  fail "ai_memory_mask off failed to remove mask files"
fi

UNMASKED_IMP=$(ai_memory_load_important "$AGENT")
if echo "$UNMASKED_IMP" | grep -q "Rule 1"; then
  pass "Unmasked reading restores access to memory contents"
else
  fail "Failed to read memory after unmask"
fi

# 9. Summary & Search
SUMMARY_OUT=$(ai_memory_summary "$AGENT")
if echo "$SUMMARY_OUT" | grep -q "Memory Summary for Agent: $AGENT" && echo "$SUMMARY_OUT" | grep -q "important.md"; then
  pass "ai_memory_summary generated report with line counts and file listings"
else
  fail "ai_memory_summary output incomplete: '$SUMMARY_OUT'"
fi

SEARCH_OUT=$(ai_memory_search "$AGENT" "Safety")
if echo "$SEARCH_OUT" | grep -q "Strict 1E-Class Safety"; then
  pass "ai_memory_search found keyword in memory files"
else
  fail "ai_memory_search failed to find keyword: '$SEARCH_OUT'"
fi

# 10. Memory clean
ai_memory_clean "$AGENT"
if [[ ! -d "$AI_MEMORY_PROJECT_DIR/$AGENT" && ! -d "$AI_MEMORY_GLOBAL_DIR/$AGENT" ]]; then
  pass "ai_memory_clean completely purged project and global memory for agent"
else
  fail "ai_memory_clean left residual directories"
fi

# Clean nonexistent agent directory handles safely
ai_memory_clean "nonexistent_agent_xyz"
pass "ai_memory_clean handles nonexistent agent cleanly"

# Test fallback SUITE_DIR resolution
(
  unset SUITE_DIR
  source "$MEMORY_LIB"
)
pass "memory.sh fallback SUITE_DIR resolution verified"

echo ""
echo "=== Summary: $PASS passed, $FAIL failed ==="
if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
exit 0
