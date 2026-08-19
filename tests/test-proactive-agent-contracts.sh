#!/bin/bash
# Phase 2: Test Architectural Validation for Proactive Agent

# Contract: All adapters must inject the "Proactive Resolution" text.

TMP_TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_TEST_DIR"' EXIT

fail() {
  echo "FAIL: $1"
  exit 1
}

get_all_skill_files() {
  echo ""
}
export -f get_all_skill_files

_mirror_skills() { :; }
_mirror_meta() { :; }
_remove_cursorrules_block() { :; }
_deploy_safety_rule() { :; }
_remove_safety_rule() { :; }
_remove_skills() { :; }
_remove_meta() { :; }

    export -f _mirror_skills _mirror_meta _remove_cursorrules_block _deploy_safety_rule _remove_safety_rule _remove_skills _remove_meta get_all_skill_files
    source ".ai-suite/layer2-cognitive/memory/core.sh"

for adapter in cursor claude opencode continue roo-code codex; do
  adapter_script=".ai-suite/layer1-abstraction/agents/$adapter/adapter.sh"
  if [ ! -f "$adapter_script" ]; then
    continue
  fi

  case "$adapter" in
    cursor) out_file=".cursorrules" ;;
    claude) out_file="CLAUDE.md" ;;
    opencode) out_file=".opencode/instructions.md" ;;
    continue) out_file=".continue/prompts/ai-suite.prompt" ;;
    roo-code) out_file=".roorules" ;;
    codex) out_file=".codexrules" ;;
  esac

  (
    source "$adapter_script"
    mkdir -p "$TMP_TEST_DIR/$adapter"
    agent_install_project "/fake/suite" "$TMP_TEST_DIR/$adapter" > /dev/null 2>&1
    
    full_out_file="$TMP_TEST_DIR/$adapter/$out_file"
    if [ ! -f "$full_out_file" ]; then
      echo "FAIL: $adapter did not generate $full_out_file"
      exit 1
    fi

    for word in "Proactive Resolution" "analyze" "devise" "alternative approaches" "iterative process" "evolution system"; do
      if ! grep -qi "$word" "$full_out_file"; then
         echo "FAIL: $adapter is missing '$word' in its generated rules."
         exit 1
      fi
    done
    echo "PASS: $adapter generated valid Proactive Resolution rules."
  ) || exit 1
done

echo "PASS: All architectural contracts passed."
exit 0
