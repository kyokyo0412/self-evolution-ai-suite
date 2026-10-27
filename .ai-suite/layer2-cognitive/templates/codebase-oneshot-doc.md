# Template: One-Pass Codebase Documentation

**Purpose:** Produce a compact four-layer document under project-relative `aigen_doc/`, or the user's explicitly authorized location.

## Inputs and scope

Resolve repository/revision, included paths, audience, and output file. Preserve existing user content. This is a documentation task, not authority to change application code/configuration.

## Layers

- **Architecture:** Purpose, verified boundaries, entry points, and a useful Mermaid overview.
- **Components:** Interfaces, state, collaborators, and actual cross-component flows.
- **Implementation:** Relevant data structures, algorithms, locks, failure/recovery paths, and source references.
- **Developer enablement:** Verified build/test commands, extension points, and operational guidance.

## Verification and recovery

Complete the scoped document in one pass when evidence and resource limits permit. Check citations and links, run available documentation/diagram validators, and report actual results. If essential source or execution is unavailable, mark claims UNKNOWN and list uncovered scope and the next useful action. Never sacrifice factual accuracy or silently truncate required coverage to satisfy a one-pass label.
