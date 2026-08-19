Feature: Categorize evolution correctly

  Scenario: AI uses correct categories during reflection
    Given the Reflection Protocol is engaged
    When the AI runs the 3-Question Generality Gate
    Then it categorizes the improvement into one of:
      | Category | Directory |
      | Core Skills / Prompts | .ai-suite/core/ |
      | Process Procedures | .ai-suite/layer3-registry/core/ |
      | Domain Knowledge | .ai-suite/layer3-registry/domains/<domain-name>/ |
      | Agent Specific | .ai-suite/layer1-abstraction/agents/<agent-name>/ |
    And the AI places the evolution in the correct directory based on the category
