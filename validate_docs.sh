#!/bin/bash
# SDET Validation Script for Phase 1

check_file() {
  local file=$1
  echo "Checking $file..."
  
  if ! grep -qi "Act as a" "$file"; then
    echo "FAIL: Missing persona definition in $file"
    return 1
  fi
  
  if ! grep -qi "NEVER guess" "$file"; then
    echo "FAIL: Missing constraint against guessing in $file"
    return 1
  fi
  
  if ! grep -qi "Do not stop to ask" "$file" && ! grep -qi "Do not stop and ask" "$file"; then
    echo "FAIL: Missing constraint against stopping for user input in $file"
    return 1
  fi
  
  if ! grep -qi "aigen_doc" "$file"; then
    echo "FAIL: Missing aigen_doc output directory in $file"
    return 1
  fi
  
  echo "PASS: $file meets requirements."
  return 0
}

check_file ".ai-suite/layer3-registry/core/feature-doc.md"
check_file ".ai-suite/layer3-registry/core/codebase-deepdoc.md"
