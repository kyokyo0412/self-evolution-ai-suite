Feature: Enhance TDD Team Skill with Prompt Alignment Review and Detailed Output

  Scenario: TDD Team process includes prompt alignment review at each stage
    Given the TDD Team skill is executed
    When the Principal Engineer reviews a stage output
    Then the Principal Engineer must verify the output aligns with the user input prompt
    And if it does not align, the team must loop back to redo the stage

  Scenario: TDD Team output includes detailed explanations
    Given the TDD Team skill is in Phase 5 Project Closure
    When the Technical Writer and PM emit the final report
    Then the report must include a detailed explanation of what was done, how it was done, and why
    And the report must point out important notes and what the user should know
