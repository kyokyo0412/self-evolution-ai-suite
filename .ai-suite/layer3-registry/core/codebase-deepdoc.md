---
name: codebase-deepdoc
description: Generate exhaustive architectural documentation suites under `aigen_doc/` with Mermaid diagrams. Use when requesting deep codebase documentation, architecture studies, or full component docs.
triggers:
  - deep doc
  - full architectural documentation
  - codebase study
  - aigen_doc
  - document this codebase
---

# Codebase Deep-Documentation Generator

Generates an exhaustive, production-grade architectural documentation suite under `aigen_doc/`. Explores code via semantic search and ripgrep, citing concrete symbols, file paths, and line ranges (`path/to/file.ext:Lstart-Lend`).

## Execution Principles
1. **Exhaustive & Traceable:** Document every core module; cite real paths and symbols.
2. **Visual Architecture:** Include structured Mermaid diagrams (C4Context, C4Container, sequence diagrams).
3. **Autonomous Execution:** Maximize parallel tool calls for concurrent reads and searches.

## Target Structure (`aigen_doc/`)
- `mkdocs.yml`: MkDocs configuration.
- `docs/00_component_inventory.md`: Full component inventory table.
- `docs/01_system_overview.md`, `02_system_functions.md`, `03_system_architecture.md`: System specs with Mermaid diagrams.
- `docs/components/<name>/`: Component design, implementation, and learning guides.
- `docs/guides/`: `USER_GUIDE.md`, `TEST_GUIDE.md`, `DEVELOPMENT_GUIDE.md`.

## Instructions & Phased Execution
- **Phase 0:** Discover repository structure; write `docs/00_component_inventory.md`.
- **Phase 1:** Emit system specifications (`01_system_overview.md`, `02_system_functions.md`, `03_system_architecture.md`).
- **Phase 2:** Author component guides under `components/<name>/`.
- **Phase 3:** Author guides (`USER_GUIDE.md`, `TEST_GUIDE.md`, `DEVELOPMENT_GUIDE.md`) and `mkdocs.yml`.

## Negative Constraints (Must NOT)
- [X] **Do not stop mid-suite or prompt user to "continue"**: Execute all documentation phases autonomously.
- [X] **Do not write generic summaries without symbols**: Cite specific files, functions, types, and line ranges.
- [X] **Do not omit components listed in inventory**: Ensure complete coverage for every enumerated module.
- [X] **Do not invent patterns or nonexistent files**: Ground all documentation strictly in verified codebase facts.
- [X] **Do not use Windows-style backslashes**: Always use Unix-style forward slashes (`/`).
- [X] **Do not write documentation files outside `aigen_doc/`**: Confine all generated docs strictly to `aigen_doc/`.
