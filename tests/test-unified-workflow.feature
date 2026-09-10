Feature: AI Suite Unified Workflow Requirements Specification

  Scenario: Enable the AI suite
    Given an AI agent workspace
    When the user runs ai-suite enable
    Then the suite is deployed to the agent

  Scenario: Disable the AI suite
    Given an enabled AI agent workspace
    When the user runs ai-suite disable
    Then the suite is cleanly uninstalled

  Scenario: Publish the AI suite
    Given the AI suite source repository
    When the user runs ai-suite publish
    Then an archive package is created without domain leakage

  Scenario: Evolve the AI suite
    Given new skills or reflection logs
    When the user runs ai-suite evolve
    Then evolutions are collected and validated

  Scenario: Guide AI suite development
    Given an engineer developing the suite
    When the user runs ai-suite workflow develop
    Then isolated development instructions are provided
