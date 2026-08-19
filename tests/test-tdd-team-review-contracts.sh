#!/bin/bash
set -e

check_contract() {
  local file=$1
  if [ ! -f "$file" ]; then
    echo "File $file does not exist."
    return 1
  fi

  echo "Checking $file for Agent process review contract..."
  if ! grep -qi "review the \`*tdd-team\`* skill" "$file"; then
    echo "FAIL: Agent process review contract not found in $file"
    return 1
  fi

  echo "Checking $file for Team phase review contract..."
  if ! grep -qi "review the tasks, rules, and constraint" "$file" && ! grep -qi "review the tasks, rules and constraint" "$file"; then
    echo "FAIL: Team phase review contract not found in $file"
    return 1
  fi

  echo "PASS: All contracts met for $file"
  return 0
}

PASS_COUNT=0
FAIL_COUNT=0

# Find all tdd-team skill files
while IFS= read -r file; do
  if check_contract "$file"; then
    PASS_COUNT=$((PASS_COUNT+1))
  else
    FAIL_COUNT=$((FAIL_COUNT+1))
  fi
done < <(find . -type f -name "SKILL.md" -path "*/tdd-team/*" -o -type f -name "tdd-team.md" -path "*/layer3-registry/core/*")

if [ $FAIL_COUNT -gt 0 ]; then
  echo "FAIL: $FAIL_COUNT skill files failed the contract check."
  exit 1
fi

if [ $PASS_COUNT -eq 0 ]; then
  echo "FAIL: No skill files found to check."
  exit 1
fi

echo "SUCCESS: Contracts validation passed for $PASS_COUNT files."
exit 0
