Feature: AI Suite Rule Enforcement
  In order to ensure that the AI Agent strictly follows all AI suite rules
  As an AI suite developer
  I want the rule system to explicitly mandate adherence to all rules and use appropriate globs

  Scenario: Deploy rules with globs
    Given the adapter deploys AI suite rules
    When the rules are deployed to the .cursor/rules directory
    Then the rules MUST include globs: "*" to ensure they are always applied

  Scenario: Enforce rules in cursorrules
    Given the adapter generates the .cursorrules block
    When the block is appended
    Then it MUST include a CRITICAL RULE ENFORCEMENT section
    And it MUST explicitly prohibit ignoring the rules
