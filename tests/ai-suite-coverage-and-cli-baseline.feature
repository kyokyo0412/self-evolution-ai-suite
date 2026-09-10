Feature: AI Suite CLI Entrypoint Dispatch and Non-Polluting Coverage Harness

  As an AI suite developer or agent
  I want a deterministic, non-polluting CLI dispatcher and test coverage profiler
  So that all commands execute reliably without regressions and line coverage exceeds 95%

  Scenario: Invoking ai-suite without arguments
    Given the ai-suite executable is present at the repository root
    When the user runs ai-suite without any arguments
    Then the exit code should be 0
    And the output should contain "USAGE:"
    And the output should list all supported commands: enable, disable, evolve, workflow, manage, publish

  Scenario: Invoking ai-suite with help flags
    Given the ai-suite executable is present at the repository root
    When the user runs ai-suite with "-h" or "--help"
    Then the exit code should be 0
    And the output should contain "USAGE:"

  Scenario: Invoking ai-suite with an unrecognized command
    Given the ai-suite executable is present at the repository root
    When the user runs ai-suite with "invalid_subcommand"
    Then the exit code should be 1
    And stderr should contain "Unknown command: invalid_subcommand"
    And the output should contain "USAGE:"

  Scenario: Non-polluting code coverage profiler tracking child processes
    Given a non-polluting BASH_ENV debug trap profiler
    When a test command executes ai-suite CLI with subshell dispatches
    Then stdout and stderr must remain strictly unpolluted by debug traces
    And executed file lines must be logged accurately to the coverage log
