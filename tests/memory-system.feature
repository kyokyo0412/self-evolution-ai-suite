Feature: AI Suite Memory System
  As a user of the AI Suite
  I want the AI agents to have a persistent memory system
  So that they can remember context, rules, tasks, and project index across long sessions and multiple tasks.

  Scenario: Memory isolation and structure
    Given the AI suite is initialized
    Then the memory system should store files isolated from the project codes
    And the memory should be isolated between different AI suite agents (e.g., cursor, claude)

  Scenario: Layered index memory for project review
    Given the AI agent is reviewing the project
    When it constructs an index memory
    Then the index memory should be layered from high to low levels
    And it should be stored in multiple files
    And the agent should be able to load the high-level index first, then the next level

  Scenario: Time-sorted task memory
    Given the AI agent is processing tasks
    When it completes a task
    Then it should store a memory of the task sorted by time
    And it should be able to review this time memory to understand past actions

  Scenario: Memory correction and masking
    Given the AI agent is handling a task
    When it finds the memory is incorrect with the current project
    Then it should fix the memory with the new facts
    When the user wants to mask the memory temporarily
    Then the agent should be able to run the task without the masked memory
    When the user wants to clean the memory
    Then the agent should be able to clear the memory files

  Scenario: Evolution with or without memory
    Given the AI suite has memory files
    When the user pushes or pulls evolution
    Then it should be possible to include or exclude the memory files
Feature: AI Suite Memory System Enhancements
  As an AI suite agent
  I want to have important memory, layered memory, and timeline memory
  So that I can remember long sessions, understand projects better, and have a human-like timeline

  Scenario: Important Memory
    Given the memory system is initialized for agent "test_agent"
    When I save important memory "Always check production safety"
    Then I should be able to load the important memory and see "Always check production safety"

  Scenario: Layered Memory
    Given the memory system is initialized for agent "test_agent"
    When I save layered memory "architecture" with content "System is microservices"
    And I save layered memory "components" with content "Auth, DB, API"
    Then I should be able to list the memory layers and see "architecture" and "components"
    And I should be able to load the layered memory "architecture" and see "System is microservices"

  Scenario: Timeline Memory
    Given the memory system is initialized for agent "test_agent"
    When I append to timeline "Started the task"
    And I append to timeline "Analyzed the codebase"
    Then I should be able to read the timeline and see both events in chronological order
