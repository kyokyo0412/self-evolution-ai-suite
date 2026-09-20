---
name: loop-work
description: Orchestrate N iterative executions of a skill toward a goal with progressive hardening and state logging. Use when iterating a task multiple times, looping skills (e.g., loop 10 times to use tdd-team), or executing multi-round refinement without early exit.
disabled-environments:
  - cloud
triggers:
  - loop-work
---

# Loop-Work Skill -- Iterative Agentic Execution

Iterative orchestrator embodying a **never-give-up spirit** for executing a task across $N$ iterations using a specified skill (e.g., `tdd-team`).

## Core Directives

1. **Parse Request:** Identify iteration count ($N$), target skill, and core task prompt (Task X).
2. **Overarching Goal Invariance (Do Not Split Goal):** The overarching goal of task X MUST explicitly serve as the goal of each iteration. Every single iteration MUST attempt to achieve the FULL original goal. You MUST NOT split the original goal into sub-tasks across iterations.
3. **Execute All N Iterations (Strict Count, No Early Exit):** Execute all $N$ requested iterations. You are STRICTLY FORBIDDEN from triggering an early exit based on premature convergence or 100% defect-free assumptions when $i < N$. Iteration count $N$ is mandatory for cumulative progressive hardening, boundary fuzzing, race safety, mutation testing, and deep verification.
4. **Iterative State Reassessment & Custom Planning:** Reassess artifact state, identify gaps, formulate a customized plan, and run task X again. Each iteration progressively refines the deliverable toward zero defects.
5. **Identical Task Target Invariant:** Repeat the same task for all $N$ iterations on the EXACT SAME, COMPLETE task target. You are STRICTLY FORBIDDEN from splitting the task target into parts, chunks, or slices across iterations.
6. **Full Review & Execution Every Iteration:** Execute target skill across all dimensions on the ENTIRE artifact. Fix defects within that iteration; subsequent iterations re-verify from start to finish.
7. **Structured State Logging (.loop_state.md):** Append each iteration to `.loop_state.md` using the mandatory schema: `Goal`, `Current State Assessment`, `Customized Plan`, `What`, `Why`, `How`, `Special Notes`, and `Status & Quality Assessment`.
8. **Cognitive LLM Validation & Cognitive Self-Evaluation:** Use LLM reasoning to evaluate against the original goal whether the iteration result better achieves the overarching goal and verify high-quality achievement of the goal.
9. **Rule & Safety Adherence:** Strictly follow `interactive-workflow`, `step-action-visibility`, and `cursor-suite-production-safety`.

## Identical Full Task Iteration Invariant & Anti-Partitioning Rules

For prompt `use loop-work skill to loop 100 times to use tdd-team skill to review file A and fix bugs`:
- Every iteration $i \in [1, 100]$ reviews the ENTIRE File A across ALL dimensions simultaneously and resolves defects in-place.
- What loop-work is NOT (Strictly Forbidden):
  - **NO Early Exit or Premature Convergence:** Forbidden from exiting early before reaching iteration $N$.
  - **NO Spatial Partitioning (Target Chunking):** Do NOT split file, codebase, or module into chunks across loops.
  - **NO Dimensional Partitioning (Aspect Splitting):** Do NOT check syntax in loop 1, concurrency in loop 2, memory in loop 3. Check ALL aspects every loop.
  - **NO Hardening Phase Partitioning:** Every iteration evaluates the FULL multi-dimensional hardening envelope simultaneously.
  - **NO Phasing / Workflow Partitioning:** Do NOT spread skill lifecycle phases across iterations.
  - **NO Goal Drift or Sub-Goal Substitution:** Maintain the exact original goal through iteration $N$.

## State Tracking

State across iterations is tracked deterministically via `.loop_state.md`:
- Each iteration logs: `Goal`, `Current State Assessment`, `Customized Plan`, `What`, `Why`, `How`, `Special Notes`, and `Status & Quality Assessment`.
- Continuation sentinel `AGENT_LOOP_WAKE_loop_work` is monitored via background execution (`block_until_ms: 0`, `notify_on_output`).

## Integration with Interactive Workflow & Step Action Visibility

1. **Step Action Visibility**: For every iteration, output full VLLM reasoning, execution plan, progress, and results to chat.
2. **Interactive Workflow Isolation**: For looping skills like `loop-work`, the main task is the entire loop across all $N$ iterations running in Step 1 (Daemon Mode). Do not trigger State 2 or State 3 prematurely until all N iterations are completely finished. Intermediate iterations execute silently in the background. Preserve AI suite isolation principle and continuous self-evolution.
3. **Step 7 Final Summary & Question Separation**: Upon completing iteration $N$, control returns to loop-work Step 7. The agent MUST NOT treat an inner skill's sub-report or Phase 5 as the final conversation summary. The agent MUST output the full, dedicated Loop-Work Final Execution Summary to chat and call `echo 'Interactive workflow summary rendered'` in Step 2, followed by `AskQuestion` in Step 3.

## Progressive Hardening Framework (Evaluated EVERY Iteration)

Every iteration $i \in [1, N]$ simultaneously applies all 5 hardening dimensions:
1. **Dimension 1: Baseline Correctness, Schema Compliance & Static Quality**: Nil/null guards, bounds protection, error wrapping, static analysis, unit/integration tests.
2. **Dimension 2: Concurrency, Synchronization & Race Safety**: Goroutine/thread contention, mutex ordering, deadlock avoidance, race detection (`go test -race`).
3. **Dimension 3: Chaos, Adversarial Fuzzing & Fault Injection**: Protocol fuzzing, malformed payloads, connection drops, timeout recovery, boundary overflows.
4. **Dimension 4: Resource Lifecycles & 1E-Class Safety Standards**: Memory leak audits, object pools, deterministic handle/socket closure (`defer`), bounded recursion, 1E nuclear safety compliance.
5. **Dimension 5: Mutation Analysis, Coverage Maximization & Regression Proof**: Mutation test survival, branch coverage $>98\%$, schema verification, regression closure.

