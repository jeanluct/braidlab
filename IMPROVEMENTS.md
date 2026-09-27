# Improvements Roadmap

This document proposes follow-up improvements after strict-warning cleanup.
The goal is to make numeric/index handling safer and more consistent while
keeping behavior unchanged unless explicitly intended.

## Quick assessment from cleanup

- No concrete runtime bug was found by the warning cleanup itself. The
  follow-up sanitizer and golden-corpus work found three (a dead `train`
  executable, uninitialized `edge`/`vertex` members, and buffer overflows in
  `frontend`); see `STRICT_WARNINGS_STATUS.md`.
- Most changes were explicit cast/type-boundary normalization.
- The codebase still has mixed integer conventions (`int`, `long`, `uint`, STL
  size types), which increases future bug risk and maintenance cost.
- One strict warning remains (`-Wnull-dereference`) in an STL-inlined path tied
  to `MyArray` assignment; this needs targeted investigation.

## Priority 1: Define integer/type policy

Create a short project-wide policy and enforce it in new/changed code.

Suggested policy:

1. Use `std::size_t` for container sizes and index loops over STL containers.
2. Use `long` only where domain semantics require signed labels/generators.
3. Use `uint` only for legacy API boundaries; avoid introducing new `uint` APIs.
4. Convert once at boundaries with explicit `static_cast`, not repeatedly in
   expressions.
5. Avoid mixed signed/unsigned arithmetic in loop conditions and index math.

## Priority 2: Introduce domain type aliases

To improve readability and reduce accidental mixing:

- Add aliases in a common header (example names):
  - `EdgeIndex`
  - `VertexIndex`
  - `Generator`
  - `Label`
  - `Count`
- Start with aliases (no wrapper class) to minimize migration risk.
- Optionally move to strong typedef wrappers later if needed.

## Priority 3: Harden conversion boundaries

Add small helper functions/macros for common checked conversions, for example:

- `to_uint_checked(long v)`
- `to_long_checked(std::size_t v)`
- `to_size_checked(long v)`

Guidelines:

- In debug/test builds, assert preconditions (`v >= 0`, upper bounds).
- In release builds, keep overhead minimal.
- Centralize these helpers to make audits and future refactors easier.

## Priority 4: Strengthen `MyArray` safety guarantees

Status: done except copy-and-swap. `operator=` is two member copies
(`std::vector` plus origin), which is already self-assignment safe and
strongly exception safe, so copy-and-swap would add nothing. Covered by
`tests/test_myarray.cpp`. `Rotate` was hardened: it used to loop forever on
an empty array and was undefined for negative angles. No caller hit either
case. Remaining latent hazards, all unreachable from current callers:
`operator[]` below the origin (a `uint` underflow leading to a huge resize),
`arrayiterator` on an empty array, and `Remove`/`Split` past the end.

Because the remaining warning touches `MyArray` assignment:

1. Audit `MyArray<T>::operator=` invariants:
   - self-assignment behavior
   - empty-source behavior
   - allocation and copy preconditions
2. Add dedicated unit tests for edge cases:
   - empty to empty
   - non-empty to empty
   - empty to non-empty
   - self-assignment
   - repeated assignment under mutation
3. Consider making assignment exception-safe via copy-and-swap pattern if
   practical without performance regression.

## Priority 5: Add sanitizer CI lane

Status: `TRAINS_SANITIZE` CMake option added and the full suite is clean
under it. There is no CI yet.

Add one CI job for Linux/clang or gcc with:

- `-fsanitize=address,undefined`
- CTest run for all existing tests
- optional targeted regression for `MakeIrreducible()`/`MyArray` assignment path

This catches latent memory/UB issues not visible through warning cleanup alone.

## Priority 6: Improve algorithm regression confidence

Status: `test_golden_batch` added, with a 53-entry corpus in `tests/golden/`
and expected output from pre-cleanup `master`.

Current tests are good smoke/invariant coverage but not exhaustive for algorithm
semantics.

Recommended additions:

1. Golden fixtures for known braids/horseshoe inputs with expected Thurston
   type and selected invariants.
2. Regression checks for `FindTrack`, `FindReduction`, and singularity/gate
   reporting outputs.
3. A small corpus runner for representative input files.

## Priority 7: Documentation and contributor guidance

Add a short contributor section in `README.md` covering:

- integer/type policy
- casting policy
- when to use sanitizers locally
- strict-warning expectation for touched files

This prevents style drift and preserves cleanup gains.

## Suggested phased execution

1. Land type policy + helper conversion utilities.
2. Add `MyArray` edge-case tests and investigate remaining null-deref warning.
3. Add sanitizer CI lane.
4. Expand golden-case algorithm regression tests.
5. Gradually migrate legacy APIs toward clearer domain aliases.

## Definition of done for this roadmap

- Remaining `-Wnull-dereference` is either fixed with evidence or narrowly
  suppressed with documented rationale and reproducer notes.
- Type policy is documented and followed in all new patches.
- Sanitizer CI lane is green.
- Algorithm regression coverage is expanded with stable fixtures.
