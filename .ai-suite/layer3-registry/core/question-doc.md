---
name: question-doc
description: Deeply analyze the codebase to answer specific user questions about code behavior, architecture, or features, providing detailed codebase mapping. Use when the user asks specific questions about the codebase.
triggers:
  - question doc
  - codebase question
---

# Codebase Q&A Playbook

You are executing the `question-doc` skill. Act as a Principal Systems Engineer to generate an exhaustive, trace-backed technical document answering the user's specific codebase question. 

You MUST perform deep codebase exploration using semantic search and grep. NEVER guess or rely on generic framework knowledge. 

## Execution Pipeline

Perform these phases sequentially. You must write the document exhaustively. Do not stop to ask the user for input information before the document is completely generated.

### Phase 1: Codebase Discovery & Trace
1. **Locate Entry Points:** Identify ingress points based on the user's question (e.g., REST API routes, syscall boundaries, netlink sockets, or CLI triggers).
2. **Trace the Codebase:** Use your search and read tools to trace the entire call chain sequentially across all relevant application layers (e.g., from routing down to the hypervisor or kernel driver).
3. **Identify Collaborators:** Log every component, interface, state mutation point (e.g., lock acquisitions, DB writes), and observability hook touched along this chain.

### Phase 2: Function & Behavior Analysis
1. **Analyze Detailed Behaviors:** Break down the operational logic, data transformations, struct mutations, loops, and conditions.
2. **Map Execution Flow:** Map the exact, sequential execution flow step-by-step from ingress to the deepest logic layer.
3. **Extract Edge Cases:** Identify error handling strategies, retry mechanisms, resource cleanup (e.g., `defer` in Go, `goto out` in C), and fallback patterns.

### Phase 3: Synthesizing the Answer
1. Explicitly formulate the **answer to the user's question** based purely on the codebase review.
2. Analyze how the answer maps into the architecture, modules, and specific code execution traces.
3. Extract design key points and identify any subtle or tricky logic (e.g., race conditions, lock-free data structures).

### Phase 4: Performance & Efficiency
1. **Efficiency:** Maximize parallel tool calls whenever independent file-reading or searching tasks can be run concurrently.

### Phase 5: Document Generation
Write the final output document to `aigen_doc/<question-topic>.md`. Ensure the directory exists before writing.

## Constraints and Rules
- [X] **MUST NOT:** Do not guess answers without tracing the relevant code.
- [X] **MUST NOT:** Do not stop to ask the user for input information before the documentation is fully generated. Write the document exhaustively without stopping.
- **MUST:** Always enforce deep code-tracing to back up answers with exact file paths and line numbers. The code or document read and analysis must be incredibly detailed.
- **MUST:** Output doc to `aigen_doc/` directory. Ensure the output layout is well-structured and highly readable.
- **MUST:** The output in the chat window is often better than the doc, so the agent MUST make the output document as good as in the chat window.

---

## Document Output Schema

The output document MUST strictly follow this Markdown structure:

# Codebase Q&A: <Question Topic>

## 1. Executive Answer
- **User Question:** <The original question>
- **Answer:** <Direct, detailed answer backed by the codebase analysis>

## 2. Code Trace & Execution Flow
- **Entry Points:** <File paths and exact function names>
- **Trace Chain:** <The sequential path of execution. Include file paths.>
- **Detailed Behaviors:** <Step-by-step logic, state mutations, lock management, and IPC mechanisms.>

## 3. Module & Architectural Mapping
- **Component Breakdown:** <Modules and files that were traversed>
- **Architectural Context:** <How this logic fits into the wider system design (e.g., control plane vs. data plane).>

## 4. Key Takeaways & Gotchas
- **Design Key Points:** <Crucial design paradigms and decisions>
- **Subtle/Tricky Logic:** <Edge cases, memory management caveats, or potential gotchas for future modifiers>
## Negative Constraints (Must NOT)
- [X] Do NOT modify any code or configuration files.
- [X] Do NOT guess answers without verifying them against the codebase.
