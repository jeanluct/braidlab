# Braidlab CI Workflow (Practical Guide)

This document explains how the GitHub Actions workflow should be used in
practice for day-to-day development and release packaging.

Workflow file: `.github/workflows/build-braidlab-packages.yml`

Config knobs reference: `devel/release-config.md`

## What the CI pipeline does

At a high level, CI does three things:

1. Builds `doc/braidlab_guide.pdf` once.
2. Builds platform-specific package artifacts with CMake + MATLAB smoke tests.
3. Runs an Ubuntu compatibility lane against the latest MATLAB (non-blocking).

The release/package jobs produce archives that include:

- `+braidlab/`
- `doc/braidlab_guide.pdf`
- `testsuite/` (copied as-is)
- `README.md`, `LICENSE`, `COPYING`, `CHANGELOG.md`
- `BUILD-MANIFEST.txt`

## Intended operating model (after moving off the issue branch)

This is the practical model to run CI long-term:

- `pull_request`: always enabled (main quality gate for development).
- `push` to stable branches (`master` and `develop`).
- `push` tags matching `release-*` (release packaging trigger; also gates
  the `no-gmp` flavor build).
- `workflow_dispatch` for manual reruns and experiments.

Manual runs can override the pinned MATLAB release via input
`matlab_release` (default `R2024b`).

All pinned/overridable workflow values are documented in
`devel/release-config.md`.

## Manual runs and overrides

Use manual runs when you want to validate packaging behavior without pushing a
new commit.

### Run manually from GitHub UI

1. Open repository -> `Actions` -> `Build Braidlab Packages`.
2. Click `Run workflow`.
3. Select the branch to run.
4. Set `matlab_release` if you want to override the pinned MATLAB for this run.
5. Start the run and inspect `release_pinned` artifacts when complete.

### Run manually from CLI

From repository root:

```bash
gh workflow run build-braidlab-packages.yml --ref master -f matlab_release=R2024b
```

Track runs:

```bash
gh run list --workflow "Build Braidlab Packages"
gh run watch <run-id>
```

### Override precedence (important)

For `BRAIDLAB_RELEASE_MATLAB`, the workflow resolves values in this order:

1. Manual input `matlab_release` (workflow_dispatch only)
2. Repository variable `BRAIDLAB_RELEASE_MATLAB`
3. Workflow default `BRAIDLAB_RELEASE_MATLAB_DEFAULT`

For other knobs there is no manual input currently, so precedence is:

1. Repository variable
2. Workflow default

Current repository-variable override knobs:

- `BRAIDLAB_RELEASE_MATLAB`
- `BRAIDLAB_COMPAT_GCC_MAJOR`
- `BRAIDLAB_LATEX_PACKAGES`
- `BRAIDLAB_BUILD_PARALLEL`

Set these under:

- `Settings` -> `Secrets and variables` -> `Actions` -> `Variables`

### Practical examples

- One-off test against a newer MATLAB without changing defaults:
  - Run manually with `matlab_release=R2025a`.
- Team-wide pin update for routine runs:
  - Set repo variable `BRAIDLAB_RELEASE_MATLAB=R2025a`.
- Slow or overloaded runners:
  - Reduce `BRAIDLAB_BUILD_PARALLEL` to `2`.
- Toolchain refresh in compat lane:
  - Set `BRAIDLAB_COMPAT_GCC_MAJOR=13` and watch compat results.

### Recommended trigger configuration

This is the trigger shape currently in use:

```yaml
on:
  push:
    branches:
      - develop
      - master
    tags:
      - "release-*"
  pull_request:
  workflow_dispatch:
    inputs:
      matlab_release:
        description: MATLAB release for the release-pinned lane
        required: true
        default: R2024b
        type: string
```

### Practical meaning for maintainers

- Normal feature work: open a PR; CI runs and validates changes.
- Merge to `master`: CI runs again on push to confirm integrated state.
- Create `release-*` tag: CI builds release-named artifacts for all platforms.
- Need ad hoc validation: run manually with `workflow_dispatch`.

## Job-by-job breakdown

## 1) `docs_pdf`

Purpose:

- Build the PDF guide exactly once on Ubuntu.
- Upload as artifact `docs-pdf` for reuse.

Why this exists:

- Avoid redundant LaTeX builds in every platform lane.

## 2) `release_pinned` (matrix: Linux/macOS/Windows × flavor)

Purpose:

- Produce the distributable package archives.
- Use a pinned MATLAB release for deterministic packaging behavior.

Platform/flavor matrix:

- `ubuntu-22.04` -> archive `.tar.gz`
- `macos-latest` -> archive `.zip`
- `windows-latest` -> archive `.zip`

Each platform produces two flavors:

- `default` (always built): GMP runtime libraries are bundled inside the
  archive (`-DBRAIDLAB_GMP_LINKAGE=bundled`).  Users do not need GMP
  installed on their system.
- `no-gmp`: GMP-using code paths are compiled out
  (`-DBRAIDLAB_GMP_LINKAGE=off`).  Smaller archive with zero GMP
  runtime dependency, for users on stripped or GMP-incompatible
  environments.  Built on every push so GMP-free build regressions
  surface immediately.

