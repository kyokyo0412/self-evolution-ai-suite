---
name: loop-work
description: "Use when the user asks to loop or iterate a task multiple times using a specific skill (e.g., 'loop 10 times to use tdd-team skill to do...'). This skill orchestrates an iterative execution process with a 'never give up' spirit, strictly executing all N requested iterations without premature early exit, aligning each iteration to the overarching goal of task X, reassessing current state and customizing a new plan on each iteration, applying a progressive multi-dimension hardening framework, logging structured state (goal, what, why, how, special notes) into .loop_state.md, and delivering a verified high-quality achievement of the goal."
disabled-environments:
  - cloud
triggers:
  - loop-work
---

# Loop-Work Skill -- Iterative Agentic Execution

Use this skill when the user requests to run a task for multiple iterations using a specific skill (e.g., `tdd-team`). This skill transforms the agent into an iterative orchestrator that embodies a **never-give-up spirit**.

## Core Directives

1. **Parse the Request:** Identify the number of iterations (`N`), the target skill to use (e.g., `tdd-team`), and the core task prompt (Task X).
2. **Goal of Task X is the Goal of Each Iteration (Do Not Split Goal):** The overarching goal of task X MUST explicitly serve as the goal of each iteration. Every single iteration MUST attempt to achieve the FULL original goal. You MUST NOT split the original goal into sub-tasks across iterations. Every iteration anchors on the complete goal of task X without goal drift, scope dilution, or sub-goal substitution.
3. **Execute All N Iterations (Strict Mandatory Iteration Count, No Premature Early Exit):** Execute the iterative workflow for all $N$ requested iterations. You are STRICTLY FORBIDDEN from triggering an early exit based on premature convergence or 100% defect-free assumptions when $i < N$. The iteration count $N$ is a strict, mandatory requirement for cumulative progressive hardening, boundary fuzzing, race safety, mutation testing, and deep verification.
4. **Iterative State Reassessment & Custom Planning:** Each iteration requires reassessing the current state and the goal, formulating a customized new plan tailored to address identified gaps and opportunities for hardening, and running task X again. After the iteration is completed, the result should better achieve the goal through progressive refinement.
5. **Identical Task Target Invariant:** You MUST repeat the same task for all $N$ iterations. Each iteration MUST have the EXACT SAME, COMPLETE task target. You are STRICTLY FORBIDDEN from splitting the task target into parts, chunks, or slices across iterations.
6. **Full Review & Full Execution Every Iteration:** Every single iteration MUST execute the target skill across all aspects, dimensions, and categories on the ENTIRE target artifact. If bugs or defects are found in an iteration, fix them within that iteration. Subsequent iterations re-review and re-verify the full target artifact from beginning to end for cumulative hardening and regression prevention.
7. **Structured State Logging (.loop_state.md):** Log each iteration into `.loop_state.md` with explicit structured fields: `Goal`, `Current State Assessment`, `Customized Plan`, `What`, `Why`, `How`, `Special Notes`, and `Status & Quality Assessment`.
8. **High-Quality Goal Achievement:** After all $N$ iterations are completed, the final deliverable must represent a verified high-quality achievement of the goal.
9. **Never-Give-Up Spirit:** You must persist through all $N$ iterations. If an iteration encounters obstacles or produces suboptimal results, you must not stop. Instead, analyze the failure, design an improvement, and immediately proceed to the next iteration.
10. **Strict Isolation:** Do not break the isolation principle of the AI suite. Each iteration must cleanly execute the target skill without corrupting global state or polluting external environments.
11. **Preserve Self-Evolution:** Do not break the self-evolution mechanisms of the AI suite. Ensure that any learnings, patterns, or improvements are properly logged and integrated according to standard Layer 4 evolutionary protocols.
12. **LLM Reasoning & Cognitive Validation:** After each iteration, use your own AI agent LLM thinking and reasoning capabilities to rigorously validate the result against the original task goal using structured cognitive self-evaluation.
13. **Strict Rule Adherence:** You MUST strictly follow all rules and guidelines, especially `interactive-workflow`, `step-action-visibility`, and `cursor-suite-production-safety`.

## Identical Full Task Iteration Invariant

When executing a loop-work request (e.g., `use loop-work skill to loop 100 times to use tdd-team skill to review file A and fix bugs`), the execution MUST strictly adhere to the following invariant rules:

