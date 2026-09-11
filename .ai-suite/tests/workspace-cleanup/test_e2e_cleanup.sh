#!/bin/bash
set -euo pipefail
set -e

echo "Running E2E System QA Gate for workspace cleanup rule..."

# Validate the rule presence
.ai-suite/tests/workspace-cleanup/validate_cleanup_rule.sh

echo "E2E System QA Gate passed successfully."
exit 0
