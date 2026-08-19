Feature: TDD Team Process Review Enhancement
  As a PM and Architect in the TDD Team
  I want the Agent and the team to review the process, tasks, rules, and constraints for each step
  So that the product quality is improved and the goals are correctly met

  Scenario: Agent reviews the tdd-team skill process
    Given the tdd-team skill is invoked
    When the Agent starts the process
    Then the Agent MUST review the tdd-team skill to ensure the process is correct before proceeding

  Scenario: Team reviews tasks, rules, and constraints for each step
    Given the tdd-team is executing a phase
    When the phase begins
    Then the team MUST review the tasks, rules, and constraints for that step
    And ensure the tasks and goals are correct before implementation
