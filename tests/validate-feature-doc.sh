#!/usr/bin/env bash
set -e

FILE=".ai-suite/layer3-registry/core/feature-doc.md"

if [ ! -f "$FILE" ]; then
  echo "Error: $FILE does not exist."
  exit 1
fi

grep -qi "Figure all related codes" "$FILE" || (echo "Missing 'Figure all related codes' instruction" && exit 1)
grep -qi "Review all codes" "$FILE" || (echo "Missing 'Review all codes' instruction" && exit 1)
grep -qi "Architecture and Design" "$FILE" || (echo "Missing 'Architecture and Design' section" && exit 1)
grep -qi "Implementation Map" "$FILE" || (echo "Missing 'Implementation Map' section" && exit 1)

echo "Contract validation passed!"
