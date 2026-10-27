---
name: publish-capability
description: Publish the AI suite capabilities from the current AI suite Agent to an AI suite publish package. Use when you need to publish, package, or export the AI suite capabilities.
triggers:
  - publish capability
  - publish ai suite
  - export agent
  - package capabilities
---

# Publish Capability

Create a local distributable archive through the existing packaging contract; publication to an external service is a separate authorized action.

## Workflow

1. **Resolve context:** In a source checkout, use its verified `ai-suite` launcher. In an installed context, discover the active agent's installed launcher and complete metadata tree. Do not select another agent's directory merely because it exists. Missing or incomplete runtime/manifest resources must fail closed; report migration/reinstallation needs rather than constructing a guessed subset.
2. **Preview:** Run the selected launcher's `publish --dry-run` when requested or useful. It validates the declared distribution artifacts and references without writing an archive. State clearly that this is a preview.
3. **Package:** Resolve the actual archive destination before invoking `publish`: a source launcher writes `ai-suite-package.tar.gz` to its checkout root regardless of the working directory; an installed launcher writes it to the current working directory. The source CLI has no output-path flag. If the user selects another destination, package from an isolated complete source copy and place the newly verified artifact at that destination, preserving existing user artifacts. Do not imply that changing directories redirects source output. The CLI excludes domain packs and validates required adapters/runtime resources; it includes `package-manifest.json`. Do not manually export unrelated custom skills, credentials, memory, or agent directories.
4. **Verify and report:** Verify the archive entries and manifest hashes, report the exact artifact path, and distinguish archive creation from upload. Leave source unchanged and repository changes uncommitted. On failure preserve any pre-existing artifact, report the failed validation, and clean only temporary staging owned by this task.

## Safety and Negative Constraints

- [X] Do not modify source capabilities or install into the developing agent while publishing.
- [X] Do not publish domain content or bypass the package manifest's validation.
- [X] Do not claim success from an incomplete installed context or a dry-run.
- [X] Do not upload, commit, or push without separate scope; git commits and pushes remain user actions.
