#!/bin/bash
set -euo pipefail
set -e

DIRECTIVE_FILE=".ai-suite/layer3-registry/directives/agent-directives.md"

if [ ! -f "$DIRECTIVE_FILE" ]; then
  echo "Error: $DIRECTIVE_FILE not found."
  exit 1
fi

echo "Validating agent-directives.md for unused files cleanup rule..."

# Check for "Unused Files" in the Workspace Cleanup section
if ! grep -qiE "unused files.*clean up|clean up.*unused files" "$DIRECTIVE_FILE"; then
  echo "RED: Missing directive to clean up unused files after the task is done."
  exit 1
fi

echo "GREEN: Unused files cleanup rule is present."
exit 0
