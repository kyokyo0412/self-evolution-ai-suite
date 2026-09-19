#!/usr/bin/env bash
set -euo pipefail

# validate_ai_review_fix_multi_url.sh
# Validates the enhanced multi-URL capabilities, local commit generation,
# branch safety, and anti-remote-push constraints in ai-review-fix.md.

FILE="./.ai-suite/layer3-registry/core/ai-review-fix.md"

if [ ! -f "$FILE" ]; then
    echo "Error: $FILE not found." >&2
    exit 1
fi

CONTENT=$(cat "$FILE")
FAILURES=0

assert_pattern() {
    local pattern="$1"
    local desc="$2"
    if echo "$CONTENT" | grep -qiE "$pattern"; then
        echo "  [PASS] $desc"
    else
        echo "  [FAIL] Missing requirement: $desc (pattern: $pattern)" >&2
        FAILURES=$((FAILURES + 1))
    fi
}

echo "=== [SDET Contract Gate] Validating Multi-URL Review-Fix Enhancements ==="

# 1. Multi-URL input and iteration
assert_pattern "(multiple|multi).*(url|review|input)" "Supports multiple review URLs"
assert_pattern "for each.*(url|commit)" "Iterates and processes each URL/commit"

# 2. Downloading / analyzing review commits locally
assert_pattern "(download|fetch|pull|checkout).*(commit|patch|change|url)" "Analyzes and downloads review commits locally"

# 3. Invocation of tdd-team per commit
assert_pattern "tdd-team" "Uses tdd-team to fix comments"

# 4. Local commit creation (commit 1 -> commit 1', commit 2 -> commit 2')
assert_pattern "commit.*(local|locally)" "Creates commits in the local git repository"
assert_pattern "(commit.*'|fix commit|commit.*prime|fixed commit)" "Explicitly creates dedicated fixed commits (e.g., commit 1 -> commit 1')"

# 5. Local repo & branch safety
assert_pattern "(must not|do not|never).*(break|damage|corrupt|alter|overwrite).*(other|existing).*(branch|commit)" "Guarantees other branches and commits in local repo are preserved"

# 6. Anti-remote-push enforcement
assert_pattern "(must not|do not|never|strictly forbidden).*(git push|push.*remote)" "Strictly forbids pushing commits to remote git repo"

# 7. Comprehensive report and patches
assert_pattern "aigen_doc/ai-review-fix-report\.md" "Generates report at aigen_doc/ai-review-fix-report.md"
assert_pattern "(patch|diff|hash)" "Records patches/diffs/hashes in report"

# 8. vLLM execution clarity
assert_pattern "(state machine|step-by-step|deterministic)" "Clear, structured execution sequence for vLLM AI agent"

# 9. Existing quality and formatting contracts preserved
assert_pattern "parallel tool calls" "Enforces parallel tool calls"
assert_pattern "(readlints|linter|quality check)" "Enforces linter/quality checks"
assert_pattern "gofmt" "Preserves gofmt standard"
assert_pattern "clang-format" "Preserves clang-format standard"
assert_pattern "gitreview" "Preserves gitreview red-flag avoidance"
assert_pattern "(defer|context manager|deterministic.*resource)" "Preserves deterministic resource lifecycles"

echo "=== Summary ==="
if [ "$FAILURES" -gt 0 ]; then
    echo "FAIL: $FAILURES contract checks failed." >&2
    exit 1
fi

echo "PASS: All multi-URL ai-review-fix contracts verified."
exit 0
