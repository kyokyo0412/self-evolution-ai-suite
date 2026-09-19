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

Act as Principal Systems Architect to generate an exhaustive documentation suite under `aigen_doc/`.
Explore code via semantic search and grep; quote real symbols, file paths, and line ranges (`path/to/file.ext:Lstart-Lend`). Never guess.

## Execution Rules

1. **Exhaustive**: Document every logical component; skip `node_modules`, `.git`, `dist`, `build`, `vendor`, binaries.
2. **Traceable**: Cite real paths and line ranges. Synthesize patterns (Repository, Factory, CQRS, Hexagonal).
3. **Actionable**: Detail interfaces, extension points, error modes, and anti-patterns.
4. **Visual**: Use Mermaid diagrams for context, containers, sequences, data flows, and state machines.
5. **Autonomous**: Execute end-to-end without stopping for "continue".
6. **Maximize parallel tool calls**: Run independent file reads, searches, and inspections concurrently for efficiency.

## Mandatory Output Tree

```
aigen_doc/
|---- mkdocs.yml                         # MkDocs config for instant serving
|---- docs/
|   |---- index.md                       # Master index matching README
|   |---- 00_component_inventory.md
|   |---- 01_system_overview.md
|   |---- 02_system_functions.md
|   |---- 03_system_architecture.md
|   |---- components/
|   |   \---- <component-name>/
|   |       |---- 01_detailed_design.md
|   |       |---- 02_implementation_guide.md
|   |       |---- 03_learning_guide.md
|   |       |---- 04_development_guide.md
|   |       \---- 05_enhancement_guide.md
|   \---- guides/
|       |---- USER_GUIDE.md
|       |---- TEST_GUIDE.md
|       \---- DEVELOPMENT_GUIDE.md
```

## Phased Execution

Write files directly to workspace in sequence:

### Phase 0 -- Discovery & Component Inventory
Write `aigen_doc/docs/00_component_inventory.md` with table: `Component | Type | Abs path | Entry point | Owns`. Every entry receives full Layer 2-6 docs in `components/`.

### Phase 1 -- System Documentation (Layer 1)
- `01_system_overview.md`: Purpose, core domain glossary, key features, user personas, C4Context Mermaid diagram, tech stack table.
- `02_system_functions.md`: Functional capability map, feature-to-component traceability, exposed APIs (REST/CLI/RPC), cross-cutting concerns (auth, logging).
- `03_system_architecture.md`: Inferred architectural style, C4Container Mermaid diagram, layered topology, data flows, >=5 inferred ADRs, evolution roadmap.

### Phase 2 -- Component Detailed Design (Layer 2)
For each component in `components/<name>/01_detailed_design.md`: Public interface signatures, internal methods, `classDiagram` models, interaction sequences, config/env vars, failure modes, concurrency model.

### Phase 3 -- Component Implementation Guide (Layer 3)
For each component in `components/<name>/02_implementation_guide.md`: File-by-file walkthrough with line ranges, algorithm analyses, persistence schemas, extension seams.

### Phase 4 -- Component Learning Guide (Layer 4)
For each component in `components/<name>/03_learning_guide.md`: Prerequisites, ordered reading path, mental models, hands-on exercises, self-assessment with answers.

### Phase 5 -- Component Development Guide (Layer 5)
For each component in `components/<name>/04_development_guide.md`: Local dev setup, build/run steps, debugging recipes, feature addition playbook, test commands, verification.

### Phase 6 -- Component Enhancement Guide (Layer 6)
For each component in `components/<name>/05_enhancement_guide.md`: Code-backed enhancement proposals, refactor recipes (Goal -> Impact -> Risk -> Plan -> Validation -> Rollout), evolution paths.

### Phase 7 -- Cross-Cutting Guides
- `guides/USER_GUIDE.md`: Installation, configuration, operations, troubleshooting, FAQ.
- `guides/TEST_GUIDE.md`: UT/IT/E2E test suite instructions, authoring guide, CI setup, coverage goals.
- `guides/DEVELOPMENT_GUIDE.md`: Repo onboarding, branching, coding standards, review and release flows.

### Phase 8 -- Master Index & MkDocs Configuration
- `docs/index.md`: Hierarchy diagram, module inventory, reading paths.
- `mkdocs.yml`: Complete configuration for `mkdocs serve`.

## Verification

```bash
# Verify all component docs exist
ls aigen_doc/docs/components/*/ | xargs -I{} ls {}/0{1,2,3,4,5}_*.md
# Verify no empty files
find aigen_doc -name '*.md' -size -200c
```

## Negative Constraints (Must NOT)
- [X] Do NOT stop mid-suite or ask user to "continue".
- [X] Do NOT write generic summaries; cite specific functions, parameters, and error codes.
- [X] Do NOT omit components listed in `00_component_inventory.md`.
- [X] Do NOT invent patterns or symbols not present in the codebase.
- [X] Do NOT use Windows-style backslash paths.
- [X] Do NOT write documentation files outside `aigen_doc/`.
