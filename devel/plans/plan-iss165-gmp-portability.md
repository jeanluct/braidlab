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

- Linux: GMP usually present, but not on minimal containers/older
  distros.
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
  package** for macOS and Windows archives.  Linux archives stay as
  system-dependency (with documented `apt`/`dnf` install instructions)
  for now.
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

## Per-OS bundling design

### macOS

- Install GMP in CI deterministically via Homebrew (`brew install gmp`).
- After `cmake --install`, copy `libgmp.<ver>.dylib` and
  `libgmpxx.<ver>.dylib` from the Homebrew prefix into the staged
  package (proposed location: `+braidlab/private/_lib/`).
- Adjust install names so MEX files resolve GMP via `@loader_path`:
  - On each MEX file: `install_name_tool -change <abs path>
    @loader_path/../../private/_lib/libgmp.<ver>.dylib <mex>`
    (and same for `libgmpxx`).
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

- Keep dynamic system linkage as default for the standard archive.
- Document required runtime packages in README:
  - Debian/Ubuntu: `apt install libgmp10 libgmpxx4ldbl`.
  - RHEL/Fedora: `dnf install gmp gmp-c++`.
- Optional follow-up (out of scope unless requested): produce a
  fully-bundled Linux variant by copying `libgmp.so.*`/`libgmpxx.so.*`
  into a sibling `lib/` directory and setting `RPATH=$ORIGIN/_lib` on
  MEX files via `patchelf` or `CMAKE_INSTALL_RPATH`.

## CMake changes

Proposed additions to `CMakeLists.txt`:

- Replace the boolean `BRAIDLAB_USE_GMP` with a string option
  (or supplement it):
  - `BRAIDLAB_GMP_LINKAGE` with values `system` (default), `bundled`,
    `static`, `off`.
  - `system` → current behavior (link to system GMP, no copying).
  - `bundled` → link to system GMP at build time but install GMP
    runtime libs into the staged package and adjust rpaths/install
    names.
  - `static` → link `libgmp.a`/`libgmpxx.a` statically (gated, opt-in,
    per-platform care; not enabled in default CI).
  - `off` → equivalent to current `BRAIDLAB_USE_GMP=OFF`.
- New install rules (when `BRAIDLAB_GMP_LINKAGE=bundled`) that copy
  GMP shared libraries into the install tree at the OS-appropriate
  location.
- macOS: handle install names with `install_name_tool` in a post-install
  script; or use `BUNDLE`/`fixup_bundle`-style helpers.
- Linux (deferred): set `INSTALL_RPATH` to `$ORIGIN/_lib` on the GMP
  MEX targets when bundling is enabled.

Backward compatibility: keep `BRAIDLAB_USE_GMP=ON|OFF` working as an
alias mapping to `BRAIDLAB_GMP_LINKAGE=system|off` so existing scripts
do not break.

## Workflow changes

In `.github/workflows/build-braidlab-packages.yml`:

- Add a deterministic GMP install step per OS (Homebrew, vcpkg/MSYS2,
  apt) instead of relying on runner default state.
- Add a `flavor` matrix dimension or a parallel job to produce both:
  - default flavor with GMP bundled (macOS/Windows) or system-dep
    (Linux);
  - `no-gmp` flavor with `BRAIDLAB_GMP_LINKAGE=off`.
- Archive-name suffix `_no-gmp` on the no-GMP flavor.
  - Open question: should the GMP-on archive remain unsuffixed or be
    explicitly tagged `_with-gmp`?  Recommend unsuffixed for the
    primary download.
- Update `BUILD-MANIFEST.txt` to record `gmp_linkage=<value>`.
- Replace the macOS conditional GMP-on/off step with an explicit, fixed
  policy per flavor.

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
  absolute path on macOS/Windows (i.e., not `@loader_path` / co-located
  DLL).

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
  toolchain compatibility with MATLAB MEX.
- Should Linux archives also bundle GMP for a uniform UX, or stay as
  system-dependency?  Default plan: stay as system-dependency unless
  users complain.
- Should every release ship both GMP-on and `no-gmp` flavors, or only
  on demand?  Default plan: ship both for tagged releases; ship only
  GMP-on flavor for `dev-*` PR artifacts to keep CI minutes down.
- Archive naming: keep GMP-on archive unsuffixed (recommended) or tag
  it `_with-gmp` for symmetry with `_no-gmp`?
- `BRAIDLAB_GMP_LINKAGE` value names: `system|bundled|static|off` vs
  `dynamic|bundled|static|off` — second option is clearer for the
  end-user-relevant axis (system vs bundled).

## Acceptance criteria

- `BRAIDLAB_GMP_LINKAGE` (or equivalent) implemented in CMake with at
  least `system`, `bundled`, and `off` values.
- macOS and Windows release-pinned archives ship with bundled GMP and
  load on a clean user system without any GMP install.
- A `no-gmp` flavor archive is produced per OS for tagged releases.
- Smoke-test step verifies MEX dependency paths and exercises at least
  one GMP-using code path.
- README updated with runtime requirements per flavor and
  per OS.
- `devel/ci-workflow.md` and `devel/release-config.md` updated with the
  new flavor knobs.
- Issue #165 closed with a recorded decision (default policy =
  `bundled` on macOS/Windows; static link kept as opt-in).

## Status

- 2026-04-23: branch created from
  `iss163-continuous-integration-github`; plan drafted.
