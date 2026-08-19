#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUITE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MANAGE="$SUITE_ROOT/ai-suite manage"

echo "Running Phase 4 Domain Registry Test..."

# Create a dummy git repo
DUMMY_REPO=$(mktemp -d "${TMPDIR:-/tmp}/dummy-repo.XXXXXX")
mkdir -p "$DUMMY_REPO/.ai-suite/layer3-registry/domains/test_domain/skills"
cat <<'EOF' > "$DUMMY_REPO/.ai-suite/layer3-registry/domains/test_domain/skills/dummy.md"
---
name: dummy
description: A dummy skill. Use when testing.
triggers:
  - test dummy
---
## Instructions
Dummy content

## Negative Constraints
None
EOF

cd "$DUMMY_REPO"
git init
git add .
git commit -m "initial commit"

cd "$SUITE_ROOT"

# Run ai-suite manage against the dummy repo
"$MANAGE" domain install "file://$DUMMY_REPO" --domain test_domain

# Check if the domain was installed
if [[ ! -f "$SUITE_ROOT/.ai-suite/layer3-registry/domains/test_domain/skills/dummy.md" ]]; then
    echo "FAILED: Domain was not installed correctly."
    rm -rf "$DUMMY_REPO"
    exit 1
fi

echo "Cleaning up..."
rm -rf "$SUITE_ROOT/.ai-suite/layer3-registry/domains/test_domain"
rm -rf "$DUMMY_REPO"

echo "Phase 4 Domain Registry Test PASSED."
exit 0
