# Architecture Contract: cursor adapter - global-scope ~/.cursorrules fix
# Phase 2 artifact. Verified by test-global-cursorrules-contracts.sh.

## Scope of change
  Only cursor/adapter.sh is modified.
  ai-suite enable, ai-suite disable, ai-suite evolve are NOT modified.

## New / changed functions in cursor/adapter.sh

  F1. _append_cursorrules_global_block(suite_dir)
        Writes (or appends) the AI Suite marker block to $HOME/.cursorrules.
        Idempotent: removes any existing block first (calls _remove_cursorrules_block).
        Block content matches the project-scope block but references:
          - Skills location: $HOME/.cursor/skills   (mirrored skills, not source)
          - Meta / protocols: <suite_dir>/meta       (deployed suite meta dir)
          - Reflection protocol: <suite_dir>/meta/reflection-protocol.md

  F2. agent_install_global(suite_dir)   [modified]
        Existing: mirrors skills, deploys safety rule
        NEW: also calls _append_cursorrules_global_block "$suite_dir"

  F3. agent_uninstall_global([suite_dir])  [modified]
        Existing: removes skills, removes safety rule
        NEW: also calls _remove_cursorrules_block "$HOME/.cursorrules"

## Marker block identity
  Uses the SAME block markers as project-scope installs:
    Start: # >>>>> cursor-ai-suite >>>>>
    End:   # <<<<< cursor-ai-suite <<<<<
  This ensures _remove_cursorrules_block works on both files without changes.

## Idempotency contract
  Running agent_install_global twice MUST NOT produce duplicate blocks.
  The resulting ~/.cursorrules MUST contain exactly one start marker.

## Isolation contract
  agent_install_project MUST NOT touch ~/.cursorrules.
  agent_install_global MUST NOT touch <project>/.cursorrules.

## Uninstall completeness contract
  After agent_uninstall_global:
    - ~/.cursorrules has no AI Suite block
    - ~/.cursor/skills/ has no suite-mirrored skill dirs
    - ~/.cursor/rules/ has no production-safety rule
    - Non-suite content in ~/.cursorrules is preserved

## Domain skill contract
  agent_install_global with AI_SUITE_DOMAIN=custom_domain:
    mirrors 7 core + 2 cursor + 4 custom_domain = 13 skills to ~/.cursor/skills/
  agent_install_global without AI_SUITE_DOMAIN:
    mirrors 7 core + 2 cursor = 9 skills only
