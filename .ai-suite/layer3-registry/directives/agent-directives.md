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
- **Strict Cleanup Verification**: Before calling a task complete, you MUST execute a terminal command (e.g., `find . -name "*.bak" -o -name "*.tmp" -o -name "patch.sh*" -o -name ".cursor_build.*"`) to verify no temporary files remain in the working directory.
- **AI Agent File List Inspection**: The AI agent MUST check the file list (via `git status --porcelain` or directory file list inspection) to audit all newly created, untracked, or residual files, and actively determine which files are temporary or unused artifacts generated during task execution.
- **Temporary & Unused Files Removal**: The agent MUST actively delete all temporary files (e.g., `.bak`, `.tmp`, temporary `patch.sh` execution scripts, `.cursor_build.log`, `.cursor_build.pid`, `.cov_init.sh`, `.coverage_trace.log`) and any unused files or redundant assets that are no longer needed after the task is done, ensuring the active task cleans up before completing and before any follow-up interactive tools (such as `AskQuestion`) are processed.
- **Active Task Cleanup Before AskQuestion**: When running the interactive workflow, if the active task should clean up unused and temporary files, let the active task remove it. Then process the `AskQuestion` tool.
- **No Pollution**: Do not leave the user's workspace polluted with artifacts that were only needed for intermediate steps.

## 9. Efficiency & Performance
- **Parallel Execution**: Maximize parallel tool calls whenever independent tasks can be run concurrently (e.g., executing parallel linters, reading multiple files) to improve AI agent execution efficiency.

## 10. Quality Check
- **Linting & Quality**: Use `ReadLints` or specific automated checking tools after code modifications to maintain a high standard of product developing quality.

## 11. Continuous Task Tracking
- **Dynamic To-Do List**: When executing complex or multi-step tasks, you MUST continuously track your progress. Use the `TodoWrite` tool (if available) or explicit markdown to track task items. Initialize a Master To-Do list and update it dynamically as you work. When an item is completed, explicitly output and show the current status of the To-Do list in the chat window.

## 12. Code Formatting & Style Standards
- **Language Standards**: When generating or modifying code, adhere strictly to established language standards:
  - For Go code, the format MUST align strictly to the `gofmt` standard.
  - For C code, the format MUST adhere to `clang-format` conventions.
- **Project Consistency**: When generating code, follow the existing code style, naming conventions, and indentation of the project.
- **No Trivial Empty Lines**: Code files must NOT have trivial empty lines containing only spaces or tabs. All blank lines must be completely clean with zero trailing whitespace.
- **Selective Formatting Scope**: Formatting MUST only be applied to new or modified code lines. Do NOT reformat unchanged code or untouched lines unless explicitly requested by the user, preserving concise git diffs.

## Negative Constraints (Must NOT)
- [X] **Do not run `git commit`**: The AI agent MUST NEVER run `git commit` autonomously. Always leave the execution of `git commit` to the user.
- [X] **Do not leave temporary files**: The AI agent MUST NEVER leave unused temporary files after the task is done. Always actively verify and clean up `.bak`, `.tmp`, and `.pid`/`.log` execution files before finishing.
- [X] **Do not call AskQuestion before cleanup**: The AI agent MUST NOT call or process `AskQuestion` while temporary or unused files generated by the active task remain in the workspace. All temporary and unused files must be removed by the active task first.
- [X] **Do not reformat unchanged code**: Only format new or modified code lines. Do NOT reformat unchanged code unless explicitly requested by the user.
- [X] **Do not leave space/tab-only empty lines**: Ensure all empty lines have zero trailing whitespace and contain no spaces or tabs.
- [X] **Do not violate language formatting standards**: Ensure Go code adheres to `gofmt` and C code adheres to `clang-format`.
