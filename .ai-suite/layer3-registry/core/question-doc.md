---
name: question-doc
description: Answer a specific codebase question with traced source evidence. Use when asking how repository behavior, architecture, or a particular feature works.
triggers:
  - question doc
  - codebase question
---

# Codebase Q&A

## Inputs and authority

Resolve the question, repository/revision, relevant scope, audience, and requested output. Reuse context and source evidence for routine details; ask early if a missing essential question or scope prevents a meaningful answer. Documentation does not authorize implementation changes.

## Execution Pipeline

1. **Entry Point Discovery:** Find the relevant CLI, API, handler, configuration, or other ingress; identify the tested revision and applicable project contracts.
2. **Call-Chain Tracing:** Follow the relevant callers, branches, state mutations, concurrency boundaries, error handling, and recovery. Use available file/search tools (`rg` or supported Read/Grep/Glob equivalents); parallelize independent reads, preserving dependencies in execution traces.
3. **Synthesis:** Give direct answers backed by exact code references and symbols. Distinguish source-defined behavior, observed runtime evidence, and unverified external behavior. State UNKNOWN for inaccessible or missing behavior with the evidence gap; do not guess.
4. **Document Generation:** Honor an explicit chat-only answer or output location. Otherwise write `aigen_doc/<question-topic>.md` using a safe project-relative topic. Update relevant existing documentation where appropriate and preserve unrelated user content.
5. **Verification:** Check cited files/symbols and local links against the examined revision. Run relevant safe tests only when needed to resolve a behavioral claim; report actual commands and limits.

## Output and recovery

Lead with the answer, then its execution trace, relevant edge cases, and references. State uncovered branches or unavailable services. Complete all independently answerable parts without routine continuation prompts; if essential source or access remains missing, report the blocker and focused next action rather than claiming complete coverage.

## Negative Constraints (Must NOT)

- [X] Do not modify any code or configuration files.
- [X] Do not guess answers, invent files, or replace repository facts with generic framework descriptions.
- [X] Do not expose secrets, execute remote mutations, or expand beyond the requested question.
- [X] Do not write files for an explicitly chat-only request or overwrite unrelated documentation.
