# Plan: GMP portability for distributed MEX artifacts (issue #165)

Tracks the design and implementation of end-user portability for the
GMP-using MEX components in braidlab.  Originally scoped narrowly to a
static-linking investigation, this issue is now scoped around the broader
question of how to ship MEX binaries that load on user systems without
requiring the user to install GMP themselves.

Companion documents:

- `devel/portability.md` — analysis of CI portability and recommended
  policy.
- `devel/ci-workflow.md` — operational use of the CI workflow.
- `devel/release-config.md` — pinned values and override knobs.
- `devel/plans/plan-iss163-continuous-integration-github.md` — CI work
  this branch builds on.
- `devel/plans/plan-iss162-cmake-conversion.md` — CMake migration work.

Branch: `iss165-GMP-portability` (based on
`iss163-continuous-integration-github`).

## Background

The GMP-using MEX targets are:

- `+braidlab/@braid/private/cross2gen_helper`
- `+braidlab/@braid/private/loopsigma_helper`
- `+braidlab/@braid/private/entropy_helper`

Per `devel/portability.md`, GMP is the only realistic portability hazard
for distributed archives:

- Linux: GMP is widely available (`libgmp10`, `libgmpxx4ldbl`) on
  workstation distros, but minimal containers, HPC compute nodes, and
  older base images frequently lack it; users without root cannot
  `apt install` to fix it.
- macOS: GMP not in the base system; users without Homebrew GMP cannot
  load these MEX files.
- Windows: GMP is not available by default; current Windows archives
  built with `BRAIDLAB_USE_GMP=ON` would fail to load on a clean user
  system.

The current macOS workflow step also flips `BRAIDLAB_USE_GMP` on/off
depending on Homebrew availability, which makes the resulting archive
non-deterministic with respect to feature set.

## Decision

- Default policy: **bundle dynamic GMP runtime libraries inside the
  package** for all three OS archives (Linux, macOS, Windows).  Linux
  baseline runner is `ubuntu-22.04`, matching the existing pinned
  release lane; the resulting archive runs on glibc/libstdc++ from
  Ubuntu 22.04 or newer (and equivalent on RHEL/Fedora).
- Provide an alternate **`no-gmp` package flavor**
  (`BRAIDLAB_USE_GMP=OFF`) per OS for users who want zero GMP runtime
  dependency or who use a stripped environment.
- Static GMP linking remains a **deferred optional**: kept as a
  documented build-system option, not the default, for the reasons in
  `devel/portability.md` (LGPL relink obligations, larger binaries,
  per-platform maintenance overhead).
- Make the GMP policy a **first-class build flavor** rather than an
  environment-detected fallback, so artifacts are deterministic for a
  given workflow input.
- Bundling is a **CI/packaging concern only**.  Local developer builds
  remain `system` linkage by default and are unchanged from today.

## Per-OS bundling design

### macOS

- Install GMP in CI deterministically via Homebrew (`brew install gmp`).
- After `cmake --install`, copy `libgmp.<ver>.dylib` and
  `libgmpxx.<ver>.dylib` from the Homebrew prefix into the same
  directory as the GMP-using MEX files
  (`+braidlab/@braid/private/`).  Co-locating with the MEX files
  keeps the rpath/install-name handling uniform across all three OSes
  and avoids a separate `_lib/` directory.
- Adjust install names so MEX files resolve GMP via `@loader_path`:
  - On each MEX file: `install_name_tool -change <abs path>
    @loader_path/libgmp.<ver>.dylib <mex>` (and same for `libgmpxx`).
  - Adjust the bundled `libgmpxx` to find `libgmp` via
    `@loader_path/libgmp.<ver>.dylib`.
- Verify with `otool -L <mex>` in the smoke-test step that GMP resolves
  to a relative path, not an absolute Homebrew path.

### Windows

- Install GMP in CI from a deterministic source.  Two candidates:
  - **vcpkg** (`vcpkg install gmp:x64-windows`).
  - **MSYS2 mingw64** (`pacman -S mingw-w64-x86_64-gmp`).
- DLL search on Windows checks the directory of the loading binary
  first, so co-locate `libgmp-*.dll` and `libgmpxx-*.dll` next to the
  `.mexw64` files in `+braidlab/@braid/private/`.
