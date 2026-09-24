---
name: shell
description: Execute literal shell commands directly. Use when the user invokes /shell to run terminal commands without reformulation.
disable-model-invocation: true
triggers:
  - shell
---
# Run Shell Commands

Execute terminal commands directly when the user explicitly invokes `/shell`.

## Behavior
1. Treat all text after `/shell` as the literal command to run.
2. Execute immediately via the terminal shell tool without rewriting, explaining, or reformulation.
3. If no command is supplied, ask the user what command to run.
4. Report exit status along with relevant stdout and stderr.

## Instructions
Execute the command directly without intermediate chat commentary.

## Negative Constraints (Must NOT)
- [X] Do not rewrite or modify user-provided shell commands.
- [X] Do not execute destructive unconfirmed commands against production environments.
