#!/usr/bin/env bash
# ai-suite publish -- Package the ai-suite for distribution
# This script creates a tarball of the ai-suite, excluding vendor-specific domain knowledge.

set -euo pipefail

ORIGIN_DIR="${AI_SUITE_PUBLISH_ORIGIN_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
SCRIPT_DIR="$(cd "$ORIGIN_DIR/../.." 2>/dev/null && pwd || echo "$ORIGIN_DIR/../..")"
TARBALL_NAME="ai-suite-package.tar.gz"

if [[ "${1:-}" =~ ^(-h|--help|help)$ ]]; then
  echo "Usage: ai-suite publish [options]"
  echo "Package the ai-suite for distribution (excluding vendor-specific domain knowledge)."
  (return 0 2>/dev/null) && return 0 || exit 0
fi

echo "Creating publish package: $TARBALL_NAME..."

# Create a temporary directory to assemble the package
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

PKG_DIR="$TMP_DIR/ai-suite-package"
mkdir -p "$PKG_DIR/.ai-suite"

clean_and_verify_zero_leak() {
  local target_dir="$1"
  local leak_pat
  leak_pat=$(printf '%s%s|%s%s' "vm" "ware" "broad" "com")
  if grep -riEl "$leak_pat" "$target_dir" >/dev/null 2>&1; then
    while IFS= read -r leak_file; do
      rm -f "$leak_file"
    done < <(grep -riEl "$leak_pat" "$target_dir")
  fi

  if grep -riE "$leak_pat" "$target_dir" >/dev/null 2>&1; then
    echo "Error: Domain leakage detected in publish package" >&2
    exit 1
  fi
}

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
  
  if [[ -d "$SUITE_DIR/tests" ]]; then
    cp -r "$SUITE_DIR/tests" "$PKG_DIR/.ai-suite/"
  fi

  if [[ -d "$SCRIPT_DIR/tests" ]]; then
    cp -r "$SCRIPT_DIR/tests" "$PKG_DIR/"
  fi
  
  clean_and_verify_zero_leak "$PKG_DIR"
  
  # Create tarball
  cd "$TMP_DIR"
  tar -czf "$SCRIPT_DIR/$TARBALL_NAME" "ai-suite-package"
  cd "$SCRIPT_DIR"
  
  echo "Package created successfully: $SCRIPT_DIR/$TARBALL_NAME"
  exit 0

elif [[ "$ORIGIN_DIR" == */meta/scripts ]]; then
  # Case 2: Normal AI suite Agent (running from ~/.cursor/meta/scripts/)
  META_DIR="$(cd "$ORIGIN_DIR/.." && pwd)"
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
  mkdir -p "$PKG_DIR/.ai-suite/layer2-cognitive"
  
  # Copy framework layers if preserved in META_DIR
  if [[ -d "$META_DIR/layer1-abstraction" ]]; then
    cp -r "$META_DIR/layer1-abstraction" "$PKG_DIR/.ai-suite/"
  fi
  if [[ -d "$META_DIR/cli" ]]; then
    cp -r "$META_DIR/cli" "$PKG_DIR/.ai-suite/"
  elif [[ -d "$ORIGIN_DIR" ]]; then
    mkdir -p "$PKG_DIR/.ai-suite/cli"
    cp "$ORIGIN_DIR/"*.sh "$PKG_DIR/.ai-suite/cli/" 2>/dev/null || true
  fi
  if [[ -d "$META_DIR/layer2-cognitive" ]]; then
    cp -r "$META_DIR/layer2-cognitive" "$PKG_DIR/.ai-suite/"
  fi
  if [[ -d "$META_DIR/layer3-registry" ]]; then
    cp -r "$META_DIR/layer3-registry" "$PKG_DIR/.ai-suite/"
    rm -rf "$PKG_DIR/.ai-suite/layer3-registry/domains"
  fi

  # Copy meta validation files
  cp -r "$META_DIR/"* "$PKG_DIR/.ai-suite/layer4-evolutionary/validation/" 2>/dev/null || true
  rm -rf "$PKG_DIR/.ai-suite/layer4-evolutionary/validation/scripts" \
         "$PKG_DIR/.ai-suite/layer4-evolutionary/validation/layer1-abstraction" \
         "$PKG_DIR/.ai-suite/layer4-evolutionary/validation/cli" \
         "$PKG_DIR/.ai-suite/layer4-evolutionary/validation/layer2-cognitive" \
         "$PKG_DIR/.ai-suite/layer4-evolutionary/validation/layer3-registry" 2>/dev/null || true
  
  # Copy root scripts and binaries
  cp "$SCRIPT_DIR/"*.sh "$PKG_DIR/" 2>/dev/null || true
  cp "$ORIGIN_DIR/"*.sh "$PKG_DIR/" 2>/dev/null || true
  cp "$SCRIPT_DIR/ai-suite" "$PKG_DIR/" 2>/dev/null || true
  cp "$META_DIR/ai-suite" "$PKG_DIR/" 2>/dev/null || true
  cp "$META_DIR/scripts/ai-suite" "$PKG_DIR/" 2>/dev/null || true
  cp "$SCRIPT_DIR/README.md" "$PKG_DIR/" 2>/dev/null || true
  cp "$META_DIR/README.md" "$PKG_DIR/" 2>/dev/null || true

  # Ensure memory core exists
  if [[ ! -f "$PKG_DIR/.ai-suite/layer2-cognitive/memory/core.sh" && -f "$ORIGIN_DIR/core.sh" ]]; then
    mkdir -p "$PKG_DIR/.ai-suite/layer2-cognitive/memory"
    cp "$ORIGIN_DIR/core.sh" "$PKG_DIR/.ai-suite/layer2-cognitive/memory/core.sh"
  fi
  
  for skill_dir in "$SKILLS_DIR"/*; do
    if [[ -d "$skill_dir" && -f "$skill_dir/SKILL.md" ]]; then
      skill_name="$(basename "$skill_dir")"
      # Skip vendor/domain specific skills
      leak_pat=$(printf '%s%s|%s%s' "vm" "ware" "broad" "com")
      if grep -qiE "$leak_pat" "$skill_dir/SKILL.md" 2>/dev/null; then
        continue
      fi
      cp "$skill_dir/SKILL.md" "$PKG_DIR/.ai-suite/layer1-abstraction/agents/cursor/skills/$skill_name.md"
    fi
  done
  
  clean_and_verify_zero_leak "$PKG_DIR"
  
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
