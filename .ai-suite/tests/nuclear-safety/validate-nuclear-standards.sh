#!/bin/bash
set -euo pipefail
# Test script to validate that 1E-class nuclear safety standards are present in the agent directives and code quality rules.

set -e

RULES_DIR=".ai-suite/layer3-registry/directives"
CODE_QUALITY_FILE="$RULES_DIR/code-quality.md"
AGENT_DIRECTIVES_FILE="$RULES_DIR/agent-directives.md"
NUCLEAR_SAFETY_FILE="$RULES_DIR/nuclear-safety.md"

echo "Running 1E-Class Nuclear Safety Standards Validation..."

# Check if nuclear-safety.md exists
if [ ! -f "$NUCLEAR_SAFETY_FILE" ]; then
  echo "FAIL: $NUCLEAR_SAFETY_FILE does not exist."
  exit 1
fi

# Validate Code Quality Standards
echo "Validating Code Quality Standards..."
grep -qi "deterministic" "$NUCLEAR_SAFETY_FILE" || { echo "FAIL: Missing 'deterministic' constraint."; exit 1; }
grep -qi "dynamic memory allocation" "$NUCLEAR_SAFETY_FILE" || { echo "FAIL: Missing 'dynamic memory allocation' constraint."; exit 1; }
grep -qi "formal verification" "$NUCLEAR_SAFETY_FILE" || { echo "FAIL: Missing 'formal verification' constraint."; exit 1; }

# Validate Testing Standards
echo "Validating Testing Standards..."
grep -qi "MC/DC" "$NUCLEAR_SAFETY_FILE" || { echo "FAIL: Missing 'MC/DC' coverage constraint."; exit 1; }
grep -qi "traceability" "$NUCLEAR_SAFETY_FILE" || { echo "FAIL: Missing 'traceability' constraint."; exit 1; }
grep -qi "Fault Injection" "$NUCLEAR_SAFETY_FILE" || { echo "FAIL: Missing 'Fault Injection' constraint."; exit 1; }

# Check integration into agent-directives or code-quality
if ! grep -qi "nuclear" "$CODE_QUALITY_FILE" && ! grep -qi "nuclear" "$AGENT_DIRECTIVES_FILE"; then
  echo "FAIL: Nuclear safety standards are not referenced in the main directives."
  exit 1
fi

echo "PASS: All 1E-Class Nuclear Safety Standards are correctly enforced."
exit 0
