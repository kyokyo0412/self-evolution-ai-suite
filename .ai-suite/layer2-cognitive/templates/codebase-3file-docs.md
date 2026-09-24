# Template: 3-File Architecture Documentation Suite
**Purpose:** Compact alternative to `codebase-deepdoc`. Produces 3 Markdown documents in `/document/architecture/`.

## 1. `01-System-Overview.md`
- **System Purpose**: Concise explanation of problem solved.
- **Architecture**: Macro design (Microservices, Monolith, Event-Driven, Hexagonal).
- **Component Ecosystem**: Major components list.
- **Interaction Flow**: Mermaid.js flowchart mapping data flow.

## 2. `02-Component-Specs.md`
For each major component:
- **Function & File Paths**: Exact files and directories.
- **Tech Stack & Logic**: Patterns, I/O data, and step-by-step processing.
- **Sequence Diagram**: Mermaid.js sequence diagram showing cross-module calls.

## 3. `03-Developer-Guide-and-Function-Map.md`
- **Design Reference**: Architecture extension patterns.
- **Function Map**: "Where to add code" index table.
- **Core Abstractions**: Shared interfaces and utilities.

## Constraints
- Strict Markdown; Mermaid.js for diagrams; cite exact file paths and line ranges.
