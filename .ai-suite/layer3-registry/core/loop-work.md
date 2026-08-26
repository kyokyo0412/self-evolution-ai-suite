---
name: loop-work
description: "Use when the user asks to loop or iterate a task multiple times using a specific skill (e.g., 'loop 10 times to use tdd-team skill to do...'). This skill orchestrates an iterative execution process with a 'never give up' spirit, validating results and designing improvements on each iteration."
disabled-environments:
  - cloud
triggers:
  - loop-work
---

# Loop-Work Skill -- Iterative Agentic Execution

Use this skill when the user requests to run a task for multiple iterations using a specific skill (e.g., `tdd-team`). This skill transforms the agent into an iterative orchestrator that embodies a **never-give-up spirit**.

## Core Directives

1. **Parse the Request:** Identify the number of iterations (`N`), the target skill to use (e.g., `tdd-team`), and the core task prompt.
2. **Never-Give-Up Spirit:** You must persist through the specified number of iterations. If an iteration fails or produces suboptimal results, you must not stop. Instead, analyze the failure, design an improvement, and immediately proceed to the next iteration.
3. **Strict Isolation:** Do not break the isolation principle of the AI suite. Each iteration must cleanly execute the target skill without corrupting the global state or interfering with other running processes.
4. **Preserve Self-Evolution:** Do not break the self-evolution mechanisms of the AI suite. Ensure that any learnings or improvements are properly logged or integrated according to the suite's standard evolutionary protocols.
5. **LLM Reasoning & Validation:** After each iteration, use your own LLM thinking and reasoning capabilities to rigorously validate the result against the user's original task prompt.
6. **Full Goal Attempt (No Splitting):** Do not split the original goal into sub-tasks across iterations. Every iteration MUST attempt to achieve the FULL original goal. Subsequent iterations are for refining and improving the quality of the previous iteration's output.
7. **Strict Rule Adherence:** You MUST strictly follow all rules and guidelines, especially `interactive-workflow` and `step-action-visibility`.

## Integration with Interactive Workflow & Step Action Visibility

When `interactive-workflow` is enabled or active, you MUST handle it carefully to avoid breaking the loop:
- **The "Main Task" is the ENTIRE loop:** The full `N` iterations constitute the "Main Task" in State 1 of the `interactive-workflow`.
- **Do NOT trigger State 2 or State 3 prematurely:** You MUST NOT output the final task summary or call the `AskQuestion` tool until ALL `N` iterations are completely finished (or the task is perfectly achieved early).
- **Step Action Visibility per Iteration:** For EACH iteration, you MUST output the detailed step actions (Architectural Analysis, Step-by-Step Execution Plan, and Implementation) to the chat window, ensuring full visibility of what is happening inside the loop.
- **Final Summary:** Once all iterations are complete, you MUST output a comprehensive final task summary BEFORE moving to State 2 and State 3 (the final `AskQuestion` tool box).

## State Tracking (Required for Long Loops)

When looping multiple times (e.g., up to 100 times), the context window may drop early iterations. You MUST maintain external state:
- Create or append to a `.loop_state.md` file in the workspace to log progress. You MUST append to this file so that all iterations are logged instead of only the last one.
- Log the iteration number, the strategy used, the result (Success/Failure), and the planned improvement for the next iteration.
- Read this file at the start of any new iteration if you need to recover context.

## Continuation Protocol (CRITICAL)

Because of the nature of LLM agent execution, your turn will naturally stop and wait for user input if you only output text. **To achieve true autonomous looping, you MUST NOT stop.**
- At the end of every iteration (unless it's the final one or the task is perfectly achieved), you MUST chain into the next iteration by explicitly calling a tool.
- To prevent stopping and reliably trigger the next iteration, you MUST use the `Shell` tool with the `notify_on_output` feature.
- Execute a background sleep command that echoes a JSON payload with the `AGENT_LOOP_WAKE_loop_work` sentinel.
- Configure the `Shell` tool with `notify_on_output` matching `^AGENT_LOOP_WAKE_loop_work`.

**Example Continuation Command:**
```bash
sleep 5
echo 'AGENT_LOOP_WAKE_loop_work {"iteration": <next_iteration_number>, "prompt": "<original_prompt>"}'
```
- When you execute this `Shell` tool call, set `block_until_ms: 0` to background it, and configure `notify_on_output` with `pattern: "^AGENT_LOOP_WAKE_loop_work"` and `reason: "loop-work iteration"`.
- This will wake you up after 5 seconds to perform the next iteration. On wake, read the payload and continue execution.

## Execution Protocol

For `i = 1` to `N` (or until the task is perfectly achieved):

### Step 1: Execute Target Skill (with Step Action Visibility)
- Invoke the user-specified skill (e.g., `tdd-team`) to perform the task.
- Follow all instructions and constraints of that target skill strictly for this iteration.
- **CRITICAL:** Output the `step-action-visibility` details (VLLM Reasoning, Execution Plan, Implementation) for this specific iteration.
- **CRITICAL:** The output of the target skill (e.g., `tdd-team`) MUST be correct and fully outputted to the chat window. Do not suppress, summarize, or skip the target skill's required outputs.
- **CRITICAL:** After the target skill completes its execution (e.g., finishes its final phase), you MUST explicitly return to the loop-work Execution Protocol (Step 2) to validate and continue.

### Step 2: Validate Result (LLM Reasoning)
- Evaluate the result against the ORIGINAL input task goal. Do not evaluate against a sub-task or partial goal.
- **Ask yourself:** Did this iteration fully solve the problem? Are there edge cases missed? Did it meet all constraints?

### Step 3: Output Iteration Report & Update State
- Provide a detailed output for the current iteration in the chat message. Each iteration step/action and result MUST be outputted to the chat window.
- Append to the `.loop_state.md` file via the `Write` or `Shell` tool (e.g., using `>>` or reading and appending).
- **Format:**
  - **Iteration #:** `[Current Iteration] / [Total Iterations]`
  - **Status:** `[Success / Partial Success / Failure]`
  - **Validation Summary:** Detailed LLM reasoning on what worked and what didn't.

### Step 4: Design Improvements
- If the validation shows the task is not 100% complete or optimal:
  - Identify the root cause of the shortcomings.
  - Formulate a concrete strategy and updated prompt/approach for the next iteration.
  - Clearly state the planned improvements in the chat message and the state file.

### Step 5: Loop Continuation
- If the task is perfectly achieved, exit the loop early.
- If not, and `i < N`, you MUST execute the **Continuation Protocol** to immediately begin the next iteration.
- If `i == N` and the task is still not perfect, provide a final failure analysis.

### Step 6: Final Summary & Interactive Workflow Wrap-up
- **ONLY AFTER ALL ITERATIONS ARE DONE:** Output the final task summary.
- **Cleanup:** Identify and remove any unused files, temporary files, or leftover artifacts created during the iterations.
- Proceed to State 2 and State 3 of the `interactive-workflow` (call the `AskQuestion` tool).

## Negative Constraints (Must NOT)
- [X] Do NOT stop the loop prematurely unless the task is 100% perfectly achieved. You MUST explicitly chain tool calls to maintain execution.
- [X] Do NOT break the isolation principle of the AI suite.
- [X] Do NOT break or bypass the self-evolution mechanisms.
- [X] Do NOT run the next iteration without explicitly validating the previous one, designing improvements, and logging to State Tracking.
- [X] Do NOT call `AskQuestion` or trigger `interactive-workflow` State 2/3 until the entire loop of `N` iterations is complete.
