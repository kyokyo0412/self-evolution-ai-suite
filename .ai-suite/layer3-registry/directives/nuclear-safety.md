# 1E-Class Security Standards

## Applicable Scope

Use this specialist profile only when the user, product requirements, or applicable safety standard establishes a safety-critical or constrained real-time component. General scripts, documentation tools, and agent workflows use proportionate bounds and verification; they do not require certification or allocation-free operation.

## Code Quality and Implementation

- Validate external inputs, state transitions, and explicit resource bounds.
- Give handles, sockets, locks, and subprocesses bounded lifetimes and deterministic cleanup.
- Apply allocation-free post-initialization paths only where the selected safety profile requires them; document the scope and verify the bound.
- Bound recursion, retries, buffers, execution time, and recovery behavior.

## Testing and Validation

- Apply MC/DC coverage only to safety-critical logic where the applicable standard requires it. Record measured coverage, tool limitations, and untested paths.
- Use boundary value analysis, equivalence partitioning, fault injection, and negative-path checks appropriate to the component.
- Trace applicable requirements to design, implementation, and executable checks. Passing tests are evidence, not certification.

## Negative Constraints

- [X] Do not claim compliance, certification, 100% coverage, or absence of defects without evidence and the applicable assessment process.
- [X] Do not impose safety-critical allocation or MC/DC requirements on unrelated scripts or UI work.
- [X] Do not leak resources, allow unbounded recursion or retries, or leave failure states unverified.
