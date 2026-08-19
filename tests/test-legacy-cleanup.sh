#!/usr/bin/env bash
set -e

echo "Running legacy cleanup test..."

# Create a fake legacy opencode config file
cat <<EOF > .opencode.md
Some user content
<!-- ai-suite:start -->
Legacy config
<!-- ai-suite:end -->
More user content
EOF

# Run uninstall project for opencode
bash ai-suite disable --scope project --agent opencode > /dev/null

if grep -q "<!-- ai-suite:start -->" .opencode.md 2>/dev/null; then
  echo "TEST FAILED: Legacy ai-suite block was not cleaned up from .opencode.md"
  rm -f .opencode.md
  exit 1
fi

echo "TEST PASSED: Legacy block was successfully cleaned up."
rm -f .opencode.md
