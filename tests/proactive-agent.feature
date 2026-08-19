Feature: Proactive Agent Issue Resolution Loop
  As an AI Suite Agent user
  I want the agent to proactively analyze, resolve, and iterate on issues autonomously
  So that problems are solved completely without requiring my constant intervention, while not breaking existing mechanisms.

  Scenario: Agent encounters an issue and iteratively resolves it
    Given an AI Suite Agent is installed and functioning
    When the agent encounters an issue or is given a problem to resolve
    Then the agent should analyze the environment and the problem
    And devise a solution strategy
    And attempt to implement the solution
    And if the initial attempt fails, it should explore alternative approaches from various angles
    And iteratively test and action until the problem is resolved
    And report the details of the final resolution

  Scenario: Proactive resolution must not compromise existing mechanisms
    Given the agent is in a proactive resolution loop
    When the agent explores alternative approaches or modifies configurations
    Then it must ensure existing AI Suite mechanisms, like the evolution system, remain functional and untouched
