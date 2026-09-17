# 1E-Class Security Standards

> **This file is the source of truth.** `ai-suite enable` deploys this content as
> `.cursor/rules/cursor-suite-nuclear-safety.mdc` with `alwaysApply: true`.

These standards MUST be strictly adhered to when developing, reviewing, or testing ALL software produced by the AI suite. While originating from the 1E-class Nuclear Reactor Protection System, these absolute security and quality measures are mandated universally for all generated code.

## 1. Code Quality & Implementation Standards

- **Deterministic Execution**: All code MUST have a deterministic execution time. Avoid unbounded loops, recursion without strict depth limits, and non-deterministic algorithms.
- **Memory Management**: NO dynamic memory allocation is allowed after system initialization. Use static allocation to prevent memory leaks and fragmentation.
- **Formal Verification**: Code MUST be written in a way that supports formal verification. Avoid complex, untraceable state machines.
- **Defensive Programming**: Implement strict defensive programming. All inputs MUST be validated against boundary conditions. All potential error states MUST be explicitly handled with graceful degradation or safe-state fallbacks.
- **Resource Lifecycle Determinism**: All system resources, file descriptors, network connections, child processes, and allocated buffers MUST have strictly bounded lifetimes and deterministic deallocation guarantees. Never allow uncollected handles, orphaned processes, or unbounded resource growth.

## 2. Testing & Validation Standards

- **MC/DC Coverage**: Tests MUST achieve 100% Modified Condition/Decision Coverage (MC/DC) for all safety-critical logic.
- **Boundary & Equivalence**: Rigorous Boundary Value Analysis (BVA) and Equivalence Partitioning MUST be applied to all inputs and state transitions.
- **Fault Injection & Negative Paths**: Tests MUST include Fault Injection and comprehensive Negative Path testing to ensure the system fails safely under adverse conditions.
- **Traceability**: There MUST be strict, documented traceability from requirements to architectural design, to implementation, and to test cases. Every test MUST reference the specific requirement it validates.

## Negative Constraints (Must NOT)
- [X] **Do not use non-deterministic algorithms**: All code execution time and paths must be deterministic.
- [X] **Do not perform unbounded dynamic memory allocation**: Post-initialization memory allocation must be strictly bounded and pre-sized.
- [X] **Do not allow unbounded recursion or infinite loops**: Strict depth limits and timeout barriers are mandatory.
- [X] **Do not leave unverified failure states**: All error conditions must have explicit safe fallbacks and defensive degradation paths.
- [X] **Do not leak system resources**: All handles, sockets, and subprocesses must be strictly deallocated.
