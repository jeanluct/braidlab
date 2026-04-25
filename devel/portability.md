# Braidlab Package Portability Analysis

This document analyzes how portable the binary archives produced by the
GitHub Actions CI workflow are, and what users need on their systems to
run them.  It covers MATLAB version compatibility, native dependencies
(notably GMP), the C++ runtime, and an assessment of whether the current
"versions can be specified" workflow design is appropriate.

Companion documents:

- `devel/ci-workflow.md` — operational use of the workflow.
- `devel/release-config.md` — what is pinned and how to override it.

## Summary recommendation

- **MATLAB version**: not a major concern.  One pinned-release archive
  per OS/arch is correct, given the legacy MEX ABI selected in
  `CMakeLists.txt`.
- **GMP**: this is the main real portability hazard.  Recommended
  default is dynamic linking with bundled GMP runtime libraries on
  macOS/Windows archives, plus an optional `no-gmp` package flavor.
  Static linking is technically possible but is not the recommended
  default (see issue #165).
- **Workflow weight**: the current three-job design is appropriate for
  a multi-platform native packaging pipeline.  Optimization should
  focus on caching and scheduling, not redesign.

## What the current pipeline produces

Three jobs, configured in `.github/workflows/build-braidlab-packages.yml`:

1. `docs_pdf` — builds `braidlab_guide.pdf` once on Ubuntu.
2. `release_pinned` — matrix over Linux / macOS / Windows, pinned MATLAB
   release, produces the distributable archives, runs a MATLAB smoke
   test against the staged install.
3. `compat_latest` — Ubuntu lane on the latest available MATLAB with a
   pinned GCC major; non-blocking early-warning lane.

Pinned defaults are centralized in workflow `env`, with override
precedence: `workflow_dispatch` input → repository variable → workflow
default.

Archive naming standard:

```
braidlab-<version>_<platform>-<arch>_matlab-<release>.<ext>
```

Each archive ships with `BUILD-MANIFEST.txt` recording commit, MATLAB
release, runner OS/arch, and timestamp.

Archives also bundle the supporting MATLAB code that braidlab needs at
runtime, so that a fresh extraction is self-contained:

- `extern/VariablePrecisionIntegers/` — John D'Errico's VPI toolbox,
  required by braidlab's arbitrary-precision MATLAB code paths.
- `examples/` — top-level example scripts referenced by the guide and
  testsuite (moved from `doc/examples/` in this release cycle).

For the default flavor, GMP runtime libraries are co-located with the
GMP-using MEX files in `+braidlab/@braid/private/`; see "Dimension 2:
GMP" below.

## Dimension 1: MATLAB version compatibility

`CMakeLists.txt` uses:

```cmake
matlab_add_mex(
  NAME ${target}
  ...
  R2017b
  NO_IMPLICIT_LINK_TO_MATLAB_LIBRARIES
)
target_link_libraries(${target} Matlab::mex Matlab::mx)
```

This forces the legacy MEX C API (`R2017b` mode) and avoids implicit
linkage to MATLAB's C++ Data API / Engine runtime libraries.  As a
result, MEX binaries depend only on `libmex` and `libmx`, which is the
stable C MEX ABI MATLAB has preserved across many releases.

Practical implications:

- A MEX built on R2024b will load on roughly R2018a → current.
  Forward-compatibility (newer MATLAB than build) is generally fine.
  Backward-compatibility (older MATLAB than build) is more fragile.
- One pinned-release archive per OS/arch is normally sufficient.  A
  multi-MATLAB matrix (for example R2022b/R2023b/R2024b/R2025a × 3 OS
  = 12 jobs) would be overkill unless a specific incompatibility is
  reported by users.

Real risk areas to monitor:

- macOS arm64 arrived later (R2023b+).  Archive names already encode
  arch, so this is handled.
- Windows MSVC runtime: MEX binaries link against the same MSVC CRT
  MATLAB ships, so if built on the matching `windows-latest` runner
  this is largely a non-issue.

Conclusion: do not worry much about MATLAB version skew for users.

## Dimension 2: GMP

GMP is the only realistic portability hazard for users today.

Current behavior:

- `BRAIDLAB_USE_GMP=ON` (default in `CMakeLists.txt`) — links
  `cross2gen_helper`, `loopsigma_helper`, and `entropy_helper` against
  `libgmp` and `libgmpxx`.
- macOS workflow step gracefully flips to `BRAIDLAB_USE_GMP=OFF` if
  Homebrew GMP is not available on the runner.
- Linux runners always build with GMP.

Per-OS user impact:

- **Linux**: GMP is widely available (`libgmp10`, `libgmpxx4ldbl`) but
  not always preinstalled.  Stripped containers, older distros, or
  minimal base images can fail to load MEX with
  `libgmp.so.10: cannot open shared object file`.
- **macOS**: GMP is *not* a system library.  Users without Homebrew GMP
  cannot load `cross2gen_helper.mexmaca64`, `loopsigma_helper`, or
  `entropy_helper`.
- **Windows**: GMP is not packaged on hosted runners by default.  Any
  Windows build with GMP enabled will fail at MEX load on a clean user
  system unless GMP DLLs are bundled.

There is also a deterministic-artifact concern: the macOS lane today
silently produces GMP-on or GMP-off archives depending on Homebrew
availability.  Two archives with the same name can therefore differ in
feature set, which is undesirable.

Three reasonable shipping strategies:

1. **Document dependency, ship dynamic only.**  Cheapest.  Acceptable
   on Linux for users who can install `libgmp10`/`libgmpxx4ldbl`.
   Painful on macOS and Windows for casual users.
2. **Bundle GMP runtime libraries inside the package** and use
   `rpath` / `@loader_path` / DLL co-location so MEX files find them.
   Medium effort, good user experience, LGPL-clean for dynamic
   redistribution if the LGPL text and a relink note are included.
3. **Static link GMP** (issue #165).  Smallest user-facing footprint,
   but LGPL static linking imposes obligations (users must be able to
   relink against a different GMP), and it complicates the build per
   platform.  Not recommended as default.

Recommended policy:

- Default: **dynamic linking with bundled GMP runtime on macOS and
  Windows** archives.  Linux can stay dependency-on-system with a clear
  note in the README.
- Add a **`no-gmp` package flavor** (`BRAIDLAB_USE_GMP=OFF`) for users
  who do not need the GMP-backed code paths.  This guarantees a fully
  portable fallback at near-zero CI cost.
- Encode the GMP policy explicitly in the build instead of relying on
  environment detection, so artifact contents are deterministic for a
  given workflow input.  Consider encoding `_no-gmp` in the archive
  name when applicable.

### Update (2026-04-23): Linux now also bundles, with a caveat

The policy above was revised under issue #165: Linux now also bundles
GMP by default for uniform UX (containers, HPC nodes, stripped images
where users cannot `apt install`).  See
`devel/plans/plan-iss165-gmp-portability.md` for the implementation.

Empirical finding from local validation on Ubuntu 24 + MATLAB R2025a:

- A bundled-mode install correctly co-locates `libgmp.so.10` and
  `libgmpxx.so.4` next to the GMP-using MEX files, sets
  `INSTALL_RPATH=$ORIGIN` on those targets, and `ldd` confirms the
  loader resolves `libgmp.so.10` to the bundled file outside MATLAB.
- Inside MATLAB, however, `/proc/<pid>/maps` shows the **system**
  `libgmp.so.10` loaded, not the bundled one.  Root cause: MATLAB
  loads `libgnutls.so.30` at startup, which transitively requires
  `libgmp.so.10`, so by the time braidlab's MEX is loaded the symbol
  is already resolved against the system library and the loader does
  not re-search rpath.
- Practical consequence on Linux: bundling helps only on systems with
  no system GMP at all.  But on such systems MATLAB itself may fail to
  start (gnutls would not load), so Linux bundling may be largely
  redundant in practice on modern MATLAB Linux installs.

We keep Linux bundling for now because:

- It costs ~554 KB per archive and a few CMake lines we already wrote.
- Future MATLAB releases or stripped Linux installs may not pull in
  gnutls; bundling is defense in depth.
- It keeps the per-OS build logic uniform with macOS/Windows where
  bundling is genuinely required.
- Removing it later if it stays redundant is straightforward.

Revisit during Phase B (workflow) once we have CI evidence from the
`ubuntu-22.04` runner across MATLAB versions.

## Dimension 3: C++ runtime and other native dependencies

The C++ runtime (`libstdc++` / `libc++` / MSVC CRT) is the other
classic gotcha for native MATLAB extensions.  Mitigations already in
place:

- The `compat_latest` lane forces GCC 12 on Ubuntu, which aligns with
  MATLAB's bundled `libstdc++` ABI window.
- The compat smoke test uses `LD_PRELOAD` of the runner's newer
  `libstdc++` so loaded MEX files can resolve against it.

No other exotic shared libraries are pulled in by the build.  This area
is in good shape.

## Is the "versions can be specified" approach optimal?

For braidlab's release model: yes, with one tweak.

What is good about it:

- One pinned MATLAB release per archive name is the right granularity,
  given the legacy MEX ABI choice.
- Repository variables plus `workflow_dispatch` input give the right
  escape hatch for occasional rebuilds against a newer MATLAB.
- Hardcoding the rest (LaTeX packages, GCC major, parallelism) in
  workflow `env` is fine for a small project; centralization gives the
  "one place to change" property.

The tweak: make GMP policy a first-class build flavor rather than an
environment-detected fallback.  Today the macOS lane silently flips
GMP on/off.  Better:

- Explicit matrix dimension or job parameter `gmp: on|off`, or always
  install GMP per OS so the result is deterministic.
- Encode the choice in the archive name when off, e.g. `_no-gmp`.

## Is the workflow heavy?

Honestly, no.  Three jobs, around 260 lines, with concurrency
cancellation.  That is lean for a multi-platform native packaging
pipeline.  What may *feel* heavy:

- LaTeX install is the single slowest step (~1–2 min).  The `docs_pdf`
  split already amortizes this across the matrix.
- The MATLAB smoke test boots MATLAB on each OS.  This is intrinsic to
  packaging native MATLAB code, not a workflow design issue.
- `compat_latest` adds a 4th MATLAB boot.  Skipping it on tag pushes
  (already configured) is appropriate.

Low-effort optimizations worth considering:

- Cache APT packages (`actions/cache` on `/var/cache/apt/archives`) to
  cut LaTeX install time on PR runs.
- Cache the CMake `build/` directory keyed on source hash for faster
  PR iteration.
- Run `compat_latest` only on `schedule` (nightly) instead of every PR
  if desired — it is the lane least tied to PR validation.

The three-job design itself is appropriate; redesign is not warranted.

## Bottom line

- MATLAB version skew for users: low concern, current setup is
  appropriate.
- GMP availability for users: real concern, addressed by issue #165
  and the GMP portability plan.  Recommended path is bundled dynamic
  GMP on macOS/Windows plus a `no-gmp` flavor.
- Workflow weight: appropriate.  Optimization leverage is in caching
  and scheduling, not in restructuring the workflow.

## Complexity cost of GMP bundling

The bundled-GMP approach delivered by issue #165 solves a real user
problem (no system GMP required on macOS or Windows), but it is worth
recording honestly how much project complexity it added so future
maintainers can weigh the trade-off.

### Where the complexity lives

Roughly 420 lines of supporting infrastructure were added across the
repository for bundling:

| Area                              | Approx. lines | Purpose                                              |
| --------------------------------- | ------------- | ---------------------------------------------------- |
| `CMakeLists.txt`                  | ~150          | GMP discovery, runtime resolution, install/rpath    |
| CI verify steps (per OS)          | ~120          | Inspect packaged MEX files for correct linkage      |
| CI matrix expansion               | ~25 YAML      | Doubled job count from 3 → 6 (system + bundled)     |
| Install rules (loader-name renames, post-install rewrites) | ~25 | Co-locate libs and patch install names |
| MATLAB smoke tests                | ~10           | Confirm bundled MEX loads inside MATLAB             |
| Archive naming and metadata       | ~10           | `-bundled` / `-system` suffixes, manifest fields    |
| `devel/portability.md` and plans  | ~80           | Documentation of the design and its caveats         |

### Conceptual costs

Three orthogonal bundling mechanisms must be maintained in parallel,
one per platform:

- Linux: `$ORIGIN` rpath on each MEX file.
- macOS: `@loader_path` rpath plus `install_name_tool` rewriting of
  the bundled `libgmp.10.dylib` install name during the install step.
- Windows: DLL co-location next to the MEX file, with vcpkg-resolved
  runtime DLLs copied into the install tree.

Several non-obvious interactions complicate the picture:

- The linker's `--as-needed` behavior drops `DT_NEEDED libgmp` for
  translation units that include GMP headers but never call any GMP
  symbol.  CI verify steps must therefore branch on "skip if no
  `DT_NEEDED` entry" rather than asserting the bundled library is
  always referenced.
- On Linux, MATLAB pre-loads `libgnutls.so.30`, which transitively
  pulls in the system `libgmp.so.10` before any braidlab MEX is
  loaded.  The bundled `libgmp` is therefore shadowed by the system
  one inside MATLAB on Linux.  Linux bundling is defense-in-depth
  only; the practical benefit is on macOS and Windows.
- The vcpkg triplet (`x64-windows`) is hard-coded in CI.  Adding
  ARM64 Windows support later will require revisiting the bundling
  pipeline, not just the build matrix.
- GMP is LGPL-3+, not GPL.  Dynamic linking with a co-located shared
  library is the comfortable path; static linking would impose
  redistribution obligations (object files or relinking ability for
  end users), which is why `BRAIDLAB_GMP_LINKAGE=static` is reserved
  but unimplemented.

### What dropping bundling would save

If a future maintainer decides the trade-off no longer pays off, the
mechanically removable scope is roughly:

- The `bundled` branch of `BRAIDLAB_GMP_LINKAGE` and all install /
  rpath / `install_name_tool` logic gated by it.
- The bundled lanes of the CI matrix and their verify steps.
- The `-bundled` archive flavor and manifest fields.

What would remain: a single `system`-mode build that requires users
on macOS and Windows to install GMP themselves (Homebrew, vcpkg, or
manual), as was the case before issue #165.  The bundling code is
written so this rollback is a contained excision rather than a
rewrite — see the separation of bundling logic into its own CMake
module.
