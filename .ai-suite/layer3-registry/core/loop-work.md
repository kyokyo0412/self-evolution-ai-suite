---
name: loop-work
description: Execute exactly the requested number of complete skill iterations with progressive hardening and state logging. Use when the user explicitly requests N repeated executions or invokes loop-work.
triggers:
  - loop-work
  - loop skill
---
# Loop-Work -- Explicit Iterative Execution

## Inputs and authority

Resolve the selected skill, complete target, unchanged goal, and a positive integer N from the request. Do not invent N when the requested iteration count is absent, zero, negative, or ambiguous; clarify that input while doing independent context gathering. Preserve the user's resource budgets, cancellation, and approval boundaries. A discovered skill's availability is not authorization to execute unrelated work.

## Core Directives

1. Preserve the same goal and complete target for every iteration; do not partition the target or review dimensions.
2. Execute all N requested iterations. Never exit early on convergence. A user cancellation, changed scope, unavailable required approval, or unsafe action takes precedence; report completed and remaining iterations honestly.
3. Keep a numbered state log in `.loop_state.md` with the iteration plan, actual changes, commands, outcomes, and unresolved items.
4. Give concise decision summaries, progress, and observed evidence. Do not request private chain-of-thought or repeat internal deliberation.

## Execution Protocol

For each iteration i from 1 through N:
1. Reassess the complete target and all applicable hardening dimensions.
   In every iteration inspect applicable behavior, failure handling, security, resource/performance bounds, and maintainability; retain complete target scope.
2. Invoke the selected skill and resolve verified defects within that iteration.
3. Run relevant checks and append actual outcomes to the state log.
4. Continue directly in the current session when possible. Use a supported continuation or scheduler only when available; never assume a background sleeper, sentinel, or agent-specific tool can resume the task.
5. When the current context must end, preserve a continuation checkpoint with completed i, remaining N-i, target, checks, and next action. Do not claim unfinished iterations completed.
6. **Step 7: Summary**: After N completed iterations, output the full multi-iteration summary in chat with goal achievement, state progression, hardening outcomes, and verification limits. Check `git status --porcelain` and remove only task-created temporary files.

If the current environment is Cursor and its separate interactive workflow is explicitly active, follow its supported summary/question sequence after completing N. Other agents use their available user-input tool or an ordinary chat response; never require AskQuestion outside Cursor.

Count an iteration only after the selected workflow's required work and checks are complete. If a failed required check or external blocker remains, record the current iteration as incomplete. Preserve the completed count k and remaining N-k, including that incomplete iteration, and resume only when its dependency is resolved. Reassessment must respect finite attempt/time budgets; a loop request never requires repeatedly running a known unsafe or inaccessible action. An explicit Reflection request interrupts the loop for that request; preserve the checkpoint without claiming the remaining iterations ran.

## Negative Constraints (Must NOT)

- [X] Do not trigger an early exit before completing all N requested iterations merely because the goal appears satisfied.
- [X] Do not alter the goal, split the target into sub-parts, or rotate review dimensions across iterations.
- [X] Do not invent unavailable tools, background continuation, approvals, or iteration results.
- [X] Do not substitute an inner skill Phase 5 report as the final complete multi-iteration summary.
- [X] Do not impose Cursor's interactive workflow on another agent or override session safety and no-commit rules.
