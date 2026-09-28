# Plan: toolchain portability of the binary packages

Branch: `toolchain-portability` (from `develop` at `879e033`).

Status: all steps are implemented and verified.  Every package job passes
on the branch (run 36439748460).  The release-publishing job was tested
with a throwaway tag (run 36445391102): it created a draft release with
all 8 archives and a matching `SHA256SUMS`, and no archive is
double-zipped.  The test release and tag were then deleted.  Target release: **3.4.2**, with
rebuilt packages for all platforms, including Intel macOS.

## Results (measured on the branch's packages)

| Package | Needs | GMP | Shared libs shipped |
| --- | --- | --- | --- |
| Linux x86-64 | `GLIBC_2.14`, `GLIBCXX_3.4.22` (was 2.35 / 3.4.30) | static | none |
| macOS arm64 | macOS 13.0 (was 15.0) | static | none (were Homebrew dylibs) |
| macOS x86-64 | macOS 13.0 (new) | static | none |
| Windows x64 | release C runtime only (was debug, for GMP) | static | none (were debug DLLs) |

On macOS every MEX file exports exactly `_mexFunction` and
`_mexfilerequiredapiversion`.  The MATLAB smoke test, including a GMP
code path, passes on all eight package jobs.  The full testsuite (442
tests) passes locally against a static-GMP Linux build.

Deviations from the plan, found along the way:
- Windows: pinned `windows-2022`, not `windows-2025`, because that label
  now serves an image with only Visual Studio 2026 (unsupported by
  R2024b).
- The `bundled` linkage was removed outright rather than kept.

Companion documents: `devel/PORTABILITY.md` (earlier analysis; parts of it
are corrected below), `devel/RELEASE-CONFIG.md`, `devel/CI-WORKFLOW.md`,
`devel/plans/plan-iss165-gmp-portability.md`.

## Background

The first CI run after the trains update (run 36338992088, 2026-09-27)
failed on both macOS jobs while Linux and Windows passed.  This was
unrelated to trains: `libtrains.a` built fine everywhere.  The
`macos-latest` label had moved from macOS 15 to macOS 26 with Xcode 26.6,
and the new linker rejects how CMake links MEX files.

Because the maintainers cannot test on macOS or Windows directly, the
investigation was widened to what the *shipped* binaries actually require.
The released 3.4 archives were inspected with `llvm-objdump` / `objdump` /
`readelf`, and the results compared with MATLAB R2024b's official system
requirements and supported-compilers list.

## Findings

### F1. macOS: MEX link fails with Xcode 26 (blocking)

The error is `Undefined symbols ... _mexCreateMexFunction,
_mexDestroyMexFunction, _mexFunctionAdapter ... referenced from
<initial-undefines>`.  It happens for every MEX file, including the
pure-C `assignmentoptimal`.

CMake 4.4.3's `FindMatlab` (`matlab_add_mex`, APPLE branch) adds MATLAB's
`cppMexFunction.map` to `-exported_symbols_list` for every MEX file.  It
papers over the three C++ MEX API entry points with `-Wl,-U,...`; its own
comment says it uses that map "indiscriminately ... even for C API
MEX-files".  The Xcode 26 linker no longer accepts this.  The old linker
did, but left dangling `[re-export] _mexCreateMexFunction (from unknown)`
entries in the 3.4 binaries.  braidlab uses only the C API (`R2017b`), so
its MEX files need to export exactly `_mexFunction` and
`_mexfilerequiredapiversion`.

### F2. macOS: packages require macOS 15 and Apple Silicon

Every Mach-O file in the 3.4 macOS archive declares `minos 15.0`: all 15
MEX files and the bundled Homebrew GMP dylibs.  That was just the April
runner's OS.  R2024b supports macOS 13.7, 14 and 15, on Intel and Apple
Silicon.  Rebuilt on `macos-26`, the floor would jump to macOS 26.

### F3. Windows: bundled GMP DLLs are debug builds

In the 3.4 archive, `gmp-10.dll` and `gmpxx-4.dll` import the *debug* C
runtime (`VCRUNTIME140D.dll`, `MSVCP140D.dll`, `ucrtbased.dll`).  It is
not redistributable and exists only where Visual Studio is installed.  On
a typical user machine the GMP-backed functions (`cross2gen_helper`,
`loopsigma_helper`, `entropy_helper`) fail to load, and the release and
debug runtimes were being mixed.

Cause: under the multi-config Visual Studio generator `CMAKE_BUILD_TYPE`
is undefined, so vcpkg's toolchain file prefers
`installed/x64-windows/debug`.  `_braidlab_resolve_runtime_dll` then
bundles the debug DLLs.  CI cannot see this because its runner has Visual
Studio installed.

### F4. Linux: packages require glibc 2.35 and GCC 12's libstdc++

