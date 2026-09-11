Feature: Enhance ai-review-fix skill to handle false issues and deep code review
  As a user of the AI suite
  I want the ai-review-fix skill to deeply understand related code and handle false review comments
  So that it doesn't blindly apply incorrect fixes and provides detailed reasons for rejecting invalid comments.

  Scenario: Review comment is a false issue
    Given the ai-review-fix skill is analyzing a review comment
    When the skill reviews all related code and deeply understands how it works
    And the skill determines the comment is a false issue
    Then the skill should not apply any code fixes for this comment
    And the skill should write the detailed reason/analysis in the reply comment in the records file

  Scenario: Review comment is a true issue
    Given the ai-review-fix skill is analyzing a review comment
    When the skill reviews all related code and deeply understands how it works
    And the skill determines the comment is a true issue
    Then the skill should continue the fix via tdd-team
    And the skill should record the fix in the records file
