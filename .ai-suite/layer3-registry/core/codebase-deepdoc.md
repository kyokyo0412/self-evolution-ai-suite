---
name: codebase-deepdoc
description: Produce an exhaustive layered architectural documentation suite (overview, architecture, component design, implementation, learning / development / enhancement guides) for an entire codebase under `aigen_doc/`, optionally with an `mkdocs.yml` so it can be served as a static site. Use when the user asks for a "deep doc", "full architectural documentation", "codebase study", "code documentation suite", or wants every component documented top-to-bottom with Mermaid diagrams.
triggers:
  - deep doc
  - full architectural documentation
  - codebase study
  - aigen_doc
  - document this codebase
---

# Codebase Deep-Documentation Generator

You are executing the `codebase-deepdoc` skill. Act as a Principal Systems Architect to generate a hierarchical, exhaustive documentation suite under `aigen_doc/`. 

You MUST perform deep codebase exploration using semantic search and grep. NEVER guess or rely on generic framework knowledge. Read every directory, every significant file. Synthesize, do not summarize.

Reader outcomes (the docs must enable each):
1. Non-tech + tech readers understand system purpose, concepts, day-in-the-life usage.
2. Architects understand design choices, why they were made, and how to evolve them.
3. Engineers understand each component's interface, internals, extension seams.
4. New hires can self-onboard component-by-component via learning / dev / enhancement guides.
5. Operators and testers find user / test / dev guides at the repo root.

## Execution Rules

1. **Be exhaustive.** Traverse every dir except `node_modules`, `.git`, `dist`, `build`, `vendor`, lockfiles, binary assets. Document every logical component.
2. **Be detailed.** Quote real function names, file paths, line ranges (`path/to/file.ext:Lstart-Lend`).
3. **Synthesize.** Extract patterns (Repository, Factory, CQRS, Hexagonal). Explain *why* decisions were made.
4. **Actionable.** Every document names extension points + anti-patterns.
5. **Markdown only.** Use headings, tables, Mermaid for dependency / data-flow / sequence / component / state / ER diagrams.
6. **One-shot.** Do not stop or wait for "continue". If you must cut, cut prose, not technical content.

## Output Tree (mandatory)

```
aigen_doc/
├── mkdocs.yml                         # MkDocs config for instant serving
├── docs/
│   ├── index.md                       # Master index matching README
│   ├── 00_component_inventory.md
│   ├── 01_system_overview.md
│   ├── 02_system_functions.md
│   ├── 03_system_architecture.md
│   ├── components/
│   │   └── <component-name>/
│   │       ├── 01_detailed_design.md
│   │       ├── 02_implementation_guide.md
│   │       ├── 03_learning_guide.md
│   │       ├── 04_development_guide.md
│   │       └── 05_enhancement_guide.md
│   └── guides/
│       ├── USER_GUIDE.md
│       ├── TEST_GUIDE.md
│       └── DEVELOPMENT_GUIDE.md
```

## Phased Execution

For each phase, write directly to the workspace and then proceed. Do not summarize between phases — produce files.

### Phase 0 — Discovery & Indexing
Write `aigen_doc/docs/00_component_inventory.md` listing every logical component (service / module / package / layer) with its absolute path. This is the **source of truth** for Phases 2–6; every entry must receive full Layer 2–6 documentation.

### Phase 1 — System Documentation (Layer 1)
Three files covering the whole system:
- `01_system_overview.md` — purpose, concepts, personas, system-context diagram, tech-stack table.
- `02_system_functions.md` — capability map, feature-to-component traceability, exposed APIs, cross-cutting concerns.
- `03_system_architecture.md` — architectural style, container/service C4 diagram, layered architecture, data architecture, runtime topology, ≥5 inferred ADRs, future roadmap.

### Phase 2 — Component Detailed Design (Layer 2)
Per component: `01_detailed_design.md` — public interface (full signatures, params, returns, errors), internal functions table, abstraction models (Mermaid `classDiagram`), interaction sequences, data flow, config & env vars, error modes, concurrency model, performance characteristics.