### 1. Concrete Exemplar & Expected Behavior
- **Prompt:** `use loop-work skill to loop 100 times to use tdd-team skill to review file A and fix bugs`
- **Total Iterations:** 100 times.
- **Per-Iteration Execution:** For EVERY iteration $i \in [1, 100]$, the goal of task X remains the overarching goal of each iteration. Execute the `tdd-team` skill to review the ENTIRE File A across all aspects and dimensions (e.g., pointer safety, bounds checking, error handling, memory safety, concurrency, performance). If any bugs or flaws are found during that iteration, fix them completely within that iteration.
- **Cumulative Outcome:** File A is reviewed 100 times in its entirety, with bug fixes applied on each review. Iteration $i+1$ operates on the updated File A to find second-order bugs, eliminate regressions, and achieve higher-order hardening across all 100 iterations.
- **What loop-work is NOT:**
  - It is **NOT** splitting File A into 100 parts or chunks, reviewing one part per iteration (**Spatial Partitioning / Target Chunking**).
  - It is **NOT** splitting the review into 100 aspects or dimensions (e.g., pointer error in iteration 1, boundary error in iteration 2, memory safety in iteration 3), where each iteration reviews only one aspect (**Dimensional Partitioning / Aspect Splitting**).
  - It is **NOT** spreading workflow phases across iterations (e.g., reading in iteration 1, writing tests in iteration 2, fixing in iteration 3) (**Phasing / Workflow Partitioning**).
  - It is **NOT** dividing hardening dimensions across iterations (e.g., checking only basic syntax in iteration 1 and postponing concurrency, chaos, or memory safety to later iterations) (**Hardening Phase Partitioning**).
  - It is **NOT** replacing the original goal of task X with fragmented or narrower sub-goals across loops (**Goal Drift / Sub-Goal Substitution**).
  - It is **NOT** terminating after 1 or 2 iterations because tests passed or linters are clean (**Premature Convergence / Early Exit**).

### 2. Negative Constraints Against Partitioning & Early Exit (Strictly Enforced)
- **NO Early Exit or Premature Convergence:** You are strictly forbidden from exiting the loop early before reaching iteration $N$. The loop count $N$ is a mandatory execution directive.
- **NO Spatial Partitioning (Target Chunking):** You MUST NOT split a file, codebase, module, or document into sub-sections across iterations.
- **NO Dimensional Partitioning (Aspect Splitting):** You MUST NOT split review dimensions, verification categories, or analysis criteria across iterations. Every iteration must check ALL aspects (e.g., pointer safety, memory safety, bounds checking, concurrency, error handling, performance).
- **NO Hardening Phase Partitioning:** You MUST NOT defer or slice hardening dimensions across iterations (e.g., deferring race conditions, chaos fuzzing, or memory leak audits to later iterations). Every single iteration must evaluate the complete multi-dimensional hardening envelope simultaneously.
- **NO Phasing / Workflow Partitioning:** You MUST NOT split phases of the target skill across loops. Each loop iteration must execute the target skill's complete end-to-end lifecycle.
- **NO Goal Drift or Task Dilution:** The goal of task X must remain the active goal of every iteration. The task target in iteration $N$ must remain identical to iteration 1. Each iteration operates on the latest state of the complete artifact to achieve progressive hardening and zero-defect convergence.

## Integration with Interactive Workflow & Step Action Visibility

When `interactive-workflow` is enabled or active, you MUST handle it carefully to avoid breaking the loop:
- **The "Main Task" is the ENTIRE loop:** The full `N` iterations constitute the "Main Task" in State 1 of the `interactive-workflow`.
- **Do NOT trigger State 2 or State 3 prematurely:** You MUST NOT output the final task summary, call `echo 'Interactive workflow summary rendered'`, or call the `AskQuestion` tool until ALL $N$ iterations are completely finished.
- **Step Action Visibility per Iteration:** For EACH iteration, you MUST output the detailed step actions (Architectural Analysis, Step-by-Step Execution Plan, and Implementation) to the chat window, ensuring full visibility of what is happening inside the loop.
- **Final Summary:** Once all $N$ iterations are complete, you MUST output a comprehensive final task summary BEFORE moving to State 2 and State 3 (the final `AskQuestion` tool box).

## State Tracking & Structured Logging (.loop_state.md)

When looping multiple times (e.g., up to 100 times), the context window may drop early iterations. You MUST maintain external state:
- Create or append to a `.loop_state.md` file in the workspace to log progress. You MUST append to this file so that all iterations are logged instead of only the last one.
- Read this file at the start of any new iteration if you need to recover context.

