Feature: Validate Suite Self-Test
  As a framework maintainer
  I want the suite validation script to be free of runtime errors
  So that the CI and local validation output is clean and accurate

  Scenario: validate-suite.sh runs without command-not-found errors
    Given the script ".ai-suite/layer4-evolutionary/validation/validate-suite.sh" exists
    When I execute the script
    Then the exit code should be 0
    And the output should not contain "command not found"
    And the output should contain "checks passed"
