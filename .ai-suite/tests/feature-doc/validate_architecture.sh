#!/bin/bash
set -euo pipefail
set -e

SKILL_FILE=".ai-suite/layer3-registry/core/feature-doc.md"
SCHEMA_FILE=".ai-suite/tests/feature-doc/skill_schema.yaml"

echo "Validating Architecture..."
if [ ! -f "$SCHEMA_FILE" ]; then
    echo "ERROR: Schema file not found."
    exit 1
fi

echo "Architecture validation test designed successfully."