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

## Notes

- Keep pins centralized in workflow `env` and avoid duplicating literals in
  individual steps.
- If a value should differ per branch or per event, prefer explicit conditions
  over hidden duplication.
