# Interactive Workflow & Zero-Cost Refinement

This rule enforces a collaborative wrapper around your normal execution. It ensures that you can provide clear, actionable options for the user to guide the task execution without consuming additional Cursor requests.

**CRITICAL RULE:** This interactive workflow is ONLY a wrapper. It must NEVER alter, simplify, or skip your normal task execution, rules, or skills. You must handle the main task EXACTLY as you would if this rule did not exist.

**CONSTRAINT:** This interactive workflow is strictly and ONLY for the Cursor Agent. It will NOT be installed to or used by any other agents.

## The Continuous Interactive Workflow Lifecycle

To prevent the interactive workflow from causing abnormal main task execution or skipping questions, you MUST strictly follow this persistent state machine for EVERY task and all subsequent task iterations.

### Step 0: State 0 - INITIALIZATION (Hard Block)

**[HARD BLOCK] HARD BLOCK: You MUST NOT execute any state-changing tools (e.g., Shell, Write, StrReplace) or begin the main task execution until you have FIRST called the `AskQuestion` tool to ask if the user wants an interactive workflow and received their answer. You MUST always ask this FIRST before any other actions.**

At the **very beginning of any task / conversation session** (before any other action):
You MUST use the `AskQuestion` tool:
- **prompt**: "Do you need an interactive workflow for this task? (This allows you to provide follow-up prompts after the task is done without consuming extra Cursor included requests. If no response is received in 3 minutes, it will default to No.)"
- **options**:
  1. `{"id": "yes", "label": "Yes, start an interactive workflow."}`
  2. `{"id": "no", "label": "No, just run the task and stop."}`

*Wait for the user's answer before proceeding to Step 1. If the system or user environment causes a timeout after 3 minutes of waiting for input, you MUST assume the user selected "No" and proceed immediately to execute the main task without the interactive workflow wrapper.*

### Step 1: State 1 - NORMAL / MAIN TASK EXECUTION (Daemon Mode)

Once the user answers "Yes" in Step 0 (or when a new follow-up task is received in Step 3), the Interactive Wrapper enters "Daemon Mode" (runs silently in the background).
1. **Execute the main task normally.** Follow all user instructions, core directives, and skills EXACTLY as requested by the task prompt.
2. **Absolute Isolation:** Treat the main task completely independently from this interactive workflow wrapper. **DO NOT** let this interactive workflow distract you from doing a thorough, complete job or cause abnormal task execution. You must pretend the wrapper does not exist during this step. Do not act stupid, lazy, or skip any steps specified by other skills. You MUST fully comply with all other .cursorrules, general directives, and active skills while executing the main task.
3. You MUST wait until the main task is 100% complete and double confirm that the main task is done. If you are using a To-Do list, every single item MUST be marked as COMPLETED before you can even think about moving to Step 2.
4. **NEVER call `echo 'Interactive workflow summary rendered'` before the main task is completely finished, verified, and the execution summary is fully output.**

### Step 2: State 2 - WRAP-UP & SUMMARY ISOLATION

When the main task is fully completed:
1. **If the user selected "No" in Step 0**, gracefully end your turn and STOP here. Do NOT advance to Step 3.
2. **If the user selected "Yes" in Step 0 (Interactive Mode is active)**, you must output your detailed execution summary to the chat window. You MUST explicitly output all step outputs and final results in the chat window text. You MUST print all output of the main task in the chat window before invoking the question.
3. **CRITICAL HARD BLOCK FOR FINAL OUTPUT**: To ensure the user sees the summary before the final question, you MUST do the following in ONE response:
   - **CRITICAL**: You MUST write the full execution summary text (and the final To-Do list status, if applicable) explicitly in your conversational response text so it is visible in the chat window. Do NOT just silently call a tool. You MUST NOT use the AskQuestion tool until the chat text is fully generated.
   - After the main task is 100% finished and the summary text is output, you must output the execution summary as normal text AND call a minor tool (such as calling the `Shell` tool with: `echo 'Interactive workflow summary rendered'`) to force UI rendering.
   - **DO NOT call `AskQuestion` in this response.**
