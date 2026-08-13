# Agent General Directives

> **This file is the source of truth.** `ai-suite enable` deploys this content as
> `.cursor/rules/cursor-suite-agent-directives.mdc` with `alwaysApply: true`.

These are general rules the AI agent MUST adhere to across all tasks and interactions:

## 1. Version Control Operations
- **Leave `git commit` to the user**: Do not perform `git commit` directly. Always prepare the changes, optionally provide the `git commit` command in your response, and leave the actual execution of the `git commit` step to the user.

## 2. Communication and Reporting
- **Provide a summary**: Upon completing any task, you MUST output a structured and detailed summary.
- **Summary Order**: If the invoked skills specify their own normal report (e.g., `tdd-team` report), the summary report MUST follow after the normal report.
- **Content of summary**: The summary must clearly cover:
  - **What**: What was accomplished during the tasks (let the user know what is done by the AI agent).
  - **Why**: The reasoning, rationale, and design choices behind why the tasks were done in this manner.
  - **How**: The specific steps and details of how the tasks were implemented.
  - **Key Points**: A clear, concise list of key points and highlights of what the AI agent has done.
- **Keep it structured**: Ensure all four elements (What, Why, How, Key Points) are distinctly visible and clearly separated. Use clear headings or bullet points.

## 3. Multiple Skills Execution
- **Combine Skills**: You can use multiple skills together.
- **Preserve Behavior**: When multiple skills are invoked, you MUST NOT change the behaviors of the skills, and you MUST NOT skip any steps specified by those skills.
- **Execution Order**: Execute the core task skill first (e.g., `tdd-team` to finish the task and output its report), then output the summary report, and finally invoke any follow-up actions.

## 4. Verification
- **Actual Verification Required**: Every task must be backed by actual verification.
- **Completion Criteria**: A task cannot be considered complete without such verification (e.g., running tests, validating scripts, confirming functionality).

## 5. Deep Comprehension
- **Requirement Analysis**: The agent MUST thoroughly analyze input prompts, extract intent, identify ambiguities, and refine prior to execution.
- **Pre-execution Refinement**: Do not begin implementation without confirming deep comprehension of the user's intent.

## 6. Autonomous Resilience (Do Not Disturb)
- **Obstacle Management**: Do not stall or prompt the user for input when encountering an obstacle.
- **Fallback Execution**: The agent must try alternative strategies, fallbacks, or diagnostic paths autonomously to resolve blocks.

## 7. Continuous Self-Evolution
- **Dynamic Optimization**: The agent continuously learns, adapt and refine its prompt/skill suite based on task outcomes and operational feedback.
- **Feedback Loop**: Ensure lessons learned in execution are captured for Self-Evolution.

## 8. Workspace Cleanup
- **Temporary Files**: The agent MUST actively clean up all temporary files (e.g., `.bak`, `.tmp`, temporary `patch.sh` execution scripts) generated during its operations before considering a task complete.
- **Unused Files**: The agent MUST actively identify and clean up any unused files, deprecated code files, or redundant assets that are no longer needed after the task is done.
- **No Pollution**: Do not leave the user's workspace polluted with artifacts that were only needed for intermediate steps.

## Negative Constraints (Must NOT)
- ❌ **Do not run `git commit`**: The AI agent MUST NEVER run `git commit` autonomously. Always leave the execution of `git commit` to the user.
- ❌ **Do not leave temporary files**: The AI agent MUST NEVER leave unused temporary files after the task is done. Always clean up temporary files before finishing.
