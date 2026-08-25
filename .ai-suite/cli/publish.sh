#!/usr/bin/env bash
# ai-suite publish - Package the ai-suite for distribution
# This script creates a tarball of the ai-suite, excluding vendor-specific domain knowledge.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TARBALL_NAME="ai-suite-package.tar.gz"

echo "Creating publish package: $TARBALL_NAME..."

# Create a temporary directory to assemble the package
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

PKG_DIR="$TMP_DIR/ai-suite-package"
mkdir -p "$PKG_DIR/.ai-suite"

if [[ -d "$SCRIPT_DIR/.ai-suite" ]]; then
  # Case 1: AI suite developing agent (has .ai-suite/ in SCRIPT_DIR)
  SUITE_DIR="$SCRIPT_DIR/.ai-suite"
  
  # Copy core components
  cp -r "$SUITE_DIR/layer1-abstraction" "$PKG_DIR/.ai-suite/"
  cp -r "$SUITE_DIR/layer2-cognitive" "$PKG_DIR/.ai-suite/"
  cp -r "$SUITE_DIR/layer3-registry" "$PKG_DIR/.ai-suite/"
  rm -rf "$PKG_DIR/.ai-suite/layer3-registry/domains"
  cp -r "$SUITE_DIR/layer4-evolutionary" "$PKG_DIR/.ai-suite/"
  
  # Copy install scripts and cli
  cp "$SCRIPT_DIR/"*.sh "$PKG_DIR/" 2>/dev/null || true
  cp "$SCRIPT_DIR/ai-suite" "$PKG_DIR/" 2>/dev/null || true
  cp "$SCRIPT_DIR/README.md" "$PKG_DIR/" 2>/dev/null || true
  
  if [[ -d "$SUITE_DIR/cli" ]]; then
    cp -r "$SUITE_DIR/cli" "$PKG_DIR/.ai-suite/"
  fi
  
  if [[ -d "$SCRIPT_DIR/tests" ]]; then
    cp -r "$SCRIPT_DIR/tests" "$PKG_DIR/"
  fi
  
  # Create tarball
  cd "$TMP_DIR"
  tar -czf "$SCRIPT_DIR/$TARBALL_NAME" "ai-suite-package"
  cd "$SCRIPT_DIR"
  
  echo "Package created successfully: $SCRIPT_DIR/$TARBALL_NAME"
  exit 0

elif [[ "$SCRIPT_DIR" == */meta/scripts ]]; then
  # Case 2: Normal AI suite Agent (running from ~/.cursor/meta/scripts/)
  META_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
  CURSOR_DIR="$(cd "$META_DIR/.." && pwd)"
  SKILLS_DIR="$CURSOR_DIR/skills"
  
  if [[ ! -d "$SKILLS_DIR" ]]; then
    echo "Error: Skills directory not found at $SKILLS_DIR" >&2
    exit 2
  fi
  
  # Reconstruct .ai-suite/ structure
  mkdir -p "$PKG_DIR/.ai-suite/layer3-registry/core"
  mkdir -p "$PKG_DIR/.ai-suite/layer1-abstraction/agents/cursor/skills"
  mkdir -p "$PKG_DIR/.ai-suite/layer4-evolutionary/validation"
  
  # Copy meta (excluding scripts which go to root)
  cp -r "$META_DIR/"* "$PKG_DIR/.ai-suite/layer4-evolutionary/validation/" 2>/dev/null || true
  rm -rf "$PKG_DIR/.ai-suite/layer4-evolutionary/validation/scripts"
  
  # Copy root scripts
  cp "$SCRIPT_DIR/"*.sh "$PKG_DIR/" 2>/dev/null || true
  cp "$SCRIPT_DIR/ai-suite" "$PKG_DIR/" 2>/dev/null || true
  cp "$SCRIPT_DIR/README.md" "$PKG_DIR/" 2>/dev/null || true
  
  # For skills, we don't know exactly which were core and which were cursor-specific,
  # but for a published package, we can put them all in core/skills or agents/cursor/skills.
  # Let's put them in agents/cursor/skills since they were extracted from a cursor agent.
  for skill_dir in "$SKILLS_DIR"/*; do
    if [[ -d "$skill_dir" && -f "$skill_dir/SKILL.md" ]]; then
      skill_name="$(basename "$skill_dir")"
      cp "$skill_dir/SKILL.md" "$PKG_DIR/.ai-suite/layer1-abstraction/agents/cursor/skills/$skill_name.md"
    fi
  done
  
  # Create tarball
  DEST_DIR="${PWD}"
  cd "$TMP_DIR"
  tar -czf "$DEST_DIR/$TARBALL_NAME" "ai-suite-package"
  cd "$DEST_DIR"
  
  echo "Package created successfully: $DEST_DIR/$TARBALL_NAME"
  exit 0

else
  echo "Error: Cannot determine AI suite context from $SCRIPT_DIR" >&2
  exit 2
fi
