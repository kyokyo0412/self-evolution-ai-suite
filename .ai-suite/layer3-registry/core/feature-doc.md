---
name: feature-doc
description: Trace and document an existing feature's architecture and behavior. Use when documenting a feature, mapping its execution flow, or analyzing feature behavior.
triggers:
  - feature_doc
  - feature doc
  - document feature
---

# Feature Documentation and Architecture Mapping

## Inputs and authority

Resolve the feature, repository/revision, audience, scope, and desired output. Use known entry points and project context to infer routine details; clarify missing essential scope before inventing an answer. This workflow authorizes documentation, not source/configuration changes or feature implementation.

## Execution Pipeline

1. **Ingress Identification:** Find REST, CLI, RPC, events, or other entry points for the feature and its configuration.
2. **Code Review and Call Chain:** Trace the relevant execution flow, branches, data mutations, state transitions, locks, retries, and failure states. Bound exploration to the actual feature; identify omitted or inaccessible branches explicitly.
3. **Component Collaboration:** Map cooperating components, interface contracts, persistence, and cross-process messages. Distinguish local source behavior from external service assumptions.
4. **Observability and Error Handling:** Explain diagnostic logs, metrics, tracing, failure propagation, and recovery using evidence from the code. Mask credentials.
5. **Synthesis:** Answer the feature's architectural questions with concrete file/symbol citations and diagrams when they clarify the flow. Mark unsupported claims UNKNOWN rather than guessing.
6. **Document Generation and Verification:** Honor the user's explicit output location or chat-only request; otherwise write `aigen_doc/<feature-name>.md` with a safe project-relative name. Reuse relevant existing documentation and preserve user edits. Check source references, local links, diagram structure, and consistency with the examined revision.

## Instructions and recovery

Trace the relevant feature using available file/search tools (`rg`, `find`/`grep`, or supported Read/Grep/Glob equivalents). Use parallel tool calls for independent reads; preserve execution dependencies. Complete independently supported sections without routine continuation prompts. If essential source or access remains unavailable, record the evidence gap, partial coverage, and next useful action.

Report the document/answer, verified behavior, uncovered cases, actual checks, and limitations. Reading source does not prove that an external deployment behaves identically.

## Negative Constraints (Must NOT)

- [X] Do not guess system behavior without verifying the underlying code.
- [X] Do not silently omit a relevant layer, invent runtime results, or claim complete coverage over missing source.
- [X] Do not modify implementation/configuration, expose credentials, or overwrite unrelated documentation.
- [X] Do not force file creation for an explicitly chat-only request.
