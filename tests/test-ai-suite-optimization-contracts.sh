#!/bin/bash
set -e

echo "Running Additional AI Suite Optimization Contracts..."

FEATURE_DOC=".ai-suite/layer3-registry/core/feature-doc.md"
DEEPDOC=".ai-suite/layer3-registry/core/codebase-deepdoc.md"

if [ ! -f "$FEATURE_DOC" ]; then
    echo "ERROR: $FEATURE_DOC does not exist."
    exit 1
fi

if [ ! -f "$DEEPDOC" ]; then
    echo "ERROR: $DEEPDOC does not exist."
    exit 1
fi

echo "Checking feature-doc.md for 'parallel tool calls'..."
if ! grep -iq "parallel tool calls" "$FEATURE_DOC"; then
    echo "ERROR: feature-doc.md does not enforce parallel tool calls."
    exit 1
fi

echo "Checking codebase-deepdoc.md for 'parallel tool calls'..."
if ! grep -iq "parallel tool calls" "$DEEPDOC"; then
    echo "ERROR: codebase-deepdoc.md does not enforce parallel tool calls."
    exit 1
fi

echo "SUCCESS: Additional AI Suite Optimization contracts verified."
exit 0
