Feature: Loop-Work Skill Enhancements
  As an AI Agent
  I want the loop-work skill to correctly loop through iterations without stopping prematurely, evaluate against the original goal, and not split the goal into sub-tasks
  So that I can achieve the highest quality output through iterative refinement of the entire task.

  Scenario: Loop-work does not split the goal
    Given the loop-work skill is invoked with a goal
    When the agent executes the first iteration
    Then the agent must attempt the FULL original goal
    And subsequent iterations must refine the output of the full goal, not execute a sub-task.

  Scenario: Loop-work evaluates against the original goal
    Given the agent has completed an iteration
    When the agent validates the result
    Then the validation must be performed against the ORIGINAL input task goal
    And the agent must design improvements to get closer to the original goal.

  Scenario: Loop-work does not stop before task is done
    Given the agent is executing a target skill within loop-work
    When the target skill completes its execution
    Then the agent must explicitly return to the loop-work Execution Protocol
    And the agent must execute the Continuation Protocol to trigger the next iteration unless the task is perfectly achieved or max iterations reached.
