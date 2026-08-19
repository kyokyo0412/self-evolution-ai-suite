# Validate Suite Semantic Contracts

## Context
To ensure AI suite evolution is always positive, effective, and safe, `validate-suite.sh` must enforce semantic structure on all skill files, not just frontmatter syntax.

## Contracts

### V1. Frontmatter Triggers
- **Contract:** The frontmatter MUST contain a `triggers:` array.
- **Validation:** `validate-suite.sh` must parse the frontmatter and fail if `triggers:` is missing or empty.

### V2. Negative Constraints / Safety Section
- **Contract:** The skill body MUST contain a section heading that matches `Negative Constraints`, `Safety Rules`, `Safety Constraints`, or `Rules of Engagement`.
- **Validation:** `validate-suite.sh` must grep the body for these keywords (case-insensitive) and fail if none are found.

### V3. Instructions / Workflow Section
- **Contract:** The skill body MUST contain a section heading that matches `Instructions`, `Workflow`, `Role`, `Context`, or `Artifact Catalog`.
- **Validation:** `validate-suite.sh` must grep the body for these keywords (case-insensitive) and fail if none are found.

### V4. Backward Compatibility
- **Contract:** All existing skills in `.ai-suite/layer3-registry/core/` and `.ai-suite/layer1-abstraction/agents/cursor/skills/` MUST pass the new validation rules without modification, or we must update them to comply.
