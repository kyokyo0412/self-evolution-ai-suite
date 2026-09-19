# Interactive Workflow & Zero-Cost Refinement

Collaborative wrapper around agent execution providing zero-cost follow-ups for the user.
To prevent the interactive workflow from causing abnormal main task execution or skipping questions, strictly follow this persistent state machine for EVERY task and all subsequent task iterations.
**CRITICAL RULE:** This is ONLY a wrapper. Handle main tasks EXACTLY as normal.
**CONSTRAINT:** This interactive workflow is strictly and ONLY for the Cursor Agent.

## The Continuous Interactive Workflow Lifecycle

### Step 0: State 0 - INITIALIZATION (Hard Block)
**[HARD BLOCK]** You MUST NOT execute any state-changing tools (e.g., Shell, Write, StrReplace) or begin main task execution until you FIRST call `AskQuestion`:
- **prompt**: "Do you need an interactive workflow for this task? (This allows you to provide follow-up prompts after the task is done without consuming extra Cursor included requests. If no response is received in 3 minutes, it will default to No.)"
- **options**:
  1. `{"id": "yes", "label": "Yes, start an interactive workflow."}`
  2. `{"id": "no", "label": "No, just run the task and stop."}`
*Default to "No" on 3-minute timeout.*

### Step 1: State 1 - NORMAL / MAIN TASK EXECUTION (Daemon Mode)
Runs silently in background upon "Yes" or new follow-up from Step 3:
1. **Normal Execution:** Execute main task fully per instructions, core directives, and active skills. Prevent abnormal main task execution.
2. **Absolute Isolation:** Wrapper MUST NOT alter, simplify, or skip task steps.
3. **Multi-Iteration & Loop-Work Invariant:** For looping skills (e.g., `loop-work`), all N iterations constitute the main task. Do NOT trigger Step 2 or 3 on intermediate iterations; wait until all iterations are 100% complete.
4. **Double Confirmation:** You must wait until the main task is 100% complete and double confirm that the main task is done. If using a To-Do list, every single item MUST be marked as COMPLETED before you can even think about moving to Step 2.
5. **Active Task Workspace Cleanup & AI Agent File List Inspection:** Before Step 2 wrap-up summary and Step 3 `AskQuestion`:
   - Active task cleanup before AskQuestion: if the active task should clean up unused and temporary files, the active task MUST remove them FIRST. Then process the AskQuestion tool.
   - AI agent file list inspection: check `git status --porcelain` or directory listing to identify and delete all temporary files (`*.bak`, `*.tmp`, `patch.sh*`, `.cursor_build.*`, `.cov_init.sh`, `.coverage_trace.log`).
6. NEVER call `echo 'Interactive workflow summary rendered'` before main task is 100% done, verified, cleanup confirmed via file list check, and execution summary fully output.

### Step 2: State 2 - WRAP-UP & SUMMARY ISOLATION
1. If "No" in Step 0: stop and end turn.
2. If "Yes" (Interactive Mode active): explicitly output all step outputs and final results in the chat window text. You MUST print all output of the main task in the chat window before invoking the question. The detailed summary must cover What, Why, How, and Key Points.
3. **CRITICAL HARD BLOCK FOR FINAL OUTPUT**: In ONE response:
   - Output full execution summary text (and final To-Do list status) explicitly in chat text. Do NOT silently call a tool. You MUST NOT use the AskQuestion tool until the chat text is fully generated.
   - After main task summary is output, output the execution summary as normal text AND call a minor tool (such as calling the `Shell` tool with: `echo 'Interactive workflow summary rendered'`) to force UI rendering.
   - **DO NOT call `AskQuestion` in this response.**

### Step 3: State 3 - THE FOLLOW-UP LOOP
Once Step 2's `echo` tool returns, call `AskQuestion` in the very next response:
- **prompt**: "Task completed. What would you like to do next? (Select an option or choose the native 'Other' to provide a custom follow-up prompt without consuming an extra request)"
- **options**:
  1. `{"id": "complete", "label": "Task is complete, stop here."}`
  2. `{"id": "explain", "label": "Explain the changes in more detail."}`

**Handling Result & Continuous Multi-Turn Loop Invariant**:
- **"complete"**: Stop and end turn.
- **"explain"**: Output detailed explanation in chat text, then call `AskQuestion` again to maintain interactive loop.
- **Custom text ("Other")**: Treated as a **NEW TASK**:
  - Interactive mode remains **already active**; **skip Step 0** (do not re-prompt Step 0).
  - Execute as Active Task: fully re-engage skills and tools to execute the required actions to fully complete the user's request in **Step 1 (State 1)**.
  - Persistent Chaining: Every task from "Other" follows `Step 1 -> Step 2 -> Step 3`. Perform file list inspection and cleanup before proceeding to Step 2 and Step 3. You MUST always use AskQuestion tool after each task is done when user input new task in the other option to ask the next question. You are STRICTLY FORBIDDEN from ending the turn or stopping without invoking AskQuestion in Step 3.
- **EXCEPTION for Reflection Protocol:** If input triggers Reflection Protocol ("run reflection", "improve the suite", "reflect on the last task"), you MUST immediately break the interactive workflow loop, pause non-reflection work, and do NOT loop back to call `AskQuestion`. Instead, execute the one-turn Reflection Protocol.

## Negative Constraints (Must NOT)
- [X] **PREMATURE ASKQUESTION BEFORE CLEANUP FORBIDDEN**: You MUST NOT process or call the `AskQuestion` tool while temporary or unused files remain uncleaned in the workspace. Active task must remove them first before AskQuestion is called.
- [X] **OMISSION OF FILE LIST CHECK FORBIDDEN**: You MUST NOT conclude the active task or advance to Step 2 / Step 3 without having the AI agent check the file list (`git status --porcelain`) to detect and remove all temporary and unused files.
- [X] **PREMATURE SUMMARY FORBIDDEN**: You MUST NOT call `echo 'Interactive workflow summary rendered'` before the main task is 100% finished and the main task summary has been output to the chat window.
- [X] **PREMATURE WRAP-UP FORBIDDEN**: You MUST NOT ask the follow-up question or stop working if there are still pending tasks in your To-Do list or if the user's core request is not fully met.
- [X] **MANDATORY ASKQUESTION AFTER 'OTHER' TASKS**: The agent MUST NOT end the turn without invoking AskQuestion after 'Other' task completion. You MUST always use AskQuestion after each task iteration is done when the user inputs a new task in the 'Other' option.
- [X] **MANDATORY LOOP-WORK SUMMARY BEFORE ASKQUESTION**: When running loop-work, you MUST NOT trigger Step 2 or 3 until all N iterations are complete, and you MUST NOT call AskQuestion without first printing the full final loop-work summary to chat and executing `echo 'Interactive workflow summary rendered'`.
- [X] **DO NOT BUNDLE ASKQUESTION WITH TASK TOOLS**: Do NOT bundle the final `AskQuestion` tool call in the same batch as the final task execution tools. Always separate them via Step 2 and Step 3.
- [X] **EXPLAIN OPTION TEXT OUTPUT REQUIRED**: Output actual explanation in chat text before calling `AskQuestion` again.
- [X] Do NOT make other agents use this interactive workflow. Strictly for Cursor Agent.
- [X] Do NOT call `AskQuestion` without first executing `echo 'Interactive workflow summary rendered'`.
- [X] Do NOT treat custom text follow-up as a simple chat question; execute it as a full, new task.
- [X] Do NOT skip the primary task's steps or summary.
- [X] Must not cost any extra Cursor included request in the interactive workflow.
