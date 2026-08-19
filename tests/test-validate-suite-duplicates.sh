#!/usr/bin/env bash
set -euo pipefail

# test-validate-suite-duplicates.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
VALIDATOR="$PROJECT_ROOT/.ai-suite/layer4-evolutionary/validation/validate-suite.sh"

# Create a temporary sandbox with fake skills
SANDBOX=$(mktemp -d)
trap 'rm -rf "$SANDBOX"' EXIT

# Mock suite root
mkdir -p "$SANDBOX/.ai-suite/layer3-registry/core"
mkdir -p "$SANDBOX/.ai-suite/layer1-abstraction/agents/cursor/skills"

cat << 'EOF' > "$SANDBOX/.ai-suite/layer3-registry/core/my-duplicate-skill.md"
---
name: my-duplicate-skill
description: A duplicate skill test. Use when testing duplicates.
triggers:
  - test duplicate
---
## Instructions
Do something.
## Negative Constraints
Must not fail.
EOF

cat << 'EOF' > "$SANDBOX/.ai-suite/layer1-abstraction/agents/cursor/skills/my-duplicate-skill.md"
---
name: my-duplicate-skill
description: A duplicate skill test for cursor. Use when testing duplicates.
triggers:
  - test duplicate cursor
---
## Instructions
Do something.
## Negative Constraints
Must not fail.
EOF

# Make the validator use the sandbox
# validate-suite.sh uses its own directory to find SUITE_ROOT. 
# We need to test the logic directly or copy the validator into the sandbox.
mkdir -p "$SANDBOX/.ai-suite/layer4-evolutionary/validation"
cp "$VALIDATOR" "$SANDBOX/.ai-suite/layer4-evolutionary/validation/"

# Run the validator
output=$(bash "$SANDBOX/.ai-suite/layer4-evolutionary/validation/validate-suite.sh" 2>&1 || true)

if echo "$output" | grep -q "FAIL.*my-duplicate-skill"; then
  echo "PASS: Validator correctly identified duplicate skill 'my-duplicate-skill'."
  exit 0
else
  echo "FAIL: Validator missed the duplicate skill."
  echo "Output was:"
  echo "$output"
  exit 1
fi
