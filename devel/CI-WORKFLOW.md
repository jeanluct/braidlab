# Braidlab CI Workflow (Practical Guide)

This document explains how the GitHub Actions workflow should be used in
practice for day-to-day development and release packaging.

Workflow file: `.github/workflows/build-braidlab-packages.yml`

Config knobs reference: `devel/RELEASE-CONFIG.md`

## What the CI pipeline does

At a high level, CI does four things:

1. Builds `doc/braidlab_guide.pdf` once.
2. Builds platform-specific package artifacts with CMake + MATLAB smoke tests.
3. On release tags, attaches those archives to a draft GitHub release.
4. Runs an Ubuntu compatibility lane against the latest MATLAB (non-blocking).

The release/package jobs produce archives that include:

- `+braidlab/` (in the default flavor, GMP is linked statically into the
  MEX files that use it)
- `extern/gmp/` (default flavor: GMP's license texts and a README)
- `extern/VariablePrecisionIntegers/` (John D'Errico's VPI toolbox,
  required by braidlab's arbitrary-precision MATLAB code paths)
- `examples/` (top-level example scripts referenced by the guide and
  testsuite)
- `doc/braidlab_guide.pdf`
- `testsuite/` (copied as-is)
- `README.md`, `LICENSE`, `COPYING`, `CHANGELOG.md`
- `BUILD-MANIFEST.txt`

## Intended operating model (after moving off the issue branch)

This is the practical model to run CI long-term:

- `pull_request`: always enabled (main quality gate for development).
- `push` to stable branches (`master` and `develop`).
- `push` tags matching `release-*` (release packaging trigger).
- `workflow_dispatch` for manual reruns and experiments.

Manual runs can override the pinned MATLAB release via input
`matlab_release` (default `R2024b`).

All pinned/overridable workflow values are documented in
`devel/RELEASE-CONFIG.md`.

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

## 2) `release_pinned` (matrix: Linux, macOS arm64/x86_64, Windows)

Purpose:

- Produce the distributable package archives.
- Use a pinned MATLAB release for deterministic packaging behavior.

Platform/flavor matrix (runner images pinned; see
`devel/RELEASE-CONFIG.md` for the toolchain pins):

- `ubuntu-22.04` -> archive `.tar.gz`.  This is only the host: the build
  runs in a pinned `manylinux_2_28` container (glibc 2.28,
  gcc-toolset-13) via `.github/scripts/build-linux-manylinux.sh`, with
  MATLAB bind-mounted read-only.
- `macos-15` (Apple silicon) and `macos-15-intel` -> archive `.zip`, with
  Xcode 16.4 and deployment target 13.0.
- `windows-2022` -> archive `.zip`, with Visual Studio 2022.

Each platform produces one package, with GMP linked statically into the
MEX files (`-DBRAIDLAB_GMP_LINKAGE=static`).  Users do not need GMP
installed, and the package ships no shared libraries.  (There is no
longer a `no-gmp` package flavor; see `nogmp_check` below.)

Static GMP per platform (pinned version and checksum):

- Linux, macOS: built by `.github/scripts/build-gmp-static.sh` (running
  GMP's own tests) and cached with `actions/cache`.
- Windows: `vcpkg install gmp:x64-windows-static-md`, with
  `CMAKE_BUILD_TYPE=Release` so vcpkg does not pick its debug libraries.

Key implementation details:

- Installs into an isolated `stage/` directory (`cmake --install ... --prefix stage`).
- Downloads the PDF artifact into `stage/doc`.
- Checks the staged MEX files: none may depend on GMP, no shared
  libraries may be shipped, and on Windows none may import the debug C
  runtime.  On Linux, `libmex`/`libmx` must be recorded by basename.
- Runs a MATLAB smoke test against the staged install; the smoke test
  exercises a GMP-backed code path (`braidlab.braid.entropy`) on every
  flavor where GMP is enabled.
- Copies metadata + `testsuite/` + `examples/` +
  `extern/VariablePrecisionIntegers/` into `stage/`.
- Writes `BUILD-MANIFEST.txt` with commit/release/platform/flavor
  metadata, including `flavor`, `gmp_linkage` and `gmp_version`.
- Archives selected directories/files from `stage/`.
- Uploads archive as GitHub artifact.

Version naming behavior:

- Tag run (`refs/tags/release-*`): version comes from tag suffix.
- Non-tag run: version is `dev-<short_sha>`.

Archive naming format:

`braidlab-<version>_<platform>-<arch>_matlab-<release>.<ext>`

Examples:

- `braidlab-3.4.2_linux-glibc2.28-x86_64_matlab-R2024b.tar.gz`
- `braidlab-dev-a1b2c3d_macos-arm64_matlab-R2024b.zip`
- `braidlab-dev-a1b2c3d_macos-x86_64_matlab-R2024b.zip`

## 2b) `publish_release` (release tags only)

Runs after every `release_pinned` job succeeds, on pushed `release-*` tags
only.  It downloads the package archives (`actions/download-artifact`
unwraps the artifact zips), writes `SHA256SUMS`, and attaches both to a
**draft** GitHub release titled `braidlab <version>`, whose notes are the
`## [<version>]` section of `CHANGELOG.md` at the tagged commit.  If the
release already exists, its assets are replaced.  It is the only job with
`contents: write`.

## 2c) `nogmp_check` (GMP-off build, not published)

Builds braidlab with `-DBRAIDLAB_GMP_LINKAGE=off`, the configuration used
by developers without GMP.  It then runs a MATLAB smoke test: `entropy`,
plus a loop with VPI coordinates, which takes the MATLAB fallback that
replaces GMP and must match double precision.  It uploads nothing, and
`publish_release` does not wait for it.

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

The full, step-by-step procedure (exact commands, conflict rules, checks,
and the two approval gates) is `devel/RELEASING.md`.  In short:

1. Prepare `CHANGELOG.md` on `develop` and a release branch
   (`devel/release-prep.py` makes the text edits).
2. Merge into `master` and tag `release-<version>`; push after approval.
3. `publish_release` creates a draft release: all archives, `SHA256SUMS`,
   and the `CHANGELOG.md` section as notes.
4. Verify the draft (checksums, archive contents, testsuite on the
   package), then publish after approval.
5. Review `compat_latest`; if failing, log follow-up if not release-critical.

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

For maintainers, use `devel/RELEASE-CONFIG.md` as the source of truth for:

- what values are pinned,
- which repository variables can override them, and
- what to bump during a release cycle.

When changing CI defaults, update both:

1. `.github/workflows/build-braidlab-packages.yml`
2. `devel/RELEASE-CONFIG.md`

---

If you want, this file can be split into:

- a short contributor-facing `README` section, and
- a maintainer-facing release runbook.

## Open questions (answered)

- Q: How do I know users can use the build? Will it fail if GMP is not
  installed on the user's system?
  A: The package jobs intentionally run a MATLAB smoke test after install,
  so each artifact is at least load-tested before upload.  Since 3.4.2 the
  MEX files link GMP statically, so users never need GMP installed, and no
  GMP library ships in the package.  CI checks that no MEX depends on GMP
  and that no shared libraries are shipped.  (Issue #165 originally
  bundled GMP shared libraries next to the MEX files; see the
  static-linking question below for why that changed.)

- Q: Can we make the Makefile system a wrapper for CMake? It would be nice if
  `make clean; make` still worked.
  A: Yes. This is now implemented to keep developer muscle memory.
  Current behavior for top-level `Makefile` wrapper targets:
  - `make` / `make all` -> `cmake -S . -B build` then `cmake --build build -j`
  - `make install` -> configure/build if needed, then `cmake --install build --prefix .`
  - `make clean` -> `cmake --build build --target clean` (if `build/` exists)
  - `make distclean` -> remove `build/` and generated doc artifacts
  This lets legacy commands work while the actual build logic lives in CMake.

- Q: I used to build binaries manually and attach them to the release. How will
  this work now?
  A: It is automated.  Push tag `release-<version>`; CI builds all
  platform archives, and the `publish_release` job attaches them, with a
  `SHA256SUMS` file and the `CHANGELOG.md` section as notes, to a draft
  GitHub release.  Check it and publish.  The whole procedure is in
  `devel/RELEASING.md`.  (Attaching by hand put the artifact wrappers,
  zips inside zips, on 3.4's macOS and Windows assets.)

- Q: Lots of things are hardwired in YAML (versions, etc.). Is that a problem?
  A: Some pinning is intentional for reproducibility, but you are right that
  hardcoding should be minimized. This is now implemented:
  - Pinned defaults are centralized in workflow `env`.
  - Dynamic values remain runtime-derived (tag version, commit SHA, arch).
  - Maintainer overrides are available via workflow input and repository
    variables.
  - `devel/RELEASE-CONFIG.md` documents what to bump and where.

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
  A: Yes, and since 3.4.2 that is what the packages do
  (`-DBRAIDLAB_GMP_LINKAGE=static`).  Issue #165 first chose bundling,
  partly because of LGPLv3 relinking obligations.  But GMP is dual-licensed,
  LGPLv3 or GPLv2, each with the option of later versions.  braidlab is
  GPLv3+, so it uses GMP under the GPLv3, where static linking only
  requires that source be available.  Bundling also turned out to be the
  most fragile part of the packaging:
  - it needed three per-platform loader mechanisms;
  - Homebrew's dylibs required macOS 15;
  - vcpkg's DLLs were debug builds;
  - on Linux, MATLAB's own libgmp shadowed it anyway.
  See `devel/plans/plan-toolchain-portability.md`.