### Required Entry Schema for .loop_state.md
For each iteration $i$, append a block with the following mandatory format:

```markdown
### Iteration i / N
- **Goal**: [The overarching goal of task X]
- **Current State Assessment**: [Reassessment of current artifact state and gaps identified prior to this iteration]
- **Customized Plan**: [Specific, tailored plan formulated for this iteration to address gaps]
- **What**: [Summary of actions taken, fixes applied, tests written, or modules refined in this iteration]
- **Why**: [Technical reasoning, root cause analysis, and architectural rationale for the changes]
- **How**: [Specific tools, test commands, code patterns, and implementation techniques used]
- **Special Notes**: [Edge cases discovered, safety caveats, operational constraints, lessons learned, or follow-up notes]
- **Status & Quality Assessment**: [Success / Partial Success / Failure; assessment of how this iteration better achieves the goal]
```

## Continuation Protocol (CRITICAL)

Because of the nature of LLM agent execution, your turn will naturally stop and wait for user input if you only output text. **To achieve true autonomous looping across all $N$ iterations, you MUST NOT stop.**
- At the end of every iteration where $i < N$, you MUST chain into the next iteration by explicitly calling a tool before ending the turn.
- To prevent stopping and reliably trigger the next iteration, you MUST use the `Shell` tool with the `notify_on_output` feature.
- Execute a background sleep command that echoes a JSON payload with the `AGENT_LOOP_WAKE_loop_work` sentinel.
- Configure the `Shell` tool with `block_until_ms: 0` and `notify_on_output` matching `^AGENT_LOOP_WAKE_loop_work`.

**Example Continuation Command:**
```bash
sleep 5
echo 'AGENT_LOOP_WAKE_loop_work {"iteration": <next_iteration_number>, "prompt": "<original_prompt>"}'
```
- When you execute this `Shell` tool call, set `block_until_ms: 0` to background it, and configure `notify_on_output` with `pattern: "^AGENT_LOOP_WAKE_loop_work"` and `reason: "loop-work iteration"`.
- This will background the sleeper immediately and wake you up after 5 seconds to perform the next iteration. On wake, read the payload from `.loop_state.md` and continue execution immediately.

## Progressive Hardening Framework

When executing an extended loop across $N$ iterations (e.g., $N=10, 50, 100$) or even a single iteration ($N=1$), the agent must systematically ensure the highest quality, resilience, and verification rigor. 

**CRITICAL INVARIANT -- No Phase-Divided Iterations:** You MUST NOT divide hardening dimensions into sequential phases across iterations (e.g., checking only correctness in iteration 1, only concurrency in iteration 2, etc.). Slicing dimensions into phases across iterations is a prohibited form of *Dimensional & Phasing Partitioning*. Instead, **EVERY iteration evaluates the FULL multi-dimensional hardening envelope simultaneously**, and multiple iterations provide **cumulative iterative depth across orders of emergence**.

### 1. The Continuous Multi-Dimensional Hardening Envelope (Evaluated EVERY Iteration)
Every single iteration $i \in [1, N]$ MUST evaluate and apply all 5 hardening dimensions simultaneously across the entire target artifact:

1. **Dimension 1: Baseline Correctness, Schema Compliance & Static Quality**
   - Core functional requirements, interface schema compliance, and contract fulfillment.
   - Comprehensive nil/null safety, pointer validation, boundary checks, array/slice bounds protection.
   - Deterministic error handling (no swallowed errors, proper error wrapping and bubbling).
   - Static analysis clean-up: resolve all compiler diagnostics, linter warnings, and formatting issues.
   - Baseline unit and integration tests covering standard happy and error paths.

2. **Dimension 2: Concurrency, Synchronization & Race Safety**
   - Multi-goroutine / multi-thread contention testing and thread safety validation.
   - Shared mutable state protection (mutex locking protocols, atomic operations, channel synchronization).
   - Deadlock prevention and strict lock ordering audits.
   - High-concurrency race condition testing using race detectors (e.g., `go test -race`).

3. **Dimension 3: Chaos, Adversarial Fuzzing & Fault Injection**
   - Protocol-level fuzzing, malformed packet injection, unexpected data payload structures.
   - Stream/buffer truncation, partial read handling, connection drops, network partitioning simulation.
   - RPC timeout recovery, backoff retry logic, database/cache reconnect loops under heavy load.
   - Extreme boundary values, numeric overflow/underflow, zero-byte allocations.