| MEX | GLIBC | GLIBCXX |
| --- | --- | --- |
| `randomwalk_helper` | 2.35 (`hypot`) | 3.4 |
| `cross2gen_helper`, `loopsigma_helper` | 2.34 (`pthread_once`) | 3.4.30 |
| `train_helper` | 2.29 | 3.4.29 |
| all others | ≤ 2.29 | ≤ 3.4.15 |

This comes from building on Ubuntu 22.04, not from the code.  R2024b
supports glibc 2.28 and newer (RHEL 8.6+, RHEL 9, Debian 11, Ubuntu 20.04,
and so on), so the 3.4 package does not load on several supported
distributions.

### F5. Floating runner labels

`macos-latest` and `windows-latest` change without notice, which is how
F1 appeared.  Rebuilding the same commit can give different binaries.

### F6. Minor: macOS and Windows release assets are zipped twice

Every GitHub Actions artifact is stored as a zip, whatever it contains.
The release procedure (`devel/CI-WORKFLOW.md`, step 4: attach the
generated archives by hand) attached each artifact's wrapper rather than
its contents.  The Linux `.tar.gz` assets were unwrapped correctly.  The
four `.zip` assets (macOS and Windows, both flavors) are the wrapper: a
valid zip, named correctly, whose only entry is the real zip.  Users who
unzip them get a second zip rather than `+braidlab/`.

## Diagnosis: one root cause, one fragile component

Four of these share one root cause: **the shipped binaries depend on
whatever the build machine has.**

- **Compiler.**  MathWorks supports specific compilers for each release.
  For R2024b those are Xcode 15–16, MSVC 2017–2022 and GCC 8–13.
  `macos-latest` built with Xcode 26, an unsupported combination (F1).
  Runner images with Visual Studio 2026 already exist, so Windows is
  likely next.
- **OS.**  The build OS leaks into the binaries: the macOS deployment
  target (F2) and glibc (F4).

