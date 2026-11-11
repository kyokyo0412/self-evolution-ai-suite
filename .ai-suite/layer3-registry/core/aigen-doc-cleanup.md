---
name: aigen-doc-cleanup
description: Review and clean generated or temporary artifacts from the repository's aigen_doc directory while preserving design documents and their sources. Use when asked to clean up aigen_doc or prepare its contents for a repository change.
triggers:
  - clean aigen_doc
  - cleanup aigen_doc
  - clean generated documentation artifacts
  - prepare aigen_doc for commit
---

# aigen_doc Cleanup

Review repository `aigen_doc/` contents and remove only artifacts proven disposable. Design documents, their references, and files needed to revise or regenerate them are project sources and must remain.

## Instructions

1. Resolve the repository root with Git and confirm the target is exactly `<repository-root>/aigen_doc`. Do not follow a symlinked directory outside the repository. If the repository or target cannot be confirmed, stop and report the evidence needed.
2. Inspect `git status --short -- aigen_doc`, tracked paths from `git ls-files -- aigen_doc`, and a sorted inventory of files. Preserve pre-existing modifications, staged changes, ignored files, and every untracked file whose disposable status is not established. Do not change the Git index.
3. Start with a dry-run review. Read every Markdown file and build a local reference set from inline and reference-style Markdown links and images, HTML `href`/`src` values, and explicit source-file mentions. Resolve relative links from the document directory and repository-root links from the root. Ignore external URLs, email links, and fragment-only links. Follow references recursively when a referenced file itself names local inputs. Report missing references; never treat a broken link as permission to delete related files.
4. Keep every `.md` file, including reports, plans, prompts, and drafts. Keep every referenced local file regardless of extension. Also keep source files and reusable inputs needed to edit or regenerate documents, including diagram sources (for example `.mmd`, `.mermaid`, `.drawio`, `.puml`, `.plantuml`, and `.dot`), templates, data inputs, publication assets, and files whose purpose is unclear. An embedded Mermaid source block remains part of its Markdown document.
5. Consider removal only for files with positive evidence that they are disposable execution residue, such as caches, bytecode, temporary backups, process markers, logs, or clearly named generated test/verification outputs. File extension, untracked status, age, or being ignored is not sufficient evidence by itself. Do not remove a file merely because it is JSON or is not linked from Markdown. Keep files whose purpose is unclear or uncertain.
6. Present a dry-run table with each candidate's path, Git state, reason it is disposable, and reference/source checks. Exclude all Markdown, referenced files, reusable source inputs, tracked files, and any file with existing user changes from deletion candidates. Retain uncertain files.
7. For a user-requested cleanup, remove only the reviewed, untracked, unchanged candidates from the confirmed `aigen_doc/` directory. Use bounded path-specific removal; never use recursive wildcard deletion. If a candidate is tracked, staged, modified, ignored, or its ownership is unclear, leave it in place and report it for user review.
8. Re-scan the directory and all Markdown references after cleanup. Confirm no retained document lost a local reference, report removed and retained candidates, and show the final `git status --short -- aigen_doc`. Do not commit or stage changes.

## Safety Rules

- Never blanket-delete all files, all untracked files, or all files of a particular extension.
- Never delete a Markdown document, a local reference target, or a source needed for future edits or publication.
- Never infer disposability from a filename alone; inspect content and Git state.
- Never overwrite or normalize documents during cleanup. This skill removes eligible residue only.
- If a safe candidate cannot be established, preserve the file and explain the uncertainty.

## Negative Constraints

- Do not delete user-authored content, design documents, references, or reusable inputs.
- Do not alter the Git index, commit, or push.
- Do not expand cleanup outside the repository's `aigen_doc/` directory.
