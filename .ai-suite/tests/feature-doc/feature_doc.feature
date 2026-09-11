Feature: feature_doc skill

As a user of the AI suite
I want a feature_doc skill
So that I can generate exhaustive documentation for a specific feature, rather than the entire codebase.

## Requirements
1. The skill must be named `feature_doc`.
2. The skill must be located at `.ai-suite/layer3-registry/core/feature-doc.md`.
3. The skill must instruct the AI to analyze specific points:
   - Entry Points (Ingress)
   - Control & Data Flow (The Call Chain)
   - Component Collaboration (Inter-process Communication)
   - State Mutations (Persistence)
   - Error Handling & Edge Cases (Added by PM)
   - Observability & Logging (Added by PM)
4. Output must be saved to the `aigen_doc/` directory (e.g., `aigen_doc/features/<feature_name>.md`).
5. The skill must enforce generating documents exhaustively without asking for user input midway.

## BDD Scenarios

Scenario: Generating documentation for a specific feature
  Given the `feature_doc` skill is available in the AI suite
  When the user asks to "document the user login feature" using the skill
  Then the agent should analyze the feature's entry points, control flow, collaboration, state mutations, errors, and observability
  And output an exhaustive document to `aigen_doc/features/user_login.md`
  And the agent should not stop to ask for user input before the document is fully written.
