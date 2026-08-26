Feature: Interactive Workflow Execution Summary and Confirmation
  In order to ensure that users see the completed main task output and the agent correctly confirms completion before asking for new tasks
  As an AI agent user
  I want the interactive workflow rule to mandate that the agent waits for the task to finish, prints all output, double confirms the task is done, and continuously loops with AskQuestion after every task iteration

  Scenario: Show chat output before AskQuestion
    Given the cursor agent is executing the interactive workflow
    When the active task is done
    Then the agent MUST explicitly output all step outputs and final results in the chat window text
    And the agent MUST NOT use the AskQuestion tool until the chat text is fully generated

  Scenario: Wait for completion and double confirm before AskQuestion
    Given the cursor agent is using the interactive-workflow rule
    When the user selects yes to enable the interactive workflow
    Then the agent MUST wait until the current task is 100% complete
    And the agent MUST print all output of the active task in the chat window
    And the agent MUST double confirm that the active task is done
    And ONLY after that double confirmation, the agent is allowed to use the AskQuestion tool to ask the next new task

  Scenario: Process extra prompts as new tasks and continue the interactive loop
    Given the cursor agent is in the interactive workflow loop
    When the user provides a custom text input via the "Other" option
    Then the agent MUST treat this as a NEW TASK
    And the agent MUST execute the required actions to fully complete the user's request
    And after the new task is complete, the agent MUST output the task execution summary
    And the agent MUST execute Step 2 with the summary output marker
    And the agent MUST call the AskQuestion tool in Step 3 to continue the interactive loop

  Scenario: Persistent Multi-Turn Interactive Workflow Loop
    Given the user enabled the interactive workflow at Step 0
    When multiple consecutive tasks are submitted via the "Other" option in AskQuestion
    Then for every completed task iteration the agent MUST execute Step 2 and Step 3
    And the agent MUST NOT terminate the turn without invoking the AskQuestion tool unless the user chooses complete or reflection
