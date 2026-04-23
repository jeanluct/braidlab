# Issue 163 Plan: Continuous Integration on GitHub

Status: Active, mostly implemented (Apr 2026)

## Objective

Create a GitHub Actions pipeline that builds and publishes braidlab binary artifacts for supported operating systems from the CMake build.

Current workflow file:

- `.github/workflows/build-braidlab-packages.yml`

## Dependencies

- Stacked on `iss162-cmake-conversion`.
- Uses probe findings from `iss161-ci-matlab-probe` to select hosted, self-hosted, or hybrid runner strategy.

Operational docs:

- `devel/ci-workflow.md`
- `devel/release-config.md`

## Scope

In scope:

- Matrix CI workflow for build and artifact packaging.
- Runner strategy based on probe outcome.
- MATLAB release pinning in workflow configuration.
- Artifact naming convention including OS, arch, and MATLAB release.
- Include user-facing documentation PDF in downloadable release artifacts.
- Optional release attachment workflow for tags.

Out of scope:

- Rewriting tests unrelated to CI portability.
- Removing legacy workflows unrelated to build artifacts.
- Package manager distribution channels.

## Runner Strategy Options

### Option A: Fully GitHub-Hosted

- Linux, macOS, Windows all on hosted runners.
- Use when probe confirms licensing and setup on all three.

### Option B: Hybrid

- Use hosted runners where allowed.
- Route restricted platforms to self-hosted labels.

### Option C: Fully Self-Hosted

- Use only organizationally controlled runners.
- Required if hosted licensing policy disallows MATLAB usage.

Chosen option must be recorded in issue notes with rationale.

Current status:

- Option A (fully GitHub-hosted) is in use for Linux/macOS/Windows package lanes.

## Workflow Design

### CI Lanes

- `release-pinned` lane:
  - Uses one explicitly pinned MATLAB release.
  - Produces official downloadable artifacts.
  - Must pass for release publication.
- `compat-latest` lane:
  - Uses floating/latest MATLAB for forward-compatibility signal.
  - Runs compile and smoke checks only.
  - Does not publish artifacts.

Policy notes:

- Release artifacts are generated only from `release-pinned`.
- `compat-latest` failures should open/update a compatibility tracking issue but should not block artifact publication when `release-pinned` is green.

Current status:

- `compat_latest` is configured as non-blocking (`continue-on-error: true`).

### Triggers

- `workflow_dispatch` for manual runs.
- `pull_request` for build verification (possibly limited matrix to control cost/time).
- `push` on selected branches.
- `push` tags for release artifact publication.

Recommended trigger behavior:

- On pull requests, run reduced matrix for fast validation (for example Linux on both lanes).
- On pushes to integration branches, run full `release-pinned` matrix.
- On tags, run full `release-pinned` matrix and publish artifacts.

Current status:

- Workflow currently targets the issue branch for `push` triggers plus PR, tags, and manual dispatch.
- Final `master`/`develop` push trigger policy remains an open decision.

### Jobs

1. Build matrix job:
   - Setup MATLAB pinned to designated release.
   - Configure CMake.
   - Build all targets.
   - Install to staging directory.
   - Package archive per matrix entry.
   - Upload artifact.
2. Optional verify job:
   - Run MATLAB smoke tests against staged artifacts.
3. Optional release job:
    - On tags, download artifacts and attach to GitHub Release.

Current status:

- Build matrix + smoke verification are implemented.
- Release attachment automation is not yet enabled; artifacts are uploaded by workflow and attached manually if needed.

### Matrix Dimensions

- `os`: Linux/macOS/Windows (as allowed by strategy)
- `arch`: at minimum runner-native architecture
- `matlab_release`: pinned single release for stable binary line

## Artifact Policy

- Artifact filename format:
  - `braidlab-<version>_<platform>-<arch>_matlab-<release>.<zip|tar.gz>`
  - Example: `braidlab-3.3.1_windows-x86_64_matlab-R2024b.zip`
  - Linux example: `braidlab-3.3.1_linux-ubuntu-22.04-x86_64_matlab-R2024b.tar.gz`
- Archive contents should mirror runtime package layout expected by users.
- Release archives should include `doc/braidlab_guide.pdf` built in CI.
- Release archives should include `testsuite/` and distribution metadata files.
- Include short manifest file with:
  - git commit,
  - MATLAB release,
  - runner OS,
  - build timestamp.

Documentation policy:

- `doc/braidlab_guide.pdf` is treated as generated output and is not committed to source control.
- CI release jobs are responsible for building and packaging the PDF.
- Any version stamping behavior must remain consistent with existing `doc` tooling.

Token normalization rules:

- Platform token values:
  - Linux: include distro baseline, for example `linux-ubuntu-22.04`.
  - macOS: `macos`.
  - Windows: `windows`.
- Architecture token values: `x86_64`, `arm64`.
- MATLAB token format: `matlab-R<year><a|b>` (for example `matlab-R2024b`).

## Validation Plan

- Ensure each matrix artifact contains expected MEX files by directory.
- Run MATLAB smoke tests per platform when feasible.
- Confirm artifact extraction works and paths are correct.
- For release flow, verify assets appear on draft or test release before enabling production tagging.

Validation status:

- Matrix packaging and smoke tests have been exercised and stabilized.
- Compatibility lane behavior and toolchain notes are documented.

## Success Criteria

All must be true:

- CI workflow succeeds for all configured matrix entries.
- Artifacts are produced with correct naming and content layout.
- MATLAB release used in build is explicit and logged.
- Smoke checks pass on each active platform lane.
- Release attachment flow works on test tag (if enabled).

## Risks and Mitigations

- Licensing interruptions or entitlement expiration.
  - Mitigation: document secrets and ownership; add troubleshooting runbook.
- Runner variability and queue delays.
  - Mitigation: separate mandatory checks from release lanes; use retries where safe.
- Excessive CI duration.
  - Mitigation: split verification depth between PR and release workflows.

## Task Checklist

- [x] Confirm issue number and branch name.
- [x] Choose runner strategy from probe results.
- [x] Add CI workflow with matrix build and artifact upload.
- [x] Add packaging script or CMake packaging commands.
- [x] Add smoke verification step.
- [ ] Add release asset attachment flow (optional initial draft mode).
- [x] Document workflow operation and maintenance.

## Open Follow-ups

- Finalize push-branch trigger policy after branch migration.
- Decide whether to add full-testsuite CTest lane beyond smoke tests.
- Decide whether to keep compat lane non-blocking long-term.
- Track optional static GMP linkage in issue #165.

## Further Work Candidates

- Add optional release-publish automation on `release-*` tags.
  - Download packaged artifacts and attach them directly to GitHub Releases.
  - Keep manual attach flow as fallback until automation proves stable.
- Introduce PR-time reduced matrix policy to lower cycle time and cost.
  - Keep full matrix on `master` pushes and release tags.
- Add explicit compatibility issue management policy.
  - When `compat_latest` fails and `release_pinned` passes, auto-open or update a tracking issue.

## Exit Decision

At completion, the repository has a documented, reproducible path to produce downloadable binaries for the chosen MATLAB release across all supported platforms under the selected runner strategy.