- Verify with `dumpbin /dependents` (or PowerShell equivalent) in the
  smoke-test step that DLLs resolve to the bundled copies.
- Open question: confirm MSVC vs MinGW ABI compatibility with MATLAB
  MEX — choose toolchain accordingly.

### Linux

- Baseline runner: `ubuntu-22.04` (matches existing release-pinned
  matrix entry).  Resulting GMP shared libs are compatible with any
  Linux distro running glibc >= 2.35 / libstdc++ from GCC 11 or newer,
  which covers all currently-supported mainstream distros.
- Install GMP in CI deterministically via apt
  (`sudo apt-get install -y libgmp-dev libgmpxx4ldbl libgmp10`).
- After `cmake --install`, copy `libgmp.so.<ver>` and
  `libgmpxx.so.<ver>` from the system path into the same directory as
  the GMP-using MEX files (`+braidlab/@braid/private/`), matching the
  macOS and Windows layouts.
- Set `INSTALL_RPATH` to `$ORIGIN` (with `$ORIGIN` properly escaped
  for CMake) on the GMP-using MEX targets when bundling is enabled,
  so they resolve GMP from the bundled co-located copy at MEX load
  time.  No `patchelf` post-processing required.
- Verify with `ldd <mex>` in the smoke-test step that GMP resolves to
  the bundled co-located library, not a system path.

## CMake changes

Proposed additions to `CMakeLists.txt`, kept intentionally minimal:

- New string option `BRAIDLAB_GMP_LINKAGE` with values
  `system` (default), `bundled`, `static`, `off`.
  - `system` → current behavior: link to system GMP, copy nothing.
    Used by local developer builds.
  - `bundled` → link to system GMP at build time, install GMP runtime
    libs into the staged package, set rpaths/install-names so MEX
    files resolve them locally.  Used by CI release jobs.
  - `static` → link `libgmp.a`/`libgmpxx.a` statically (gated, opt-in,
    per-platform care; not enabled in default CI).
  - `off` → equivalent to current `BRAIDLAB_USE_GMP=OFF`.
- Backward compatibility: keep `BRAIDLAB_USE_GMP=ON|OFF` working as an
  alias mapping to `BRAIDLAB_GMP_LINKAGE=system|off` so existing
  scripts do not break.

GMP-not-found diagnostic policy (replaces today's silent fallback to
`OFF`):

- If `BRAIDLAB_GMP_LINKAGE` is `system`, `bundled`, or `static`
  (whether explicitly set or inherited from the default), and
  `find_package`/`find_library` cannot locate GMP and gmpxx, emit a
  single `FATAL_ERROR` with a short multi-line diagnostic that
  suggests per-OS install commands and points to
  `-DBRAIDLAB_GMP_LINKAGE=off` as the explicit opt-out.
- If `BRAIDLAB_GMP_LINKAGE=off` is explicitly set, emit a normal
  `STATUS` message confirming the no-GMP build (no warning).
- The diagnostic stays in a single `message(FATAL_ERROR ...)` call to
  keep `CMakeLists.txt` readable.

Install-rule additions (only active when
`BRAIDLAB_GMP_LINKAGE=bundled`):

- Resolve the actual GMP shared library files via
  `get_filename_component(... REALPATH)` so symlink chains are followed
  to the versioned `.so`/`.dylib`/`.dll`.
- Install those resolved files into the same directory as the
  GMP-using MEX files (`+braidlab/@braid/private/`), giving a uniform
  co-located layout across all three OSes.
- macOS: post-install fix-up step using `install_name_tool` to rewrite
  GMP install-name references to `@loader_path/<libname>`.
  Implemented as an `install(CODE ...)` block to keep it
  self-contained.
- Linux: set `INSTALL_RPATH` on the GMP-using MEX targets to
  `\$ORIGIN` (escaped for CMake), with `INSTALL_RPATH_USE_LINK_PATH OFF`
  to avoid leaking absolute paths.
- Windows: no install-name/rpath fix-up needed; DLL co-location with
  the MEX file is sufficient.

## Workflow changes

