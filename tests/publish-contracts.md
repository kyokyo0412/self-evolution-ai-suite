# Architecture Contract: ai-suite publish
# Phase 2 artifact — defines interface for packaging ai-suite

## Module Boundary

ai-suite publish MUST:
  - Be located at SUITE_ROOT/ai-suite publish
  - Exit 0 on success, non-zero on any error.

## Packaging rules

  P1. The script creates a tarball named `ai-suite-package.tar.gz`.
  P2. The package includes the following directories/files:
      - `.ai-suite/core/`
      - `.ai-suite/layer1-abstraction/agents/`
      - `.ai-suite/layer4-evolutionary/validation/`
      - `ai-suite enable`
      - `ai-suite disable`
      - `ai-suite evolve`
      - `ai-suite publish`
  P3. The package EXCLUDES `.ai-suite/layer3-registry/domains/` entirely.
