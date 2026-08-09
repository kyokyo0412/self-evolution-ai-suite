---
name: bazel-deb-deps
description: Analyze Bazel BUILD/WORKSPACE/MODULE.bazel files and translate them into an exact Ubuntu/Debian apt runtime + build-time dependency tree for the target .deb. Use when the user asks about Debian/Ubuntu package dependencies for a bazel-built binary, library, or VIB, or when figuring out what apt-get install commands are required to deploy a .deb.
triggers:
  - bazel deb dependencies
  - debian packages for bazel
  - apt-get install for deb
---

# Bazel → Debian Dependency Analyzer

Translate Bazel-declared dependencies into a precise apt package tree. Distinguish runtime vs build-time. Cite real Debian/Ubuntu package names — never invent.

## Inputs the User Will Provide

- Path(s) to `BUILD`, `BUILD.bazel`, `WORKSPACE`, `WORKSPACE.bazel`, or `MODULE.bazel`.
- The target label (e.g., `//crx/dns/monitor:dns-monitor-deb`).
- Optionally: target Ubuntu release codename (focal/jammy/noble).

If any are missing, ask.

## Analysis Procedure

1. **Enumerate Bazel deps**
   - Read the target's `deps`, `data`, `srcs`, and transitive `cc_library` / `go_library` deps with Grep.
   - For external repos referenced (e.g., `@com_github_grpc_grpc//...`, `@boringssl//...`, `@openssl//...`), check `WORKSPACE`/`MODULE.bazel` for `http_archive`/`git_repository`/`bzlmod` records.
   - Detect `pkg_deb`, `pkg_tar`, `pkg_zip`, `tar_pkg` rules — these are the .deb staging rules; record their `data`, `version`, `description`, `depends`, `preinst`/`postinst` attributes.

2. **Classify each dependency**
   - **Statically linked** (default for many `cc_library` with `linkstatic = 1`) → no runtime apt dep, but build-time `-dev` package required on the build host.
   - **Dynamically linked** → both runtime SO package (`libfoo3`) and build-time dev package (`libfoo-dev`) are required.
   - **Pure source** (header-only, codegen) → build-time `-dev` only.
   - **External binary downloaded by toolchain** (e.g., gobuild fetches envoy) → record the URL/hash and treat as embedded, not apt.

3. **Map to Debian package names**
   - Use exact apt names. Cross-check against the target Ubuntu release; package names can change (e.g., `libssl1.1` on focal vs `libssl3` on jammy).
   - If a Bazel external repo has no obvious apt equivalent (vendored library, custom build), say so and flag for the user.

4. **Construct the hierarchical tree**

## Required Output Structure

```
## Analysis / Translation
<concise reasoning: how each Bazel dep maps to apt>

## Build-Time vs Runtime
- Build-Time: <list of -dev packages, bazel itself, compilers>
- Runtime:    <list of SO / executable packages>

## Debian Package Dependency Tree
<target-deb-name>
├── <runtime-pkg-1>
│   ├── <transitive-1>
│   └── <transitive-2>
├── <runtime-pkg-2>
│   └── libc6
└── libc6

## Validation / Apt Commands
sudo apt-get update
sudo apt-get install -y <space-separated runtime packages>

# Build-time (for the build host only):
sudo apt-get install -y <space-separated -dev packages>

## Dockerfile Snippet
```dockerfile
# Runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    <space-separated runtime packages> \
    && rm -rf /var/lib/apt/lists/*
```
```

## Negative Constraints (Must NOT)

- ❌ Do not invent package names. If unsure, name the closest known package and flag it: `# UNVERIFIED: <pkg>`.
- ❌ Do not list a `-dev` package as a runtime requirement.
- ❌ Do not mix Ubuntu release-specific SO version names (e.g., `libssl1.1` and `libssl3`) without explicitly noting the target release.
- ❌ Do not omit `libc6` from the tree leaves — it is the canonical root and proves you analyzed transitive deps.
- ❌ Do not propose `apt-get install` without `apt-get update` first.
- ❌ Do not propose `apt-get upgrade` or `dist-upgrade` — those are out of scope and may break production.

## Verification

After producing the tree, the user should be able to run on a fresh container:

```bash
docker run --rm -it ubuntu:22.04 bash -c \
    "apt-get update -qq && apt-get install -y --simulate <pkgs from tree>"
```

…and see all packages resolve with no `E: Unable to locate` errors.

If `apt-cache madison <pkg>` returns nothing, the mapping is wrong — revise.