GMP is installed deterministically per OS in CI before configuring CMake:

- Linux: `apt-get install -y libgmp-dev libgmpxx4ldbl libgmp10`.
- macOS: `brew install gmp`.
- Windows: `vcpkg install gmp:x64-windows`; CMake is pointed at the
  vcpkg toolchain file via `CMAKE_TOOLCHAIN_FILE`.

Key implementation details:

- Configures and builds with CMake using `BRAIDLAB_GMP_LINKAGE` (system,
  bundled, or off) per matrix entry.
- Installs into an isolated `stage/` directory (`cmake --install ... --prefix stage`).
- Downloads the PDF artifact into `stage/doc`.
- Runs a per-OS dependency check on the staged GMP-using MEX files
  (`ldd` on Linux, `otool -L` on macOS, `Get-ChildItem` on Windows) for
  the bundled flavor; fails if a MEX still resolves GMP to a system path
  instead of the co-located bundled copy.
- Runs a MATLAB smoke test against the staged install; the smoke test
  exercises a GMP-backed code path (`braidlab.braid.entropy`) on every
  flavor where GMP is enabled.
- Copies metadata + `testsuite/` into `stage/`.
- Writes `BUILD-MANIFEST.txt` with commit/release/platform/flavor
  metadata, including the `flavor` and `gmp_linkage` fields.
- Archives selected directories/files from `stage/`.
- Uploads archive as GitHub artifact.

Version naming behavior:

- Tag run (`refs/tags/release-*`): version comes from tag suffix.
- Non-tag run: version is `dev-<short_sha>`.

Archive naming format:

`braidlab-<version>_<platform>-<arch>_matlab-<release>[_no-gmp].<ext>`

Examples:

- `braidlab-3.4.0_linux-ubuntu-22.04-x86_64_matlab-R2024b.tar.gz`
- `braidlab-3.4.0_linux-ubuntu-22.04-x86_64_matlab-R2024b_no-gmp.tar.gz`
- `braidlab-dev-a1b2c3d_macos-arm64_matlab-R2024b.zip`

## 3) `compat_latest` (Ubuntu, allow-failure)

Purpose:

- Early warning lane for newest MATLAB/runtime behavior.

Important behavior:

- Skipped for release tag pushes.
- `continue-on-error: true` so it does not block packaging artifacts.
- Uses latest available MATLAB.
- Forces GCC 12 toolchain to reduce libstdc++ ABI mismatch risk.

Interpretation:

- If this lane fails while release-pinned lanes pass, shipping is usually still
  safe; investigate separately.

What "non-blocking" means in practice:

- This lane is informational by default (`continue-on-error: true`).
- A failure here should create a follow-up issue, but does not block release
  artifact generation from the pinned lanes.
- If team policy changes later, this lane can be made required in branch
  protection without redesigning the workflow.

## Why local build/test can differ from CI

CI package jobs install into `stage/` on purpose:

- It guarantees a clean package layout.
- It prevents accidental leakage from local paths.

Local developer flow is different and should remain simple:

- Build: `cmake -S . -B build`
- Compile: `cmake --build build -j`
- Install in-place: `cmake --install build --prefix .`

This mirrors the classic `make` workflow where built MEX files land in-place.

## Performance parity note (Make vs CMake)

Historically, `make` was faster because it always built optimized MEX binaries,
while CMake in single-config mode could default to empty `CMAKE_BUILD_TYPE`
(unoptimized).

Current fix:

- `CMakeLists.txt` defaults single-config builds to `Release` when unset.

Expected result:

- CMake test runtime should now be closer to classic `make` runtime.

## Practical release checklist

1. Merge release candidate changes to `master`.
2. Ensure `release_pinned` matrix jobs are green on `master`.
3. Create and push release tag: `release-<version>`.
4. Verify tag-triggered artifacts are generated for Linux/macOS/Windows.
5. Confirm each archive contains docs + metadata + `testsuite/`.
6. Review `compat_latest`; if failing, log follow-up if not release-critical.

## Practical development checklist

1. Open a PR from feature branch.
2. Wait for `docs_pdf` + `release_pinned` lanes to complete.
3. Treat `compat_latest` failures as warnings unless they indicate imminent
   runtime breakage.
4. Merge when required checks pass.
5. If needed, use `workflow_dispatch` to retest with a different MATLAB pin.

## Troubleshooting guide

If macOS MATLAB smoke test fails with runtime library issues:

- Check dynamic library path handling in the smoke test step
  (`DYLD_LIBRARY_PATH` setup).

If Ubuntu compat lane fails with C++ runtime symbols:

- Confirm GCC 12 installation and compiler selection were applied.
- Confirm `LD_PRELOAD` workaround is in effect for compat smoke test.

If package is missing expected files:

- Verify copy steps into `stage/` before archive creation.
- Verify archive command includes all required paths explicitly.

If local MATLAB tests do not find braidlab:

