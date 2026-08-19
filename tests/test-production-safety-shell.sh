#!/bin/bash
set -euo pipefail

FILE=".ai-suite/layer3-registry/safety/production-safety.md"

if grep -q "cat << EOF > file" "$FILE" && grep -q "native agent file-writing tool" "$FILE"; then
    echo "PASS: UTF-8 file creation constraint found in production-safety.md"
    exit 0
else
    echo "FAIL: UTF-8 file creation constraint NOT found in production-safety.md"
    exit 1
fi
