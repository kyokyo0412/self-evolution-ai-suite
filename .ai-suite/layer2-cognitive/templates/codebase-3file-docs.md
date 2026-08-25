# Template: 3-File Architecture Documentation Suite

**Purpose:** A compact alternative to `codebase-deepdoc`. Produces exactly **three** Markdown documents inside `/document/architecture/`: a system overview, a component spec, and a developer guide / function map. Use when you want a coherent architecture pack without the full 6-layer-per-component explosion.

**Output directory:** `/document/architecture/`

---

@Codebase

Act as an **Expert Software Architect and Technical Writer**. Analyze this entire repository and generate a comprehensive suite of architectural and developer documentation as Markdown files in a new folder named `/document/architecture/`. If the codebase is too large to do in one response, start with the first file and wait for my prompt to continue.

Generate the following three documents.

## 1. `01-System-Overview.md` - High-Level Design & Function

- **System Purpose** - clear, concise explanation of what this source code does and the business / technical problem it solves.
- **High-Level Architecture** - macro architecture (Microservices, Monolith, Event-Driven, MVC, modular monolith, hexagonal, etc.).
- **Component Ecosystem** - list the major components / modules.
- **Interaction Flow** - how the major components interact, plus a Mermaid.js flowchart mapping the high-level architecture and data flow.

## 2. `02-Component-Specs.md` - Detailed Component Implementation

For EVERY major component identified in the overview, provide:

- **Component Function** - what exactly does this component do?
- **File Paths** - the exact directories and source files that make up this component.
- **Tech Stack** - language, frameworks, libraries used to implement it.
- **Algorithms & Techniques** - notable design patterns, algorithms, data structures.
- **Inputs & Outputs** - what data it ingests (APIs, events, DB reads) and what it emits or mutates.
- **Processing Logic** - step-by-step transformation from input to output.
- **Sequence Diagram** - a Mermaid.js sequence diagram showing how this component communicates with others.

## 3. `03-Developer-Guide-and-Function-Map.md` - Coding & Design Reference

Design this as a **daily tool** for the engineer coding and designing enhancements.

- **Design Reference** - guidelines on how to use the existing architecture to design new features. Where should new business logic go? How should state be managed given current patterns?
- **The Function Map** - a "Where to add code" index. Format as a table or Mermaid mindmap mapping common developer tasks to specific file paths.
  - *Example:* "To add a new API endpoint -> go to `/src/api/routes/` and update `router.go`."
  - *Example:* "To modify database schemas -> go to `/src/db/migrations/`."
- **Core Abstractions** - the most important interfaces, base classes, or shared utilities that should be reused instead of rewritten.

## Constraints

- Strict Markdown.
- Mermaid.js for all diagrams.
- Cite file paths and where useful, line ranges (`path/to/file.ext:Lstart-Lend`).
- Never write vague statements; specify behavior precisely.
