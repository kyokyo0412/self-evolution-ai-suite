---
name: loop
description: Schedule recurring local work with supported host scheduling. Use when explicitly requesting /loop or timed recurring commands; use loop-work for a finite number of hardening iterations.
disabled-environments:
  - cloud
triggers:
  - loop
---
# Recurring Work

## Instructions
1. Parse `/loop [interval] <prompt>`, accepting positive intervals with units `s`, `m`, `h`, or `d`. Identify the target, finite repeat count or deadline, and cancellation condition. Ask for a lifetime when none is supplied; do not silently create indefinite work.
2. Inspect the available scheduling or monitored-execution capabilities in the active host. Verify supported arguments, delivery guarantees and cancellation before creating recurring work. Terminal output alone cannot resume an agent session.
3. If scheduling is unavailable, disclose that limit and complete useful work in the current session. Provide a concrete manual scheduling option without claiming it was activated. For a requested finite iteration count without a time requirement, use `loop-work`.
4. With supported scheduling and user authorization, register one job. Keep each run bounded by a timeout, prevent overlapping runs, record its identifier and cancellation command, and preserve the original task permissions for every execution.
5. Report the actual schedule, deadline, last observed result and pending runs. On completion, cancellation or failure, cancel task-created jobs and verify cleanup. Report cleanup failures rather than claiming success.

## Negative Constraints (Must NOT)
- [X] Do not invent scheduler APIs or background wake mechanisms unavailable in the host.
- [X] Do not start unbounded shell loops, detached sleepers or orphaned watchers.
- [X] Do not infer authorization for new actions from a timer, missed response or recurring trigger.
- [X] Do not report future work complete before observing its result.
