Feature: Interactive Workflow Rule Enhancements
  As a Cursor user
  I want the interactive workflow rule to be stable, persistent, and reliable
  So that I can refine my tasks without consuming extra requests, while every task iteration runs normally.

  Scenario: Agent reliably asks to enable interactive workflow at start
    Given the user issues a new task
    When the Agent begins processing the initial prompt
    Then the Agent MUST immediately call the `AskQuestion` tool to ask if interactive workflow is needed
    And the Agent MUST NOT execute any state-changing tools before the user answers

  Scenario: Agent executes the active task normally when enabled
    Given the user selected "Yes" for interactive workflow
    When the Agent executes the current task
    Then the Agent MUST follow the task prompt exactly as if the interactive workflow rule did not exist
    And the execution MUST NOT be influenced or made abnormal by the interactive workflow wrapper

  Scenario: Agent completes the task and outputs summary before asking the follow-up question
    Given the active task is 100% complete
    When the Agent prepares to ask the follow-up question
    Then the Agent MUST first output the complete execution summary
    And the Agent MUST call `echo 'Interactive workflow summary rendered'` to force UI rendering
    And the Agent MUST wait for the tool call to return
    And ONLY THEN in the next response call the `AskQuestion` tool
    And the Agent MUST NOT ask the follow-up question before the task is fully complete

  Scenario: Agent persistently loops for follow-up prompts across all iterations
    Given the interactive workflow is active and a task iteration is complete
    When the user provides a custom prompt via the "Other" option
    Then the Agent MUST treat it as a new active task
    And the Agent MUST NOT re-prompt Step 0 since interactive workflow is already active
    And the Agent MUST execute the new task fully in Step 1
    And upon completion the Agent MUST execute Step 2 summary wrap-up
    And the Agent MUST execute Step 3 and call the `AskQuestion` tool again
    And the Agent MUST NOT end its turn or stop without invoking `AskQuestion`
