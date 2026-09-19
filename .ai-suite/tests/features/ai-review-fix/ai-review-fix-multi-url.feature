Feature: Multi-URL Code Review Fixer with Local Commits and Isolation
  As an AI suite user
  I want the ai-review-fix skill to support multiple review URLs
  So that I can autonomously resolve review comments across multiple commits locally with dedicated fix commits and zero remote risk

  Scenario: Processing multiple review URLs with sequential commit fixes
    Given the user provides multiple review URLs:
      | URL                                           | Commit   |
      | https://review.example.com/c/project/+/10001 | commit 1 |
      | https://review.example.com/c/project/+/10002 | commit 2 |
    When the ai-review-fix skill analyzes and downloads the review commits
    Then the skill must process each URL independently in order
    And for each URL, the skill must invoke tdd-team to fix unresolved comments
    And the skill must create a local commit "commit 1'" for "commit 1"
    And the skill must create a local commit "commit 2'" for "commit 2"
    And the resulting local git history must contain the original and fixed commits in sequence:
      | Order | Item      | Description                       |
      | 1     | URL1      | commit 1                          |
      | 2     | Fix 1     | commit 1' - fixed comments for 1  |
      | 3     | URL2      | commit 2                          |
      | 4     | Fix 2     | commit 2' - fixed comments for 2  |

  Scenario: Local repository safety and zero remote push enforcement
    Given the ai-review-fix skill is operating on a local git repository
    When the skill completes all fixes and generates local commits
    Then the skill MUST NOT alter or damage other local branches or untracked work
    And the skill MUST NOT execute "git push" under any circumstances
    And the skill MUST record all fixed comments, patches, and commit hashes in "aigen_doc/ai-review-fix-report.md"

  Scenario: Clear, simple execution for vLLM AI agents
    Given a vLLM AI agent executing the ai-review-fix skill
    When the skill prompt is loaded into the agent context
    Then the execution steps must follow a deterministic state machine:
      | State | Step                  | Action                                            |
      | S1    | Authenticate          | Read credentials if needed (local only)           |
      | S2    | Inspect & Protect     | Check git status and isolate review branch        |
      | S3    | Batch URL Iteration   | For each URL: download, deep review, tdd-team fix |
      | S4    | Local Commit          | Commit fixed changes locally (commit N')          |
      | S5    | Report Generation     | Generate report with patch diffs and replies      |
      | S6    | Final Verification    | Run test suites, verify no remote push performed  |
