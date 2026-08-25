# Feature: Enhanced ai-suite Reflection Protocol
# Context:
#   The current reflection-protocol.md is shallow (4 bullet points), Cursor-centric,
#   tier-unaware, and produces no machine-readable evolution record.
#   This enhancement makes reflection deeper, agent-agnostic, tier-aware,
#   and produces a structured evolution report compatible with ai-suite evolve.

Feature: Deeper structured analysis

  Background:
    Given the AI agent has just completed a task
    And "Run Reflection" (or any recognised trigger) is typed

  Scenario: AI runs a 5-category retrospective
    When reflection is triggered
    Then Step 1 produces analysis across all five categories:
      | Category              | What is examined                                       |
      | Trigger accuracy      | Was the right skill found and activated?               |
      | Instruction gaps      | Were all context/steps complete inside the skill?      |
      | Safety guard gaps     | Were destructive/risky actions caught before execution?|
      | Tool-use efficiency   | Excessive re-reads, redundant calls, wasted turns?     |
      | Output quality        | Was the result actionable and clear for the human?     |

  Scenario: Analysis cites the exact file path
    When a skill or template is identified as the improvement target
    Then the analysis names the full relative path
    And distinguishes whether it is in core/ agents/ or domains/

  Scenario: Severity tagging
    When Step 1 analysis is complete
    Then each identified issue is tagged as one of:
      Critical / High / Medium / Low
    And only Critical or High items drive the improvement selection

Feature: Agent-generality gate before editing

  Scenario: Generality check guides tier placement
    When Step 2 chooses an improvement target
    Then the AI runs a 3-question generality gate before editing:
      Q1: Does this improvement apply to ALL agents (Cursor, Claude, OpenCode, ...)?
          YES -> place / keep in .ai-suite/core/
      Q2: Is it specific to one AI agent (Cursor IDE, Claude Code, ...)?
          YES -> place / keep in .ai-suite/layer1-abstraction/agents/<agent-name>/
      Q3: Is it specific to one software domain (CustomDomain, ...)?
          YES -> place / keep in .ai-suite/layer3-registry/domains/<domain-name>/
    And the AI states the gate result before making any edit

  Scenario: Core tier improvement must not contain agent-specific content
    When the improvement target is in .ai-suite/core/
    Then the AI verifies the edited file contains no Cursor-specific APIs
    And contains no domain-specific system names (Custom, Custom, VIB, )

  Scenario: New skill placement is always justified
    When a new skill file is created during reflection
    Then the closing summary explicitly states which tier was chosen and why

Feature: Structured evolution report

  Scenario: Evolution report file written after every reflection
    When the reflection edit is complete
    Then the AI writes a Markdown report to:
      .ai-suite/layer4-evolutionary/reflection/evolutions/REFLECTION-<ISO-timestamp>.md
    And the report contains:
      - Task summary (what the human was trying to do)
      - Improvement target (file path + tier)
      - Root cause (one of the 5 categories from Step 1)
      - Change description (what was edited and why)
      - Generality gate result (which tier + justification)
      - Git diff excerpt or file delta summary

  Scenario: Evolution report integrates with ai-suite evolve collect
    When the evolution report is written
    Then it is co-located in .ai-suite/layer4-evolutionary/reflection/evolutions/
    And the closing summary lists the report filename for the user to git-add
    And the report can be picked up by ai-suite evolve collect
      when remote instances push their evolutions back

  Scenario: Closing summary includes report filename
    When Step 5 emits the closing summary
    Then it includes the evolution report path
    And lists copy-paste git commands including the report file

Feature: Preserved constraints and backward compatibility

  Scenario: One-improvement-per-call rule is retained
    When multiple issues are found
    Then only the highest-severity issue is edited in this call
    And the AI tells the user to run Reflection again for the next issue

  Scenario: No auto-commit constraint is retained
    When any reflection edit is made
    Then git add, git commit, git push are strictly forbidden
    And the closing summary always instructs manual review

  Scenario: Validate-suite.sh is run with correct no-arg invocation
    When a skill file is edited
    Then the protocol runs:
      bash .ai-suite/layer4-evolutionary/validation/validate-suite.sh
    And uses the no-argument form (scans all three tiers)
    And NOT the old single-directory form

  Scenario: Reflection triggers remain backward compatible
    When any of the following is typed:
      "Run Reflection" / "Reflect on the last task" /
      "Improve the suite" / "Run Reflection"
    Then reflection mode is engaged regardless of agent type
    And works identically in Cursor, Claude Code, and any other AI agent

  Scenario: Protocol does not break install/uninstall scripts
    When reflection edits a skill or template
    Then ai-suite enable, ai-suite disable, and ai-suite evolve are NOT modified
    And the test suites (run-acceptance-tests.sh etc.) still pass after the edit

Feature: Clear and detailed evolution explanation

  Scenario: Closing summary is self-contained and detailed
    When Step 5 emits the closing summary
    Then it explains WHAT was changed (specific text delta or new section)
    And WHY it was changed (root cause from Step 1 analysis)
    And HOW it prevents the same friction in future runs
    And WHICH TIER the change belongs to and why that tier was chosen