*Cumulative Depth:* Iteration 1 provides Order-1 primary fixes; subsequent iterations achieve Order-2 interaction defense, Order-3 mutation resistance, and Order-N formal invariance.

## Continuation Protocol (CRITICAL)

To maintain autonomous looping across all $N$ iterations without stalling:
- At the end of every iteration where $i < N$, chain into the next iteration via tool call before ending the turn.
- Spawn a background sleeper with `Shell` (`block_until_ms: 0`, `notify_on_output` matching `^AGENT_LOOP_WAKE_loop_work`):
  ```bash
  sleep 5
  echo 'AGENT_LOOP_WAKE_loop_work {"iteration": <next_iteration_number>, "prompt": "<original_prompt>"}'
  ```
- On wake, read `.loop_state.md` and continue immediately.

## Execution Protocol

For `i = 1` to `N`:
1. **Step 1: Reassess State & Customize Plan**: Reassess state and past entries in `.loop_state.md`; calibrate multi-dimensional envelope; formulate plan aligned with full goal.
2. **Step 2: Run Task X Again (with Step Action Visibility)**: Invoke target skill on the full, unpartitioned target; after target skill completes, return to loop-work Execution Protocol; resolve defects in-iteration; output full VLLM reasoning and execution plan to chat.
3. **Step 3: Validate the Result & Goal Improvement**: Validate the result against goal alignment, progressive improvement, complete scope, and all-aspect coverage.
4. **Step 4: Output Iteration Report & Update State File**: Output step progress and results to chat; append mandatory block to `.loop_state.md`.
5. **Step 5: Design Improvements**: Formulate concrete strategy for iteration $i+1$ across all 5 dimensions.
6. **Step 6: Loop Continuation**:
   - If $i < N$: Execute background continuation command (`AGENT_LOOP_WAKE_loop_work`). Never stop.
   - If $i == N$: Proceed to Step 7.
7. **Step 7: Final Summary & Interactive Workflow Wrap-up**:
   - Verify high-quality achievement across all $N$ iterations.
   - **Return from Target Skill & Dedicated Loop-Work Summary**: When the target skill (e.g., `tdd-team`) completes its final iteration, control explicitly returns to loop-work Step 7. You MUST NOT treat or substitute the inner skill's Phase 5 or sub-report as the complete task summary.
   - **Mandatory Chat Summary Before Any Interactive Tool**: Once all $N$ iterations are done, output the full, comprehensive execution summary of the entire loop-work process in the conversational chat window text before invoking any wrap-up or question tools (covering Overall Goal Achievement across all N iterations, State Progression Log from `.loop_state.md`, Multi-Dimensional 5-Dimension Hardening Matrix for all N iterations, and Final Key Points).
   - **Cleanup & File List Inspection**: Before Step 2 wrap-up summary and Step 3 `AskQuestion`:
     - The AI agent MUST check the file list (via `git status --porcelain` or directory listing) to detect all leftover, temporary, or unused files (`*.bak`, `*.tmp`, `patch.sh*`, `.cursor_build.*`, `.cov_init.sh`, `.coverage_trace.log`).
     - Remove all temporary and unused files before outputting summary and invoking AskQuestion.
   - **Strict Separation of State 2 and State 3**:
     - State 2 (Wrap-Up & Summary Isolation): Output final execution summary as visible chat text AND call `echo 'Interactive workflow summary rendered'` to force UI synchronization. DO NOT call AskQuestion in this response.
     - State 3 (The Follow-Up Loop): After `echo` returns, call `AskQuestion` in very next response.
     - DO NOT call AskQuestion until chat summary has been rendered and UI echo has returned. Do NOT bundle AskQuestion with task execution tools.

## Negative Constraints (Must NOT)
- [X] Do NOT trigger an early exit before completing all $N$ requested iterations. Never exit early on premature convergence.
- [X] Do NOT end a turn or wait for user input when $i < N$; chain tool calls via background continuation sleeper.
- [X] Do NOT alter or substitute the goal of task X across iterations (No Goal Drift or Sub-Goal Substitution).
- [X] Do NOT run an iteration without reassessing state and customizing a new plan.
- [X] Do NOT fail to log each iteration into `.loop_state.md` with goal, what, why, how, and special notes.
- [X] Do NOT split target file or codebase into sub-parts across iterations (Spatial Partitioning).
- [X] Do NOT split review dimensions or categories across iterations (Dimensional Partitioning).
- [X] Do NOT defer or divide hardening dimensions across iterations (Hardening Phase Partitioning).
- [X] Do NOT spread workflow phases across iterations (Phasing Partitioning).
- [X] Do NOT break AI suite isolation or self-evolution mechanisms.
- [X] Do NOT call `AskQuestion` or trigger `interactive-workflow` State 2/3 until all $N$ iterations are complete.
- [X] Do NOT call AskQuestion before outputting the full final execution summary to the chat window and executing `echo 'Interactive workflow summary rendered'`.
- [X] Do NOT call AskQuestion before removing all temporary or unused files generated during active task execution.
- [X] Do NOT conclude loop or advance to AskQuestion without having the AI agent check the file list (`git status --porcelain`) to identify and remove all temporary and unused files.
- [X] Do NOT substitute or treat an inner skill's Phase 5 or sub-report as the final complete task summary; always return to loop-work Step 7 to emit the full multi-iteration summary report.
