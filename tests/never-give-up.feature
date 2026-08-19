Feature: Never-Give-Up Spirit and Production Safety
  As an AI Suite Agent user
  I want the agent to persist on a task when explicitly instructed not to give up
  So that it exhausts all possible solutions and makes repeated attempts to complete the task
  While strictly adhering to the prohibition against damaging the production environment.

  Scenario: Agent persists when instructed not to give up
    Given an AI Suite Agent is executing a task
    And the user explicitly instructs the agent "not to give up"
    When the agent encounters failures or roadblocks
    Then the agent must persist and make repeated attempts
    And exhaust all possible solutions and alternative approaches
    And continue until the task is successfully completed

  Scenario: Agent strictly protects the production environment during persistent attempts
    Given the agent is in a persistent "never-give-up" loop
    When the agent explores alternative approaches or executes commands
    Then it must absolutely prohibit any actions that could damage the production environment
    And adhere strictly to production safety guardrails

  Scenario: Agent runs in normal mode when not explicitly instructed
    Given an AI Suite Agent is executing a task
    And the user does not explicitly instruct the agent "not to give up"
    When the agent encounters failures or roadblocks
    Then it should run as normal mode
