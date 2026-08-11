---
name: feature-doc
description: Produce exhaustive architecture and logic documentation for a specific feature by analyzing the codebase. Use when the user asks to document a feature, answer questions about a feature, or map out the architecture of a specific feature.
globs: ""
alwaysApply: false
triggers:
  - feature_doc
  - feature doc
  - document feature
---

# Feature Documentation & Question Answering Generator

You are executing the `feature-doc` skill. Act as a Principal Systems Engineer to generate an exhaustive, detailed architectural and logic documentation suite for a specific feature. 

You MUST perform deep codebase exploration using semantic search and grep. NEVER guess or rely on generic framework knowledge. Review the source code and dig into the details to answer the user's questions.

## Execution Pipeline

Perform these phases sequentially. You must write the document exhausted, do not stop to ask users input information before all done.

### Phase 1: Codebase Discovery & Ingress Identification
1. Locate the feature entry point (e.g., REST/gRPC endpoints, CLI commands, event consumers).
2. **Figure all related codes about the feature in the codebase**: Trace the entire call chain sequentially across all application layers. Use codebase search tools to find all files and components related to the feature.
3. Identify every component, interface, state mutation point, and observability hook touched along this chain.

### Phase 2: Code Review & Function Analysis
1. **Review all codes above and figure out the functions of the features**: Deeply analyze the identified code to understand what each component does and how they contribute to the overall feature.
2. **Document full code trace chains**: Map out the exact, sequential execution flow step-by-step from ingress to the deepest logic layer.
3. **Analyze detailed behaviors**: Break down the specific operational logic, data transformations, conditions, loops, and state changes occurring within the analyzed code.
4. Extract all edge-case handlings, error handling strategies, retry mechanisms, and fallback patterns.

### Phase 3: Synthesizing the Answer
1. Explicitly formulate the **answer to the question** the user asked based on the codebase review.
2. Analyze how the answer is mapped into the architecture, design, modules, and codes.
3. Extract **design key points** and identify any **subtle or tricky logic** that a developer must know when modifying this feature.
4. Gather **extra information which benefits the user**.

### Phase 4: Performance & Efficiency
1. **Efficiency & Performance**: Maximize parallel tool calls whenever independent tasks can be run concurrently (e.g., executing parallel searches, reading multiple files) to improve AI agent execution efficiency.

### Phase 5: Document Generation
Write the final output doc to `aigen_doc/<feature-name>.md`. Ensure the directory exists.

## Constraints and Rules
- Always enforce deep code-tracing across ALL layers. The code or document read and analysis must be incredibly detailed and cover all the details.
- Output doc to aigen_doc/ directory.
- As detailed as possible. Ensure the output layout is well-structured and highly readable.
- Write the document exhaustively, do not stop to ask users input information before all done.
- The output in the chat window is often better than the doc, so the agent MUST make the output document as good as in the chat window.

## Negative Constraints (Must NOT)
- ❌ **MUST NOT:** Do not skip tracing any layer in the call chain.
- ❌ **MUST NOT:** Do not stop to ask users input information before the documentation is fully generated. Write the document exhaustively without stopping.
- ❌ **MUST NOT:** Do not guess answers without tracing the relevant code.

---

## Document Output Schema

The output document MUST strictly follow this Markdown structure:

# Technical Specification: <Question Topic / Feature Name>

## 1. Executive Summary & Answer
- **Question:** The user's original question.
- **Answer:** The direct, detailed answer to the question based on the code analysis.

## 2. Architecture & Design Mapping
- **Architectural Context:** How the answer mapped into the architecture, design.
- **Design Key Points:** Critical design decisions and architectural guidelines necessary for future enhancement.
- **Design Trade-offs:** Relevant architectural decisions and patterns used.

## 3. Module & Code Mapping
- **Component Breakdown:** How the answer mapped into the modules and codes.
- **Full Code Trace Chain:** A step-by-step, sequential mapping of the execution flow traversing across the relevant components and files.
- **Detailed Behaviors & Implementation:** Deep dive into the precise logic, conditions, data transformations, and state mutations within the analyzed functions.

## 4. Extra Beneficial Information
- **Subtle/Tricky Logic (Gotchas):** Important edge cases, hidden dependencies, or complex logic nuances that developers must be aware of to prevent regressions.
- **Best Practices:** Recommendations or standards.
- **Contextual Insights:** Extra informations which benefit to the user (related systems, edge cases).
