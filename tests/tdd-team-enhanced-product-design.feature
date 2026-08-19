Feature: Enhanced TDD Team Product Design Phase
  As an AI Suite PM
  I want to review legacy features and iteratively debate design tradeoffs
  So that the requirements are of higher quality before the team starts development

  Scenario: TDD Team process explicitly requires legacy review and simulated PM discussions
    Given the tdd-team skill is executed
    When the agent starts Phase 1
    Then the process must include "Product Discovery & Legacy Review"
    And it must require the PM to "review legacy features"
    And it must require the PM to engage in "simulated discussion" or "multiple PM perspectives" to debate tradeoffs
    And the process must enforce "multiple iterations" during the product design stage
