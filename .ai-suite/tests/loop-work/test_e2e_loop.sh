#!/bin/bash
set -euo pipefail

echo "Running E2E System QA Gate for loop-work enhancements..."

# Validate the architecture, requirements, contracts, deep checks, identical task invariants, state reassessment logging, and full iteration enforcement
.ai-suite/tests/loop-work/validate_contract.sh
.ai-suite/tests/loop-work/validate_requirements.sh
.ai-suite/tests/loop-work/validate_loop_work_architecture.sh
.ai-suite/tests/loop-work/validate_loop_work_requirements.sh
.ai-suite/tests/loop-work/validate_identical_task_invariant.sh
.ai-suite/tests/loop-work/validate_loop_work_deep.sh
.ai-suite/tests/loop-work/validate_loop_work_state_reassessment.sh
.ai-suite/tests/loop-work/validate_full_iteration_enforcement.sh

echo "E2E System QA Gate passed successfully."
exit 0
