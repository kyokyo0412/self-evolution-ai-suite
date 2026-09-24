---
name: feature-doc
description: Document architecture and logic for a specific codebase feature. Use when documenting a feature, mapping feature architecture, or analyzing feature behavior.
globs: ""
alwaysApply: false
triggers:
  - feature_doc
  - feature doc
  - document feature
---

# Feature Documentation & Architecture Mapping

Principal Systems Engineering workflow to produce exhaustive architectural and logic documentation for a codebase feature.

## Execution Pipeline
1. **Ingress Identification**: Trace ingress boundaries (REST, CLI, RPC, event loops) down through all application layers.
2. **Code Review & Call Chain**: Map the full sequential execution flow step-by-step; document data mutations, locks, retries, and failure states.
3. **Synthesis**: Formulate direct answers to architectural queries, mapping key points and tricky/subtle edge cases.
4. **Document Generation**: Write final document to `aigen_doc/<feature-name>.md`.

## Instructions
Exhaustively map the feature across the codebase using `Read`, `Grep`, and `Glob` before writing documentation.

## Negative Constraints (Must NOT)
- [X] Do not skip tracing any layer in the feature call chain.
- [X] Do not pause or prompt the user for missing details before documentation is fully generated.
- [X] Do not guess system behavior without verifying the underlying code.
