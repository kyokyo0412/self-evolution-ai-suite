---
name: loop
description: Run a prompt or skill on a recurring or variable interval. Use when running prompts on a timer or repeating recurring commands.
disabled-environments:
  - cloud
triggers:
  - loop
---
# Loop

Use monitored shell output when the goal is to wake the agent for recurring local work.

## Parse
Accept `/loop [interval] <prompt>`. Units: `s`, `m`, `h`, `d`.

## Fixed Schedule
```bash
while true; do
  sleep <seconds>
  echo 'AGENT_LOOP_TICK_<purpose> {"prompt":"<prompt>"}'
done
```
Start one background shell loop with `notify_on_output` on `^AGENT_LOOP_TICK_<purpose>`. First tick arrives after initial sleep. Track PID to stop if requested.

## Dynamic Schedule
For event-driven loops:
1. Run prompt now.
2. If event-gated, arm background watcher emitting sentinel `^AGENT_LOOP_WAKE_<purpose>`.
3. Arm fallback heartbeat sleeper:
```bash
sleep <seconds>
echo 'AGENT_LOOP_WAKE_<purpose> {"prompt":"<prompt>"}'
```
4. On wake, read payload, execute prompt, and re-arm heartbeat.

## Instructions
Monitor output sentinels and process loop payloads sequentially.

## Negative Constraints (Must NOT)
- [X] Do not leave loop processes running indefinitely after task completion; track and terminate PIDs deterministically.
- [X] Do not fire dynamic wake sentinels before preceding execution completes.
