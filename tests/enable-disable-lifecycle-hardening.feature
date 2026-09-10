Feature: AI Suite Lifecycle Hardening and Boundary Coverage

  As an AI suite user and CI pipeline
  I want robust flag parsing, error handling, shell hook management, and multi-agent lifecycle operations
  So that invalid arguments fail fast safely and installations are fully idempotent and reversible

  Scenario Outline: Rejecting invalid or missing CLI arguments in enable
    Given a sandbox environment
    When the user runs ai-suite enable with arguments "<args>"
    Then the command must exit with a non-zero exit code
    And stderr must contain an informative error message

    Examples:
      | args                          |
      | --agent invalid_agent         |
      | --scope invalid_scope         |
      | --project /nonexistent/path   |
      | --host                        |
      | --shell invalid_shell         |

  Scenario Outline: Rejecting invalid or missing CLI arguments in disable
    Given a sandbox environment
    When the user runs ai-suite disable with arguments "<args>"
    Then the command must exit with a non-zero exit code
    And stderr must contain an informative error message

    Examples:
      | args                          |
      | --agent invalid_agent         |
      | --shell invalid_shell         |
      | --scope remote                |

  Scenario: Idempotent shell hook installation and uninstallation
    Given a sandbox HOME with simulated .zshrc and .bashrc
    When the user installs hooks with --install-hook --shell both
    Then both rc files must contain the auto-enable hook
    When the user runs --install-hook --shell both again
    Then the hook must not be duplicated
    When the user uninstalls hooks with --uninstall-hook --shell both
    Then the hook markers must be cleanly removed from both rc files

  Scenario: Enabling and disabling with --agent all
    Given a target project sandbox
    When the user runs ai-suite enable --agent all --scope project
    Then rules and artifacts for cursor, claude, opencode, continue, roo-code, and codex must be provisioned
    When the user runs ai-suite disable --agent all --scope project
    Then all provisioned agent artifacts must be cleanly removed

  Scenario: Dry-run non-mutation guarantee
    Given a target project sandbox
    When the user runs ai-suite enable with --dry-run
    Then no files or directories must be created in the project target
