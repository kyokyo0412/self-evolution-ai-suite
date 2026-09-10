Feature: AI Suite Layer 4 Evolution Sync Protocol Hardening

  As an AI agent or distributed engineer
  I want deterministic self-evolution sync across local and remote environments
  So that improvements are faithfully collected, formatted, validated, and pushed without data loss

  Scenario: Invoking evolve without arguments or with help
    Given the ai-suite evolve CLI
    When invoked without arguments or with "--help"
    Then exit code must be 0
    And stdout must contain usage and examples

  Scenario Outline: Rejecting missing or invalid arguments
    Given the ai-suite evolve CLI
    When invoked with "<args>"
    Then the exit code must be non-zero
    And stderr must describe the argument error

    Examples:
      | args                                  |
      | invalid_subcmd                        |
      | collect                               |
      | push                                  |
      | collect --host                        |
      | push --host user@test --remote-path   |
      | collect --local --unknown-flag        |

  Scenario: Dry-run remote collection and push
    Given remote target "user@dev.example.com"
    When running evolve collect --host user@dev.example.com --dry-run
    Then exit code must be 0
    And output must indicate dry-run rsync and diff operations without executing network calls
    When running evolve push --host user@dev.example.com --dry-run --exclude-memory
    Then exit code must be 0
    And output must indicate dry-run rsync excluding memory and remote enable dispatch

  Scenario: Local evolution collection and report generation
    Given modified or new skills in simulated ~/.cursor/skills
    When running evolve collect --local
    Then new skills are merged into .ai-suite
    And an evolution report markdown is generated under evolutions/
