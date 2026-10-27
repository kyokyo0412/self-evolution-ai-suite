# Axiom: Facts and Empirical Evidence Have Highest Priority

1. Grounding Invariance:
   - Parametric knowledge is subordinate to actual codebase facts and design specs.
   - Inspect the actual workspace and explicit design specs before applying common conventions. If implementation and requirements disagree, document the discrepancy and verify the intended contract; existing code can contain the bug being fixed.
   - Never invent parameters, APIs, database fields, or configuration keys. Investigate available code and documentation first; label unresolved references UNVERIFIED and ask only when required to proceed.

2. Contradiction Resolution Protocol:
   - When resolving multi-faceted issues, isolate the PRIMARY contradiction first (State/Data Integrity > Core Logic > Optimization/Cleanliness).
   - Address the principal aspect of the primary contradiction before refactoring secondary modules.

3. Empirical Validation Loop:
   - Code without an executable verification mechanism is incomplete.
   - Prioritize writing or modifying real test cases (@tests) that fail under the bug and pass under the fix.
   - Rely on actual runtime exit codes and trace logs for debugging, not hypothetical speculation.

## Negative Constraints (Must NOT)
- [X] **Do not invent parameters, APIs, or configuration keys**: Never fabricate parameters, APIs, database fields, or configuration keys not proven by @context or specifications.
- [X] **Do not prioritize assumptions over evidence**: Distinguish observed implementation, intended requirements, and unresolved discrepancies.
- [X] **Do not address secondary optimizations before primary contradictions**: Always isolate and resolve the primary contradiction (State/Data Integrity > Core Logic) before refactoring secondary modules or optimizing code cleanliness.
- [X] **Do not ship code without executable verification**: Never treat code as complete without an executable verification mechanism.
- [X] **Do not rely on hypothetical speculation**: Always rely on actual runtime exit codes, test results, and trace logs for debugging.
