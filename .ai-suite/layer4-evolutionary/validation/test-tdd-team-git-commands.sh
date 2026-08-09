#!/usr/bin/env bash
set -euo pipefail

echo "Running TDD Team git commands test..."

TDD_SKILL=".ai-suite/layer3-registry/core/tdd-team.md"

if [[ ! -f "$TDD_SKILL" ]]; then
  echo "FAIL: $TDD_SKILL not found"
  exit 1
fi

if ! grep -iq "Provide copy-paste \`git\` commands" "$TDD_SKILL"; then
  echo "FAIL: $TDD_SKILL does not contain instruction to provide copy-paste git commands"
  exit 1
fi

if ! grep -iq "git commit" "$TDD_SKILL"; then
  echo "FAIL: $TDD_SKILL does not contain 'git commit' example"
  exit 1
fi

echo "PASS: TDD Team skill instructs to provide copy-paste git commands"
exit 0
