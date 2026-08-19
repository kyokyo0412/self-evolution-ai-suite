Feature: question-doc skill
  As a developer
  I want a question_doc skill
  So that I can ask specific questions about the codebase and get detailed answers backed by code analysis

  Scenario: question-doc answers user questions with code mapping
    Given the user asks a specific question about the codebase
    When the question_doc skill is triggered
    Then it should perform a codebase discovery and trace
    And it should deeply analyze code functions and behaviors
    And it should provide a direct answer to the question
    And it should provide the full code trace chain supporting the answer
    And it should output the document to "aigen_doc/"
