Feature: AI Suite Source Code Cleanup and Refactoring
  As an AI suite developer
  I want to clean up the source code structure and remove redundant files
  So that the repository is easier to maintain and the core functions (evolution, isolation) remain intact

  Scenario: Remove empty and redundant directories
    Given the repository contains an empty "src" directory
    And the repository contains outdated tests in "tests" directory
    When the cleanup script is executed
    Then the "src" directory should be removed
    And the outdated tests in "tests" directory should be removed

  Scenario: Consolidate test artifacts into tests directory
    Given the ".ai-suite/layer4-evolutionary/validation" directory contains test scripts ("test-*.sh"), feature files ("*.feature"), and contract files ("*-contracts.md")
    When the tests are moved to the "tests" directory
    Then the ".ai-suite/layer4-evolutionary/validation" directory should no longer contain these test artifacts
    And the "tests" directory should contain all the test artifacts
    And the references in "README.md" and other scripts should point to "tests/" instead of ".ai-suite/layer4-evolutionary/validation/"

  Scenario: Core functions remain intact after refactoring
    Given the source code has been refactored
    When the acceptance tests ("run-acceptance-tests.sh") are executed
    Then all acceptance tests should pass
    And the isolation of AI suite and AI suite developing agent should be maintained
