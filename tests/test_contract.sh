#!/bin/bash
set -e

CONTRACT_FILE="tests/feature-doc-contract.md"

echo "Validating schema contract in $CONTRACT_FILE..."

grep -qi "Executive Summary & Answer" "$CONTRACT_FILE" || { echo "Contract missing: Answer section"; exit 1; }
grep -qi "Architecture & Design Mapping" "$CONTRACT_FILE" || { echo "Contract missing: Architecture section"; exit 1; }
grep -qi "Module & Code Mapping" "$CONTRACT_FILE" || { echo "Contract missing: Code mapping section"; exit 1; }
grep -qi "Extra Beneficial Information" "$CONTRACT_FILE" || { echo "Contract missing: Extra info section"; exit 1; }

echo "Architectural contract validation PASSED."
exit 0
