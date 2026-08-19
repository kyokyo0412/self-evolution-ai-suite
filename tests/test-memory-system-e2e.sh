#!/bin/bash
set -e

echo "Running End-to-End QA Gate for AI Suite Memory System..."

echo "1. Feature Validation"
./tests/test-memory-system-feature.sh

echo "2. Contract Validation"
./tests/test-memory-system-contracts.sh

echo "3. Unit Tests (EUT)"
./tests/test-memory-system-eut.sh

echo "4. Evolution Integration Tests"
./tests/test-memory-system-evolution.sh

echo "All End-to-End QA Gate tests passed successfully."
exit 0
