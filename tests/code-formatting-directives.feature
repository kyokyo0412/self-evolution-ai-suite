Feature: Code Formatting and Style Directives in AI Suite
  As a software engineer using AI suite
  I want the AI suite to strictly adhere to language-standard coding formatting and project style
  So that generated Go, C, and other code is cleanly formatted, free of whitespace artifacts, and maintains minimal git diffs

  Background:
    Given the AI suite is configured with coding standards and directives

  Scenario: Go code adheres to gofmt standard
    Given the AI agent generates or modifies Go source code
    Then the code format MUST align to the gofmt standard
    And tab indentation and standard Go token spacing MUST be enforced

  Scenario: C code adheres to clang-format standard
    Given the AI agent generates or modifies C source code
    Then the code format MUST align to the clang-format standard
    And consistent brace placement and operator spacing MUST be enforced

  Scenario: Prevention of trivial empty lines containing whitespace
    Given the AI agent generates or edits code files
    Then empty lines MUST NOT contain trailing spaces or tabs
    And blank lines MUST be purely empty without invisible whitespace characters

  Scenario: Selective formatting scope for changed lines only
    Given the AI agent is modifying an existing source file
    Then formatting MUST be applied only to new and modified code lines
    And unchanged code MUST NOT be reformatted unless explicitly requested by the user

  Scenario: Deployment of code formatting directives across AI suite agents
    Given the AI suite directives are maintained in ".ai-suite/layer3-registry/directives"
    When the suite is enabled for Cursor, Codex, Claude, Roo-Code, OpenCode, or Continue
    Then the code formatting directives MUST be included in the deployed rules
