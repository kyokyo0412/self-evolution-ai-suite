---
name: question-doc
description: Deeply analyze the codebase to answer specific user questions about code behavior, architecture, or features, providing detailed codebase mapping. Use when the user asks specific questions about the codebase.
triggers:
  - question doc
  - codebase question
---

# Codebase Q&A Playbook

Analyze codebase architecture and implementation details to answer specific inquiries with code-level precision.

## Execution Pipeline
1. **Entry Point Discovery**: Locate ingress boundaries (API routes, syscalls, handlers, CLI commands).
2. **Call-Chain Tracing**: Sequentially trace logic paths, structs, state mutations, and concurrency boundaries across all relevant files.
3. **Synthesis**: Formulate direct answers backed by exact code references; highlight design paradigms and edge-case gotchas.
4. **Document Generation**: Write final report to `aigen_doc/<question-topic>.md`.

## Instructions
Trace and read relevant files exhaustively using `Read`, `Grep`, and `Glob` before synthesizing answers.

## Negative Constraints (Must NOT)
- [X] Do not guess answers without tracing source code.
- [X] Do not pause for user inputs before completing the full documentation.
- [X] Do not emit generic framework answers without citing actual repository paths.
- [X] Do not modify any code or configuration files.
