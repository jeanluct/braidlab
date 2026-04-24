# Braidlab Build Modernization Roadmap

## Purpose

Define the staged path from the legacy Makefile-based build to a CMake-based build and GitHub Actions artifact pipeline for Linux, macOS, and Windows.

This roadmap is split into issue-driven plans to keep scope controlled and to support stacked branches.

## Branch and Issue Model

- `iss161-ci-matlab-probe`
- `iss162-cmake-conversion`
- `iss163-continuous-integration-github`
- `iss165-GMP-portability`

Issue #165 was added later to track GMP runtime portability for
distributed binary archives (originally scoped to a static-linking
investigation; the implemented solution bundles GMP shared libraries
inside the archive instead).

## Stacking Strategy

1. `iss161-ci-matlab-probe` branches from `develop`.
2. `iss162-cmake-conversion` branches from `iss161-ci-matlab-probe`.
3. `iss163-continuous-integration-github` branches from `iss162-cmake-conversion`.

Rationale:

- Probe findings immediately inform MATLAB version pinning and CI assumptions.
- CMake conversion remains valuable even if hosted CI licensing fails.
- Final CI branch can consume completed CMake targets and packaging rules.

## Current Status (Apr 2026)

- `iss161` goals were completed and fed into `iss162`/`iss163`.
- `iss162` established CMake-based MEX build/install flow.
- `iss163` established package workflow, smoke tests, and artifact assembly.
- `iss165` shipped GMP runtime portability via bundling (default
  flavor co-locates GMP shared libraries with the GMP-using MEX
  files; an opt-in `no-gmp` flavor is also produced per OS).
  Validated on Linux/macOS/Windows in CI; ready to merge to develop.
- Cross-branch backports already applied:
  - `0eecd36` (cross2gen vector init bug fix) was cherry-picked to `develop`.
  - `e8a8750` and `258e438` were cherry-picked to `iss162`.

## Integration Plan (Recommended)

1. Merge `iss162-cmake-conversion` into `develop` first.
2. Keep CI governance/docs evolution in `iss163` until policy is finalized.
3. Cherry-pick only required CI/runtime commits from `iss163` into `develop`.
4. Merge `iss163` after trigger policy and release process are agreed.

Why this order:

- Keeps CMake conversion progress independent from CI policy debates.
- Minimizes merge noise from workflow-only commits.
- Preserves ability to ship CMake improvements even if CI knobs keep evolving.

## Decision Gates

### Gate A: GitHub-Hosted MATLAB Feasibility

- Input: probe workflow results across Linux/macOS/Windows.
- Decision:
  - Pass: proceed with hosted runner implementation in final CI.
  - Fail: retain CMake conversion and switch CI strategy to self-hosted or hybrid.

Status: Passed for smoke-test level validation.

### Gate B: CMake Parity

- Input: CMake build output, target list coverage, and smoke tests.
- Decision:
  - Pass: proceed to artifact CI rollout.
  - Fail: continue iterating on conversion before enabling release artifacts.

Status: Passed for build/install/smoke parity; performance parity fix added by
defaulting single-config CMake builds to `Release`.

### Gate C: Release Operations Clarity

- Input: maintainer documentation and manual-run playbook.
- Decision:
  - Pass: maintainers can run workflow_dispatch, override pins, and ship artifacts from tags.
  - Fail: complete docs/config cleanup before making CI process canonical.

Status: In progress (docs mostly in place, trigger policy still pending).

## Milestones

1. Probe workflow merged and manually executed.
2. Top-level CMake build merged with full MEX target coverage.
3. Matrix artifact workflow merged and tested on tagged or manually triggered runs.
4. Runtime bug fix (`cross2gen_helper.hpp` reserve/resize) backported to `develop`.
5. CI config centralization documented (`devel/release-config.md`) and linked from CI workflow guide.

## Supporting Plan Files

- `devel/plans/plan-iss161-ci-matlab-probe.md`
- `devel/plans/plan-iss162-cmake-conversion.md`
- `devel/plans/plan-iss163-continuous-integration-github.md`
- `devel/ci-workflow.md`
- `devel/release-config.md`

## Compatibility Policy (Working Assumption)

- Build artifacts are tied to explicit MATLAB release labels (for example, `R2024b`).
- CI and artifact names must include OS, architecture, and MATLAB release.
- Artifact naming convention is defined in `devel/plans/plan-iss163-continuous-integration-github.md`.
- Documentation PDF is generated in CI release workflows and treated as artifact output, not a tracked source file.
- Any compatibility claims must be backed by smoke tests in that exact release.
- `compat_latest` remains non-blocking unless team policy changes.

## Rollback and Safety

- Keep existing Makefiles during migration.
- Avoid removing legacy build paths until CMake and CI have shipped at least one successful artifact cycle.
- If CI is blocked by licensing, freeze CI branch and continue with CMake-only improvements.

## Open Decisions

- Final `push` branch trigger set (`master` only vs `master` + `develop`).
- Whether to add full MATLAB testsuite via CTest lane in CI (beyond smoke tests).
