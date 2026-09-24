# Template: One-Shot 4-Layer Codebase Documentation
**Purpose:** Single-pass alternative to `codebase-deepdoc` prioritizing density. Emitted in `aigen_doc/`.

## Execution Rule: One-Shot Completion
Emit all 4 layers in a single response without stopping. Prioritize technical density over prose.

## Layers
- **Layer 1 (Macro-Architecture):** System purpose, directory tree, Mermaid architecture diagram.
- **Layer 2 (Component Design):** Subsystems, public APIs, Mermaid sequence diagrams.
- **Layer 3 (Implementation Deep Dive):** Data structures, critical paths, locks, performance optimizations with concrete file citations.
- **Layer 4 (Developer Enablement):** Build/test setup, extension points, and onboarding runbooks.

## Constraints
Strict Markdown, Mermaid diagrams, cite exact file paths and line ranges. Zero filler.
