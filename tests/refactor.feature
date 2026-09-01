# Feature: Refactor cursor-suite into a universal ai-suite framework
# Context:
#   The original framework was tightly coupled to Cursor IDE and CustomDomain CustomDomain.
#   This refactoring makes the core agent-agnostic and domain-agnostic while
#   preserving all existing capabilities in clearly-scoped sub-directories.

Feature: New .ai-suite/ directory structure

  Background:
    Given the workspace contains an old .cursor-suite/ directory
    And ai-suite enable, ai-suite disable, and ai-suite evolve exist at the workspace root

  Scenario: Universal directory layout exists
    When the refactoring is applied
    Then .ai-suite/ replaces .cursor-suite/ as the top-level suite directory
    And .ai-suite/layer3-registry/core/ contains all agent-agnostic skills
    And .ai-suite/layer2-cognitive/templates/ contains all agent-agnostic templates
    And .ai-suite/layer1-abstraction/agents/cursor/skills/ contains Cursor-specific skills
    And .ai-suite/layer1-abstraction/agents/cursor/ contains a cursor-specific adapter
    And .ai-suite/layer1-abstraction/agents/claude/ contains a Claude Code adapter
    And .ai-suite/layer3-registry/domains/custom_domain/skills/ contains CustomDomain domain skills
    And .ai-suite/layer3-registry/domains/custom_domain/templates/ contains CustomDomain domain templates
    And .ai-suite/layer4-evolutionary/validation/ retains all meta scripts with updated paths

  Scenario: Core skills are agent-agnostic
    When the core skills are inspected
    Then .ai-suite/layer3-registry/core/ contains tdd-team.md
    And .ai-suite/layer3-registry/core/ contains autonomous-team.md
    And .ai-suite/layer3-registry/core/ contains codebase-deepdoc.md
    And .ai-suite/layer3-registry/core/ contains ai-review-fix.md
    And .ai-suite/layer3-registry/core/ contains ai-review-fix-manual.md
    And .ai-suite/layer3-registry/core/ contains evolve-collect.md
    And none of the core skills reference Cursor-specific API (no .cursorrules, no ~./cursor/)
    And none of the core skills reference CustomDomain domain-specific systems

  Scenario: Cursor agent skills are isolated
    When the cursor agent skills are inspected
    Then .ai-suite/layer1-abstraction/agents/cursor/skills/ contains ai-suite-architect.md
    And .ai-suite/layer1-abstraction/agents/cursor/skills/ contains prompt-developer.md
    And these skills may reference .cursorrules and Cursor-specific configuration

  Scenario: CustomDomain domain skills are isolated
    When the custom domain skills are inspected
    Then .ai-suite/layer3-registry/domains/custom_domain/skills/ contains custom-skill-1.md
    And .ai-suite/layer3-registry/domains/custom_domain/skills/ contains testbed-setup.md
    And .ai-suite/layer3-registry/domains/custom_domain/skills/ contains unified-lb-testbed.md
    And .ai-suite/layer3-registry/domains/custom_domain/skills/ contains bazel-deb-deps.md
    And .ai-suite/layer3-registry/domains/custom_domain/templates/ contains custom-daemon-dummy.md

  Scenario: Old .cursor-suite/ is removed
    When the root directory is inspected
    Then .cursor-suite/ no longer exists at the workspace root

Feature: Multi-agent enable/disable support

  Scenario: Enable for Cursor IDE (default, backward compatible)
    When the user runs:
      bash ai-suite enable --agent cursor --scope global
    Then core skills and cursor-specific skills are deployed to ~/.cursor/skills/
    And the production-safety rule is deployed to ~/.cursor/rules/
    And the behaviour is identical to the old --scope global

  Scenario: Enable for Claude Code (project scope)
    When the user runs:
      bash ai-suite enable --agent claude --scope project
    Then CLAUDE.md is created or updated in the project root
    And CLAUDE.md lists all core skill names and their descriptions
    And CLAUDE.md includes the Reflection Protocol trigger instructions
    And no .cursorrules or .cursor/ files are written

  Scenario: Enable for Claude Code (global scope)
    When the user runs:
      bash ai-suite enable --agent claude --scope global
    Then ~/.claude/CLAUDE.md is created or updated
    And it contains the core skill index and reflection trigger

  Scenario: Enable for all agents at once
    When the user runs:
      bash ai-suite enable --agent all --scope project
    Then both the Cursor and Claude configurations are written
    And the combined install is idempotent

  Scenario: Enable with CustomDomain domain pack
    When the user runs:
      bash ai-suite enable --agent cursor --domain custom_domain --scope global
    Then CustomDomain skills are also deployed alongside core skills
    And domain skills appear in ~/.cursor/skills/ as well

  Scenario: Enable without domain pack (default)
    When the user runs:
      bash ai-suite enable --agent cursor --scope global
    Then only core + cursor-agent skills are deployed
    And CustomDomain domain skills are NOT deployed

  Scenario: Disable cleans up the correct agent's files
    When the user runs:
      bash ai-suite disable --agent claude --scope project
    Then CLAUDE.md is removed (or the ai-suite block is removed from it)
    And .cursor/ files are untouched

  Scenario: Unknown agent flag is rejected with helpful error
    When the user runs:
      bash ai-suite enable --agent unknownagent --scope project
    Then the script exits non-zero
    And the error message lists the supported agents

Feature: Backward compatibility and migration

  Scenario: Old --scope global still works (agent defaults to cursor)
    When the user runs the old invocation:
      bash ai-suite enable --scope global
    Then it behaves identically to --agent cursor --scope global
    And no migration steps are required from the user

  Scenario: validate-suite.sh scans all skill directories
    When the user runs:
      bash .ai-suite/layer4-evolutionary/validation/validate-suite.sh
    Then it scans layer3-registry/core/ + layer1-abstraction/agents/cursor/skills/ + domains/custom_domain/skills/
    And reports pass/fail for every .md file found

  Scenario: ai-suite evolve paths use .ai-suite/
    When ai-suite evolve collect or push is run
    Then it reads/writes .ai-suite/ (not .cursor-suite/)
    And evolution reports land in .ai-suite/layer4-evolutionary/reflection/evolutions/

Feature: tdd-team description is domain-agnostic

  Scenario: tdd-team skill description mentions no CustomDomain
    When the skill description is inspected
    Then .ai-suite/layer3-registry/core/tdd-team.md description does not contain "Custom"
    And it does not contain "Bazel" in the description (body may still reference it)
    And it works as a general TDD skill for any language or framework
