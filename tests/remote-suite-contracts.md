# Architecture Contract: remote-suite skill
# Phase 2 artifact -- interface, intent-mapping, and safety contracts.
# Verified by test-remote-suite-contracts.sh.

## Placement

  P1. File: .ai-suite/layer4-evolutionary/merging/remote-suite.md
  P2. Frontmatter must comply with validate-suite.sh (name, description, triggers)

## Frontmatter Contract

  F1. name: remote-suite
  F2. description contains "Use when"
  F3. triggers include: install ai-suite, remove ai-suite, check ai-suite status,
      collect evolution, push evolution, deploy ai-suite, remote ai-suite

## Intent-to-Command Mapping

  I1. "install" | "deploy" | "set up"       -> ai-suite enable --scope remote
  I2. "collect" | "sync" | "pull" | "fetch" -> ai-suite evolve collect
  I3. "push" | "send evolution"              -> ai-suite evolve push
  I4. "remove" | "disable" | "uninstall"    -> ai-suite disable --scope remote
  I5. "status" | "check" | "verify"         -> SSH status probe
  I6. Default (ambiguous)                   -> install intent

## Command-Building Rules

  CB1. --host extracted from USER@HOST patterns in user message
  CB2. --agent extracted from: "for cursor" | "for claude" | "for all"; default cursor
  CB3. --domain extracted from: "custom_domain" | "with custom" | "with domain custom_domain"; default none
  CB4. --remote-scope project added when: "project" + path present; else global
  CB5. --remote-path PATH added when explicit path mentioned with install/disable
  CB6. --dry-run added when: "preview" | "dry" | "test" | "what would happen"
  CB7. Multiple USER@HOST patterns -> run ai-suite enable once per host sequentially

## Missing-Host Rule

  MH1. If no USER@HOST pattern detected, skill MUST ask the user
       before running any command -- it must NOT guess a host
  MH2. Question format: "Which remote host? (format: user@hostname)"

## Safety Rules

  SR1. Production pattern warning: if host contains prod | ,
       warn before proceeding and request explicit confirmation
  SR2. After collect: always print copy-paste git commands; never auto-commit
  SR3. Preflight: if ai-suite enable / ai-suite evolve / ai-suite disable not found,
       report the missing file and stop

## Structural Requirements

  S1.  Skill has a "## Operations" section documenting all 5 sub-commands
  S2.  Skill has a "## Examples" section with real prompt -> command pairs
  S3.  Skill has a "## Safety" section
  S4.  Skill has a "## Negative Constraints" section (Must NOT)
  S5.  Skill body <= 600 lines (validate-suite.sh)

## Relationship to evolve-collect.md

  R1. remote-suite covers the FULL lifecycle: install + collect + push + status + disable
  R2. evolve-collect continues to exist for collect/push-only workflows
  R3. When a user asks only about collect/push (no install/status/disable intent),
      either skill may be used; both produce the same ai-suite evolve commands
