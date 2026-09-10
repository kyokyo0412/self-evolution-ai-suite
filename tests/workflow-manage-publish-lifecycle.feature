Feature: Workflow Orchestration, Domain Management, and Publish Packaging Lifecycles

  As an AI developer or platform engineer
  I want robust workflow commands, safe domain installations, and clean publishing
  So that high-level workflows execute reliably without leaking proprietary domain artifacts

  Scenario Outline: Workflow command dispatching and dry-runs
    Given the ai-suite workflow CLI
    When invoked with "<subcmd>" and "<flags>"
    Then the exit code must be <expected_code>
    And stdout must contain "<expected_output>"

    Examples:
      | subcmd    | flags       | expected_code | expected_output                   |
      |           |             | 0             | USAGE                             |
      | --help    |             | 0             | USAGE                             |
      | invalid   |             | 1             | Unknown command                   |
      | evolve    | --dry-run   | 0             | [DRY-RUN]                         |
      | evolve    |             | 0             | Workflow: Evolve                  |
      | absorb    | --dry-run   | 0             | [DRY-RUN]                         |
      | absorb    | mock-arg    | 0             | Workflow: Absorb                  |
      | integrate | --dry-run   | 0             | [DRY-RUN]                         |
      | integrate | mock-arg    | 0             | Workflow: Integrate               |
      | develop   | --dry-run   | 0             | [DRY-RUN]                         |
      | develop   |             | 0             | AI Suite Development Environment  |

  Scenario Outline: Manage domain parameter validation and error states
    Given the ai-suite manage CLI
    When invoked with "<args>"
    Then the exit code must be 1
    And stderr must contain "<expected_error>"

    Examples:
      | args                                    | expected_error                    |
      | invalid_cmd                             | Unknown command                   |
      | domain                                  | domain requires a sub-command     |
      | domain invalid_subcmd                   | Unknown domain sub-command        |
      | domain install                          | domain install requires a git URL |
      | domain install https://mock.git --bad   | Unknown option                    |
      | domain install https://mock.git --domain| --domain requires a value         |

  Scenario: Publish package creation and zero proprietary domain leakage
    Given an AI suite source tree
    When executing ai-suite publish
    Then a tarball "ai-suite-package.tar.gz" is generated
    And the tarball contains core layers (layer1, layer2, layer3, layer4)
    And proprietary domain files are strictly excluded from the package
