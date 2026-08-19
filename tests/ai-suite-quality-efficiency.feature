Feature: AI Suite Performance and Quality Improvement
  As an AI-Suite Architect
  I want to improve the ai-expert and tdd-team skills
  So that any AI agent installed with this suite achieves better product development quality and highly efficient AI performance

  Scenario: TDD Team explicitly enforces parallel tool execution and linter checks
    Given the "tdd-team" skill file exists
    When I review the core directives
    Then it should contain a directive to "Maximize parallel tool calls"
    And it should contain a directive to run "linter checks" using ReadLints or similar tools after implementation

  Scenario: AI Expert prompts include efficiency and quality constraints
    Given the "ai-expert" skill file exists
    When I review its core responsibilities
    Then it should instruct the AI Expert to embed "efficiency" constraints like parallel tool calls in optimized prompts
    And it should instruct the AI Expert to embed "quality" constraints like linter checks or tests in optimized prompts
