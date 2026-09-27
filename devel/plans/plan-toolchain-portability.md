# Plan: toolchain portability of the binary packages

Branch: `toolchain-portability` (from `develop` at `879e033`).

Status: plan only; nothing implemented yet.  To be discussed before
starting.

Companion documents: `devel/PORTABILITY.md` (earlier analysis; parts of it
are corrected below), `devel/RELEASE-CONFIG.md`, `devel/CI-WORKFLOW.md`,
`devel/plans/plan-iss165-gmp-portability.md`.

## Background

The first CI run after the trains update (run 36338992088, 2026-09-27)
failed on both macOS jobs while Linux and Windows passed.  The failure is
unrelated to trains (`libtrains.a` built fine on every platform): the
`macos-latest` runner label had moved from macOS 15 to macOS 26 with
Xcode 26.6, and the new linker rejects how CMake links MEX files.

Because the maintainers cannot test on macOS or Windows directly, the
investigation was widened to what the *shipped* binaries actually require.
The released 3.4 archives were downloaded and inspected with
`llvm-objdump` / `objdump` / `readelf`, and the results compared with
MATLAB R2024b's official system requirements.  This uncovered three
further problems that CI cannot see, because each runner happens to have
exactly the environment that hides them.

## Findings

### F1. macOS: MEX link fails with Xcode 26 (blocking)

```
Undefined symbols for architecture arm64:
  "_mexCreateMexFunction", referenced from: <initial-undefines>
  "_mexDestroyMexFunction", ...
  "_mexFunctionAdapter", ...
```

This happens for every MEX file, including the pure-C `assignmentoptimal`.
The runner has CMake 4.4.3.  Its `FindMatlab` (`matlab_add_mex`, APPLE
branch) always adds MATLAB's `cppMexFunction.map` to
`-exported_symbols_list`, and papers over the three C++ MEX API entry
points with `-Wl,-U,_mexCreateMexFunction` etc.  Its own comment says it
uses that map "indiscriminately ... even for C API MEX-files".  Even
MATLAB's C export map lists those three symbols.  The Xcode 26 linker no
longer accepts `-U` for an exported symbol that is not defined anywhere.

The old linker did accept it, but produced odd binaries: the 3.4 MEX
files carry dangling `[re-export] _mexCreateMexFunction (from unknown)`
entries next to the real exports `_mexFunction` and
`_mexfilerequiredapiversion`.

braidlab uses only the C API (`R2017b`), so its MEX files define exactly
two symbols that MATLAB needs: `_mexFunction` (our source) and
`_mexfilerequiredapiversion` (MATLAB's `c_mexapi_version.c` /
`cpp_mexapi_version.cpp`, which `matlab_add_mex` compiles in).

### F2. macOS: packages require macOS 15 (and Apple Silicon)

Every Mach-O file in the 3.4 macOS archive declares `minos 15.0`: all 15
MEX files and the bundled Homebrew `libgmp.10.dylib` /
`libgmpxx.4.dylib`.  That was simply the OS of the April runner.  MATLAB
R2024b supports macOS 13.7, 14 and 15, on both Intel and Apple Silicon.
So braidlab 3.4 cannot load on macOS 13/14, and there is no Intel
package.  Rebuilt today on `macos-26`, the floor would silently jump to
macOS 26, both for our code and for the Homebrew bottles.

### F3. Windows: bundled GMP DLLs are debug builds

In the 3.4 Windows archive, `gmp-10.dll` imports `VCRUNTIME140D.dll` and
`ucrtbased.dll`, and `gmpxx-4.dll` also imports `MSVCP140D.dll` and
`VCRUNTIME140_1D.dll`.  These are Microsoft's *debug* C runtime.  It is
not redistributable and is present only on machines with Visual Studio.
On a typical user's machine the GMP-backed functions
(`cross2gen_helper`, `loopsigma_helper`, `entropy_helper`) will fail to
load.  The MEX files themselves use the release runtime, so release and
debug C runtimes were also being mixed across a DLL boundary, which risks
heap corruption.

Cause: the Visual Studio generator is multi-config, so `CMAKE_BUILD_TYPE`
is undefined (`CMakeLists.txt` sets it only for single-config
generators).  In that case vcpkg's toolchain file deliberately prepends
`installed/x64-windows/debug` to the search paths.  `find_library` then
returns `debug/lib/gmp.lib`, and `_braidlab_resolve_runtime_dll` in
`cmake/BraidlabBundledGMP.cmake` derives the DLL from that path.  Pinning
`VCPKG_TARGET_TRIPLET` in the workflow did not prevent this.  The CI
smoke test passes because the runner has Visual Studio installed.

