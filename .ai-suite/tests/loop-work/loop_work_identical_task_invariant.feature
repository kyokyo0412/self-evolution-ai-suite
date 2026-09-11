Feature: Loop-Work Identical Full Task Iteration Invariant
  As an AI Agent using the AI Suite
  I want the loop-work skill to repeat the exact same complete task target across all iterations
  So that the entire target artifact is thoroughly and repeatedly analyzed, verified, and refined without being partitioned across iterations.

  Scenario: Execution of identical complete task target without partitioning
    Given a user invokes loop-work with "use loop-work skill to loop 100 times to use tdd-team skill to review file A and fix bugs"
    When the agent initializes and executes the loop-work workflow
    Then every iteration from 1 to 100 must have the exact same complete task target (File A in its entirety)
    And each iteration must execute the target skill across all review aspects and dimensions (pointer safety, boundary conditions, error handling, concurrency, performance, etc.)
    And the agent must NOT split File A into 100 sub-parts or chunks across iterations
    And the agent must NOT split the review into 100 aspects where each iteration only examines one aspect
    And the agent must NOT spread workflow phases across iterations

  Scenario: Iterative full-target bug fixing and progressive refinement
    Given the agent is running iteration i of N on a complete target file or codebase
    When the target skill discovers bugs or flaws during that iteration
    Then the agent must fix those bugs completely within that iteration
    And the next iteration i+1 must re-review and re-verify the full target artifact from beginning to end
    And the validation in Step 2 must evaluate the full original goal using LLM reasoning
    And the agent must apply cognitive self-evaluation checks to ensure no dimensional or spatial drift occurred

  Scenario: Strict negative constraints against task target decomposition
    Given any multi-iteration loop-work prompt
    Then the agent is strictly prohibited from decomposing the primary target into sub-tasks per loop
    And the agent is strictly prohibited from partitioning scope, files, or verification categories across iterations
    And each iteration must be a standalone, full-scope execution of the specified skill
    And the execution must strictly preserve AI Suite self-evolution mechanisms and isolation principles
