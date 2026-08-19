Feature: Generalize AI Suite for broad development and multiple agents

  Scenario: Remove CustomDomain specific domain constraints
    Given the AI suite is installed
    When I configure the suite for general software development
    Then the suite should not contain CustomDomain specific domain skills
    And the framework should remain functional for self-evolution

  Scenario: Add support for OpenCode, Continue, and Roo Code agents
    Given the AI suite supports Cursor and Claude Code
    When I add adapters for OpenCode, VS Code Continue, and VS Code Roo Code
    Then the suite should successfully validate the new agent adapters
    And the README should reflect the multi-agent and general software support