In `.github/workflows/build-braidlab-packages.yml`:

- Add a deterministic GMP install step per OS (apt on Linux, Homebrew
  on macOS, vcpkg or MSYS2 on Windows) instead of relying on runner
  default state.  Replace the existing macOS conditional GMP-on/off
  branch with an unconditional install + bundled build.
- Pass `-DBRAIDLAB_GMP_LINKAGE=bundled` in the `release_pinned` matrix
  for all three OSes.
- Add a `flavor` matrix dimension producing both archives:
  - default flavor with GMP bundled on all OSes;
  - `no-gmp` flavor with `-DBRAIDLAB_GMP_LINKAGE=off`.
- Archive-name suffix `_no-gmp` on the no-GMP flavor; primary
  GMP-bundled archive remains unsuffixed.
- Build the `no-gmp` flavor on every push so GMP-free build
  regressions surface immediately.  (Original plan was to gate on
  `refs/tags/release-*`, but matrix context is not allowed in
  job-level `if`, and the no-gmp jobs are cheap because they skip
  GMP install and bundled-layout verification.)
- Update `BUILD-MANIFEST.txt` to record `gmp_linkage=<value>`.

## Smoke-test additions

Augment the existing MATLAB smoke test to:

- Call one of the GMP-using helpers (e.g. `cross2gen_helper` via a
  high-level braid operation) so that GMP load failures surface in CI,
  not on user machines.
- Run a platform-appropriate dependency check on at least one GMP MEX:
  - macOS: `otool -L`.
  - Linux: `ldd`.
  - Windows: `dumpbin /dependents` or PowerShell `Get-ItemProperty`.
- Fail the job if any GMP-related symbol resolves to an unexpected
  absolute path on macOS/Linux (i.e., not `@loader_path` / `_lib/`)
  or to a missing DLL on Windows.

## Licensing

GMP and GMPXX are LGPLv3.  Dynamic redistribution is straightforward:

- Ship `COPYING.LESSER` (or equivalent) with the archive when GMP libs
  are bundled.
- Add a short README note acknowledging GMP and informing users they
  can replace the bundled GMP libraries with their own build.

Static linking imposes additional obligations (provide object files or
equivalent so users can relink).  Staying out of static-link default
keeps distribution simple.

## Validation strategy

1. Build all flavors in CI on every PR to this branch.
2. Inspect MEX dependencies in CI smoke test as described above.
3. Local validation: download an artifact on a clean container/VM
   without GMP installed and run the smoke test.
4. For the `no-gmp` flavor, confirm the relevant MATLAB code paths
   either fall back gracefully or raise informative errors.

## Cherry-pick / integration notes

The work cleanly separates into two layers:

- **CMake layer**: `BRAIDLAB_GMP_LINKAGE` option, install rules,
  rpath/install-name handling.  Reusable independently and can be
  cherry-picked onto `iss162-cmake-conversion` or `develop` if useful.
- **Workflow layer**: GMP install steps, matrix expansion, archive
  naming, smoke-test additions.  Depends on the iss163 workflow file
  and stays on this branch until iss163 lands.

Recommended merge order:

1. iss163 → master (or develop).
2. Rebase iss165 onto the new tip.
3. iss165 → master (or develop).

## Open questions

- Windows GMP source: **vcpkg** vs **MSYS2 mingw64**?  Decision affects
  toolchain compatibility with MATLAB MEX on `windows-latest`.
  Working assumption: start with **vcpkg** (`vcpkg install
  gmp:x64-windows`) and adjust empirically if MEX load fails on
  Windows.
- `BRAIDLAB_GMP_LINKAGE` value names: `system|bundled|static|off` vs
  `dynamic|bundled|static|off`.  Current plan uses `system|bundled|...`
  because `system` more clearly contrasts with `bundled` along the
  end-user-relevant axis.
- Linux baseline upgrade: keep `ubuntu-22.04` until end of support, or
  proactively introduce a second `ubuntu-24.04` baseline lane?  Default
  plan: stay on 22.04 for now; revisit when 22.04 nears EOL.

## Implementation sequencing

This plan is gated on the prior CI work landing first.  Recommended
order of operations:

1. Finish and merge `iss163-continuous-integration-github` into
   `develop`.
