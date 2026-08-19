Feature: Agent Directives
  In order to enforce general rules for the AI suite
  As a PM
  I want the AI agent to adhere to specific general directives and have them deployed

  Background:
    Given the AI suite is enabled
    And the configuration deploys rules to ".cursor/rules"

  Scenario: Deploying Agent Directives
    When the suite is installed
    Then the agent directives MUST be deployed as ".cursor/rules/cursor-suite-agent-directives.mdc"
    And the agent directives MUST include a rule to leave git commit to the user
    And the agent directives MUST include a rule to provide a summary upon completing any task
    And the agent directives MUST include a rule that the summary report follows the normal report specified by the skills
    And the agent directives MUST include a rule that multiple skills can be invoked together without skipping steps
    And the agent directives MUST include a rule that every task must be backed by actual verification
