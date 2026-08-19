# Feature: Trigger ai-suite evolve collect via AI agent prompt
# Context:
#   cursor-suite ships ai-suite evolve for collecting remote reflections.
#   A new Cursor skill (evolve-collect.md) allows users to trigger that
#   workflow through natural-language prompts instead of bare shell commands.
#   The AI agent reads the user's intent, derives the SSH target(s) and
#   optional remote path, runs ai-suite evolve collect, and presents the
#   evolution report + copy-paste git commands for review.

Feature: Collect remote evolution via AI prompt (global user scope)

  Background:
    Given cursor-suite is installed in the local git repo
    And ai-suite evolve is present in the workspace root
    And one or more remote SSH hosts have cursor-suite installed

  Scenario: User triggers collection with a simple host reference
    When the user types one of:
      "collect evolution from user@host"
      "sync reflection from user@host"
      "pull suite changes from user@host"
      "evolve collect user@host"
    Then the AI agent recognises the evolve-collect skill
    And the AI agent runs:
        bash ai-suite evolve collect --host "user@host"
    And the AI presents the evolution report content to the user
    And the AI prints the copy-paste git commands for review
    And the AI does NOT commit automatically

  Scenario: User triggers collection specifying multiple hosts
    When the user types:
      "collect evolution from user@host1 and user@host2"
    Then the AI agent runs:
        bash ai-suite evolve collect --host "user@host1" --host "user@host2"
    And presents a per-host summary of changes
    And prints combined copy-paste git commands

  Scenario: User triggers dry-run collection (preview only)
    When the user types:
      "preview evolution changes from user@host"
      "dry run collect from user@host"
      "what changed on user@host"
    Then the AI agent runs:
        bash ai-suite evolve collect --host "user@host" --dry-run
    And shows the diff output without modifying any local files
    And confirms no files were changed

  Scenario: User triggers collection for a specific remote project path
    When the user types:
      "collect evolution from user@host at /home/user/myproject"
      "sync changes from user@host path /home/user/myproject"
    Then the AI agent runs:
        bash ai-suite evolve collect --host "user@host" --remote-path "/home/user/myproject"
    And presents the evolution report filtered to that project

  Scenario: AI asks for missing host when none provided
    When the user types:
      "collect evolution"
      "sync remote reflection"
    Then the AI agent asks the user to provide the remote host (USER@HOST)
    And waits for the user to supply it before running any command

  Scenario: User triggers push after reviewing collected evolution
    When the user types:
      "push suite to user@host"
      "update remote host user@host with the evolved suite"
      "deploy evolution to user@host"
    Then the AI agent runs:
        bash ai-suite evolve push --host "user@host"
    And confirms the push succeeded or reports per-host failures

Feature: Collect remote evolution via AI prompt (specific remote project scope)

  Scenario: Collection scoped to a remote project directory
    When the user says:
      "collect evolution from user@host project /opt/myapp"
    Then the AI agent runs:
        bash ai-suite evolve collect --host "user@host" --remote-path "/opt/myapp"
    And the evolution report reflects only the changes under that project's .cursor-suite/

  Scenario: Push scoped to a remote project directory
    When the user says:
      "push evolution to user@host project /opt/myapp"
    Then the AI agent runs:
        bash ai-suite evolve push --host "user@host" --remote-path "/opt/myapp" --remote-scope project
    And confirms success

Feature: Safety and guardrails

  Scenario: AI never commits automatically
    Given the collect command detected changed files
    When the AI presents the copy-paste git commands
    Then the AI explicitly states "do NOT auto-commit"
    And the AI instructs the user to review git diff before running the git commands

  Scenario: AI handles collection errors gracefully
    Given the remote host is unreachable
    When the AI runs ai-suite evolve collect --host "user@host"
    Then the AI reports the error clearly
    And suggests the user verify SSH connectivity manually

  Scenario: AI respects dry-run flag
    When the user adds "preview" or "dry-run" to their request
    Then the AI always appends --dry-run to the command
    And explicitly confirms no files were changed on the local repo
