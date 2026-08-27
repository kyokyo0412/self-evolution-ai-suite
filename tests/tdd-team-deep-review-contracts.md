# TDD Team Deep Review, Senior Roles & Code Quality Contracts

## 1. Senior & Expert Roles Specification
The `tdd-team` skill must define a team roster where all roles operate at a distinguished / staff / principal expert level:
1. **Staff/Principal PM & Product Strategist**: Owns Executable Specifications (BDD scenarios) and Master To-Do list. Focuses on edge-case foresight, non-functional requirements (scale, latency, throughput, concurrency), failure scenario modeling, requirement disambiguation, and anti-regression rigor.
2. **Distinguished AI Expert & Cognitive Architect**: Optimizes prompts, requirements, meta-prompts, agent workflows, anti-hallucination guardrails, context management, and reasoning paths for maximum execution efficiency.
3. **Fellow/Principal Engineer & Chief Reviewer (Veto Authority)**: Conducts rigorous, multi-dimensional reviews across PM plans, SDET test designs, Architect technical architectures, and Developer code implementations. Exercises absolute veto power to reject incomplete, fragile, or unaligned deliverables. Mandates deep line-level code audits for boundary conditions, memory/resource safety, error handling, string/stream safety, concurrency safety, and algorithmic efficiency.
4. **Principal Systems Architect**: Designs highly testable, scalable, modular architectures. Defines interface contracts, mock schemas, and API stubs. Focuses on concurrency models, parallel processing, non-blocking operations, failure domains, blast radius containment, and data flow. Authorized to pivot the technical strategy on 3x dead-end escalation.
5. **Senior Principal SDET / Chaos Gatekeeper**: Writes requirement-validation scripts, contract tests, and UT/IT/FT/EUT test suites. Enforces stage gates. Validates requirement correctness and intent before implementation. Enforces Boundary Value Analysis (BVA), Equivalence Partitioning, Combinatorial coverage, Fault Injection, and Negative Path testing. Adheres to 1E-Class Security Standards.
6. **Staff Systems Developer**: Strictly executes Red-Green-Refactor. Writes minimal, clean, deterministic, robust, and idiomatic production code solely to satisfy failing tests. Adheres to defensive programming, zero resource leaks, explicit error handling, and robust string/stream processing.
7. **Senior Lead Technical Writer & Knowledge Architect**: Compiles the comprehensive final documentation suite, architectural rationales, operational guides, and detailed user explanations with explicit notes and caveats.

## 2. Phase 2 Architectural & Scalability Review Contract
Phase 2.2 Architecture Review MUST explicitly evaluate:
- **Scalability & Capacity**: Memory consumption bounds, horizontal/vertical scalability, streaming large datasets vs buffering in memory.
- **Concurrency & Parallel Processing**: Parallel processing capabilities, worker pools, non-blocking I/O, race condition and deadlock prevention.
- **Robustness & Failure Modes**: Failure blast radius, graceful degradation, circuit breaking, deterministic recovery, idempotency.
- **Contract & Schema Integrity**: Strict interface schemas, error models, backward compatibility, and SOLID principles.

## 3. Phase 3 Line-Level Code Review Checklist Contract
Phase 3.5 Code & Implementation Review MUST enforce a structured, mandatory line-level review across 7 dimensions:
1. **Boundary & Edge Case Handling**: Off-by-one errors, empty/null/nil inputs, minimum/maximum value extremes, slice/index bounds.
2. **Deterministic Error Handling**: No swallowed exceptions/errors, explicit propagation, actionable error messages, safe fallbacks, deterministic cleanup.
3. **String, Stream & Injection Safety**: Safe quoting, buffer/stream bounds, UTF-8 safety, injection prevention, regex backtracking safety.
4. **Resource & Memory Safety**: Explicit resource deallocation, file descriptor closures, memory leak prevention, timeout enforcement on all I/O.
5. **Concurrency & Race Safety**: Thread-safety, atomic operations, lock contention minimization, deadlock-free lock ordering.
6. **Algorithmic Efficiency & Performance**: Time/space complexity ($O(N)$ vs $O(N^2)$), vectorization/batching, minimal disk I/O and redundant lookups.
7. **User Prompt & Requirement Alignment**: Exact fulfillment of user requirements and negative constraints without omitting any requested behavior.

## 4. Phase 3.2 Mental Dry-Run Contract
Before mutating any files, the Principal Engineer must perform a static analysis and mental simulation of proposed changes against edge cases, boundary conditions, algorithmic complexity, parallel safety, and resource lifecycles.
