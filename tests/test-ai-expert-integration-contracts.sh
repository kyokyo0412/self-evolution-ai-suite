#!/bin/bash
set -e

CONTRACT_FILE="tests/ai-expert-integration-contracts.md"

if [ ! -f "$CONTRACT_FILE" ]; then
  echo "Error: $CONTRACT_FILE does not exist"
  exit 1
fi

if ! grep -q "Reflection Protocol" "$CONTRACT_FILE"; then
  echo "Error: Missing Reflection Protocol contract"
  exit 1
fi

if ! grep -q "Global AI Suite Block" "$CONTRACT_FILE"; then
  echo "Error: Missing Global AI Suite Block contract"
  exit 1
fi

if ! grep -q "TDD Team Process" "$CONTRACT_FILE"; then
  echo "Error: Missing TDD Team Process contract"
  exit 1
fi

if ! grep -q "Autonomous Team Process" "$CONTRACT_FILE"; then
  echo "Error: Missing Autonomous Team Process contract"
  exit 1
fi

echo "Contract validation passed."
exit 0
