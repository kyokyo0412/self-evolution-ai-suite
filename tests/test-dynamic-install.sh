#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SUITE_DIR="$ROOT_DIR/.ai-suite"

TEST_DIR=$(mktemp -d -t ai-suite-test-dynamic.XXXXXX)
trap 'rm -rf "$TEST_DIR"' EXIT

echo "Testing Cursor installation..."
cd "$TEST_DIR"
bash "$ROOT_DIR/ai-suite" enable --scope project --project "$TEST_DIR" --agent cursor >/dev/null

# Check directives
for src in "$SUITE_DIR/layer3-registry/directives/"*.md; do
  [[ -f "$src" ]] || continue
  filename=$(basename "$src" .md)
  if [[ ! -f "$TEST_DIR/.cursor/rules/cursor-suite-${filename}.mdc" ]]; then
    echo "ERROR: cursor-suite-${filename}.mdc not found!"
    exit 1
  fi
done

# Check safety
for src in "$SUITE_DIR/layer3-registry/safety/"*.md; do
  [[ -f "$src" ]] || continue
  filename=$(basename "$src" .md)
  if [[ ! -f "$TEST_DIR/.cursor/rules/cursor-suite-${filename}.mdc" ]]; then
    echo "ERROR: cursor-suite-${filename}.mdc not found!"
    exit 1
  fi
done

# Check cursor rules
for src in "$SUITE_DIR/layer1-abstraction/agents/cursor/rules/"*.md; do
  [[ -f "$src" ]] || continue
  filename=$(basename "$src" .md)
  if [[ ! -f "$TEST_DIR/.cursor/rules/cursor-suite-${filename}.mdc" ]]; then
    echo "ERROR: cursor-suite-${filename}.mdc not found!"
    exit 1
  fi
done

echo "Testing Claude installation..."
bash "$ROOT_DIR/ai-suite" enable --scope project --project "$TEST_DIR" --agent claude >/dev/null

# Check CLAUDE.md
if [[ ! -f "$TEST_DIR/CLAUDE.md" ]]; then
  echo "ERROR: CLAUDE.md not found!"
  exit 1
fi

for src in "$SUITE_DIR/layer3-registry/directives/"*.md; do
  [[ -f "$src" ]] || continue
  # Just check if a known string from the file is in CLAUDE.md
  # We can check if the title is there
  title=$(grep '^# ' "$src" | head -1)
  if ! grep -qF "$title" "$TEST_DIR/CLAUDE.md"; then
    echo "ERROR: Content of $src not found in CLAUDE.md!"
    exit 1
  fi
done

for src in "$SUITE_DIR/layer3-registry/safety/"*.md; do
  [[ -f "$src" ]] || continue
  title=$(grep '^# ' "$src" | head -1)
  if ! grep -qF "$title" "$TEST_DIR/CLAUDE.md"; then
    echo "ERROR: Content of $src not found in CLAUDE.md!"
    exit 1
  fi
done

echo "All dynamic installation tests passed!"
exit 0
