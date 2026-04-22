# Issue 161 Plan: CI MATLAB Probe

## Objective

Establish whether GitHub-hosted runners can install and run a pinned MATLAB release for non-interactive MEX compilation on Linux, macOS, and Windows.

## Why This Exists

Before investing in full cross-platform CI and artifact publishing, confirm that licensing and runner setup are viable in the real repository context.

## Scope

In scope:

- Add one manual-only GitHub Actions workflow for MATLAB feasibility checks.
- Run checks on `ubuntu-latest`, `macos-latest`, and `windows-latest`.
- Pin one MATLAB release (initial default: `R2024b`, adjustable by issue decision).
- Compile one tiny probe MEX source during the workflow.
- Capture structured pass/fail evidence in workflow logs and job summary.

Out of scope:

- Full project build.
- Release artifact packaging.
- CMake migration.
- Branch protection or required-check policy changes.

## Deliverables

1. Workflow file under `.github/workflows/` (manual trigger only).
2. Minimal probe source file used solely for MEX compile validation.
3. Job summary output with an OS-by-OS result table.
4. Issue comment documenting conclusion and recommendation for next branch.

## Technical Approach

### Workflow Triggering

- Use `workflow_dispatch` only.
- Optionally include a manual input for MATLAB release, with a default value.

### Matrix

- `os`: `ubuntu-latest`, `macos-latest`, `windows-latest`
- `matlab_release`: pinned single release for initial probe.

### Steps

1. Checkout repository.
2. Setup MATLAB using `matlab-actions/setup-matlab`.
3. Run a diagnostic block via MATLAB action:
   - `ver`
   - `mex -setup` (or equivalent compiler query)
   - compile tiny probe MEX source.
4. Validate generated artifact extension exists.
5. Write concise pass/fail and key diagnostics to job summary.

### Probe Source

- Use a trivial MEX source that does not depend on project code.
- Keep file in a clear temporary or tooling path (for example `devel/ci-probe/`).

## Success Criteria

All must be true:

- MATLAB setup step succeeds on each matrix OS.
- MATLAB command execution succeeds on each matrix OS.
- Probe MEX compilation succeeds on each matrix OS.
- Summary clearly marks each OS as pass or fail and includes failure reason if any.

## Failure Handling

If one or more platforms fail:

- Classify failure cause:
  - license/entitlement,
  - MATLAB setup/download,
  - compiler/toolchain issue,
  - runner environment mismatch.
- Record actionable next step in issue:
  - retry with adjusted runner/toolchain,
  - switch affected platform to self-hosted,
  - or defer platform in final CI.

## Risks and Mitigations

- Licensing policy blocks hosted use.
  - Mitigation: keep workflow manual; gather evidence; pivot to self-hosted/hybrid.
- Runner image toolchain changes.
  - Mitigation: log compiler details and pin setup behavior where possible.
- Probe passes but project build later fails.
  - Mitigation: treat probe as licensing/setup gate only, not build parity proof.

## Task Checklist

- [ ] Confirm issue number and rename branch accordingly.
- [ ] Add probe workflow file.
- [ ] Add trivial probe MEX source.
- [ ] Run workflow manually.
- [ ] Record OS-by-OS result table in issue.
- [ ] Decide go/no-go for hosted runners in downstream CI plan.

## Exit Decision

At completion, document one of:

- Hosted runners approved for all three OSes.
- Hosted runners approved for subset; define hybrid strategy.
- Hosted runners not viable; recommend self-hosted strategy.