4. **Dimension 4: Resource Lifecycles & 1E-Class Safety Standards**
   - Memory leak audits, object pool recycling (`sync.Pool`), zero dynamic allocations in critical hot paths.
   - File descriptor and socket closure guarantees (deterministic `defer` / cleanup lifecycles).
   - Deterministic execution time enforcement, bounded recursion depth, unbounded loop elimination.
   - Full 1E-class Nuclear Safety compliance and defensive fail-safe fallbacks.

5. **Dimension 5: Mutation Analysis, Coverage Maximization & Regression Proof**
   - Mutation testing: validating that test suites fail when conditional branches or operators are inverted.
   - Maximum line, branch, and MC/DC code coverage targeting $>98\%$.
   - Formal schema contract verification against protobuf/API definitions.
   - End-to-end regression validation across all modules and invariants.

### 2. Cumulative Multi-Iteration Depth vs. Single Iteration Scope

- **Can Progressive Hardening be done in 1 iteration ($N=1$)?**
  **YES.** If $N=1$, the agent executes the complete multi-dimensional hardening envelope across all 5 dimensions holistically. No dimension is deferred, skipped, or compromised.
- **Why do multiple iterations ($N>1$) achieve deeper quality than dividing phases?**
  Multiple iterations do NOT divide or distribute the work; instead, they provide **cumulative iterative depth** across progressive orders of emergence:
  - **Order-1 Emergence (Single-Iteration Scope):** Primary defect detection, immediate contract fulfillment, and static safety across all 5 dimensions.
  - **Order-2 Emergence (Multi-Iteration Interaction Depth):** Detecting secondary bugs, subtle race windows, interface incompatibilities, or performance regressions unmasked or introduced by code modifications made in earlier iterations.
  - **Order-3 Emergence (High-Entropy Chaos & Mutation Resistance):** Exploring combinatorial edge-case spaces, non-deterministic timing variations, and validating test suite survival against complex code mutations.
  - **Order-N Emergence (Formal Invariance & Zero-Defect Convergence):** Mathematical invariance proofs, absolute resource leak verification, deterministic runtime guarantees, and complete regression closure.

## Execution Protocol

For `i = 1` to `N`:

### Step 1: Reassess State & Customize Plan (with Goal Alignment & Multi-Dimensional Envelope)
- Reassess the current state of the artifact, past iteration entries in `.loop_state.md`, and the original goal of task X.
- Apply the **Continuous Multi-Dimensional Hardening Envelope** (all 5 dimensions simultaneously) and calibrate the order of emergent depth (Order-1 primary fixes, Order-2 interaction defects, Order-3 chaos/mutation resistance, Order-N formal invariance) targeted for iteration $i$.
- Formulate a customized new plan tailored to address discovered gaps, deepen concurrency/chaos/resource/mutation coverage, or optimize code quality without partitioning dimensions.
- Confirm that the goal of this iteration is strictly aligned with the full goal of task X.

### Step 2: Run Task X Again (with Step Action Visibility)
- Invoke the user-specified skill (e.g., `tdd-team`) on the **full, complete, unpartitioned task target** executing the customized plan.
- Follow all instructions and constraints of that target skill strictly for this iteration across all analysis aspects.
- If defects/bugs are found during this iteration, resolve them completely within this iteration.
- **CRITICAL:** Output the `step-action-visibility` details (VLLM Reasoning, Execution Plan, Implementation) for this specific iteration.
- **CRITICAL:** The output of the target skill (e.g., `tdd-team`) MUST be correct and fully outputted to the chat window. Do not suppress, summarize, or skip the target skill's required outputs.
- **CRITICAL:** After the target skill completes its execution (e.g., finishes its final phase), you MUST explicitly return to the loop-work Execution Protocol (Step 3) to validate and continue.

