Feature: AI Suite Master Code Quality & Resource Lifecycle Directives

  As an AI suite developer and autonomous agent
  I want strict, enforceable directives for code quality, resource lifecycles, and language robustness
  So that all AI-generated and modified code achieves zero resource leaks, explicit error handling, and high reliability

  Scenario: Code Quality directive defines deterministic resource lifecycle standards
    Given the code quality directive at ".ai-suite/layer3-registry/directives/code-quality.md"
    Then it must mandate deterministic resource cleanup (file descriptors, sockets, child processes)
    And it must reference deterministic patterns: defer in Go, context managers in Python, RAII in C++, trap in Shell

  Scenario: Code Quality directive enforces language-specific robustness rules
    Given the code quality directive at ".ai-suite/layer3-registry/directives/code-quality.md"
    Then it must specify Python robustness rules forbidding bare except and requiring type annotations
    And it must specify Shell robustness rules requiring defensive execution and quoted variables
    And it must specify Go robustness rules requiring explicit error wrapping and context propagation
    And it must specify C/C++ buffer bounds checking and return value validation

  Scenario: Agent Directives mandate anti-hardcoding in test assertions
    Given the agent directives at ".ai-suite/layer3-registry/directives/agent-directives.md"
    Then it must explicitly mandate dynamically computed test assertions
    And it must forbid hardcoding corpus sizes or static entity counts in test assertions
