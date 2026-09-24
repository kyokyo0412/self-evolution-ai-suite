---
name: absorb-capability
description: Ingest, deduplicate, and merge capabilities from external agents via semantic analysis. Use when absorbing, ingesting, or fetching capabilities from an external agent configuration directory.
triggers:
  - absorb capability
  - absorb agent
  - ingest external agent
  - absorb from
---

# Absorb Capability -- External Agent Ingestion Engine

Orchestrate the ingestion and structural evolution of external agent capabilities into the AI suite.

## Instructions
1. **Fetch:** Sandbox directory via `mktemp -d`. Rsync remote `.cursor/` or copy local agent skills/rules.
2. **Semantic Mapping:** Parse capabilities using `Glob` and `Read`; extract core intent and preconditions.
3. **Integration:** Merge into `.ai-suite/` and active agent configuration without duplicate appending.
4. **Verification & Cleanup:** Run `validate-suite.sh`, remove sandbox directory, and report absorbed capabilities.

## Negative Constraints (Must NOT)
- [X] Do not break the existing evolutionary loop (`ai-suite evolve`).
- [X] Do not auto-commit changes to git repository.
- [X] Do not merge duplicate capabilities without unifying semantic differences.
