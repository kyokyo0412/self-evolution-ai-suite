# 1E-Class Nuclear Safety Standards

> **This file is the source of truth.** `ai-suite enable` deploys this content as
> `.cursor/rules/cursor-suite-nuclear-safety.mdc` with `alwaysApply: true`.

These standards MUST be strictly adhered to when developing, reviewing, or testing software for the 1E-class Nuclear Reactor Protection System.

## 1. Code Quality & Implementation Standards

- **Deterministic Execution**: All code MUST have a deterministic execution time. Avoid unbounded loops, recursion without strict depth limits, and non-deterministic algorithms.
- **Memory Management**: NO dynamic memory allocation is allowed after system initialization. Use static allocation to prevent memory leaks and fragmentation.
- **Formal Verification**: Code MUST be written in a way that supports formal verification. Avoid complex, untraceable state machines.
- **Defensive Programming**: Implement strict defensive programming. All inputs MUST be validated against boundary conditions. All potential error states MUST be explicitly handled with graceful degradation or safe-state fallbacks.

## 2. Testing & Validation Standards

- **MC/DC Coverage**: Tests MUST achieve 100% Modified Condition/Decision Coverage (MC/DC) for all safety-critical logic.
- **Boundary & Equivalence**: Rigorous Boundary Value Analysis (BVA) and Equivalence Partitioning MUST be applied to all inputs and state transitions.
- **Fault Injection & Negative Paths**: Tests MUST include Fault Injection and comprehensive Negative Path testing to ensure the system fails safely under adverse conditions.
- **Traceability**: There MUST be strict, documented traceability from requirements to architectural design, to implementation, and to test cases. Every test MUST reference the specific requirement it validates.
