Feature: Interactive Workflow Execution Summary and Confirmation
  In order to ensure that users see the completed main task output and the agent correctly confirms completion before asking for new tasks
  As an AI agent user
  I want the interactive workflow rule to mandate that the agent waits for the main task to finish, prints all output, and double confirms the task is done before invoking the AskQuestion tool

  Scenario: Show chat output before AskQuestion
    Given the cursor agent is executing the interactive workflow
    When the main task is done
    Then the agent MUST explicitly output all step outputs and final results in the chat window text
    And the agent MUST NOT use the AskQuestion tool until the chat text is fully generated

  Scenario: Wait for completion and double confirm before AskQuestion
    Given the cursor agent is using the interactive-workflow rule
    When the user selects yes to enable the interactive workflow
    Then the agent MUST wait until the main task is 100% complete
    And the agent MUST print all output of the main task in the chat window
    And the agent MUST double confirm that the main task is done
    And ONLY after that double confirmation, the agent is allowed to use the AskQuestion tool to ask the next new task

  Scenario: Process extra prompts as new tasks
    Given the cursor agent is in the interactive workflow loop
    When the user provides a custom text input via the "Other" option
    Then the agent MUST treat this as a NEW TASK
    And the agent MUST execute the required actions to fully complete the user's request
    And the agent MUST NOT simply think about it without processing it carefully