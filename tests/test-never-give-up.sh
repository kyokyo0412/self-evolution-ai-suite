#!/usr/bin/env bash
set -euo pipefail

echo "Running never-give-up tests..."

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

SANDBOX=$(mktemp -d "${TMPDIR:-/tmp}/never-give-up.XXXXXX")
trap 'rm -rf "$SANDBOX"' EXIT

# Run ai-suite enable with --project flag pointing to SANDBOX
bash "$PROJECT_ROOT/ai-suite" enable --scope project --project "$SANDBOX" --agent all > /dev/null

cd "$SANDBOX"

# Check cursorrules
if ! grep -iq "never-give-up" .cursorrules; then
  echo "FAIL: .cursorrules does not contain 'never-give-up' spirit"
  exit 1
fi

if ! grep -iq "damaging the production environment" .cursorrules; then
  echo "FAIL: .cursorrules does not contain production safety constraint"
  exit 1
fi

if ! grep -iq "Otherwise, it should run as normal mode" .cursorrules; then
  echo "FAIL: .cursorrules does not contain 'normal mode' fallback"
  exit 1
fi

# Check CLAUDE.md
if ! grep -iq "never-give-up" CLAUDE.md; then
  echo "FAIL: CLAUDE.md does not contain 'never-give-up' spirit"
  exit 1
fi

if ! grep -iq "Otherwise, it should run as normal mode" CLAUDE.md; then
  echo "FAIL: CLAUDE.md does not contain 'normal mode' fallback"
  exit 1
fi

echo "PASS: never-give-up spirit is present in generated rules"
exit 0