# Interactive Workflow Interface Contracts & State Machine Specification

## 1. Architectural Model

The Cursor Interactive Workflow is a zero-cost collaborative wrapper that enables continuous iterative development across multiple turns within a single Cursor session without consuming extra prompt request allocations.

### State Transition Diagram

```
[Session Start: Initial User Prompt]
                |
                v
  +-------------------------------+
  | Step 0: INITIALIZATION        |
  | (AskQuestion for interactive) |
  +---------------+---------------+
                  |
        +---------+---------+
      [yes]               [no]
        |                   |
        v                   v
+-------------------+ +-------------------+
| INTERACTIVE = TRUE| |INTERACTIVE = FALSE|
+---------+---------+ +---------+---------+
          |                     |
          v                     v
+-------------------+ +-------------------+
| Step 1: EXECUTE   | | Normal Execution  |
| (Active Task)     | | (Standard mode)   |
+---------+---------+ +---------+---------+
          |                     |
          v                     v
+-------------------+      [Turn End]
| Step 2: WRAP-UP   |
| (Summary + echo)  |
+---------+---------+
          |
          v
+-------------------+
| Step 3: FOLLOW-UP |
| (AskQuestion)     |
+---------+---------+
          |
    +-----+---------------------+
    |     |                     |
[complete]|             [Other (New Task)]
    |  [explain]                |
    v     |                     v
 [Stop]   |            +--------------------+
    ^     |            | Skip Step 0        |
    |     |            | Set Active Task    |
    |     |            | INTERACTIVE = TRUE |
    |     |            +--------+-----------+
    |     |                     |
    |     v                     |
    |  (Provide explanation)    |
    |     |                     |
    |     +---------> Step 3    |
    |                           v
    +----------------------- Step 1 (Execute Task)
```

## 2. Invariants & Guarantees

1. **Persistent Session Invariant**:
   Once interactive workflow is enabled (`INTERACTIVE = TRUE`) in Step 0, the interactive lifecycle MUST govern ALL subsequent tasks in the conversation session until the user explicitly selects `complete` or triggers the Reflection Protocol.

2. **Every Iteration Execution Cycle**:
   Every task iteration -- whether the initial task or any subsequent task submitted through the "Other" option -- MUST execute the complete 3-step cycle:
   - **Step 1**: Execute the active task normally in Daemon Mode until 100% complete and verified.
   - **Step 2**: Output the full execution summary in conversational chat text, followed by `echo 'Interactive workflow summary rendered'`.
   - **Step 3**: Call `AskQuestion` with the follow-up prompt and options (`complete`, `explain`, `Other`).

3. **Re-entry Contract (Skip Step 0)**:
   When handling a follow-up task received via the "Other" option of `AskQuestion`, Step 0 is NOT re-prompted because the interactive workflow is already active. The agent transitions immediately to Step 1 for the new task.

4. **Negative Constraint: Mandatory AskQuestion**:
   The agent is **strictly forbidden** from terminating its turn or finishing execution after completing an "Other" task without executing Step 2 and calling `AskQuestion` in Step 3.

5. **No Extra Cost Guarantee**:
   The wrapper uses native UI questions and single-turn continuous chaining to prevent consuming additional included user quota.