### F4. Linux: packages require glibc 2.35 and GCC 12's libstdc++

Maximum symbol versions required by the 3.4 Linux MEX files:

| MEX | GLIBC | GLIBCXX |
| --- | --- | --- |
| `randomwalk_helper` | 2.35 (`hypot`) | 3.4 |
| `cross2gen_helper`, `loopsigma_helper` | 2.34 (`pthread_once`) | 3.4.30 (`condition_variable::wait`) |
| `train_helper` | 2.29 | 3.4.29 |
| all others | ≤ 2.29 | ≤ 3.4.15 |

These come only from building on Ubuntu 22.04 (glibc 2.35), not from the
code.  MATLAB R2024b supports glibc 2.28 and newer: RHEL 8.6+ (2.28),
RHEL 9 (2.34), Debian 11 (2.31), Ubuntu 20.04 (2.31), and so on.  So the
3.4 Linux package does not load on several supported distributions.
`GLIBCXX_3.4.30` also needs MATLAB's bundled `libstdc++` to come from
GCC 12 or newer; this should be checked against R2024b's copy in CI
rather than assumed.

### F5. Floating runner labels

`macos-latest` and `windows-latest` change under the workflow without
notice.  That is how F1 appeared between April and September, and it
means that rebuilding the same commit can produce different binaries.

### F6. Minor: release assets are zipped twice

Each release asset is a zip containing the actual `.zip`/`.tar.gz`
archive, a side effect of downloading CI artifacts to attach them.

### Corrections to `devel/PORTABILITY.md`

- Dimension 1 ("MSVC runtime ... largely a non-issue") holds for our MEX
  files but not for the bundled GMP DLLs (F3).
- Dimension 3 ("C++ runtime ... in good shape") holds on the build
  runner but not for users on older glibc or macOS (F2, F4).
- Missing entirely: the minimum OS versions of the shipped binaries.

## Goals and non-goals

Target: every archive loads on every platform that the pinned MATLAB
release (R2024b) supports:

- macOS 13.0 or newer, on Apple Silicon and (optionally) Intel.
- Linux x86-64 with glibc 2.28 or newer.
- Windows 10/11 x64 without Visual Studio installed.

Each property should be enforced by an automated CI check, not by
reasoning, since it cannot be tested by hand here.

Non-goals: changing the MATLAB release pin, static GMP linking, Windows
or Linux on ARM64, and running the full testsuite in CI.

## Stages

Each stage is one or more commits on this branch.  It is verified by
dispatching the workflow on the branch
(`gh workflow run build-braidlab-packages.yml --ref toolchain-portability`),
reading the job logs, and inspecting the uploaded archives locally with
`llvm-objdump` as was done for 3.4.  `develop` is not touched until
everything is green.

### A. macOS export list (fixes F1)

- In `braidlab_add_mex` (`CMakeLists.txt`), on APPLE only, replace the
  `LINK_FLAGS` that `matlab_add_mex` set with
  `-Wl,-exported_symbols_list,<file>`, where `<file>` is a
  braidlab-generated list containing exactly `_mexFunction` and
  `_mexfilerequiredapiversion`.  Leave everything else from
  `matlab_add_mex` (compile definitions, `-fvisibility=default`, the
  version source) unchanged.
- This does not depend on how any linker version treats `-U`, and it
  produces cleaner binaries than 3.4 (no dangling re-exports).
- CI check (macOS): every `.mexmaca64` exports exactly those two symbols
  and has no re-exports (`nm -gU` / `dyld_info -exports`).
- Risk: low.  The existing smoke test proves that MATLAB loads the
  result.

### B. macOS 13 floor (fixes F2)

- `CMAKE_OSX_DEPLOYMENT_TARGET` defaults to `13.0` on APPLE (a cache
  variable, overridable).  It must be set before `project()`.
- Bundled GMP: build GMP 6.3.0 from the official tarball (with its
  SHA-256 checked) using `MACOSX_DEPLOYMENT_TARGET=13.0 --enable-cxx`,
  cached with `actions/cache` keyed on GMP version, target, arch and
  image.  This replaces Homebrew, whose bottles are built for the
  runner's own OS.  Check that the existing `@loader_path` install-name
  rewrite in `BraidlabBundledGMP.cmake` works with a non-Homebrew prefix.
