Feature: Isolate Memory from AI Suite Source Code
  As a developer of the ai-suite framework
  I want the memory system to be completely isolated from the ai-suite source code
  So that project memory is not accidentally committed, published, or synced to remote hosts when distributing the ai-suite

  Scenario: Memory system is isolated into .ai-memory
    Given the ai-suite is installed
    When an agent uses the memory system
    Then project-specific memory should be stored in ".ai-memory/<agent_name>/index/"
    And global memory should be stored in "~/.ai-suite/memory/<agent_name>/tasks/"
    And the ai-suite project's `.ai-memory` directory is added to `.gitignore`
    And `ai-suite enable` should NOT sync the `.ai-memory` directory to remote hosts
    And `ai-suite publish` should NOT package the `.ai-memory` directory
    And system prompts in `core.sh`, `instructions.md`, and `ai-suite.prompt` should reference `.ai-memory/` instead of `.ai-suite/memory/`