### Step 3: Validate Result & Goal Improvement (LLM Reasoning & Cognitive Self-Evaluation)
- Use your AI agent LLM thinking and reasoning capabilities to rigorously evaluate whether the completed iteration result better achieves the goal compared to previous iterations.
- Evaluate the result directly against the ORIGINAL input task goal. Do not evaluate against a sub-task or partial goal.
- **Cognitive Self-Evaluation Checklist:**
  1. *Goal Alignment Audit:* Is the overarching goal of task X maintained as the goal of each iteration?
  2. *Progressive Improvement Audit:* Did this iteration result better achieve the goal than the previous iteration?
  3. *Complete Scope Audit:* Did this iteration analyze and verify the ENTIRE target artifact from start to finish?
  4. *All-Aspect Audit:* Were all review dimensions, categories, and safety aspects checked simultaneously, rather than partitioned?
  5. *In-Iteration Resolution:* Were all defects discovered during this iteration fixed within this iteration?
  6. *Target Invariance Check:* Does the next iteration target remain the exact complete original artifact?
  7. *Multi-Dimensional & Emergent Depth Check:* Did this iteration evaluate all 5 hardening dimensions simultaneously and deepen cumulative verification rigor (Order-1 through Order-N)?

### Step 4: Output Iteration Report & Update State File (.loop_state.md)
- Provide a detailed output for the current iteration in the chat message. Each iteration step/action and result MUST be outputted to the chat window.
- Append the structured entry (including Goal, Current State Assessment, Customized Plan, What, Why, How, Special Notes, and Status & Quality Assessment) to `.loop_state.md` via the `Write` tool or file operations.

### Step 5: Design Improvements
- If $i < N$:
  - Identify remaining hardening gaps, edge cases, mutation vulnerabilities, or stress areas across all 5 dimensions.
  - Formulate a concrete strategy and updated prompt/approach for iteration $i+1$ on the full target applying the continuous multi-dimensional hardening envelope and targeting higher-order emergent depth.
  - Clearly state the planned improvements in the chat message and the state file.

### Step 6: Loop Continuation (Strict Full-Iteration Invariant)
- **Mandatory Iteration Count:** You are STRICTLY FORBIDDEN from exiting the loop early before reaching iteration $N$. Even if tests pass and linters are clean, you MUST continue to iteration $i+1$ to execute deeper progressive hardening.
- **When $i < N$:** You MUST immediately execute the **Continuation Protocol** using the background sleep notification command (`Shell` with `block_until_ms: 0` and `notify_on_output` matching `^AGENT_LOOP_WAKE_loop_work`). You MUST NOT end your turn without issuing this tool call.
- **When $i == N$:** All $N$ iterations are 100% complete. Proceed to Step 7.

### Step 7: Final Summary & Interactive Workflow Wrap-up
- **High-Quality Achievement Verification:** Verify that the final deliverable represents a high-quality achievement of the goal across all $N$ completed iterations.
- **ONLY AFTER ALL $N$ ITERATIONS ARE DONE:** Output the final task summary detailing What, Why, How, Key Points, and Special Notes.
- **Cleanup:** Actively identify and remove any unused files, temporary files, or leftover artifacts created during the iterations.
- Proceed to State 2 and State 3 of the `interactive-workflow` (output execution summary, execute `echo 'Interactive workflow summary rendered'`, and call the `AskQuestion` tool).

## Negative Constraints (Must NOT)
- [X] Do NOT trigger an early exit before completing all $N$ requested iterations. You MUST NOT assume premature convergence or exit early on 100% defect-free claims. All $N$ iterations are mandatory.
- [X] Do NOT end a turn or wait for user input when $i < N$. You MUST explicitly chain tool calls using the background continuation sleeper command.
- [X] Do NOT alter or substitute the goal of task X across iterations (No Goal Drift or Sub-Goal Substitution).
- [X] Do NOT run an iteration without first reassessing the current state and customizing a new plan.
- [X] Do NOT fail to log each iteration into `.loop_state.md` with goal, what, why, how, and special notes.
- [X] Do NOT deliver a final result that fails to achieve a high-quality achievement of the goal.
- [X] Do NOT split the target file, codebase, or document into sub-parts or chunks across iterations (Spatial Partitioning).
- [X] Do NOT split the review or analysis into separate aspects or categories across iterations (Dimensional Partitioning).
- [X] Do NOT defer or divide hardening dimensions into sequential phases across iterations (Hardening Phase Partitioning). Every iteration must evaluate all 5 hardening dimensions simultaneously.
- [X] Do NOT spread workflow phases of the target skill across iterations (Phasing Partitioning).
- [X] Do NOT break the isolation principle of the AI suite.
- [X] Do NOT break or bypass the self-evolution mechanisms.
- [X] Do NOT run the next iteration without explicitly validating the previous one, designing improvements, and logging to State Tracking.
- [X] Do NOT call `AskQuestion` or trigger `interactive-workflow` State 2/3 until the entire loop of all $N$ iterations is complete.
