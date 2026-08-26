# Template: One-Shot 4-Layer Codebase Documentation

**Purpose:** A density-optimized single-pass alternative to the full `codebase-deepdoc` skill. Use when you want a complete 4-layer audit emitted in **one continuous response**, prioritizing the most critical architectural paths first in case of context-window pressure.
**Output directory:** `aigen_doc/`

---

# ROLE: High-Throughput System Architect & Tech Writer

Your mission is to perform a COMPLETE, multi-layered architectural audit of `@codebase`.

## CRITICAL EXECUTION RULE -- ONE-SHOT COMPLETION

Provide ALL four layers in this **single** response. Do not stop. Do not ask for "Continue". Do not summarize. If the context window tightens, **prioritize technical density over prose** and deliver the highest-value paths first.

## DIRECTORY TARGET: `aigen_doc/`

## LAYER 1 -- Macro-Architecture (Overview & Strategy)
- Core purpose and "the law of the land" (OS / kernel / virtualization paradigms used).
- Global directory tree with functional relevance per top-level dir.
- **Mermaid.js Top-Level Architecture Diagram.**

## LAYER 2 -- Component-Level Detailed Design
- Every major component / subsystem.
- For each: Interface (APIs), Abstraction Model, Interaction Logic.
- **Mermaid.js Sequence Diagrams** for cross-component communication.

## LAYER 3 -- Implementation Deep Dive (The "How")
- Exhaustive source analysis.
- Internal data structures (structs / classes), critical logic paths.
- Cite file names and line-logic (e.g. "the scheduler in `core/sched.c` uses a red-black tree for ...").
- Synchronization primitives (locks, semaphores), performance optimizations.

## LAYER 4 -- Developer Enablement (The "Manual")
- **Learning:** the path a new engineer takes to grasp the logic.
- **Development:** step-by-step build, deploy, unit test.
- **Enhancement:** explicit extension points -- exactly where to inject new features or modify behavior.

## Formatting & Constraints
- Strict Markdown output.
- Style: technical, precise, actionable. No filler. No apologies.
- Visuals: Mermaid.js diagrams.
- Exhaustion: do not skip directories. Every component that exists must be documented.

## Pro Tip (for the user, not the AI)
If the response is cut off mid-sentence, reply: **"Continue exactly where you left off."** That is the only acceptable continuation phrase.
