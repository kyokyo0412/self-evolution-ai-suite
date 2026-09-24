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
3. **Multi-Iteration & Loop-Work Invariant:** For looping skills (e.g., `loop-work`), all N iterations constitute the main task. Do NOT trigger Step 2 or 3 on intermediate iterations; wait until all iterations are 100% complete. When an outer orchestrator (`loop-work`) loops another skill (such as `tdd-team`), completion of the inner skill's final phase returns control to `loop-work` Step 7. The agent MUST NOT treat or substitute the inner skill's report as the main task summary; the agent MUST render the full, dedicated `loop-work` multi-iteration summary report in chat text in Step 2 before calling `echo 'Interactive workflow summary rendered'` and invoking `AskQuestion`.
4. **Double Confirmation:** You must wait until the main task is 100% complete and double confirm that the main task is done. If using a To-Do list, every single item MUST be marked as COMPLETED before you can even think about moving to Step 2.
5. **Active Task Workspace Cleanup & AI Agent File List Inspection:** Before Step 2 wrap-up summary and Step 3 `AskQuestion`:
   - Active task cleanup before AskQuestion: if the active task should clean up unused and temporary files, the active task MUST remove them FIRST. Then process the AskQuestion tool.
   - AI agent file list inspection: inspect the file list (check `git status --porcelain` or directory listing) to identify and delete all temporary files (`*.bak`, `*.tmp`, `patch.sh*`, `.cursor_build.*`, `.cov_init.sh`, `.coverage_trace.log`).
6. NEVER call `echo 'Interactive workflow summary rendered'` before main task is 100% done, verified, cleanup confirmed via file list check, and execution summary fully output.

### Step 2: State 2 - WRAP-UP & SUMMARY ISOLATION
1. If "No" in Step 0: stop and end turn.
2. If "Yes" (Interactive Mode active): explicitly output and print all output in the chat window text covering What, Why, How, and Key Points.
3. **CRITICAL HARD BLOCK FOR FINAL OUTPUT**: In ONE response:
   - Output full execution summary text explicitly in chat text.
   - After main task summary is output, call `echo 'Interactive workflow summary rendered'` to force UI rendering.
   - **DO NOT call `AskQuestion` in this response.**

### Step 3: State 3 - THE FOLLOW-UP LOOP
Once Step 2's `echo` tool returns, call `AskQuestion` in the very next response:
- **prompt**: "Task completed. What would you like to do next? (Select an option or choose the native 'Other' to provide a custom follow-up prompt without consuming an extra request)"
- **options**:
  1. `{"id": "complete", "label": "Task is complete, stop here."}`
  2. `{"id": "explain", "label": "Explain the changes in more detail."}`

**Handling Result & Continuous Multi-Turn Loop Invariant**:
- **"complete"**: Stop and end turn.
- **"explain"**: Output explanation in chat text, then call `AskQuestion` again.
- **Custom text ("Other")**: Treated as a **NEW TASK**:
  - Interactive mode remains active; skip Step 0.
  - Re-engage tools to execute the required actions following Step 1 -> Step 2 -> Step 3; always use AskQuestion after each task completed from 'Other'.
  - Perform file list check (`git status --porcelain`) and cleanup before proceeding to Step 2 and Step 3.
  - Output summary, execute `echo 'Interactive workflow summary rendered'`, and call `AskQuestion`.
- **EXCEPTION for Reflection Protocol:** If input triggers Reflection Protocol ("run reflection", "improve the suite", "reflect on the last task"), break interactive workflow loop, pause non-reflection work, and execute Reflection Protocol without calling `AskQuestion`.

## Negative Constraints (Must NOT)
- [X] **PREMATURE ASKQUESTION BEFORE CLEANUP FORBIDDEN**: You MUST NOT process or call `AskQuestion` while temporary files remain uncleaned.
- [X] **OMISSION OF FILE LIST CHECK FORBIDDEN**: Check `git status --porcelain` to remove temporary/unused files before summary and question.
- [X] **PREMATURE SUMMARY FORBIDDEN**: Do not call `echo 'Interactive workflow summary rendered'` before main task is 100% finished and chat summary generated.
- [X] **PREMATURE WRAP-UP FORBIDDEN**: Do not ask follow-up questions if pending tasks remain in To-Do list.
- [X] **MANDATORY ASKQUESTION AFTER 'OTHER' TASKS**: You MUST NOT end the turn or stop without invoking AskQuestion after each task completed from 'Other'.
- [X] **MANDATORY LOOP-WORK SUMMARY BEFORE ASKQUESTION**: When running loop-work, wait until all N iterations complete; render outer loop-work summary before AskQuestion.
- [X] **DO NOT BUNDLE ASKQUESTION WITH TASK TOOLS**: Separate summary and AskQuestion via Step 2 and Step 3.
- [X] **EXPLAIN OPTION TEXT OUTPUT REQUIRED**: Output actual explanation in chat text before calling `AskQuestion` again.
- [X] Do NOT make other agents use this interactive workflow. Strictly for Cursor Agent.
- [X] Do NOT call `AskQuestion` without first executing `echo 'Interactive workflow summary rendered'`.
- [X] Do NOT treat custom text follow-up as a simple chat question; execute it as a full, new task.
- [X] Do NOT skip primary task steps or summary.
- [X] Must not cost any extra Cursor included request in interactive workflow.
