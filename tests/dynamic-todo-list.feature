Feature: Dynamic Todo-List Support in Development Processes
  As an AI agent using tdd-team or autonomous-team
  I want the process to support dynamic todo-list updates
  So that when issues are found, the todo-list can be updated and execution continues seamlessly

  Scenario: tdd-team.md includes dynamic todo-list instructions
    Given the file ".ai-suite/layer3-registry/core/tdd-team.md" exists
    Then the file should contain instructions for dynamic todo-list updates
    And it should specify that if issues are found, the todo-list should be updated
    And it should specify that the process will continue running the new todo-list

  Scenario: autonomous-team.md includes dynamic todo-list instructions
    Given the file ".ai-suite/layer3-registry/core/autonomous-team.md" exists
    Then the file should contain instructions for dynamic todo-list updates
    And it should specify that if issues are found, the todo-list should be updated
    And it should specify that the process will continue running the new todo-list