### Phase 3 — Component Implementation Guide (Layer 3)
Per component: `02_implementation_guide.md` — file-by-file walkthrough with line-range cites, algorithm deep dives, persistence mappings, extension seams.

### Phase 4 — Component Learning Guide (Layer 4)
Per component: `03_learning_guide.md` — prerequisites, ordered read-along, mental models, hands-on exercises, self-assessment with answers.

### Phase 5 — Component Development Guide (Layer 5)
Per component: `04_development_guide.md` — copy-pasteable local setup, build & run, debug recipes, "add a feature" steps, write tests, verification, rollback.

### Phase 6 — Component Enhancement Guide (Layer 6)
Per component: `05_enhancement_guide.md` — enhancement opportunities backed by code refs, recipes (Goal → Impact → Risk → Plan → Validation → Rollout), refactor candidates with before/after, evolution paths, migration playbook.

### Phase 7 — Cross-Cutting Guides
- `guides/USER_GUIDE.md` — install, configure, operate, troubleshoot, FAQ.
- `guides/TEST_GUIDE.md` — UT / IT / E2E / perf / sec; how to run; how to author; CI integration; coverage targets.
- `guides/DEVELOPMENT_GUIDE.md` — repo-wide onboarding, branching, code style, review process, release process.

### Phase 8 — Index + MkDocs
- `docs/index.md` — master index linking every doc with a one-liner, organized by layer, with a Mermaid doc-hierarchy diagram.
- `aigen_doc/mkdocs.yml` — minimal MkDocs config so `mkdocs serve` works out of the box.

## Negative Constraints (Must NOT)

- ❌ **MUST NOT:** Do not stop and ask the user to say "continue" mid-suite. Write the document exhaustively without stopping.
- ❌ **MUST NOT:** Do not summarize a component as "handles requests" — name the specific requests, middleware, returns, errors.
- ❌ **MUST NOT:** Do not include vague generic content. Every paragraph must reference a real file / line / symbol.
- ❌ **MUST NOT:** Do not skip components from the inventory.
- ❌ **MUST NOT:** Do not invent design patterns the code doesn't actually use. NEVER guess.
- ❌ **MUST NOT:** Do not use Windows-style paths.
- ❌ **MUST NOT:** Do not write doc files outside `aigen_doc/`.

## Verification

The user can verify completeness with:

```bash
# Every inventory entry has all 5 layer files
ls aigen_doc/docs/components/*/ | xargs -I{} ls {}/0{1,2,3,4,5}_*.md

# No empty files
find aigen_doc -name '*.md' -size -200c
```

---

## Reference Structures (Per-Document Required Sections)

Use this as the authoritative checklist when authoring each markdown file in `aigen_doc/`. Every numbered item is mandatory. Cite real code with `path/to/file.ext:Lstart-Lend`.

### `00_component_inventory.md`

Table: `Component | Type (service/module/package/layer) | Abs path | Entry-point file | Owns (one-line)`. Every entry receives a Layer-2-6 directory in `components/`.

### `01_system_overview.md`

1. **Purpose & Problem Statement**
2. **Core Concepts & Domain Glossary** (define every domain term)
3. **Key Functionality** (bulleted feature list, each with a one-line description)
4. **Primary User Personas & Use Cases**
5. **High-Level Usage Walkthrough** — "a day in the life"
6. **System Context Diagram** — Mermaid `C4Context` or flowchart with system + external actors + external systems
7. **Tech Stack Summary Table** — `Layer | Technology | Version | Purpose`

### `02_system_functions.md`

1. **Functional Capability Map** — hierarchical breakdown
2. **Feature-to-Component Traceability Matrix** — `Feature | Components | Files`
3. **External APIs / Interfaces Exposed** — for each REST/gRPC/GraphQL/CLI/SDK/event: method, path, payload schema, auth, error codes
4. **Cross-Cutting Concerns** — auth, logging, observability, caching, rate limiting, i18n, feature flags

### `03_system_architecture.md`

