# Template: Three-File Architecture Documentation

**Purpose:** Produce a compact source-grounded suite in project-relative `aigen_doc/architecture/`, or an explicitly authorized output directory.

## Inputs

Resolve repository/revision, included paths, audience, and output root. Preserve relevant existing documentation and user edits. Ask for missing essential scope; mark unavailable behavior UNKNOWN instead of inventing it.

## Artifacts

1. `01-System-Overview.md`: Purpose, verified architecture, major components, entry points, and a Mermaid data/control-flow diagram when useful.
2. `02-Component-Specs.md`: Each included component's exact files/symbols, interfaces, state, collaborators, error/recovery paths, and relevant sequence diagrams.
3. `03-Developer-Guide-and-Function-Map.md`: Build/test commands verified from the repository, extension points, file/function map, and applicable coding conventions.

## Verification and handoff

Check source citations, local links, diagrams, and consistency with the examined revision. State scope, actual checks, excluded components, and unresolved claims. Do not modify application code/configuration or write outside the authorized output root.
