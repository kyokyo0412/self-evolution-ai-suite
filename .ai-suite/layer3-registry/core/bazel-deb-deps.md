---
name: bazel-deb-deps
description: Map verified Bazel target dependencies to Debian packages. Use when resolving Debian/Ubuntu build or runtime dependencies for a Bazel target or package.
triggers:
  - bazel deb dependencies
  - debian packages for bazel
  - apt-get install for deb
---

# Bazel to Debian Dependency Analysis

## Inputs and authority

Resolve the Bazel target label, intended Debian/Ubuntu distribution release and architecture, build configuration/toolchain, and available build/package artifacts. Reuse repository packaging rules and lockfiles. Clarify missing essential target/platform identity; do not assume a particular Ubuntu release. This is dependency analysis, not permission to install packages, update a host, or change build definitions.

## Analysis procedure

1. Inspect the target's `deps`, `data`, `srcs`, workspace/module dependencies, and packaging rules (`pkg_deb`, `pkg_tar`, or actual equivalents). Use available source search and authorized read-only query tooling. Bazel analysis/build commands can execute repository hooks or fetch dependencies; inspect their effects and respect offline/network and execution constraints before running them.
2. Separate **build-time tools and headers**, **linked runtime libraries**, **interpreters/services**, and **packaged data**. A Bazel edge alone does not identify a Debian runtime package. Static linkage usually removes that library's runtime dependency but can retain other runtime requirements.
3. Verify artifacts when available: inspect ELF `NEEDED`/interpreter metadata with non-executing tools such as `readelf`, package manifests, and existing dependency-generation output. Do not execute an untrusted target binary or use untrusted executable probes merely to identify its libraries.
4. Map requirements using verified metadata for the selected release/architecture and repository conventions. Distinguish provider packages, `-dev` build packages, alternatives, version constraints, bundled dependencies, and unresolved mappings. Include libc6 only when verified linkage, interpreter, package metadata, or another actual runtime requirement justifies it; never add a universal leaf.
5. Cross-check the proposed package tree against actual packaging output and relevant tests when available. Mark absent artifacts, unavailable package indexes, conditional dependencies, and uncertain mappings as UNVERIFIED; do not substitute plausible package names for evidence.

## Output and recovery

Return the target/platform/configuration, evidence-backed build-time and runtime lists, a dependency tree with the source of each mapping, and unresolved items. Give installation commands only when requested, using verified package names and an identified target environment. Explain any required index refresh separately; it is a proposed host change, not a step authorized by analysis.

If a mapping cannot be verified, complete the independently supported tree and state the exact metadata/artifact needed next. Do not retry unavailable indexes indefinitely, invent dependencies, or claim runtime validation from source inspection alone.

## Negative Constraints (Must NOT)

- [X] Do not install packages, execute target binaries, mutate hosts, or change build rules for an analysis-only request.
- [X] Do not invent package names, universal runtime dependencies, platform compatibility, or validation results.
- [X] Do not suggest upgrades or distribution upgrades outside the user's explicit scope.
- [X] Do not commit, push, expose credentials, or fetch dependencies contrary to session constraints.
