---
name: loop-work
description: Orchestrate N iterative executions of a skill toward a goal with progressive hardening and state logging. Use when iterating a task multiple times, looping skills (e.g., loop 10 times to use tdd-team), or executing multi-round refinement without early exit.
disabled-environments:
  - cloud
triggers:
  - loop-work
---

# Loop-Work Skill -- Iterative Agentic Execution

Iterative orchestrator for executing a task across $N$ iterations using a specified skill (e.g., `tdd-team`) with progressive hardening and continuous state logging.

## Core Directives
1. **Goal Invariance**: The overarching goal MUST serve as the goal of every iteration. Do NOT split or partition the goal across iterations.
2. **Execute All N Iterations**: Execute all $N$ requested iterations. Never exit early on premature convergence.
3. **State Logging (`.loop_state.md`)**: Reassess artifact state, identify gaps, formulate a customized plan, and append each iteration to `.loop_state.md`.
4. **Identical Target**: Repeat the task on the exact same complete target across all iterations without spatial or dimensional slicing.
5. **Visibility**: Output VLLM reasoning, execution plan, progress, and results to chat for every iteration.

## Execution Protocol
For `i = 1` to `N`:
1. Reassess state from `.loop_state.md` and formulate customized plan across all 5 hardening dimensions.
2. Invoke target skill across the complete artifact; resolve defects in-iteration.
3. Verify improvements and append results to `.loop_state.md`.
4. If $i < N$: spawn background continuation sleeper matching sentinel `^AGENT_LOOP_WAKE_loop_work`.
5. If $i == N$: Proceed to Step 7.
6. **Step 7: Summary & Interactive Workflow Synergy**:
   - Output full multi-iteration summary in chat (Goal Achievement, State Progression Log, Hardening Matrix, Key Points).
   - Check file list (`git status --porcelain`) and remove temporary or unused files before AskQuestion (`*.bak`, `*.tmp`, `.cursor_build.*`).
   - In Cursor Agent with interactive workflow active: Step 2 summary -> Step 3 AskQuestion. Output full chat summary, call `echo 'Interactive workflow summary rendered'`, and invoke `AskQuestion` in next turn (do NOT bundle AskQuestion with task tools).

## Negative Constraints (Must NOT)
- [X] Do NOT trigger an early exit before completing all $N$ requested iterations.
- [X] Do NOT alter or substitute the goal of task X across iterations.
- [X] Do NOT split target file or codebase into sub-parts across iterations.
- [X] Do NOT split review dimensions or hardening phases across iterations.
- [X] In Cursor Agent, do NOT call `AskQuestion` before outputting the full final execution summary to the chat window and executing `echo 'Interactive workflow summary rendered'`.
- [X] In Cursor Agent, do NOT call `AskQuestion` before removing all temporary or unused files generated during active task execution.
- [X] In Cursor Agent, do NOT conclude loop or advance to `AskQuestion` without having the AI agent check the file list (`git status --porcelain`) to identify and remove all temporary and unused files.
- [X] Do not substitute inner skill Phase 5 or report as final complete task summary; always return to loop-work Step 7 to emit the full multi-iteration summary report.
- [X] Do NOT make other agents use this interactive workflow. Strictly for Cursor Agent.
