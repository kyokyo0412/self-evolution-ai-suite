#!/bin/bash
set -e

echo "Running End-to-End System QA Gate for AI-Expert..."

./tests/test-ai-expert-feature.sh
./tests/test-ai-expert-contracts.sh
./tests/test-ai-expert-skill.sh

echo "End-to-End QA Gate passed successfully."
exit 0
