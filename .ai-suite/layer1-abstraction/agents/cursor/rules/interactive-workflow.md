# Optional Interactive Workflow

This workflow is strictly and ONLY for the Cursor Agent. It provides optional task follow-ups using supported user-input tools. It makes no billing or request-count guarantees.

## The Continuous Interactive Workflow Lifecycle

### Step 0: State 0 - INITIALIZATION

Activate only when the user explicitly requests interactive follow-ups. Otherwise execute the task normally and finish without an activation question. Never infer opt-in or approval from elapsed time. If AskQuestion is unavailable, use an ordinary chat response.

### Step 1: State 1 - NORMAL / MAIN TASK EXECUTION

1. Execute the authorized main task normally; this wrapper must not alter, simplify, or skip its requirements.
2. For loop-work, all N requested iterations form the main task. Wait until all N iterations complete before wrap-up; an inner skill report returns control to the outer loop.
3. Confirm completion against the current To-Do list and executed verification. Disclose blocked work or failed checks instead of presenting the task as complete.
4. Before follow-up, inspect the file list with `git status --porcelain` or a supported directory listing. Remove only task-created temporary files; preserve user files. Report cleanup failures before continuing.

### Step 2: State 2 - WRAP-UP & SUMMARY ISOLATION

Output the full execution summary in chat text before AskQuestion, covering What, Why, How, Key Points, and verification limits. Keep the summary visible before the follow-up tool call. Do not bundle a follow-up question with pending task execution tools. Do not require a dummy echo or an unsupported rendering tool.

### Step 3: State 3 - THE FOLLOW-UP LOOP

If interactive mode is active and the main task is complete, use AskQuestion when available to offer stop, explanation, or another task. Honor the user's choice:
- Complete: stop and end the turn.
- Explain: give the requested explanation, then offer follow-up while interactive mode remains active.
- Custom text (Other): execute it as a complete new authorized task through Step 1 -> Step 2 -> Step 3. Skip Step 0 because the explicit opt-in remains active.
- EXCEPTION for Reflection Protocol: on an explicit reflection trigger, break the interactive workflow loop, pause non-reflection work, and run reflection without calling AskQuestion.

## Negative Constraints (Must NOT)

- [X] Do not activate this workflow or ask an activation question without explicit user opt-in.
- [X] Do not call AskQuestion before completion checks, file list inspection, cleanup, and the chat summary.
- [X] Do not impose this workflow on other agents.
- [X] Do not wrap up an explicit loop before all N requested iterations are complete.
- [X] Do not treat a follow-up task as a substitute for completing the active task.
- [X] Do not invent tool support, billing savings, request-count guarantees, or timeout approvals.
