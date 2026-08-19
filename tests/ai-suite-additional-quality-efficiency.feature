Feature: Additional AI Suite Performance and Quality Improvement
  As an AI-Suite Architect
  I want to improve the autonomous-team and automated-code-reviewer skills
  So that any AI agent installed with this suite achieves better product development quality and highly efficient AI performance

  Scenario: Autonomous Team explicitly enforces parallel tool execution and linter checks
    Given the "autonomous-team" skill file exists
    When I review the core directives
    Then it should contain a directive to "Maximize parallel tool calls"
    And it should contain a directive to run "linter checks" using ReadLints or similar tools after implementation

  Scenario: Automated Code Reviewer explicitly enforces parallel tool execution and linter checks
    Given the "automated-code-reviewer" skill file exists
    When I review its core responsibilities
    Then it should instruct the reviewer to use "parallel tool calls" for efficiency
    And it should instruct the reviewer to use "linter checks" or "ReadLints" to verify product quality
