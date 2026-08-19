Feature: AI Suite Agent Memory Usage
  As an AI agent in the AI Suite
  I want to be instructed to use the memory system
  So that I can persist and retrieve project knowledge and task history across sessions

  Scenario: Agent is instructed to use the memory system with split storage
    Given the AI suite generates the markdown block for the agent
    When the agent name is provided
    Then the generated markdown should contain a "Memory System" section
    And it should specify the agent's name
    And it should instruct the agent to review project memory in `.ai-memory/<agent_name>/index/`
    And it should instruct the agent to review global history memory in `~/.ai-suite/memory/<agent_name>/tasks/`
    And it should instruct the agent to update memory using `.ai-suite/layer2-cognitive/memory/memory.sh`
    
  Scenario: Memory system auto-initialization
    Given a project with the AI suite installed
    When the agent adapter is installed or an agent starts a task
    Then the memory system should auto-initialize the project memory directory
    And the memory system should auto-initialize the global memory directory
