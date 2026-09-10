Feature: 1E-Class Safety, Deterministic Execution, and Portability Hardening

  As a critical systems developer
  I want deterministic boundaries, safe remote operations, and cross-platform portability
  So that lifecycle hooks, portable shell helpers, and domain extensions operate with 1E-class safety

  Scenario Outline: Remote scope parameter validation and dry-run guarantees
    Given the ai-suite lifecycle CLI "<cmd>"
    When invoked with scope "remote" and args "<args>"
    Then the exit code must be <expected_code>
    And stdout or stderr must contain "<expected_output>"

    Examples:
      | cmd     | args                                           | expected_code | expected_output                   |
      | enable  |                                                | 1             | --scope remote requires --host    |
      | disable |                                                | 1             | --scope remote requires --host    |
      | enable  | --host user@test --remote-scope invalid        | 1             | invalid --remote-scope            |
      | disable | --host user@test --remote-scope invalid        | 1             | invalid --remote-scope            |
      | enable  | --host user@test --remote-scope global --dry-run| 0             | [dry-run]                         |
      | disable | --host user@test --remote-scope global --dry-run| 0             | [dry-run]                         |
      | enable  | --host user@test --remote-scope project --dry-run| 0            | [dry-run]                         |
      | disable | --host user@test --remote-scope project --dry-run| 0            | [dry-run]                         |

  Scenario Outline: Shell hook installation and uninstallation flags
    Given the ai-suite lifecycle CLI "<cmd>"
    When configuring hooks with target shell "<shell>" in dry-run
    Then the command must exit with code <expected_code>
    And stdout or stderr must indicate "<expected_output>"

    Examples:
      | cmd     | shell   | expected_code | expected_output               |
      | enable  | zsh     | 0             | [dry-run] would append zsh    |
      | enable  | bash    | 0             | [dry-run] would append bash   |
      | enable  | both    | 0             | [dry-run] would append        |
      | enable  | invalid | 1             | invalid --shell               |
      | disable | zsh     | 0             | [dry-run] would strip hook    |
      | disable | bash    | 0             | [dry-run] would strip hook    |
      | disable | both    | 0             | [dry-run] would strip hook    |
      | disable | invalid | 1             | invalid --shell               |

  Scenario: Cross-platform portable shell helpers
    Given the portable helper library _portable.sh
    When invoking sed_inplace, mktemp_portable, and ensure_trailing_newline
    Then temporary files are created safely across platforms
    And files without trailing newlines receive exactly one trailing newline
    And files with existing trailing newlines remain uncorrupted
