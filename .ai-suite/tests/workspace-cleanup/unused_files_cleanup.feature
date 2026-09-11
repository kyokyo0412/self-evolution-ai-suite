Feature: Workspace Cleanup - Unused Files
  As an AI Agent
  I want a rule that enforces the cleanup of unused files after a task is done
  So that the workspace remains clean and free of deprecated or redundant files.

  Scenario: Agent cleans up unused files after task completion
    Given the agent has completed the main implementation of a task
    When the agent prepares to close the task
    Then the agent MUST actively identify any unused files, deprecated code, or redundant assets
    And the agent MUST delete these unused files before considering the task complete.
