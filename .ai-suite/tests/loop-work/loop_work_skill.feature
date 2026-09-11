Feature: Loop Work Skill for Iterative Execution
  As an AI agent user
  I want to use a loop-work skill to run a task for multiple iterations with a specified skill
  So that the agent can iteratively improve and achieve the goal with a "never give up" spirit

  Scenario: User requests to loop a task multiple times
    Given the user prompt is "loop-work 3 times to use tdd-team skill to build a calculator"
    When the loop-work skill is triggered
    Then the agent should understand it needs to run up to 3 iterations
    And for each iteration, it should invoke the "tdd-team" skill
    And after the skill execution, it should use LLM reasoning to validate the result
    And it should output detailed iteration results in the chat
    And if the result is not perfect, it should design improvements for the next iteration
    And it should continue to the next iteration until success or the max iterations are reached
    And the loop-work execution must not break the self-evolution for the AI suite
    And the loop-work execution must not break the isolation principle of AI suite
