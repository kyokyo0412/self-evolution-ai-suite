Feature: Unified AI Suite Workflow Orchestration
  In order to manage the AI suite lifecycle effectively
  As an AI agent or a developer
  I want a single unified CLI entry point that wraps all disparate scripts

  Scenario: Enable the AI suite
    Given the AI suite is not enabled
    When I run "ai-suite workflow enable --agent cursor --scope project"
    Then it should delegate to ai-suite enable and succeed

  Scenario: Disable the AI suite
    Given the AI suite is enabled
    When I run "ai-suite workflow disable --agent cursor --scope project"
    Then it should delegate to ai-suite disable and succeed

  Scenario: Publish the AI suite
    Given the AI suite is ready
    When I run "ai-suite workflow publish"
    Then it should delegate to ai-suite publish and succeed

  Scenario: Evolve the AI suite
    Given the AI suite has local evolutions
    When I run "ai-suite workflow evolve"
    Then it should output instructions for reflection and collection

  Scenario: Guide AI suite development
    Given I want to develop the AI suite
    When I run "ai-suite workflow develop"
    Then it should explain the isolation requirements and steps to develop

  Scenario: Invalid command
    When I run "ai-suite workflow invalid_command"
    Then it should fail and print usage
