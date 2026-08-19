Feature: AI Suite Memory System V2 (Search and Summary)
  As an AI agent in the AI Suite
  I want to be able to summarize and search my memory
  So that I can easily discover what context I have stored and find specific information quickly

  Scenario: Memory Summary
    Given the memory system is initialized for agent "test_agent"
    And I have saved a layer "architecture" with content "Microservices"
    And I have saved a task "123" with content "Setup DB"
    When I run the memory summary command for "test_agent"
    Then it should output a list of available memory layers
    And it should output a list of available tasks
    And it should indicate if timeline or important memory exists

  Scenario: Memory Search
    Given the memory system is initialized for agent "test_agent"
    And I have saved a layer "architecture" with content "System uses Postgres DB"
    And I have saved a task "123" with content "Migrated DB to Postgres"
    When I search the memory for "Postgres" using "test_agent"
    Then the search results should include the "architecture" layer
    And the search results should include the "123" task

  Scenario: Prompt Advertising
    Given the AI suite generates the markdown block for the agent
    When the agent name is provided
    Then the generated markdown should instruct the agent to use `ai_memory_summary` to discover available memory
    And it should instruct the agent to use `ai_memory_search` to find specific keywords
