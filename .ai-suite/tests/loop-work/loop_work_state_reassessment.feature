Feature: Loop-Work Iterative State Reassessment and Structured State Logging
  As an AI Agent orchestrating iterative tasks with loop-work
  I want each iteration to reassess the current state against the goal, customize a new plan, execute task X, and log detailed structured state
  So that multi-iteration execution achieves progressive refinement and high-quality goal attainment.

  Scenario: Goal alignment across every iteration
    Given a user requests a task with "use loop-work skill to loop N times to do task X"
    When the loop-work skill initializes and executes each iteration from 1 to N
    Then the overarching goal of task X must be explicitly established as the goal of each individual iteration
    And the agent must not substitute or drift the goal into disconnected sub-tasks.

  Scenario: Iterative state reassessment, custom planning, and progressive enhancement
    Given the agent begins iteration i of N
    When the agent evaluates the artifact and prior iteration results
    Then the agent must reassess the current state against the original goal
    And the agent must customize a new execution plan addressing remaining gaps or opportunities for hardening
    And the agent must re-run task X on the full target using the customized plan
    And after the iteration completes, the validated result must better achieve the goal than the previous iteration.

  Scenario: Structured state logging in .loop_state.md
    Given an iteration i completes its execution and validation
    When the agent updates the state tracking file ".loop_state.md"
    Then the agent must append an entry containing:
      | Field                    | Content Description                                                     |
      | Goal                     | The overarching goal of task X                                         |
      | Current State Assessment | Reassessment of current state and gaps before this iteration          |
      | Customized Plan          | Tailored execution plan formulated for this iteration                  |
      | What                     | What was accomplished and modified during this iteration               |
      | Why                      | Technical reasoning and rationale for the actions taken                |
      | How                      | Specific execution methods, tools, and implementation details           |
      | Special Notes            | Caveats, edge cases, safety constraints, observations, lessons learned |
      | Status & Quality         | Execution status and measured improvement toward the goal              |

  Scenario: High-quality goal convergence upon completion of all iterations
    Given all N iterations have concluded (or verified 100% defect-free convergence reached)
    When the final summary is assembled
    Then the final deliverable must represent a high-quality, fully verified achievement of the goal
    And the agent must preserve the isolation principle and self-evolution mechanisms of the AI suite
    And the agent must verify results using AI agent LLM thinking and cognitive self-evaluation.