2. Rebase `iss165-GMP-portability` onto the new `develop` tip.
3. Implement in two phases on the rebased branch:
   - **Phase A — CMake only.**  Locally testable, no CI dependency.
     Adds `BRAIDLAB_GMP_LINKAGE`, the `BRAIDLAB_USE_GMP` alias, the
     GMP-not-found `FATAL_ERROR` diagnostic, and the `bundled`-mode
     install rules (rpath/install-name handling per OS).  Validate
     locally with `-DBRAIDLAB_GMP_LINKAGE=bundled` and `ldd`.
   - **Phase B — Workflow.**  Requires the iss163 workflow file to be
     present on the integration target.  Adds the per-OS GMP install
     steps, the flavor matrix, archive-naming changes, manifest
     `gmp_linkage` field, and the smoke-test dependency checks.
     Discover Windows GMP issues empirically here rather than via a
     pre-implementation spike.

## Acceptance criteria

- `BRAIDLAB_GMP_LINKAGE` implemented in CMake with at least `system`,
  `bundled`, and `off` values, plus the `BRAIDLAB_USE_GMP` alias for
  backward compatibility.
- `FATAL_ERROR` GMP-not-found diagnostic with per-OS install hints in
  place; silent fallback to no-GMP removed.
- All three release-pinned archives (Linux/macOS/Windows) ship with
  bundled GMP and load on a clean user system without any GMP install.
- A `no-gmp` flavor archive is produced per OS on every push.
- Smoke-test step verifies MEX dependency paths and exercises at least
  one GMP-using code path on every flavor.
- README updated with runtime requirements per flavor and per OS, plus
  install hints mirroring the CMake diagnostic.
- `devel/ci-workflow.md` and `devel/release-config.md` updated with the
  new flavor knobs.
- Local developer build behavior (default `system` linkage) confirmed
  unchanged from today.
- Issue #165 closed with a recorded decision (default policy =
  `bundled` on all OSes; static link kept as opt-in).

## Status

- 2026-04-23: branch created from
  `iss163-continuous-integration-github`; plan drafted.
- 2026-04-23: plan revised — Linux now in the bundling default with
  `ubuntu-22.04` baseline; GMP-not-found diagnostic policy added;
  `no-gmp` flavor scoped to tagged releases only; open questions
  trimmed.
- 2026-04-23: rebased onto `develop` after `iss163` merged; bundled
  GMP layout simplified to co-locate libs with the GMP-using MEX
  files (`+braidlab/@braid/private/`) on all three OSes, replacing
  the earlier `+braidlab/private/_lib/` proposal.
- 2026-04-23: Phase A landed (commit `39f3823`).  CMake-only changes:
  `BRAIDLAB_GMP_LINKAGE` option, `BRAIDLAB_USE_GMP` alias, GMP-not-found
  `FATAL_ERROR` with per-OS hints, SONAME-resolving install rules for
  bundled mode, and macOS install_name_tool fix-up.  Validated locally
  on Ubuntu 24 + MATLAB R2025a.
- 2026-04-23: Phase B drafted.  Workflow updated with per-OS GMP
  install steps (apt/brew/vcpkg), `flavor` matrix dimension producing
  `default` (bundled) and tag-gated `no-gmp` archives, per-OS
  bundled-layout verification (`ldd`/`otool`/PowerShell), GMP-using
  smoke-test code path (`braid.entropy`), `flavor`/`gmp_linkage`
  fields in `BUILD-MANIFEST.txt`, and triggers switched from the
  iss163 branch to `develop`/`master`.  `compat_latest` left on the
  `BRAIDLAB_USE_GMP=ON` alias.  Awaiting first CI run on `develop` to
  validate macOS install_name_tool block and Windows vcpkg path.
- 2026-04-23: workflow YAML rejected by GitHub on first push.  Fixed
  two issues: (a) `env.X_DEFAULT` self-references in the `env:` block
  are not allowed — defaults inlined into each `||` fallback chain;
  (b) `matrix` context is not allowed in job-level `if` — dropped the
  tag-gate and now run the `no-gmp` flavor on every push (cheap and
  catches GMP-free regressions early).
