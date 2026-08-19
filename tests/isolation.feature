Feature: AI Suite Source Code Isolation
  As an AI suite developer
  I want the AI suite source code to be strictly isolated from the Host Agent configuration
  So that integrating or absorbing capabilities does not mix source code with the developing agent's runtime state, and no autonomous git commits occur.

  Scenario: Integrate capability from AI suite developing agent
    Given the agent is an AI suite developing agent (workspace contains ".ai-suite/")
    When the user triggers "integrate ai suite"
    Then the agent should source its capabilities ONLY from the AI suite source code (e.g., ".ai-suite/")
    And the agent should NOT include any items from the Host agent configuration (e.g., ".cursor/", ".continue/")

  Scenario: Absorb capability into AI suite developing agent
    Given the agent is an AI suite developing agent (workspace contains ".ai-suite/")
    When the user triggers "absorb capability"
    Then the agent should merge the new capabilities ONLY into the AI suite source code (e.g., ".ai-suite/")
    And the agent should NOT impact or modify any items in the Host agent configuration (e.g., ".cursor/", ".continue/")

  Scenario: Never autonomously git commit
    Given any AI suite workflow or skill
    When the agent completes a task or evolution
    Then the agent must NEVER autonomously execute "git commit"
    And the agent must provide copy-paste git commands for the user to execute manually