- CI check (macOS): every Mach-O file in `stage/` has `minos ≤ 13.0`
  (`vtool -show-build` or `otool -l`).
- Runtime proof: a small extra job on the oldest available macOS runner
  (`macos-14`) downloads the arm64 archive built on `macos-26`, installs
  R2024b, and runs the smoke test.  This actually exercises older-OS
  loading instead of only inferring it.
- Risk: moderate.  GMP needs about 2 minutes to build and is cached.

### C. Windows release GMP (fixes F3)

- Configure the Windows jobs with `-DCMAKE_BUILD_TYPE=Release` so vcpkg's
  toolchain prefers the release prefix.  In
  `BraidlabBundledGMP.cmake`, fail at configure time on WIN32 if the
  resolved GMP library or DLL path contains `/debug/`.
- CI check (Windows): for every `.mexw64` and `.dll` in `stage/`, list the
  imports (`dumpbin /dependents`) and fail on any debug runtime
  (`*D.dll` variants of `MSVCP`/`VCRUNTIME`, `ucrtbased.dll`).  Also fail
  on any import outside an allowlist: system `api-ms-win-*`,
  `KERNEL32`, the VC++ 2015+ runtime, `libmex`/`libmx`, and the bundled
  GMP DLLs.
- Risk: low.  The import check is the proof; the runner cannot simulate
  a machine without Visual Studio.

### D. Linux glibc 2.28 floor (fixes F4)

- Build the Linux release jobs inside `quay.io/pypa/manylinux_2_28_x86_64`
  (AlmaLinux 8, glibc 2.28, gcc-toolset).  Run `setup-matlab` on the
  host and bind-mount the MATLAB root read-only into the container at the
  same path, then configure with `-DMatlab_ROOT_DIR=...`.  GMP comes from
  AlmaLinux 8's `gmp-devel` / `gmp-c++`; bundling copies those libraries,
  which are themselves built for glibc 2.28.
- gcc-toolset links newer C++ runtime pieces statically
  (`libstdc++_nonshared`), so the MEX files should only need GCC 8's
  `GLIBCXX` (3.4.25).
- The smoke test then runs in host MATLAB on the container-built stage,
  as now.
- CI check (Linux): maximum `GLIBC_` ≤ 2.28 across all MEX files and
  bundled `.so` files, and maximum `GLIBCXX_`/`CXXABI_` ≤ what MATLAB's own
  `sys/os/glnxa64/libstdc++.so.6` provides.  The existing absolute-path
  check stays.
- Risk: the largest stage.  Points to confirm: that `FindMatlab`
  configures from a mounted root without running MATLAB, and that the
  `-l:libmex.so` linking works unchanged inside the container.

### E. Runner policy and coverage (addresses F5)

- Pin the build runners explicitly (`macos-26`, `windows-2025`; Linux
  builds in the container of D on `ubuntu-22.04`), and bump them
  deliberately.
- Optional: Intel macOS packages on `macos-15-intel`, with GMP configured
  `--enable-fat` so it doesn't tune to the runner's CPU.
- Non-blocking canary: build-only jobs on `macos-latest` and
  `windows-latest` (like `compat_latest`), to see image drift before it
  breaks a pinned lane.

### F. Documentation

- `devel/PORTABILITY.md`: add a "minimum platform" table (target and
  enforced-by check) and correct Dimensions 1 and 3 as above.
- `devel/RELEASE-CONFIG.md`: document the new knobs (deployment target,
  GMP version and checksum, container image, runner pins).
- `devel/CI-WORKFLOW.md`: the new checks and jobs.
- `README.md` / guide appendix: state the supported OS versions.
- `CHANGELOG.md`.

## Suggested order

A (unblocks macOS), then C (small and self-contained), then B, then D,
then E.  Documentation goes with each stage.

## Open questions

1. macOS floor: 13.0 (matching R2024b, whose minimum is 13.7) or 14?
2. Build Intel macOS packages?  R2024b supports Intel Macs.
3. Linux floor: glibc 2.28 via the container (all R2024b distributions),
   or accept a higher floor with less CI change?
4. Given F2–F4, publish a 3.4.1 with rebuilt packages once this lands?
5. F6: fix the double-zipped release assets (for example, attach the
   inner archives with `gh release upload`)?
