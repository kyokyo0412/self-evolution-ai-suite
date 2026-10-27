---
name: codebase-deepdoc
description: Generate a source-grounded architecture documentation suite. Use when requesting deep codebase documentation, a codebase study, or full component documentation.
triggers:
  - deep doc
  - full architectural documentation
  - codebase study
  - aigen_doc
  - document this codebase
---

# Codebase Deep Documentation

## Inputs and authority

Resolve the repository/revision, included and excluded paths, audience, and output root. Default to project-relative `aigen_doc/`; honor an explicitly authorized alternative and adapt all links consistently. Preserve existing user documentation. This workflow writes documentation, not application code or configuration. Clarify missing essential scope while continuing independent discovery.

## Execution principles

Ground claims in verified codebase facts: cite existing files, symbols, and line locations. Distinguish source behavior, observed execution, and unknown external deployment behavior. Use available file/search tools and supported parallel tool calls for independent reads. Mermaid diagrams explain architecture and flows; do not infer components merely to fill a diagram.

## Instructions and phased execution

- **Phase 0 -- Inventory:** Discover core modules, entry points, dependencies, and tests in the requested scope. Write `docs/00_component_inventory.md` under the output root with stable component IDs, source paths, importance, and planned artifacts. Record exclusions and unknowns.
- **Phase 1 -- System:** Write `docs/01_system_overview.md`, `docs/02_system_functions.md`, and `docs/03_system_architecture.md`. Cover purpose, contracts, state/control flow, trust boundaries, failure recovery, and applicable resource bounds, using Mermaid where useful.
- **Phase 2 -- Components:** Write design, implementation, and extension guidance under `docs/components/<name>/`. Trace interfaces, key algorithms/state, collaborators, errors, and tests. Link each included inventory component to its actual document; choose filenames to fit its content rather than manufacturing a fixed number of files.
- **Phase 3 -- Guides:** Write `docs/guides/USER_GUIDE.md`, `TEST_GUIDE.md`, and `DEVELOPMENT_GUIDE.md`. Generate `mkdocs.yml` with real relative paths when a browsable suite is requested; preserve an existing site configuration and merge deliberately.
- **Phase 4 -- Verification:** Compare inventory entries with actual artifact links; check cited source paths/symbols, Markdown links, and navigation. Run the project's documentation build or diagram validator when available; disclose unavailable tooling. File size, filename counts, and keyword presence do not prove documentation quality.

## Output and recovery

Execute all documentation phases autonomously within the authorized scope; avoid routine "continue" prompts. For large repositories, prioritize system boundaries and critical paths while maintaining a coverage ledger of completed, excluded, and unresolved components. Checkpoint remaining work if a resource limit or external blocker prevents completion. Report the actual covered scope, artifacts, verification commands/results, UNKNOWN claims, and remaining work; do not disguise partial coverage as exhaustive completion.

## Negative Constraints (Must NOT)

- [X] Do not invent patterns or nonexistent files, symbols, tests, runtime results, or deployment facts.
- [X] Do not omit inventory components silently or certify completeness from file size or fixed counts.
- [X] Do not modify application code/configuration, expose credentials, or overwrite unrelated user documentation.
- [X] Do not write outside the authorized output root; use forward slashes in project-relative links.
