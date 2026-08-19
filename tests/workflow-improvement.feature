Feature: Streamlined AI Suite Workflow
  As a developer using the ai-suite
  I want a simplified, unified workflow for evolution, absorption, and integration
  So that I can seamlessly evolve the ai-suite and interact with external agents without manual steps

  Scenario: Unified Evolve Workflow (Enable -> Reflection -> Collect)
    Given an AI agent has completed a task
    When the user runs the unified evolve command
    Then the system should trigger reflection
    And the system should automatically collect and merge the evolution
    And the system should provide a clear summary of the newly evolved capabilities

  Scenario: Streamlined Absorb Workflow
    Given an external AI agent with new capabilities
    When the user runs the unified absorb command against the external agent
    Then the system should automatically fetch the capabilities
    And the system should automatically merge the non-conflicting capabilities into the local ai-suite
    And the system should generate an evolution report

  Scenario: Streamlined Integrate Workflow
    Given an external AI agent without ai-suite
    When the user runs the unified integrate command against the external agent
    Then the system should push the local ai-suite capabilities to the external agent
    And the external agent should have ai-suite enabled automatically