4. Wait for the `Shell` tool to return.

### Step 3: State 3 - THE FOLLOW-UP LOOP

Once Step 2's `echo` shell tool has returned:
1. In your very next response, call the `AskQuestion` tool:
- **prompt**: "Task completed. What would you like to do next? (Select an option or choose the native 'Other' to provide a custom follow-up prompt without consuming an extra request)"
- **options**:
  1. `{"id": "complete", "label": "Task is complete, stop here."}`
  2. `{"id": "explain", "label": "Explain the changes in more detail."}`

**Handling the Result & Continuous Multi-Turn Loop Invariant**:
- If **"complete"**: Stop here and gracefully end your turn.
- If **"explain"**: Provide the detailed explanation, and then loop back to Step 3 (call `AskQuestion` again).
- If **custom text ("Other")**: This is a **NEW TASK**.
  - **Persistent Interactive Mode**: The interactive workflow remains **already enabled and active**. You must **skip Step 0** (do not re-prompt Step 0 since interactive workflow is already active).
  - **Execute as Active Task**: You MUST fully re-engage all your skills, coding tools, and agent rules to execute it. Do NOT just give a conversational reply. Treat it as a completely new prompt from the user. You MUST execute the required actions to fully complete the user's request in **Step 1 (State 1)**.
  - **Always Loop Back to Step 2 and Step 3**: Every task iteration received from the "Other" option MUST follow the complete lifecycle (`Step 1 -> Step 2 -> Step 3`). Upon completing this new task, you MUST execute **Step 2 (State 2)** to output the execution summary and run `echo 'Interactive workflow summary rendered'`, and then in **Step 3 (State 3)** you MUST always use AskQuestion tool after each task is done when user input new task in the other option to ask the next question.
- **EXCEPTION for Reflection Protocol:** If the custom text input is a trigger for the Reflection Protocol (e.g., "run reflection", "improve the suite", "reflect on the last task"), you MUST immediately break the interactive workflow loop. Do not execute the task within the interactive loop constraints and do NOT loop back to call `AskQuestion`. Instead, instantly pause all non-reflection work and execute the strict one-turn Reflection Protocol.

## Negative Constraints (Must NOT)
- [X] **PREMATURE SUMMARY FORBIDDEN**: You MUST NOT call `echo 'Interactive workflow summary rendered'` before the main task is 100% finished and the main task summary has been output to the chat window.
- [X] **PREMATURE WRAP-UP FORBIDDEN**: You MUST NOT ask the follow-up question or stop working if there are still pending tasks in your To-Do list or if the user's core request is not fully met.
- [X] **MANDATORY ASKQUESTION AFTER 'OTHER' TASKS**: Once interactive workflow is enabled, you are STRICTLY FORBIDDEN from ending the turn or stopping after executing an 'Other' task without executing Step 2 (summary + echo) and Step 3 (`AskQuestion`). The agent MUST NOT end the turn without invoking AskQuestion after 'Other' task completion. You MUST always use AskQuestion after each task iteration is done when the user inputs a new task in the 'Other' option.
- [X] **DO NOT BUNDLE ASKQUESTION WITH TASK TOOLS**: Do NOT bundle the final `AskQuestion` tool call in the same batch as the final task execution tools. Always separate them via Step 2 and Step 3.
- [X] Do NOT make other agents (like Claude Code, Roo Code, etc.) use this interactive workflow. This is strictly for the Cursor Agent.
- [X] Do NOT call `AskQuestion` at the end of the task without first doing the `echo 'Interactive workflow summary rendered'` step to force the summary output.
- [X] Do NOT treat a custom text follow-up as a simple chat question. You MUST execute it as a full, new task using your tools and rules. You must re-initialize your mental state to Step 1 and execute fully.
- [X] Do NOT skip the primary task's steps or summary. You MUST fully complete the primary task.
- [X] Must not cost any extra Cursor included request in the interactive workflow.
