# Template: Codebase Onboarding

**Purpose:** Answer an onboarding request in chat without file creation unless explicitly requested.

## Inputs

Resolve repository/revision, audience, and relevant scope. Trace actual source and project guidance; clarify missing essential scope and label unverified behavior.

## Answer structure

1. Purpose, verified high-level architecture, languages, and relevant frameworks.
2. Major modules and responsibilities, actual entry point, and an ordinary execution flow.
3. State, persistence, schemas, concurrency, trust boundaries, and recovery where applicable.
4. Extension points with exact file/symbol references and source-backed build/test commands.

Keep detail proportional to the question. Cite relevant source and distinguish observation from inference. Report unavailable verification; do not invent files, runtime results, or write artifacts for a chat-only request.
