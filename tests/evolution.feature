# Feature: Remote Evolution Collection and Push
# Functional context:
#   cursor-suite is installed to remote SSH hosts via ai-suite enable.
#   When Cursor runs "Run Reflection" on a remote host, it edits files inside
#   the remote .cursor-suite/ installation.  Those improvements are siloed —
#   they never flow back to the local git repo (the "mother").
#   This feature closes that loop.

Feature: Collect remote evolution back into the local git repo

  Background:
    Given a local cursor-suite git repository at SUITE_ROOT
    And a remote SSH host HOST with cursor-suite deployed at REMOTE_PATH
    And Reflection Mode has edited one or more files in REMOTE_PATH/.cursor-suite/

  Scenario: Collect changed files from a single remote host
    When the user runs:
      ai-suite evolve collect --host HOST
    Then the script SSHes / rsyncs from HOST:REMOTE_PATH/.cursor-suite/ to a temp dir
    And diffs the temp dir against the local SUITE_ROOT/.cursor-suite/
    And copies only the changed (or new) files from the temp dir into SUITE_ROOT/.cursor-suite/
    And writes an evolution report to SUITE_ROOT/.cursor-suite/layer4-evolutionary/reflection/evolutions/<timestamp>-<host>.md
      containing: host, timestamp, list of changed files, and unified diff per file
    And prints copy-paste git commands:
      git add .cursor-suite/
      git commit -m "feat(evolution): collect remote changes from HOST at TIMESTAMP"
    And exits 0

  Scenario: No changes detected
    Given no files differ between remote and local
    When the user runs:
      ai-suite evolve collect --host HOST
    Then the script prints "No changes detected from HOST"
    And does NOT create an evolution report
    And exits 0

  Scenario: Push local (evolved) suite back to one remote
    When the user runs:
      ai-suite evolve push --host HOST
    Then the script rsyncs SUITE_ROOT/.cursor-suite/ and the toggle scripts to HOST:REMOTE_PATH/ without --delete
    And SSHes HOST and runs:
      bash REMOTE_PATH/ai-suite enable --scope global
    And exits 0

  Scenario: Push local suite to multiple remotes
    When the user runs:
      ai-suite evolve push --host HOST1 --host HOST2
    Then the push is performed to HOST1 and HOST2 in sequence
    And the push does not use full replacement (no --delete) to allow merging remote-only changes
    And exits 0 if all pushes succeed
    And exits non-zero (reporting which hosts failed) if any push fails

  Scenario: Collect from multiple remotes (merge)
    When the user runs:
      ai-suite evolve collect --host HOST1 --host HOST2
    Then changes from HOST1 are collected first
    Then changes from HOST2 are collected and merged (later host wins on conflict)
    And one evolution report per host is written
    And the combined copy-paste git commands cover all collected files
    And exits 0

  Scenario: Dry-run shows what would be collected/pushed without mutating anything
    When the user runs:
      ai-suite evolve collect --host HOST --dry-run
    Then the script prints the diff but does NOT copy any files
    And does NOT write an evolution report
    And exits 0

  Scenario: Missing --host argument
    When the user runs:
      ai-suite evolve collect
    Then the script prints an error message containing "--host is required"
    And exits non-zero

  Scenario: Remote path not reachable
    Given HOST is unreachable or REMOTE_PATH does not exist on HOST
    When the user runs:
      ai-suite evolve collect --host HOST
    Then the script prints a clear error
    And exits non-zero

Feature: Validate frontmatter after collection

  Scenario: Collected evolution contains a skill with broken frontmatter
    Given a remote skill file has invalid frontmatter (e.g. missing "Use when")
    When ai-suite evolve collect --host HOST completes
    Then validate-suite.sh is run automatically on the collected skills
    And a WARNING is printed for each failing skill
    And the evolution report notes the validation failures
    And the user is advised to fix before committing
    And the copy-paste git command is still printed (user decides)
