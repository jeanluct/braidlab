# Issue 162 Plan: CMake Conversion

Status: Active, largely implemented (Apr 2026)

## Objective

Introduce a CMake build system for braidlab MEX components and supporting native libraries while preserving current behavior and output layout.

This conversion is valuable independent of final CI hosting model.

## Current State Snapshot

- Root `CMakeLists.txt` exists and builds all baseline MEX targets.
- CMake install layout matches package-relative MATLAB paths.
- Local in-place install flow is documented and used:
  - `cmake -S . -B build`
  - `cmake --build build -j`
  - `cmake --install build --prefix .`
- Single-config build default now falls back to `Release` for performance parity.
- `doc/Makefile distclean` portability cleanup landed and is compatible with CMake-era docs flow.

## Why This Exists

Current builds are split across multiple Makefiles and directory-local rules. CMake provides a single dependency graph, clearer target modeling, and easier CI portability.

## Scope

In scope:

- Add top-level CMake entry point and target structure.
- Build all current MEX modules currently produced via root/sub Makefiles.
- Model external native dependencies (`extern/cbraid`, `extern/trains`) as explicit CMake targets.
- Preserve package-relative output/install layout expected by MATLAB package structure.
- Provide an installation/staging path for release packaging.
- Add a CMake documentation target that can build `doc/braidlab_guide.pdf` without changing release/version semantics.

Out of scope:

- Removing legacy Makefiles during initial conversion.
- Altering MATLAB runtime behavior or algorithm semantics.
- Release automation details (handled in issue 163 plan).
- Reintroducing committed PDF artifacts into git history.

Follow-on scope now tracked elsewhere:

- Optional static GMP linkage investigation (issue #165).

## Existing Build Inventory (Target Baseline)

MEX outputs currently produced in:

- `+braidlab/private`
  - `randomwalk_helper`
- `+braidlab/+util`
  - `assignmentoptimal`
- `+braidlab/@loop/private`
  - `looplist_helper`, `length_helper`, `intersec_helper`
- `+braidlab/@cfbraid/private`
  - `cfbraid_helper`, `conjtest_helper`
- `+braidlab/@braid/private`
  - `compact_helper`, `loopsigma_helper`, `entropy_helper`, `train_helper`, `cross2gen_helper`, `subbraid_helper`

Native static libraries:

- `libcbraid-mex.a` (custom MEX-compatible build path)
- `libtrains.a`

## Technical Approach

### CMake Foundation

- Add `CMakeLists.txt` at repo root.
- Set minimum CMake version and C/C++ language standards.
- Integrate MATLAB via `find_package(Matlab REQUIRED COMPONENTS MEX_COMPILER)`.

### Target Modeling

- Create reusable CMake helper function for MEX targets to avoid repeated boilerplate.
- Define static library target for cbraid MEX-compatible objects.
- Define static library target for trains.
- Define one MEX target per module listed in baseline inventory.

### Compiler and Feature Flags

- Keep C++11 compatibility where currently required.
- Support optional GMP usage behind a CMake option equivalent to `BRAIDLAB_USE_GMP`.
- Preserve include paths and link libraries used in current Makefiles.

### Output and Install Layout

- Use build tree for compilation outputs.
- Use `install(TARGETS ...)` destinations that mirror existing runtime layout, for example:
  - `+braidlab/@braid/private`
  - `+braidlab/@cfbraid/private`
  - `+braidlab/@loop/private`
  - `+braidlab/private`
  - `+braidlab/+util`
- Add one staging install prefix for packaging and CI artifact creation.

### Coexistence with Makefiles

- Keep Makefile build path intact during migration.
- Update docs with side-by-side build commands:
  - legacy Makefile path,
  - new CMake configure/build/install path.

### Documentation Build Policy

- Keep `doc/Makefile` and `doc/for_arxiv` as the source of truth for LaTeX/version behavior.
- Add a CMake convenience target (for example `braidlab-doc`) that invokes the existing doc build.
- Do not make PDF commits part of normal development flow.
- Treat `doc/braidlab_guide.pdf` as a generated release artifact, not a tracked source asset.

## Validation Plan

- Configure and build on Linux first.
- Verify produced MEX files exist in expected staged layout.
- Run MATLAB smoke checks that exercise representative helpers from each directory group.
- If possible, compare built module list against Makefile-produced module list.
- Verify CMake doc target can build the latest PDF when explicitly invoked.

Validation status:

- Build/install/smoke validation: passed on active conversion branch.
- Full testsuite parity: currently manual via MATLAB command; CTest integration remains optional follow-up.

## Success Criteria

All must be true:

- CMake config succeeds in a clean build directory.
- CMake builds all baseline MEX modules and dependent libraries.
- Install/staging output layout matches expected package-relative paths.
- MATLAB smoke load/use checks pass for representative MEX modules.
- Legacy Makefile build remains usable during transition.
- Documentation target works and preserves existing release-version workflow.

## Risks and Mitigations

- MATLAB discovery differences across environments.
  - Mitigation: document required MATLAB env vars and fallback hints.
- Link-order differences vs Makefiles.
  - Mitigation: explicit target_link_libraries order and per-target verification.
- Hidden source-specific compile assumptions.
  - Mitigation: migrate incrementally and validate each target cluster.

## Task Checklist

- [x] Confirm issue number and branch name.
- [x] Add root CMake scaffolding.
- [x] Add cbraid and trains library targets.
- [x] Add MEX targets for each current output.
- [x] Add install rules for staged package layout.
- [x] Update documentation for CMake usage.
- [x] Run Linux validation build and smoke checks.
- [ ] Open PR with mapping table (Make target -> CMake target).

## Backports and Related Commits

- `0eecd36` fixed a runtime bug in `cross2gen_helper.hpp` (reserve/resize) and was cherry-picked to `develop`.
- `258e438` set single-config CMake default build type to `Release`.
- `e8a8750` fixed `doc/Makefile` `distclean` behavior.

## Further Work Candidates

- Add optional CTest integration for full MATLAB testsuite execution.
  - Add `enable_testing()` and a guarded full-testsuite test invocation.
  - Gate behind a CMake option (for example `BRAIDLAB_ENABLE_FULL_TESTSUITE`) so local default remains fast.
- Keep Makefile wrapper compatibility as migration convenience.
  - Preserve `make`, `make clean`, and `make install` ergonomics while delegating to CMake where feasible.

## Exit Decision

At completion, CMake should be the recommended build path for contributors, while Makefiles remain as fallback until CI artifact pipeline (issue 163) is proven stable.
