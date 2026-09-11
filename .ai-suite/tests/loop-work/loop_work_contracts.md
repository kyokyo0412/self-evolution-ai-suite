# Loop-Work Interface & Architectural Contracts

## 1. Skill Metadata & Frontmatter Contract
The `loop-work.md` skill definition MUST reside at `.ai-suite/layer3-registry/core/loop-work.md` with:
- `name: loop-work`
- `triggers:` containing `loop-work`
- `description:` detailing iterative execution with never-give-up spirit, mandatory execution of all requested iterations without premature early exit, goal alignment across iterations, state reassessment, custom planning, structured state logging, progressive multi-dimension hardening, and convergence to a high-quality goal achievement.

## 2. Goal Alignment & Identical Full Task Target Contract
The orchestrator MUST enforce the following invariant equations:
$$\forall i \in [1, N], \quad \text{IterationGoal}(i) \equiv \text{Goal}_{\text{Task X}}$$
$$\forall i \in [1, N], \quad \text{TaskTarget}(i) \equiv \text{TaskTarget}_{\text{original}}$$
$$\forall i \in [1, N], \quad \text{ReviewAspects}(i) \equiv \text{ReviewAspects}_{\text{full}}$$

### Negative Anti-Patterns (Strictly Prohibited):
- **Premature Early Exit**: Aborting the loop before reaching iteration $N$ based on assumptions of 100% quality, zero compiler errors, or clean linters.
- **Chunking / Spatial Partitioning**: Splitting a target file, codebase, or document into $N$ parts to process one part per iteration.
- **Slicing / Dimensional Partitioning**: Splitting review checks (e.g., pointer safety in iteration 1, boundary conditions in iteration 2) across iterations.
- **Staging / Phasing Partitioning**: Splitting phases of the target skill across iterations instead of running the full lifecycle per iteration.
- **Goal Drift / Sub-Goal Substitution**: Replacing the overarching goal of Task X with narrower, fragmented sub-goals in subsequent iterations.

### Positive Operational Guarantees:
- **Mandatory Full Iteration Count ($N$)**: The orchestrator MUST execute all $N$ requested iterations.
- **Goal Continuity**: The overarching goal of Task X is the explicit goal of every iteration $i \in [1, N]$.
- **Iterative State Reassessment & Custom Planning**:
  $$\text{State}(i) = \text{Reassess}(\text{Artifact}_{i-1}, \text{Goal}_{\text{Task X}})$$
  $$\text{Plan}(i) = \text{CustomizePlan}(\text{State}(i), \text{Goal}_{\text{Task X}})$$
  $$\text{Artifact}_i = \text{Execute}(\text{Task X}, \text{Plan}(i))$$
- **Progressive Multi-Dimensional Hardening & Emergent Depth**:
  1. **Continuous Multi-Dimensional Envelope (Evaluated EVERY Iteration)**:
     Every single iteration $i \in [1, N]$ simultaneously applies all 5 hardening dimensions:
     - *Dimension 1 (Baseline & Static Correctness)*: Core functional requirements, nil/null safety, pointer validation, defensive bounds, compiler diagnostics, linter cleanliness.
     - *Dimension 2 (Concurrency & Race Safety)*: Thread safety, multi-goroutine contention, mutex locking order, atomic synchronization, race detector cleanliness.
     - *Dimension 3 (Chaos, Boundary Fuzzing & Fault Injection)*: Extreme edge cases, malformed payloads, truncated streams, connection drops, timeout recovery, backoff loops.
     - *Dimension 4 (Resource & 1E-Class Safety)*: Memory leak audits, object pool recycling, deterministic execution time, bounded recursion, fail-safe fallbacks.
     - *Dimension 5 (Mutation Analysis & Invariant Verification)*: Mutation testing, contract schema validation, coverage maximization (>98%), end-to-end regression testing.
  2. **Cumulative Multi-Iteration Emergent Depth (Deepened Across Cycles)**:
     Multiple iterations provide non-linear quality improvements through cumulative orders of emergence:
     - *Order-1 (Single-Iteration Scope)*: Primary defect detection and holistic remediation across all 5 dimensions.
     - *Order-2 (Multi-Iteration Scope)*: Discovery of emergent cross-module defects, secondary race hazards, and regression risks unmasked by earlier code modifications.
     - *Order-3 (Deep Hardening Scope)*: High-entropy combinatorial chaos, adversarial state fuzzing, and mutation survival analysis.
     - *Order-N (Convergence Scope)*: Mathematical invariance, formal zero-defect proof, and complete regression closure.
  3. **Single vs Multi-Iteration Resolution**:
     - *Can it be done in 1 iteration?* YES. If $N=1$, the agent executes the complete multi-dimensional hardening envelope across all 5 dimensions. No dimension is deferred or skipped.
     - *Why multiple iterations?* Multiple iterations do NOT divide work; they explore dynamic state-space trajectories, surface hidden second-order bugs created by prior fixes, and stress-test the system against mutations until zero-defect convergence is achieved.
- **In-Iteration Bug Fixing**: If bugs or issues are found in iteration $i$, they are fixed within iteration $i$.
- **Cumulative Hardening**: Iteration $i+1$ re-analyzes and re-verifies the entire updated artifact from scratch to discover deeper second-order issues and ensure zero regressions.
- **Final High-Quality Convergence**: After all $N$ iterations complete, the final deliverable represents a verified high-quality achievement of the goal.

## 3. Structured State Logging & Continuation Contract
- **State File**: `.loop_state.md` must be maintained across all iterations with appended progress logs.
- **Mandatory Log Schema**: Every iteration entry in `.loop_state.md` MUST contain:
  1. `### Iteration i / N` (Header with iteration index and total)
  2. `**Goal**:` (The overarching goal of task X)
  3. `**Current State Assessment**:` (Reassessment of artifact state & gaps before this iteration)
  4. `**Customized Plan**:` (Custom plan tailored for this iteration)
  5. `**What**:` (What was accomplished, modified, or verified in this iteration)
  6. `**Why**:` (Technical reasoning, rationale, and root cause addressed)
  7. `**How**:` (Specific implementation steps, tools used, methods applied)
  8. `**Special Notes**:` (Edge cases, observations, caveats, constraints, lessons learned)
  9. `**Status & Quality Assessment**:` (Success / Partial Success / Failure, measured progress toward goal)
- **Continuation Protocol**: For all $i < N$, the agent MUST chain into the next iteration by backgrounding a sleep command with `block_until_ms: 0` and `notify_on_output` matching `^AGENT_LOOP_WAKE_loop_work`.
- **Closure Criteria**: Terminates strictly when all $N$ iterations have completed.
- **Interactive Workflow Integration**: Strict isolation of State 1 (Daemon Mode) until all $N$ iterations are finished before triggering State 2 (Summary) and State 3 (`AskQuestion`).

## 4. Security & Isolation Contract (1E-Class Standards)
- **Isolation Principle**: No leaking of temporary variables or pollution of external workspace environments.
- **Self-Evolution Preservation**: Learnings and improvements follow Layer 4 evolutionary protocols.
- **Deterministic Execution**: Bounded loop count $N \le 100$, deterministic error handling, and zero swallowed failures.
- **Cognitive Verification**: Results validated through AI agent LLM thinking and structured cognitive self-evaluation.
