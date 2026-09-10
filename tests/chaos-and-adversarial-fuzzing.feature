Feature: Quality Validation and Adversarial Chaos Fuzzing

  As an AI suite quality guardian
  I want strict validation gates and graceful degradation under corrupted inputs
  So that malformed skills, invalid specifications, and filesystem errors never crash the agent

  Scenario: Feature linting validates well-formed Gherkin files
    Given a valid Gherkin feature file
    When running lint-feature.sh
    Then the validation must pass with exit code 0

  Scenario Outline: Feature linting rejects malformed specifications
    Given a feature file with "<defect>"
    When running lint-feature.sh
    Then the validation must fail with exit code 1
    And stderr must describe the "<defect>"

    Examples:
      | defect               |
      | missing_feature      |
      | missing_scenario     |
      | missing_when_step    |
      | missing_then_step    |
      | placeholder_tokens   |
      | empty_file           |

  Scenario: Skill validator rejects malformed and non-compliant skills
    Given a sandboxed suite directory
    When skills violate naming, description length, triggers, body limits, or negative constraints
    Then validate-suite.sh must identify each failure distinctly
    And the process must exit with non-zero status

  Scenario: Graceful degradation under permission denial
    Given a read-only target workspace
    When attempting ai-suite enable
    Then the command must fail safely with an informative error
    And the filesystem must remain uncorrupted
