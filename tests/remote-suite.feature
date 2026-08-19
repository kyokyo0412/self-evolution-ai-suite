# Feature: AI-prompted remote ai-suite lifecycle management
# Skill: remote-suite
# The user can use natural language to manage ai-suite installations on
# remote SSH hosts — no need to remember shell command syntax.

Feature: Intent recognition for remote operations

  Background:
    Given the remote-suite skill is loaded
    And a workspace containing ai-suite enable, ai-suite disable, and ai-suite evolve

  Scenario: Install ai-suite on a remote host
    When the user says:
      "install ai-suite on alice@dev.example.com"
    Then the skill maps this to:
      bash ai-suite enable --scope remote --host "alice@dev.example.com"
    And the default agent is cursor
    And the default remote scope is global

  Scenario: Install with a specific agent
    When the user says:
      "install ai-suite on alice@dev.example.com for claude"
    Then the skill builds the command with --agent claude

  Scenario: Install with domain pack
    When the user says:
      "install ai-suite on alice@dev.example.com with custom_domain domain"
    Then the skill builds the command with --domain custom_domain

  Scenario: Install for project scope on remote
    When the user says:
      "install ai-suite on alice@dev.example.com project /opt/myapp"
    Then the skill builds:
      bash ai-suite enable --scope remote --host "alice@dev.example.com"
        --remote-path "/opt/myapp" --remote-scope project

  Scenario: Collect evolutions from remote host
    When the user says:
      "collect evolution from alice@dev.example.com"
    Then the skill runs:
      bash ai-suite evolve collect --host "alice@dev.example.com"
    And presents the evolution report
    And prints copy-paste git commands
    And does NOT auto-commit

  Scenario: Push evolved suite to remote
    When the user says:
      "push the evolved suite to alice@dev.example.com"
    Then the skill runs:
      bash ai-suite evolve push --host "alice@dev.example.com"
    And confirms which hosts were updated

  Scenario: Check installation status on remote host
    When the user says:
      "check ai-suite status on alice@dev.example.com"
    Then the skill SSHs into the host
    And checks whether .ai-suite-deploy/.ai-suite/ exists
    And reports installed skill count or "not installed"

  Scenario: Disable (remove) ai-suite from remote host
    When the user says:
      "remove ai-suite from alice@dev.example.com"
    Then the skill runs:
      bash ai-suite disable --scope remote --host "alice@dev.example.com"
    And confirms uninstall completed

  Scenario: Multiple hosts for install
    When the user says:
      "install ai-suite on alice@host1 and bob@host2"
    Then the skill runs ai-suite enable once per host
    And reports success or failure for each

  Scenario: Missing host name prompts the user
    When the user says:
      "install ai-suite on a remote machine"
    And no USER@HOST pattern is found
    Then the skill asks:
      "Which remote host? (format: user@hostname)"
    And does NOT proceed until a host is provided

  Scenario: Dry-run preview
    When the user says:
      "preview install ai-suite on alice@dev.example.com"
    Then the skill appends --dry-run
    And confirms no changes were made

  Scenario: Unknown sub-command falls back to install
    When the user says just:
      "ai-suite on alice@dev.example.com"
    Then the skill interprets this as install (default intent)

Feature: Safety constraints for remote operations

  Scenario: Never auto-commit after collect
    When the user triggers a collect operation
    Then the skill prints git commands for the user to copy-paste
    And explicitly states "Review the diff before running git commands"
    And does NOT run git add or git commit itself

  Scenario: Target validation before install
    When the user says:
      "install ai-suite on prod-server"
    And the host matches a production-looking pattern (prod)
    Then the skill warns the user about the production-looking target
    And asks for explicit confirmation before proceeding

  Scenario: Fail gracefully when scripts are missing
    When the user triggers any remote operation
    And ai-suite enable or ai-suite evolve is not found
    Then the skill reports the missing script
    And does NOT attempt to continue
