# 1E-Class Security Standards

Mandatory security and quality standards universally required for all generated code.

## 1. Code Quality & Implementation Standards
- **Deterministic Execution**: Deterministic execution time. Avoid unbounded loops, recursion without strict depth limits, and non-deterministic algorithms.
- **Memory Management**: NO dynamic memory allocation post-initialization. Static allocation prevents leaks and fragmentation.
- **Formal Verification**: Code MUST support formal verification; avoid untraceable state machines.
- **Defensive Programming**: Validate inputs against boundary conditions. Graceful degradation and safe-state fallbacks for all error paths.
- **Resource Lifecycle Determinism**: All system resources, handles, sockets, buffers, and child processes MUST have bounded lifetimes and deterministic deallocation guarantees. Never allow uncollected handles or unbounded resource growth.

## 2. Testing & Validation Standards
- **MC/DC Coverage**: Tests MUST achieve 100% Modified Condition/Decision Coverage (MC/DC) for safety-critical logic.
- **Boundary & Equivalence**: Rigorous Boundary Value Analysis (BVA) and Equivalence Partitioning on all inputs and states.
- **Fault Injection & Negative Paths**: Comprehensive fault injection and negative path testing ensuring safe failure under adverse conditions.
- **Traceability**: Documented traceability from requirements through design, implementation, and test cases.

## Negative Constraints (Must NOT)
- [X] **Do not use non-deterministic algorithms**: All code execution paths and time must be deterministic.
- [X] **Do not perform unbounded dynamic memory allocation**: Post-initialization memory allocation must be strictly bounded.
- [X] **Do not allow unbounded recursion or infinite loops**: Strict depth limits and timeout barriers are mandatory.
- [X] **Do not leave unverified failure states**: All error conditions must have explicit safe fallbacks.
- [X] **Do not leak system resources**: All handles, sockets, and subprocesses must be strictly deallocated.
