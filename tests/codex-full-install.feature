Feature: Codex Agent Full Installation of Rules, Directives, Templates, and Scripts
  As an AI Suite user and developer
  I want the Codex agent to install all templates/prompts, rules, directives, and scripts
  So that the Codex agent has complete operational capability in both project and global scopes
  While ensuring that published packages contain zero VMware or Broadcom domain artifacts

  Scenario: Project-scope Codex enable installs all components
    Given a clean target project directory
    When I run "ai-suite enable --agent codex --scope project"
    Then an "AGENTS.md" file should be created containing the ai-suite block
    And "AGENTS.md" must include all agent directives and safety rules
    And the ".codex/skills" directory should contain all core skills
    And the ".codex/meta" directory should contain meta validation and reflection protocols
    And the ".codex/templates" directory should contain all framework templates and prompt briefs
    And the ".codex/scripts" directory should contain all framework scripts
    And the ".codex/rules" directory should contain all framework rules and safety guardrails
    And the ".codex/directives" directory should contain all framework directives

  Scenario: Global-scope Codex enable installs all components
    Given a clean user home directory
    When I run "ai-suite enable --agent codex --scope global"
    Then the "~/.codex/AGENTS.md" file should be created containing the ai-suite block
    And the "~/.codex/skills" directory should contain all core skills
    And the "~/.codex/meta" directory should contain meta validation and reflection protocols
    And the "~/.codex/templates" directory should contain all framework templates
    And the "~/.codex/scripts" directory should contain all framework scripts
    And the "~/.codex/rules" directory should contain all framework rules
    And the "~/.codex/directives" directory should contain all framework directives

  Scenario: Project and Global uninstallation cleanly removes all installed components
    Given a project directory and global home with Codex enabled
    When I run "ai-suite disable --agent codex --scope project"
    Then the ai-suite block should be removed from "AGENTS.md"
    And ".codex/skills", ".codex/meta", ".codex/templates", ".codex/scripts", ".codex/rules", and ".codex/directives" should be removed
    When I run "ai-suite disable --agent codex --scope global"
    Then the ai-suite block should be removed from "~/.codex/AGENTS.md"
    And "~/.codex/skills", "~/.codex/meta", "~/.codex/templates", "~/.codex/scripts", "~/.codex/rules", and "~/.codex/directives" should be removed

  Scenario: Installation from a published package contains zero VMware or Broadcom domain assets
    Given an AI Suite package produced by "ai-suite publish"
    When the package is extracted and enabled for Codex
    Then all core skills, templates, rules, directives, and scripts must be installed
    And there must be zero VMware or Broadcom domain files, rules, or references in the installed directories or AGENTS.md
