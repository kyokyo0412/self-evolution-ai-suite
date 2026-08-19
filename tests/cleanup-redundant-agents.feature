Feature: Cleanup Redundant Agent Configurations
  As an AI Suite Developer
  I want to clean up redundant agent configurations like .roo, .continue, .opencode, and .claude
  So that the AI suite source repository remains clean and isolated from generated artifacts
  While preserving the .cursor directory for the developing agent.

  Scenario: Remove redundant agent configuration directories
    Given the AI suite source repository contains redundant agent directories
    When the cleanup process is executed
    Then the directories .roo, .continue, .opencode, and .claude must be removed
    And the .cursor directory must be preserved
    And the CLAUDE.md file must be removed if it exists
