---
name: automate
description: Create and configure Cursor Automations. Use when creating new automations, scheduled agent jobs, or opening the Automations editor.
environments:
  - local
triggers:
  - automate
---
# Create Automation (Interactive)

Use when creating or configuring new **Cursor Automations** (scheduled agent jobs, event-driven workflows, or Automations editor handoffs).

## Instructions & Automation Creation Workflow
1. **Finish-Path Check:** Verify in-app editor capability (`cursor-app-control.open_automation`). If unavailable, prompt: "Please use this skill in the Agents Window." and halt.
2. **Intent & Integrations:** Identify trigger (Cron schedule, git event, Slack), target actions, and ensure referenced MCPs exist and are authenticated.
3. **Cron Syntax:** Convert schedules to standard 5-field cron (e.g. `0 9 * * 1-5`).
4. **Draft Presentation:** Present concise summary table of Name, Trigger, Tools, and Resolved Settings. Obtain user confirmation.
5. **Finish Handoff:** Invoke `cursor-app-control.open_automation` with approved payload.

## Negative Constraints (Must NOT)
- [X] **Do not confuse generic automation with Cursor Automations**: Disambiguate CI/CD, bash scripts, and GitHub Actions from Cursor Automations.
- [X] **Do not expose raw internal tool names or YAML**: Present clean Markdown tables in user chat.
- [X] **Do not prefill unauthenticated MCPs**: Halt drafting until target MCP is authenticated.
- [X] **Do not edit existing automations from chat**: Guide users to edit directly in the Automations UI.
- [X] **Do not proceed without draft approval**: Obtain user confirmation before opening editor handoff.
