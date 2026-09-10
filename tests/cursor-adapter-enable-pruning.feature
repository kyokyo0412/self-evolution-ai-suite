Feature: Cursor Adapter Enable Pruning & Zero Stale Artifact Invariance
  As a developer using the AI Suite with Cursor Agent
  I want global and project re-enablement to clean up obsolete skills, templates, scripts, and rules
  So that the Cursor Agent never discovers or executes deprecated skills or conflicting legacy rules.

  Scenario: Global enablement prunes obsolete skills and stale rule files
    Given an existing global Cursor deployment with obsolete skills "ai-expert", "ai-review-fix-manual", "prompt-enhancer"
    And legacy unversioned markdown rules "agent-directives.md", "production-safety.md" in "~/.cursor/rules/"
    When "ai-suite enable --scope global --agent cursor" is executed
    Then obsolete skills "ai-expert", "ai-review-fix-manual", "prompt-enhancer" must not exist in "~/.cursor/skills/"
    And legacy rules "agent-directives.md", "production-safety.md" must not exist in "~/.cursor/rules/"
    And active suite skills must be mirrored with current versions
    And active suite rules must be deployed as ".mdc" files with alwaysApply: true
    And the "~/.cursorrules" block must be updated idempotently without duplicate markers

  Scenario: Project enablement prunes obsolete skills and stale rule files
    Given an existing project Cursor deployment with obsolete skills and stale rules
    When "ai-suite enable --scope project --agent cursor" is executed
    Then obsolete skills must not exist in the project ".cursor/skills/"
    And legacy markdown rules must not exist in the project ".cursor/rules/"
    And active suite skills and rules must be cleanly deployed

  Scenario: Remote enablement propagates clean deployment to remote host
    Given a remote host with previous installations containing obsolete skills
    When "ai-suite enable --scope remote --host <HOST> --remote-scope global --agent cursor" is executed
    Then obsolete skills are pruned from the remote "~/.cursor/skills/"
    And remote validation passes with 100% success
