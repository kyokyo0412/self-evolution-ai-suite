Feature: Loop-Work Full Iteration Enforcement and Non-Premature Exit
  As an AI Agent orchestrating iterative tasks with loop-work
  I want the loop-work skill to strictly execute all N iterations requested by the user without premature exit
  So that deep progressive hardening, mutation analysis, formal boundary fuzzing, and cumulative verification are guaranteed across the entire iteration count.

  Scenario: Strict mandatory iteration count execution without early exit
    Given a user requests a task with "use loop-work skill to loop 100 times to use tdd-team skill to review file A and fix bugs"
    When the loop-work skill initializes and executes each iteration
    Then the agent must treat N=100 as a strict mandatory loop count
    And the agent is strictly forbidden from triggering an early exit based on premature convergence or 100% defect-free assumptions
    And each iteration from 1 to 100 must execute on the entire target artifact.

  Scenario: Autonomous background continuation chaining
    Given the agent completes iteration i where i < N
    When the iteration report is outputted and logged to .loop_state.md
    Then the agent must not end the turn or pause for user input
    And the agent must immediately chain into iteration i+1 using the background sleep notification command
    And the agent must set block_until_ms: 0 and configure notify_on_output matching "^AGENT_LOOP_WAKE_loop_work".

  Scenario: Progressive deepening and cumulative hardening roadmap
    Given the agent is executing an extended loop of N iterations
    When executing any iteration from 1 to N
    Then every iteration must evaluate the complete multi-dimensional hardening envelope simultaneously:
      | Hardening Dimension | Scope Evaluated on Every Iteration                                                     |
      | Baseline Correctness| Core logic, nil/null safety, pointer validation, defensive bounds, static lint checks   |
      | Concurrency & Race  | Thread contention, mutex synchronization, atomic ops, deadlock-free lock ordering      |
      | Chaos & Faults      | Extreme boundaries, malformed inputs, truncated streams, timeout recovery, fault loops |
      | Resource & 1E Safety| Zero dynamic leaks, deterministic runtime, bounded recursion, fail-safe fallbacks     |
      | Mutation & Invariant| Mutation resistance, schema contracts, >98% coverage, non-regression verification     |
    And multiple iterations must deepen cumulative verification rigor across orders of emergence:
      | Iteration Order | Emergent Verification Depth                                                          |
      | Order-1 (Single)| Primary defect detection & immediate remediation across all dimensions               |
      | Order-2 (Multi) | Cross-module interaction defects & secondary bugs unmasked by earlier modifications  |
      | Order-3 (Deep)  | High-entropy combinatorial chaos, adversarial fault loops, and mutation survival      |
      | Order-N (Final) | Mathematical invariance, formal zero-defect proof, and 100% regression closure       |

  Scenario: Isolation from Interactive Workflow State 2/3 until all N iterations complete
    Given the interactive-workflow wrapper is active
    When loop-work is running iteration i where i < N
    Then the agent is strictly forbidden from outputting the final task summary or calling AskQuestion
    And the agent must only transition to State 2 and State 3 after iteration N is 100% completed.
