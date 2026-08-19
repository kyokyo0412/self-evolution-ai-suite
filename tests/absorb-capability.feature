Feature: Absorb capability from external agent

  Background:
    Given the AI suite is installed to the local AI agent, making it an AI suite Agent
    And the AI suite Agent has a skill called absorb-capability

  Scenario: AI suite Agent absorbs external Agent
    When the user says "Absorb agent from user@host at /path/to/.cursor"
    Then the AI suite Agent fetches the external Agent configuration to a local sandbox
    And the AI suite Agent semantically analyzes the external Agent capabilities against its own capabilities based on file content comparison
    And the AI suite Agent merges the new capabilities into its own configuration (e.g., ~/.cursor/skills/)
    And the AI suite Agent does NOT modify the .ai-suite/ directory if it is not developing the AI suite

  Scenario: AI suite developing agent absorbs external Agent
    Given the AI suite Agent is currently developing the AI suite project (i.e., .ai-suite/ exists in the workspace)
    When the user says "Absorb agent from user@host at /path/to/.cursor"
    Then the AI suite developing agent fetches the external Agent configuration to a local sandbox
    And the AI suite developing agent merges the new capabilities into its own configuration (e.g., ~/.cursor/skills/)
    And the AI suite developing agent ALSO merges the new capabilities into the developing AI suite source code (.ai-suite/)
