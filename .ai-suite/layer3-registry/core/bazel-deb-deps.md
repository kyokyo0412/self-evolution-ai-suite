---
name: bazel-deb-deps
description: Map Bazel build targets into Debian/Ubuntu apt runtime and build dependency trees. Use when resolving Debian dependencies for Bazel targets or determining package installations for a .deb.
triggers:
  - bazel deb dependencies
  - debian packages for bazel
  - apt-get install for deb
---

# Bazel -> Debian Dependency Analyzer

Translates Bazel-declared build targets and dependency rules into precise Debian/Ubuntu `apt` dependency trees, distinguishing runtime dependencies from build-time prerequisites.

## Analysis Procedure
1. **Target Inspection:** Ripgrep `deps`, `data`, and `srcs` of target label, workspace dependencies, and packaging rules (`pkg_deb`, `pkg_tar`).
2. **Classification:**
   - *Static:* Link into binary; requires build host `-dev` package only.
   - *Dynamic:* Requires runtime shared library (`libfoo3`) and `-dev` package.
   - *Source/Codegen:* Build-time toolchain only.
3. **Mapping:** Resolve verified package names for target Ubuntu release (jammy, noble).

## Required Output Structure
```
## Build-Time vs Runtime Dependencies
- Build-Time: <list of -dev packages and toolchains>
- Runtime:    <list of shared libraries>

## Debian Package Dependency Tree
<target-deb>
\---- libc6

## Installation Commands
sudo apt-get update && sudo apt-get install -y <runtime packages>
```

## Negative Constraints (Must NOT)
- [X] **Do not invent package names**: Use verified Debian/Ubuntu package names.
- [X] **Do not omit libc6 from tree leaves**: Root canonical dependency must be explicit.
- [X] **Do not propose apt-get install without apt-get update**: Always refresh package index first.
- [X] **Do not suggest apt-get upgrade or dist-upgrade**: Upgrade operations are strictly out of scope.
