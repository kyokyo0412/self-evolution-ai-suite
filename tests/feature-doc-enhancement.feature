Feature: Enhance feature-doc skill
  As a developer using the AI suite
  I want the feature-doc skill to answer specific codebase questions and map them to architecture and code
  So that I can get exhaustive, detailed insights without interruptions

  Scenario: feature-doc outputs complete architectural and code mapped answers
    Given the user provides a question about the codebase
    When the feature-doc skill is triggered
    Then it should review the source code and dig into details
    And it should output the answer to the question
    And it should map the answer into the architecture and design
    And it should map the answer into the modules and codes
    And it should provide extra information which benefits the user
    And it should output the document to "aigen_doc/"
    And it should write the document exhaustively
    And it should not stop to ask the user for input before it is all done
