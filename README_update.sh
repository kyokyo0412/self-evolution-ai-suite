#!/usr/bin/env bash
# Update README.md with the new isolation and local collection features
# This is part of the tdd-team Phase 5 documentation step.

set -euo pipefail

# In a real scenario, we would use a more robust way to update the README,
# but for this demonstration, we'll just append a section if it doesn't exist.

if ! grep -q "AI Suite Development Isolation" README.md; then
    cat << 'README_ADD' >> README.md

## AI Suite Development Isolation

When developing the AI suite itself, it is crucial to isolate the source code repository from the runtime configuration of the Augmented Agent.

1.  **Do not use `--scope project` inside the AI suite source repository.** This will mix runtime configurations (like `.cursorrules` and `.cursor/skills`) with the source code.
2.  **Use `--scope global`** to install the AI suite globally on your machine for development purposes.
3.  If you accidentally contaminate the source repository, use the `scripts/clean_dev_env.sh` script to remove the runtime configurations.
4.  To collect evolutions (e.g., new skills) that you have developed locally in your global installation back into the source repository, use the `--local` flag with the collect command:
    ```bash
    ./evolve_suite.sh collect --local
    ```
README_ADD
    echo "README.md updated."
else
    echo "README.md already contains the isolation section."
fi
