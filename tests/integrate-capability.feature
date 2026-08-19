Feature: Integrate capability to external agent

  Background:
    Given the AI suite is installed to the local AI agent, making it an AI suite Agent
    And the AI suite Agent has a skill called integrate-capability

  Scenario: AI suite Agent integrates capabilities to external Agent
    When the user says "Integrate ai suite to user@host at /path/to/.cursor"
    Then the AI suite Agent fetches the external Agent configuration to a local sandbox
    And the AI suite Agent semantically analyzes its own capabilities (e.g., ~/.cursor/skills/) against the external Agent capabilities based on file content comparison
    And the AI suite Agent pushes its capabilities to the external Agent
    And the external Agent is transformed into a new AI suite Agent
