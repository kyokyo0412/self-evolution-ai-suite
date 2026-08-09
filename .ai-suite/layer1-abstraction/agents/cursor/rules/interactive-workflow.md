# Interactive Workflow & Zero-Cost Refinement

This rule enforces a collaborative wrapper around your normal execution. It ensures that you can provide clear, actionable options for the user to guide the task execution without consuming additional Cursor requests.

**CRITICAL RULE:** This interactive workflow is ONLY a wrapper. It must NEVER alter, simplify, or skip your normal task execution, rules, or skills. You must handle the main task EXACTLY as you would if this rule did not exist.

## The 4-Step Interactive Wrapper

To prevent the interactive workflow from causing abnormal main task execution or skipping questions, you MUST strictly follow this 4-Step machine for EVERY task.

### Step 0: INITIALIZATION (Hard Block)

**🛑 HARD BLOCK: You MUST NOT execute any state-changing tools (e.g., Shell, Write, StrReplace) or begin the main task execution until you have FIRST called the `AskQuestion` tool to ask if the user wants an interactive workflow and received their answer.**

At the **very beginning of any task** (before any other action), you MUST use the `AskQuestion` tool:
- **prompt**: "Do you need an interactive workflow for this task? (This allows you to provide follow-up prompts after the task is done without consuming extra Cursor included requests.)"
- **options**:
  1. `{"id": "yes", "label": "Yes, start an interactive workflow."}`
  2. `{"id": "no", "label": "No, just run the task and stop."}`

*Wait for the user's answer before proceeding to Step 1.*

### Step 1: NORMAL TASK EXECUTION

Once the user answers Step 0:
1. **Execute the main task normally.** Follow all user instructions, core directives, and skills EXACTLY as requested by the user prompt.
2. Treat the main task completely independently from this interactive workflow. **DO NOT** let this interactive workflow distract you from doing a thorough, complete job.
3. You MUST wait until the main task is 100% complete before moving to Step 2.

### Step 2: WRAP-UP & SUMMARY ISOLATION

When the main task is fully completed:
1. **If the user selected "No" in Step 0**, gracefully end your turn and STOP here. Do NOT advance to Step 3.
2. **If the user selected "Yes" in Step 0**, you must output your detailed task execution summary to the chat window.
3. **CRITICAL HARD BLOCK FOR FINAL OUTPUT**: To ensure the user sees the summary before the final question, you MUST do the following in ONE response:
   - Output the full execution summary text.
   - Call the `Shell` tool with: `echo 'Interactive workflow summary rendered'`
   - **DO NOT call `AskQuestion` in this response.**
4. Wait for the `Shell` tool to return.

### Step 3: THE FOLLOW-UP LOOP

Once Step 2's `echo` shell tool has returned:
1. In your very next response, call the `AskQuestion` tool:
- **prompt**: "Task completed. What would you like to do next? (Select an option or choose the native 'Other' to provide a custom follow-up prompt without consuming an extra request)"
- **options**:
  1. `{"id": "complete", "label": "Task is complete, stop here."}`
  2. `{"id": "explain", "label": "Explain the changes in more detail."}`

**Handling the Result**:
- If **"complete"**: Stop here and gracefully end your turn.
- If **"explain"**: Provide the explanation, then loop back to Step 3 (call AskQuestion again).
- If **custom text ("Other")**: This is a **BRAND NEW MAIN TASK**. You MUST fully re-engage all your skills, coding tools, and agent rules to execute it. Do NOT just give a conversational reply. Treat it as a completely new prompt from the user. Go back to **Step 1** to execute this new task fully, then proceed to Step 2 and 3 again.
- **EXCEPTION for Reflection Protocol:** If the custom text input is a trigger for the Reflection Protocol (e.g., "run reflection", "improve the suite"), immediately break this loop and run the strict one-turn Reflection Protocol.

## Negative Constraints (Must NOT)
- ❌ Do NOT make other agents (like Claude Code, Roo Code, etc.) use this interactive workflow. This is strictly for the Cursor Agent.
- ❌ Do NOT call `AskQuestion` at the end of the task without first doing the `echo 'Interactive workflow summary rendered'` step to force the summary output.
- ❌ Do NOT treat a custom text follow-up as a simple chat question. You MUST execute it as a full, new task using your tools and rules.
- ❌ Do NOT skip the primary task's steps or summary. You MUST fully complete the primary task.
- ❌ Must NOT cost any extra Cursor included request in the interactive workflow.