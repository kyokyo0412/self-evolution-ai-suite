#!/bin/bash
# Phase 4: End-to-End System QA Gate for Proactive Agent
# This test acts as a mock user installing the suite to a fake project
# and verifying the final output matches exactly what an agent would read.

TMP_PROJECT=$(mktemp -d)
trap 'rm -rf "$TMP_PROJECT"' EXIT

# Need to source ai-suite enable if it exists.
# We saw ai-suite workflow or similar, let's search for an install script.
# Wait, I don't see ai-suite enable in root. Let's find it.
# Actually, the adapter.sh defines `agent_install_project`. We can just test that directly with real paths.

for adapter in cursor claude opencode continue roo-code codex; do
  adapter_script=".ai-suite/layer1-abstraction/agents/$adapter/adapter.sh"
  if [ ! -f "$adapter_script" ]; then continue; fi

  case "$adapter" in
    cursor) target_file=".cursorrules" ;;
    claude) target_file="CLAUDE.md" ;;
    opencode) target_file=".opencode/instructions.md" ;;
    continue) target_file=".continue/prompts/ai-suite.prompt" ;;
    roo-code) target_file=".roorules" ;;
    codex) target_file="AGENTS.md" ;;
  esac

  # Subshell to isolate functions
  (
    # Mocking mirror functions just to avoid moving real files which might fail in isolated test
    _mirror_skills() { :; }
    _mirror_meta() { :; }
    _remove_cursorrules_block() { :; }
    _deploy_safety_rule() { :; }
    _remove_safety_rule() { :; }
    _remove_skills() { :; }
    _remove_meta() { :; }
    get_all_skill_files() { echo ""; }
    
    export -f _mirror_skills _mirror_meta _remove_cursorrules_block _deploy_safety_rule _remove_safety_rule _remove_skills _remove_meta get_all_skill_files
    # We must source core.sh to get the real generate_markdown_block
    source ".ai-suite/layer2-cognitive/memory/core.sh"

    source "$adapter_script"
    mkdir -p "$TMP_PROJECT/$adapter"
    # Execute the install
    agent_install_project "." "$TMP_PROJECT/$adapter" > /dev/null 2>&1
    
    out_file="$TMP_PROJECT/$adapter/$target_file"
    
    # Assert
    if ! grep -qi "proactively resolve" "$out_file"; then
      echo "FAIL: E2E missing 'proactively resolve' in $adapter ($out_file)"
      exit 1
    fi
    if ! grep -qi "evolution system" "$out_file"; then
      echo "FAIL: E2E missing 'evolution system' in $adapter ($out_file)"
      exit 1
    fi
    
    echo "PASS E2E: $adapter successfully generated proactive resolution guidance."
  ) || exit 1
done

echo "PASS E2E: All System QA Gate tests passed."
exit 0
