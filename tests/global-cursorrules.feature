# Feature: Cursor global-scope install writes ~/.cursorrules block
# Root cause: agent_install_global() in cursor/adapter.sh mirrors skills
# but never writes to ~/.cursorrules, so the AI has no awareness of the
# reflection protocol or meta framework path after a global install.

Feature: Global Cursor install injects AI Suite awareness into ~/.cursorrules

  Background:
    Given the ai-suite is deployed to $HOME/.ai-suite on a remote host
    And ai-suite enable --scope global --agent cursor is run

  Scenario: Global install writes the AI Suite block to ~/.cursorrules
    When agent_install_global is invoked
    Then ~/.cursorrules exists
    And ~/.cursorrules contains the AI Suite marker block start
    And ~/.cursorrules contains a reference to the reflection-protocol.md path
    And ~/.cursorrules contains a reference to the skills location

  Scenario: Global install block is idempotent
    When agent_install_global is run twice
    Then ~/.cursorrules contains exactly one AI Suite marker block
    And the file is not corrupted

  Scenario: Global uninstall removes the block from ~/.cursorrules
    Given ~/.cursorrules has the AI Suite block
    When agent_uninstall_global is invoked
    Then the AI Suite marker block is removed from ~/.cursorrules
    And any non-suite content in ~/.cursorrules is preserved

  Scenario: Global install with --domain custom_domain mirrors all 13 skills
    When agent_install_global is invoked with AI_SUITE_DOMAIN=custom_domain
    Then ~/.cursor/skills/ contains 13 skill directories
    And the 4 custom_domain domain skills are present:
      | bazel-deb-deps       |
      | custom-skill-1          |
      | testbed-setup        |
      | unified-lb-testbed   |

  Scenario: Global install without --domain mirrors 9 skills only
    When agent_install_global is invoked without AI_SUITE_DOMAIN
    Then ~/.cursor/skills/ contains 9 skill directories
    And custom_domain domain skills are absent

Feature: Remote install with --domain custom_domain deploys all 13 skills

  Scenario: Remote install forwards --domain custom_domain to the remote ai-suite enable
    When ai-suite enable --scope remote --host USER@HOST --domain custom_domain is run
    Then the remote ai-suite enable is called with --domain custom_domain
    And the remote ~/.cursor/skills/ contains 13 skill directories

  Scenario: Remote install produces a ~/.cursorrules block on the remote host
    When ai-suite enable --scope remote --host USER@HOST --domain custom_domain is run
    Then the remote ~/.cursorrules contains the AI Suite marker block
    And it references the reflection-protocol.md at the remote deploy path

Feature: Backward compatibility

  Scenario: Project-scope install is unaffected
    When agent_install_project is invoked
    Then .cursorrules in the project contains the AI Suite block
    And ~/.cursorrules is NOT modified by a project-scope install

  Scenario: All existing acceptance tests still pass
    When the full acceptance test suite is run
    Then all tests pass with 0 failures
