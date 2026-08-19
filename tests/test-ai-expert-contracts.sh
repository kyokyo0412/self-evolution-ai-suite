#!/bin/bash
set -e

CONTRACT_FILE="tests/ai-expert-contracts.md"

if [ ! -f "$CONTRACT_FILE" ]; then
  echo "Error: $CONTRACT_FILE does not exist"
  exit 1
fi

if ! grep -q "Frontmatter" "$CONTRACT_FILE"; then
  echo "Error: Missing Frontmatter definition in contract"
  exit 1
fi

if ! grep -q "Body" "$CONTRACT_FILE"; then
  echo "Error: Missing Body definition in contract"
  exit 1
fi

echo "Contract validation passed."
exit 0
