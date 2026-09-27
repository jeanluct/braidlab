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

Status: done. The policy lives in `CLAUDE.md` ("Integer types"). It
differs from the suggestion below in one way: counts stay `uint`, and
`size_t` is limited to direct STL iteration, rather than migrating container
sizes wholesale.

Create a short project-wide policy and enforce it in new/changed code.

Suggested policy:

1. Use `std::size_t` for container sizes and index loops over STL containers.
2. Use `long` only where domain semantics require signed labels/generators.
3. Use `uint` only for legacy API boundaries; avoid introducing new `uint` APIs.
4. Convert once at boundaries with explicit `static_cast`, not repeatedly in
   expressions.
5. Avoid mixed signed/unsigned arithmetic in loop conditions and index math.

## Priority 2: Introduce domain type aliases

Status: done for `graph.h`, `edgevert.h` and `braid.h` signatures and data
members (`trains/types.h`). The aliases are `EdgeLabel`, `EdgeIndex`,
`VertexLabel`, `VertexIndex`, `PunctureIndex` and `BraidGenerator`. The
single `Label` below was split in two because edge labels are signed and
vertex labels are not. `Count` was dropped because it is a common local
name and would trip `-Wshadow`. The three overload pairs that differed only
by `long` versus `uint` (`IsPeripheral`, `IntersectsP`,
`ValenceTwoIsotopy`) were renamed. Local variables inside function bodies
were not migrated. Wrapper types are deferred.

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

Status: not started (deferred).

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
under it. CI is not being pursued (decided 2026-09-27): run the sanitizer
build locally instead.

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

## Remaining work (ranked)

Recorded 2026-09-27. Ranked by value for effort; to be discussed one by one.

1. **Close out and merge the branch** (small effort, high value). This
   unblocks the bug fixes, which are only on `address-warnings`.
   - Settle the `-Wnull-dereference` at `Graphalg.cpp:681` (likely a GCC
     false positive, since ASan and UBSan are clean on that path). Either
     suppress it narrowly with `#pragma GCC diagnostic` and a comment, or
     formally accept it.
   - Refresh "What Remains" in `STRICT_WARNINGS_STATUS.md`; the
     `operator=` audit is now covered by `test_myarray`.
   - Add `build-*/` and `strict-warnings*.log` to `.gitignore`.
   - Merge into `master`, then push (confirm before pushing).
2. **Give each build directory its own outputs** (small). Done: the
   `TRAINS_IN_TREE_OUTPUTS` option is on only for `build/` (and always set
   by the Makefile), and there are new `make test`, `make strict` and
   `make asan` targets. At present
   `build`, `build-strict` and `build-asan` all write the same in-tree
   `src/frontend`, `src/train` and `lib/libtrains.a`. This once made a
   normal build link against the sanitizer library. `make` should keep
   putting copies in the old places for anything that expects them (such as
   the MATLAB `train.m` wrapper).
3. **Remove old-build leftovers** (trivial): `src/Makefile`, `src/*.o`, and
   the stray `warnings` file. The `strict-warnings*.log` files are
   superseded by `STRICT_WARNINGS_STATUS.md`; delete them or keep them as
   history.
4. **Try a Clang build** (small to medium). Done: see
   `STRICT_WARNINGS_STATUS.md` ("Clang"). Only GCC has been used so far.
   The history has Mac compiler fixes, and Clang's warnings differ.
5. **README contributor section** (small; Priority 7). Most of the content
   already exists in `CLAUDE.md` ("Integer types", the build and test
   sections); the README needs a version for human contributors.
6. **Modernize `frontend` input** (medium, low value). It still parses
   into fixed `char` buffers with `strcpy`, and more than 10 words on a
   line throws. The overflow is fixed, but `std::string` would remove the
   whole class of problem.
7. **Checked conversions** (medium, low value; Priority 3). The golden
   test and the sanitizers already cover most of what they would catch.
8. **Latent `MyArray` hazards** (low; see Priority 4). None is reachable
   from current callers.

Decided against:

- **Strong index types.** An experiment turning the `types.h` aliases into
  wrapper classes needed 272 or more lines of explicit wraps in the library
  alone. That was mostly edge labels taken from `intarray`s, plus 75 `uint`
  loop counters. Typing the edge arrays made it worse (323 lines). It found
  no case of one kind being passed as another. The overload renames already
  removed the concrete hazard.
- **CI.** Not wanted; see Priority 5.

## Suggested phased execution

Superseded by "Remaining work (ranked)" above.

1. Land type policy + helper conversion utilities.
2. Add `MyArray` edge-case tests and investigate remaining null-deref warning.
3. Add sanitizer CI lane.
4. Expand golden-case algorithm regression tests.
5. Gradually migrate legacy APIs toward clearer domain aliases.

## Definition of done for this roadmap

- Remaining `-Wnull-dereference` is either fixed with evidence or narrowly
  suppressed with documented rationale and reproducer notes.
- Type policy is documented and followed in all new patches.
- The suite passes under `TRAINS_SANITIZE` (ASan + UBSan).
- Algorithm regression coverage is expanded with stable fixtures.