- Ensure in-place install was run (`--prefix .`).
- Ensure MATLAB path includes repository root and `testsuite/`.

## Team policy decisions to lock in

- Which push branches should run CI (`master` only vs `master` + `develop`)?
- Keep smoke tests only, or add periodic full testsuite runs?
- Keep `compat_latest` non-blocking, or promote to required later?
- How often to bump the default pinned MATLAB release from `R2024b`?

## Where to change pinned values

For maintainers, use `devel/release-config.md` as the source of truth for:

- what values are pinned,
- which repository variables can override them, and
- what to bump during a release cycle.

When changing CI defaults, update both:

1. `.github/workflows/build-braidlab-packages.yml`
2. `devel/release-config.md`

---

If you want, this file can be split into:

- a short contributor-facing `README` section, and
- a maintainer-facing release runbook.

## Open questions (answered)

- Q: How do I know users can use the build? Will it fail if GMP is not
  installed on the user's system?
  A: The package jobs intentionally run a MATLAB smoke test after install, so
  each artifact is at least load-tested before upload.  As of issue #165,
  GMP portability is handled at packaging time:
  - The default-flavor archive ships with GMP runtime libraries bundled
    inside the package (`-DBRAIDLAB_GMP_LINKAGE=bundled`), co-located
    with the GMP-using MEX files in `+braidlab/@braid/private/`.  The
    MEX files load these via `$ORIGIN` (Linux) / `@loader_path` (macOS)
    / DLL co-location (Windows).  Users do not need GMP installed.
  - A `no-gmp` flavor archive (built on every push) compiles out
    the GMP-using code paths (`-DBRAIDLAB_GMP_LINKAGE=off`) for
    users who explicitly want zero GMP runtime dependency.
  - Per-OS dependency-check steps (`ldd`/`otool -L`) verify in CI that
    the bundled-flavor MEX files resolve GMP to the co-located library,
    not to a system path.

- Q: Can we make the Makefile system a wrapper for CMake? It would be nice if
  `make clean; make` still worked.
  A: Yes. That is a good migration path and keeps developer muscle memory.
  Recommended behavior for top-level `Makefile` wrapper targets:
  - `make` / `make all` -> `cmake -S . -B build` then `cmake --build build -j`
  - `make install` -> `cmake --install build --prefix .`
  - `make clean` -> `cmake --build build --target clean`
  - `make distclean` -> remove `build/` and generated doc artifacts
  This lets legacy commands work while the actual build logic lives in CMake.

- Q: I used to build binaries manually and attach them to the release. How will
  this work now?
  A: The intended flow is tag-driven packaging in CI:
  1. Merge release-ready changes to `master`.
  2. Push tag `release-<version>`.
  3. CI builds all platform archives and uploads workflow artifacts.
  4. Create/edit the GitHub Release and attach those generated archives.
  Optional next step: automate step 4 by adding a release-publish job that runs
  only on `release-*` tags and uploads artifacts directly to the GitHub Release.

- Q: Lots of things are hardwired in YAML (versions, etc.). Is that a problem?
  A: Some pinning is intentional for reproducibility, but you are right that
  hardcoding should be minimized. This is now implemented:
  - Pinned defaults are centralized in workflow `env`.
  - Dynamic values remain runtime-derived (tag version, commit SHA, arch).
  - Maintainer overrides are available via workflow input and repository
    variables.
  - `devel/release-config.md` documents what to bump and where.

- Q: Is there a way to run the testsuite through `ctest`?
  A: Yes. The clean approach is to add a CTest test that shells out to MATLAB
  in batch mode and returns nonzero on failure. Practical implementation:
  - In `CMakeLists.txt`, call `enable_testing()`.
  - Add a test like:
    - `matlab -batch "cd('<repo>'); addpath(pwd); addpath(fullfile(pwd,'testsuite')); res=test_braidlab; nfail=sum([res.Failed]); if nfail>0, exit(1); end"`
  - Keep this opt-in for CI (for example `BRAIDLAB_ENABLE_FULL_TESTSUITE=ON`),
    because full tests are slower than smoke tests.
  Recommended policy:
  - Keep smoke tests in package lanes.
  - Add full testsuite via `ctest` in a dedicated job (nightly or required on
    `master` only).

- Q: Follow-up to GMP question above: can we statically-link GMP so the user
  doesn't have to have it installed on their system?
  A: As of issue #165, the chosen solution is to bundle GMP shared
  libraries inside the package rather than to static-link.  Tradeoffs
  considered:
  - Static linking pros: fewer runtime files in the archive.
  - Static linking cons: larger MEX binaries, per-platform maintenance
    overhead, and LGPLv3 relink obligations for shipped static libs.
  - Bundling pros: same end-user effect (no system GMP required), keeps
    distribution under simple LGPL dynamic-redistribution rules, and
    lets users replace the bundled libraries with their own build.
  Static linking remains a deferred opt-in
  (`-DBRAIDLAB_GMP_LINKAGE=static`, currently unimplemented and rejected
  at configure time) for the rare case where bundling is unsuitable.
