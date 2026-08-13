Feature: Agent Directives Enhancement
  As a user of the AI suite
  I want the AI agent to never run git commit and always clean up temporary files
  So that my repository history and workspace remain clean and under my control

  Scenario: Agent directives contain strict negative constraints
    Given the agent directives file ".ai-suite/layer3-registry/directives/agent-directives.md" exists
    When I check the directives file
    Then it should contain a "Negative Constraints (Must NOT)" section
    And it should explicitly forbid running "git commit"
    And it should explicitly forbid leaving temporary files
