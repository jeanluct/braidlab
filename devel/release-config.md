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

## Recommended maintenance cadence

- MATLAB pin: bump intentionally when validating a new release cycle.
- GCC compat pin: bump only when needed for ABI/runtime changes.
- LaTeX package list: keep minimal and stable.

## Package flavor and GMP linkage (issue #165)

The `release_pinned` job builds two flavors per OS, controlled by
`BRAIDLAB_GMP_LINKAGE` in the matrix rather than by a repository
variable:

- `default` flavor: `BRAIDLAB_GMP_LINKAGE=bundled`.  GMP shared
  libraries are bundled inside the archive, co-located with the
  GMP-using MEX files in `+braidlab/@braid/private/`.  Built on every
  push to `develop`/`master`, on PRs, and on release tags.
- `no-gmp` flavor: `BRAIDLAB_GMP_LINKAGE=off`.  GMP-using code paths
  are compiled out.  Built on every push (not gated on release tags)
  so GMP-free build regressions surface immediately; the no-gmp jobs
  are cheap because they skip the GMP install and bundled-layout
  verification steps.  (An earlier plan gated this on
  `refs/tags/release-*`, but `matrix` context is not allowed in
  job-level `if` conditions, so the gate was dropped.)

These values are intentionally not exposed as repository variables;
they describe the shipped artifacts and changing them per build would
defeat reproducibility.  To change the flavor lineup, edit the matrix
directly in `.github/workflows/build-braidlab-packages.yml`.

GMP install sources used in CI per OS:

- Linux: `apt-get install libgmp-dev libgmpxx4ldbl libgmp10`.
- macOS: `brew install gmp`.
- Windows: `vcpkg install gmp:x64-windows`.

A future `static` value for `BRAIDLAB_GMP_LINKAGE` is reserved but not
implemented; CMake currently rejects it at configure time.

## Notes

- Keep pins centralized in workflow `env` and avoid duplicating literals in
  individual steps.
- If a value should differ per branch or per event, prefer explicit conditions
  over hidden duplication.
