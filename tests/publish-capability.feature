Feature: Publish AI suite capability

  Background:
    Given the AI suite is installed to the local AI agent, making it an AI suite Agent
    And the AI suite Agent has a skill called publish-capability

  Scenario: AI suite Agent publishes its capabilities
    When the user says "Publish my capabilities"
    Then the AI suite Agent triggers the publish-capability skill
    And the AI suite Agent packages its own capabilities (e.g., ~/.cursor/skills/ and ~/.cursor/meta/) into an AI suite publish package
    And the publish package can be distributed to other agents
