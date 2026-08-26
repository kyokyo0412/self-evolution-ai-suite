#!/bin/bash
set -euo pipefail

echo "Running architectural contract tests..."

declare -a LAYERS=(
    ".ai-suite/layer1-abstraction"
    ".ai-suite/layer2-cognitive"
    ".ai-suite/layer3-registry"
    ".ai-suite/layer4-evolutionary"
)

declare -a CONTRACTS=(
    ".ai-suite/layer1-abstraction/agents/cursor/adapter.sh"
    ".ai-suite/layer2-cognitive/memory/memory.sh"
    ".ai-suite/layer2-cognitive/memory/core.sh"
    ".ai-suite/layer2-cognitive/meta-compiler/prompt-compiler.md"
    ".ai-suite/layer2-cognitive/meta-compiler/prompt-compiler.md"
    ".ai-suite/layer2-cognitive/meta-compiler/ai-expert.md"
    ".ai-suite/layer3-registry/core/tdd-team.md"
    ".ai-suite/layer3-registry/core/codebase-deepdoc.md"
    ".ai-suite/layer3-registry/domains/example_domain/skills/example-skill.md"
    ".ai-suite/layer3-registry/safety/production-safety.md"
    ".ai-suite/layer4-evolutionary/reflection/reflection-protocol.md"
    ".ai-suite/layer4-evolutionary/merging/absorb-capability.md"
    ".ai-suite/layer4-evolutionary/merging/integrate-capability.md"
    ".ai-suite/layer4-evolutionary/validation/validate-suite.sh"
)

declare -a FORBIDDEN=(
    ".ai-suite/agents"
    ".ai-suite/core"
    ".ai-suite/domains"
    ".ai-suite/meta"
)

failed=0

for layer in "${LAYERS[@]}"; do
    if [[ ! -d "$layer" ]]; then
        echo "[X] Missing layer: $layer"
        failed=1
    else
        echo "M-^\M-^E Found layer: $layer"
    fi
done

for contract in "${CONTRACTS[@]}"; do
    if [[ ! -f "$contract" ]]; then
        echo "[X] Missing contract file: $contract"
        failed=1
    else
        echo "M-^\M-^E Found contract file: $contract"
    fi
done

for forbidden in "${FORBIDDEN[@]}"; do
    if [[ -d "$forbidden" ]]; then
        echo "[X] Forbidden directory still exists: $forbidden"
        failed=1
    else
        echo "M-^\M-^E Forbidden directory absent: $forbidden"
    fi
done

if [[ $failed -eq 1 ]]; then
    echo "Contract validation failed!"
    exit 1
fi

echo "All contracts passed."