1. **Architectural Style** with justification inferred from code (monolith / microservices / modular-monolith / event-driven / hexagonal / layered)
2. **Container/Service Diagram** — Mermaid C4 Container
3. **Layered Architecture Diagram** with strict layer responsibilities
4. **Data Architecture** — datastores, schemas (high-level), data lifecycle
5. **Runtime Topology & Deployment Diagram**
6. **Cross-Cutting Architecture** — security model, observability, scalability strategy, fault tolerance, concurrency model
7. **Architectural Decisions (inferred ADRs)** — at least 5, each with Decision / Context / Consequences / Alternatives
8. **Future Enhancement Roadmap** — concrete extensibility recommendations grounded in the codebase

### `components/<name>/01_detailed_design.md`

1. **Component Summary** — role, responsibility, scope boundary
2. **Public Interface** — every exported function/class/API with full signatures, params, returns, errors, examples
3. **Internal Functions** — table of significant internal functions with purpose
4. **Abstraction Models** — domain entities, value objects, DTOs, state models with Mermaid `classDiagram`
5. **Interactions With Other Components** — Mermaid `sequenceDiagram` per major interaction; dependency direction; sync vs async; protocols
6. **Data Flow Diagram** in/out of the component
7. **Configuration & Environment Variables** consumed
8. **Error Handling & Failure Modes**
9. **Concurrency / Threading / Async Model**
10. **Performance Characteristics & Known Bottlenecks** (inferred from code)

### `components/<name>/02_implementation_guide.md`

1. **File-by-File Walkthrough** — for each source file: purpose, key constructs, line-range references, gotchas
2. **Critical Code Paths** annotated with code excerpts (real, from the repo)
3. **Algorithms & Logic Deep Dives** — pseudocode + complexity analysis
4. **State Management** — creation, mutation, persistence, invalidation
5. **Persistence Layer Mapping** — entities ↔ tables/collections ↔ migrations
6. **Testing Strategy Currently In Place** — what's tested, gaps
7. **Known Pitfalls & Anti-Patterns** observed
8. **Extension Seams** — exact files, functions, interfaces, or config to modify for common change scenarios

### `components/<name>/03_learning_guide.md`

A progressive tutorial.

1. **Prerequisites** — knowledge + tooling
2. **Step 1..N — Guided Read-Along** — ordered file reading sequence + what to focus on each step
3. **Mental Models & Analogies**
4. **Hands-On Exercises** — concrete tasks: "Trace the call from X to Y", "Modify Z and observe", "Add a log at line N and run scenario M"
5. **Self-Assessment Questions** with answer key
6. **Common Misconceptions**

### `components/<name>/04_development_guide.md`

Executable, copy-pasteable.

1. **Local Setup** — exact commands, env vars, dependencies, OS notes
2. **Build & Run** — every relevant command
3. **Debugging Recipes** — breakpoints, log toggles, profilers
4. **Adding a New Feature** — numbered steps with file paths, code snippets, test additions
5. **Modifying Existing Behavior** — numbered steps + safe-change checklist
6. **Writing Tests** — unit/integration/e2e patterns specific to this component
7. **Verification & Acceptance** — commands, expected outputs, log samples
8. **Rollback Procedure**

### `components/<name>/05_enhancement_guide.md`

Forward-looking.

1. **Identified Enhancement Opportunities** (performance, security, UX, scalability, maintainability), each backed by specific code references
2. **Enhancement Recipes** — for each: Goal → Impact → Risk → Step-by-Step Plan → Validation → Rollout
3. **Refactoring Candidates** with before/after sketches
4. **Architectural Evolution Paths** — how this component could evolve (extract service, introduce caching, switch protocol)
5. **Migration / Deprecation Playbook** if applicable

### `guides/USER_GUIDE.md`

End-user how-to: install, configure, operate, troubleshoot, FAQ.

### `guides/TEST_GUIDE.md`

Full test strategy: UT/IT/E2E/perf/sec; how to run; how to author; CI integration; coverage targets.

### `guides/DEVELOPMENT_GUIDE.md`

Repo-wide: onboarding, branching model, code style, review process, release process.

### `README.md` (master index)

Master index linking every document with a one-line description, organized by layer. Include a Mermaid diagram of the doc hierarchy.
