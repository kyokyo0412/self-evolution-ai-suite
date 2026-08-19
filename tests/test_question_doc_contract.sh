#!/bin/bash
set -e

CONTRACT_FILE="tests/question-doc-contract.md"

echo "Validating schema contract in $CONTRACT_FILE..."

grep -qi "Executive Answer" "$CONTRACT_FILE" || { echo "Contract missing: Answer section"; exit 1; }
grep -qi "Trace Chain" "$CONTRACT_FILE" || { echo "Contract missing: Trace Chain section"; exit 1; }
grep -qi "Detailed Behaviors" "$CONTRACT_FILE" || { echo "Contract missing: Detailed Behaviors section"; exit 1; }
grep -qi "Module" "$CONTRACT_FILE" || { echo "Contract missing: Module mapping section"; exit 1; }

echo "Architectural contract validation PASSED."
exit 0
