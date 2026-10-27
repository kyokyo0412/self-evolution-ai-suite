# Specialist review guide for TDD Team

When applicable, use these dimensions to design tests and review changes. Mark other dimensions `NOT_APPLICABLE` with a reason. These are review aids, not universal mandates or certification.

## Domain Classification & Risk Profiling

The Domain Context Matrix records Domain Category & Standards Mapping, Domain Specific Failure Modes, and Domain Non-Functional Requirements. Ground protocols, regulatory constraints, and SLAs in the product specification. Domain Integrity includes security and data ownership boundaries.

Examples: Telecom packet ordering, HealthTech patient access, FinTech concurrent checkout, IoT offline recovery, Automotive control timing, and Aerospace safety margins. Examples do not make those domains applicable. Produce a Domain Compliance & Regulatory Traceability Matrix only for actual obligations; tests alone never establish compliance.

## Architecture and reliability

- **Contract integrity**: Design by Contract may use preconditions (`requires`), postconditions (`ensures`), and state invariants (`invariant`), or existing types, schemas, validation, and tests. Do not introduce a formal framework without need.
- **Scalability and algorithmic complexity**: Check actual input sizes, payload bounds, bounded memory, batching, and throughput. Measure performance claims.
- **Concurrency and race safety**: Check ownership, cancellation, deadlocks, lock ordering, idempotency, retries, and atomicity. When relevant, test race conditions in inventory and preventing double-spend; distributed lock leases and idempotency tokens require expiry/replay tests.
- **Robustness and failure isolation**: Bound blast radius; exercise backpressure, circuit breakers, Graceful Degradation, partial failures, rollback, and restart recovery.
- **Adverse conditions**: Select BVA extrema (`min`, `min+1`, `max-1`, `max`, overflow, null, empty, malformed) and Equivalence Partitioning for meaningful boundaries. Use Fault Injection or domain chaos injection for relevant network partition simulation, malformed protocol frame injection, clock jitter, or dependency errors. Bound execution and isolate effects.

## Principal Coding Engineer review

Review changed behavior and relevant context. Record concrete triggers, impact, and evidence; unfamiliar patterns and removed lines alone do not prove a defect.

| Dimension | Evidence |
| --- | --- |
| Boundary & Null/Nil Safety | Off-by-one, String/index bounds, empty collections, missing fields, and external-input validation. |
| Deterministic Error Handling | No swallowed errors; propagation, actionable redacted diagnostics, bounded retries, and recovery. |
| Resource & Memory Safety | Deterministic cleanup, zero resource leaks in tested paths, bounded buffer allocations, tracked subprocesses, timeout and reap. |
| Concurrency, Subprocess & Race Safety | Ownership, atomic updates, cancellation, interleavings, and partial failure. |
| Security, Injection & Path Traversal | Parameter boundaries, symlink/root containment, permissions, and secret protection. |
| Algorithmic Efficiency & Bounded Complexity | Input-dependent time/memory; benchmark claims against relevant workloads. |
| Code Formatting & Cleanliness | Project formatter/linter policy, cohesive helpers, clean blanks, and scoped changes. |
| UI/UX & AI Workflow Fidelity | Applicable interface states, accessibility, uncertainty, cancellation, and recovery. |
| Anti-Hardcoding & Dynamic Test Assertions | Dynamically computed corpus expectations and deliberate fixed boundary fixtures. |
| Domain Integrity & User Alignment | Actual protocol rules, data boundaries, user scope, and compatibility. |
| Review evidence and false positives | Correct diff/base, callers, reproduction, and baseline failures versus regressions. |
| Separation of Concerns | Existing layer boundaries, API compatibility, and references to removed symbols. |
| Contract enforcement | Preconditions/postconditions and invariants at actual trust boundaries. |
| Compiler, lint and assertion quality | Configured checks, non-vacuous assertions, targeted mutation evidence, and unavailable-tool reporting. |

Normalize only case-insensitive identifiers, such as DNS hostnames; preserve case-sensitive payloads such as DNS TXT data. Mask secrets. Use established authentication libraries and constant-time comparison where needed; avoid invented hash work and blanket early-return bans.

## Team Persona & UI/UX Guidelines

Load only for an affected interface. UX/UI Designer, Frontend/Mobile Architect, and AI-Augmented Workflow Engineer consider:

- **Aesthetics, Usability and Consistency**: Existing theme, color palette, typography hierarchy, spacing rules, interaction states, and design system. Avoid arbitrary rounded corners, shadows, or frameworks to satisfy checklists.
- **Frontend architecture**: Separate pure presentation from business logic and state management where supported; custom hooks are a React option, not a universal requirement. Preserve tech stack and responsive/mobile behavior.
- **Accessibility**: Verify semantic structure, keyboard/focus behavior, contrast, labels, and touch targets against specified WCAG/platform standards. A 44px target is a contextual reference, not universal compliance.
- **AI interactions**: Streaming latency, cancellation, optimistic UI rollback, skeleton/fallback states, offline recovery, and human validation checkpoints when present.
- **Domain ergonomics**: High-density financial data tables, telemetry gauges, or clinical patient cards only for the corresponding product.

## Safety-critical profile

Apply 1E-Class Security Standards only when required. Establish deterministic execution time enforcement, bounded buffer allocations, resource lifetimes, payload bounds, safe failure states, and the target allocation policy. MC/DC and traceability need measured artifacts and qualified scope; simulated roles and ordinary tests do not provide certification.

## Developer setup and runbook

For changed setup/operations, document prerequisites, supported versions, configuration and secrets, commands, expected outputs, cleanup, troubleshooting, and rollback. Verify examples in a disposable environment. Credential rotation, irreversible operations, and external publication require actual user authorization.
