# Release/CI Config Knobs

This file documents the small set of CI values that are intentionally pinned
for reproducibility, and how to override them safely.

Workflow: `.github/workflows/build-braidlab-packages.yml`

## Priority order for config values

For values that support overrides, resolution is:

1. `workflow_dispatch` input (manual run only)
2. repository variable (`Settings -> Secrets and variables -> Actions -> Variables`)
3. workflow default in YAML

## Current knobs

`BRAIDLAB_RELEASE_MATLAB`

- Purpose: MATLAB release used by `release_pinned` package jobs.
- Input name: `matlab_release` (manual runs).
- Repository variable (optional): `BRAIDLAB_RELEASE_MATLAB`.
- Workflow default: `R2024b`.

`BRAIDLAB_COMPAT_GCC_MAJOR`

- Purpose: GCC major used in `compat_latest` lane.
- Repository variable (optional): `BRAIDLAB_COMPAT_GCC_MAJOR`.
- Workflow default: `12`.

`BRAIDLAB_LATEX_PACKAGES`

- Purpose: apt package list for docs PDF build job.
- Repository variable (optional): `BRAIDLAB_LATEX_PACKAGES`.
- Workflow default: `texlive-latex-base texlive-latex-extra texlive-fonts-recommended texlive-bibtex-extra make`.

`BRAIDLAB_BUILD_PARALLEL`

- Purpose: `-j` parallelism used by CMake build steps in release and compat lanes.
- Repository variable (optional): `BRAIDLAB_BUILD_PARALLEL`.
- Workflow default: `4`.

## Toolchain pins (the build release and its compilers)

Packages are built once per platform against the *oldest* MATLAB release
they support (`BRAIDLAB_RELEASE_MATLAB`).  C-API MEX files are forward
compatible, so they also load in every later release.  The build release
therefore fixes two things:

- the compilers, which follow MathWorks' supported-compilers list for that
  release; and
- the oldest operating systems, which follow that release's system
  requirements.

Everything else about the toolchain is pinned too, so nothing changes
under the workflow.  The pins below all derive from R2024b, and they must
be bumped together with it.

`BRAIDLAB_XCODE_VERSION`
- Xcode selected on macOS runners (through `DEVELOPER_DIR`).  Default:
  `16.4`.  R2024b supports Xcode 15 and 16.
- The job fails if that Xcode is not on the image.

`BRAIDLAB_VS_GENERATOR`
- CMake generator on Windows, which selects the Visual Studio version.
  Default: `Visual Studio 17 2022`.  R2024b supports MSVC 2017, 2019 and
  2022.

`BRAIDLAB_CMAKE_VERSION`
- CMake used on every platform (from `lukka/get-cmake`, or PyPI in the
  Linux container).  Default: `3.31.6`.

`BRAIDLAB_MACOS_DEPLOYMENT_TARGET`
- Oldest macOS the packages load on.  Default: `13.0` (R2024b supports
  13.7 and later).  It also applies to the static GMP.

`BRAIDLAB_MANYLINUX_IMAGE`, `BRAIDLAB_GCC_TOOLSET`
- Linux packages are built in this container.  Defaults:
  `quay.io/pypa/manylinux_2_28_x86_64:<dated tag>` (glibc 2.28, the
  oldest R2024b supports) and gcc-toolset `13` (R2024b supports GCC 8–13).
- Keep a dated tag, not `latest`.

`BRAIDLAB_GMP_VERSION`, `BRAIDLAB_GMP_SHA256`
- GMP linked statically into the default packages.  The checksum is the
  SHA-256 of `gmp-<version>.tar.xz` and must change with the version.

Runner images (in the `release_pinned` matrix, not in `env`):
- `ubuntu-22.04` (host for the Linux container), `macos-15`,
  `macos-15-intel`, and `windows-2022`.
- Do not use the `*-latest` labels, which change without notice.  The
  `windows-2025` label, for example, now serves an image with only
  Visual Studio 2026, which R2024b does not support.

### Bumping the build release

1. Pick the new `BRAIDLAB_RELEASE_MATLAB`.
2. From MathWorks' "supported compilers" PDF for that release, choose an
   Xcode, a Visual Studio and a GCC major.
3. From its system requirements, take the oldest macOS and the oldest
   glibc (the manylinux image to use).
4. Choose runner images that carry those compilers.
5. Update the values above, and dispatch the workflow on a branch.

Otherwise the only forced change is GitHub retiring a pinned runner
image, which is announced months ahead.

## Recommended maintenance cadence

- MATLAB pin: bump intentionally when validating a new release cycle,
  together with the toolchain pins (see "Bumping the build release").
- GCC compat pin: bump only when needed for ABI/runtime changes.
- LaTeX package list: keep minimal and stable.

## Package flavor and GMP linkage

The `release_pinned` job builds one package per platform, with
`gmp_linkage` set in the matrix rather than by a repository variable:

- `BRAIDLAB_GMP_LINKAGE=static`.  GMP is linked
  statically into the MEX files that use it, so the packages have no
  GMP runtime dependency and ship no shared libraries.  GMP's license
  texts and `extern/gmp/README.md` are installed into the package.  GMP
  is used under the GPLv3 option of its LGPLv3/GPLv2 (or later) dual
  license, so static linking is ordinary GPL use.  The static GMP comes
  from:
  - Linux and macOS: `.github/scripts/build-gmp-static.sh`, which builds
    and checks a pinned, checksummed tarball.  It is cached per platform.
    On x86-64 it configures with `--enable-fat`.
  - Windows: vcpkg's `x64-windows-static-md` triplet, with
    `CMAKE_BUILD_TYPE=Release`.
These values describe the shipped artifacts and are deliberately not
repository variables.  To change them, edit the matrix in
`.github/workflows/build-braidlab-packages.yml`.

Until 3.4.2 there was also a `no-gmp` package flavor
(`BRAIDLAB_GMP_LINKAGE=off`), for users who could not install GMP.
Static GMP made it pointless, so it is no longer shipped.  The GMP-off
build, which developers without GMP use, is still checked by the
non-publishing `nogmp_check` job, which builds it and smoke-tests the
MATLAB fallback.

The former `bundled` linkage (GMP shared libraries shipped next to the
MEX files) was removed in 3.4.2.  `system` remains for local builds.

## Notes

- Keep pins centralized in workflow `env` and avoid duplicating literals in
  individual steps.
- If a value should differ per branch or per event, prefer explicit conditions
  over hidden duplication.
