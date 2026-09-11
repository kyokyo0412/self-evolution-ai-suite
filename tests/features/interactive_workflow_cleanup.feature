Feature: Interactive Workflow Active Task Workspace Cleanup and File List Inspection
  In order to ensure that workspaces remain clean and unpolluted across interactive workflows and loop-work tasks
  As an AI agent user
  I want the interactive workflow and directives to mandate that the active task removes all unused and temporary files before processing AskQuestion
  And I want the AI agent to actively inspect the file list to detect and remove temporary or unused files

  Scenario: Active task removes unused and temporary files before AskQuestion
    Given the AI agent is executing an active task within the interactive workflow
    When the active task has finished its core execution and before transitioning to AskQuestion
    Then the active task MUST clean up all unused and temporary files generated during execution
    And the agent MUST process the AskQuestion tool only after the cleanup is verified complete

  Scenario: AI agent inspects file list to detect and remove temporary files
    Given an active task has generated temporary, scratch, or intermediate files
    When the AI agent prepares to wrap up the active task
    Then the AI agent MUST check the file list using git status or directory inspection
    And the AI agent MUST remove the temporary or unused files identified in the file list
    And the AI agent MUST verify the workspace is free of residual artifacts before wrap-up

  Scenario: Loop-work cleans up iteration artifacts before AskQuestion
    Given the AI agent is running an iterative loop-work workflow
    When all N iterations of the loop are complete
    Then the AI agent MUST check the workspace file list to detect leftover iteration files
    And the AI agent MUST remove all unused or temporary files from all iterations
    And the AI agent MUST execute the final summary and UI echo before invoking the AskQuestion tool

  Scenario: Negative constraint against calling AskQuestion with uncleaned temporary files
    Given temporary or unused files remain in the workspace after task execution
    When the AI agent considers advancing to the wrap-up question
    Then the AI agent MUST NOT call the AskQuestion tool while temporary or unused files exist
    And the AI agent MUST NOT skip the mandatory file list inspection