The single most fragile component is **GMP bundling**.  It uses three
per-platform mechanisms (`$ORIGIN` rpath; `@loader_path` plus
`install_name_tool`; DLL co-location with vcpkg resolution), about 420
lines by `devel/PORTABILITY.md`'s own count.  It caused two of the four
binary problems (F2's dylibs, F3).  On Linux it is inert anyway, because
MATLAB loads the system `libgmp` first (via gnutls).

## Strategy

### A. Pin the toolchain to the build release's supported compilers

- **Build release.**  The packages are built once per platform against the
  *oldest* MATLAB release to be supported.  C-API MEX files are forward
  compatible, so one package covers that release and all newer ones.  The
  build release stays **R2024b** (decided).  It sets both the compiler
  pins and the OS floors below.  (Native Apple Silicon MATLAB exists only
  from R2023b, and the older the build release, the sooner its compilers
  disappear from GitHub's images.)
- **Pins for R2024b.**
  - macOS: runner `macos-15`, Xcode 16 selected explicitly with
    `xcode-select`.
  - Windows: runner `windows-2025` with Visual Studio 2022, selected
    explicitly (not whatever is newest on the image).
  - Linux: build inside `quay.io/pypa/manylinux_2_28_x86_64` (AlmaLinux 8,
    glibc 2.28, gcc-toolset in R2024b's range), with MATLAB set up on the
    host and bind-mounted read-only.
  - CMake: a pinned version on every platform (for example via
    `lukka/get-cmake`), not the image's.
  - All pins live next to `BRAIDLAB_RELEASE_MATLAB` in the workflow `env`
    and in `devel/RELEASE-CONFIG.md`.
- **OS floors for R2024b.**
  - `CMAKE_OSX_DEPLOYMENT_TARGET=13.0` (a cache default on APPLE, set
    before `project()`).
  - glibc 2.28 comes from the container.
- **macOS export list** (fixes F1 regardless of linker version).  In
  `braidlab_add_mex`, on APPLE, replace the `LINK_FLAGS` from
  `matlab_add_mex` with `-Wl,-exported_symbols_list,<file>`.  The file is
  braidlab-generated and lists exactly `_mexFunction` and
  `_mexfilerequiredapiversion`.  Nothing else from `matlab_add_mex`
  changes.
- **Maintenance model.**  Nothing changes under the workflow any more.
  The toolchain changes only when braidlab bumps the MATLAB release (then
  the pins are updated from MathWorks' supported-compilers list for that
  release), or when GitHub retires a pinned image.  That is announced
  months ahead and happens roughly yearly.
- **Intel macOS packages** (decided): two more matrix entries (default
  and no-gmp) on `macos-15-intel`.  They use Intel MATLAB R2024b from
  `setup-matlab`, Xcode 16, the same 13.0 deployment target, and a GMP
  static library configured `--enable-fat`, so it does not tune to the
  runner's CPU.  The archive name picks up `x86_64` from `RUNNER_ARCH`
  automatically.  Intel support has a natural end: GitHub is phasing out
  Intel macOS images, and Apple and MathWorks are ending Intel support.
  When `macos-15-intel` is retired, these entries are simply dropped.

### B. Link GMP statically; remove bundling

- **Licensing.**  GMP is dual-licensed under LGPLv3 or GPLv2, each with the
  option of later versions (GMP manual, "Copying").  braidlab is GPLv3+,
  so GMP can be used under GPLv3.  Static linking is ordinary GPL use; the
  obligation is that corresponding source be available, which it already
  is for braidlab.  Ship GMP's license text and a pointer to its source.
  The "LGPL static-linking obligations" concern in `devel/PORTABILITY.md`
  applies to proprietary programs and should be corrected.
- **Static libraries.**  Build a pinned, SHA-256-checked GMP 6.3.0 static
  library per platform in CI, with `--enable-cxx`, and cache it:
  - macOS: `MACOSX_DEPLOYMENT_TARGET=13.0`.  If Intel packages are added,
    `--enable-fat` so it doesn't tune to the runner's CPU.
  - Linux: `--with-pic`, inside the manylinux container.
  - Windows: vcpkg triplet `x64-windows-static-md` (static GMP, dynamic
    release CRT, matching the MEX files), or a source build if that proves
    simpler.
- **Symbol hygiene.**  MATLAB's export map already makes every symbol
  except the MEX entry points local.  So statically linked GMP can't
  collide with the `libgmp.so.10` that MATLAB loads on Linux; add
  `-Wl,--exclude-libs,ALL` there as well.
- **CMake.**  `BRAIDLAB_GMP_LINKAGE` gets a working `static` value, which
  becomes the CI default.  `bundled` is removed along with
  `cmake/BraidlabBundledGMP.cmake`'s install and rpath logic and the three
  per-OS "verify bundled layout" workflow steps.  `system` stays for local
  developer builds, and `off` stays for the no-gmp flavor.
- **Result.**  The GMP-using MEX files have no dependency beyond MATLAB's
  libraries and the OS runtime.  F3 and the dylib half of F2 disappear by
  construction.

### D. Publish release assets from CI (fixes F6)

A `publish_release` job runs only on `release-*` tags, after every
package job succeeds.  `actions/download-artifact` unwraps the
artifacts, so it gets the real archives.  It uploads them with
`gh release upload` to a **draft** GitHub release for the maintainer to
review and publish, together with a `SHA256SUMS` file.  Only this job gets
`permissions: contents: write`.  This replaces the manual step 4 in
`devel/CI-WORKFLOW.md`.

### C. Self-checking builds (deferred)

On the back burner until A and B are done; then decide whether it is
worth it.  The candidates are:
- automated checks of minimum macOS version, glibc/GLIBCXX, exported
  symbols and imported DLLs;
- a monthly non-blocking canary on the `*-latest` images;
- a job that loads the package in the newest MATLAB, to prove the top of
  the version range.

## Implementation order

Each step is one or more commits on this branch.  Each is verified by
dispatching the workflow on the branch
(`gh workflow run build-braidlab-packages.yml --ref toolchain-portability`),
and by inspecting the uploaded archives locally with `llvm-objdump` as was
done for 3.4.  `develop` is not touched until everything is green.

1. **macOS export list and pins** (A).  Unblocks macOS.  Pin `macos-15` +
   Xcode 16, `windows-2025` + VS 2022, and CMake; set the deployment
   target.
2. **Static GMP on macOS and Windows** (B).  Remove bundling there.
3. **Linux in manylinux_2_28 with static GMP** (A + B).  Remove the
   remaining bundling code.
4. **Release publishing job** (D), tested on a throwaway tag such as
   `release-0.0.0-test` against a draft release that is then deleted.
5. **Documentation.**
   - `devel/PORTABILITY.md`: the licensing correction, a minimum-platform
     table, and corrections to Dimension 1 ("MSVC runtime ... largely a
     non-issue") and Dimension 3 ("C++ runtime ... in good shape").
   - `devel/RELEASE-CONFIG.md`: the new pins and how to bump them.
   - `devel/CI-WORKFLOW.md`, `README.md` (supported MATLAB and OS
     versions), `CHANGELOG.md`.

For each step, a manual check of the archives confirms that it did what
it claims: minimum OS, glibc/GLIBCXX, exports, imports, and no bundled
libraries.

## Decisions

- Build release floor: R2024b.
- Ship Intel macOS packages.
- Publish the result as braidlab 3.4.2.
- Fix F6 by publishing release assets from CI (D).
- Self-checking builds (C): deferred until the rest is done.
