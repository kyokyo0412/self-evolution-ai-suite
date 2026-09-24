# Agent General Directives

General rules the AI agent MUST adhere to across all tasks and interactions:

## Directives
1. **Version Control**: Prepare changes, optionally provide git commit command; leave actual execution of `git commit` to the user.
2. **Execution Summary**: Upon task completion, output a structured summary covering What, Why, How, and Key Points.
3. **Multiple Skills Execution**: Combine multiple skills without altering workflows or skipping steps.
4. **Verification Required**: Tasks cannot be considered complete without running tests or confirming functionality.
5. **Comprehension & Resilience**: Deeply analyze requirements; resolve obstacles autonomously without stalling.
6. **Continuous Self-Evolution**: Refine prompts and skills based on operational feedback.
7. **Workspace Cleanup**: Check file list (`git status --porcelain`) and remove temporary files (`*.bak`, `*.tmp`, `patch.sh*`, `.cursor_build.*`).
8. **Efficiency & Tooling**: Maximize parallel tool calls for independent actions; run `ReadLints` after modifications.
9. **Dynamic Task Tracking**: Dynamically maintain To-Do list with `TodoWrite` or markdown until 100% complete.
10. **Code Formatting & Gitreview Red-Flag Prevention**:
    - Go code must align to `gofmt`; C code to `clang-format`.
    - Zero space/tab-only empty lines: clean empty lines must contain zero whitespace.
    - Format strictly modified lines; never reformat untouched code.
11. **Deterministic Resource Management**: Explicit cleanup of handles, sockets, and subprocesses (`defer`, `with`, `trap ... EXIT`).
12. **Dynamic Test Assertions**: Assertions on counts that grow with codebase MUST be computed dynamically at runtime; never hardcode static integer counts.

## Negative Constraints (Must NOT)
- [X] **Do not run `git commit`**: The AI agent MUST NEVER run git commit autonomously.
- [X] **Do not leave temporary files**: Actively verify and clean up `.bak`, `.tmp`, `.pid`, and `.log` execution artifacts before finishing.
- [X] **Do not reformat unchanged code**: Selective formatting applies strictly to new or modified lines.
- [X] **Do not leave space/tab-only empty lines**: Ensure all empty lines have zero trailing whitespace to avoid gitreview red flags.
- [X] **Do not hardcode corpus counts**: Dynamic baseline calculations mandatory for entity counts.
- [X] **Do not leak resources or subprocesses**: Guarantee deterministic deallocation of handles and processes.
- [X] **Do not skip Principal Coding Engineer Pre-Review**: Always execute adversarial review before delivery.
