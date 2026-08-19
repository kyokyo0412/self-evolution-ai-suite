Feature: Auto-Evolution Directive
  As an AI Suite user
  I want the AI agent to automatically trigger self-reflection
  So that evolution is continuous and not reliant on manual user prompts

  Scenario: Adapter injects Auto-Evolution directive
    Given the AI suite is enabled for an agent
    When the adapter script runs
    Then the resulting agent config file must contain "Auto-Evolution Directive"
    And it must instruct the agent to automatically execute the Reflection Protocol after complex tasks
