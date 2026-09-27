# Strict Warnings Status

This document is the single source of truth for strict-warning work.

## Current Snapshot

Build profile:

- `cmake -S . -B build-strict -DTRAINS_STRICT_WARNINGS=ON`
- `cmake --build build-strict --target clean`
- `cmake --build build-strict 2>&1 | tee strict-warnings-latest.log`
  (or simply `make strict`)

Warning counts:

| Warning Type | Baseline | After phase 2 | Delta |
| --- | ---: | ---: | ---: |
| `-Wconversion` | 134 | 0 | -134 |
| `-Wsign-conversion` | 124 | 0 | -124 |
| `-Wextra-semi` | 74 | 0 | -74 |
| `-Wshadow` | 17 | 0 | -17 |
| `-Wunused-parameter` | 16 | 0 | -16 |
| `-Wold-style-cast` | 2 | 0 | -2 |
| `-Wuseless-cast` | 1 | 0 | -1 |
| `-Wnull-dereference` | 1 | 1 | 0 |
| **Total** | **369** | **1** | **-368** |

## Completed Work

### Phase 1 (low-risk noise cleanup)

Completed:

- Removed extra semicolons in inline header constructors.
- Removed intentionally unused parameter names in throwing dummy operators.
- Replaced low-risk old/useless casts.
- Fixed local shadowing names.

Outcome:

- Removed all `-Wextra-semi`, `-Wunused-parameter`, `-Wold-style-cast`, and `-Wuseless-cast` warnings.

### Phase 2 (type-boundary normalization)

Completed:

- Normalized signed/unsigned boundaries in headers and core source files.
- Added explicit narrow conversions at clear boundaries.
- Standardized index variable types around container access.

Main touched areas:

- Headers: `trains/newarray.h`, `trains/graph.h`, `trains/edgevert.h`, `trains/braid.h`
- Sources: `src/Graphset.cpp`, `src/graph.cpp`, `src/Graputil.cpp`, `src/Graphalg.cpp`, `src/ttt.cpp`, `src/edgevert.cpp`, `src/hshoe.cpp`, `src/Batch.cpp`, `src/Matrix.cpp`, `src/braid.cpp`, `src/help.cpp`, `src/frontend.cpp`, `src/train.cpp`

Trend snapshots:

- phase 2d: 126 total
- phase 2e: 67 total
- phase 2f: 34 total
- phase 2g: 24 total
- phase 2h: 15 total
- phase 2i: 8 total
- phase 2j: 1 total

Outcome:

- Removed all `-Wconversion` and `-Wsign-conversion` warnings.

## Accepted Warning

### `-Wnull-dereference` (single diagnostic)

Current warning:

- `/usr/include/c++/13/bits/stl_algobase.h:398:17`
- `warning: potential null pointer dereference [-Wnull-dereference]`

Compiler backtrace points through:

- `std::copy`/`std::vector<long>::operator=` internals (inlined)
- `trains::MyArray<T>::operator=` in `trains/newarray.h`
- `trains::graph::MakeIrreducible(bool)` in `src/Graphalg.cpp`

Interpretation:

- This is emitted from inlined STL internals after optimization.
- It may be a conservative analyzer path rather than a concrete runtime fault.
- It touches core assignment flow, so it was investigated before being
  accepted.

Sanitizer evidence (2026-09-26):

- The flagged statement is `CurrentPreP = NextPreP` (`src/Graphalg.cpp`),
  a plain `std::vector<long>` copy inside `MakeIrreducible()`.
  `FindTrainTrack()` calls `MakeIrreducible()` on every run.
- The full CTest suite, including the golden corpus of 53 braids and
  horseshoe orbits, runs clean under `-DTRAINS_SANITIZE=ON`
  (ASan + UBSan). There are no reports on this path.
- This strongly suggests a GCC `-O3` false positive. The two UBSan/ASan
  findings from that run were real bugs elsewhere, and both are fixed
  (see below).
- Clang 18's strict build does not report it (see "Clang").
- `MyArray::operator=` is two member copies (`std::vector` plus the
  origin), and `tests/test_myarray.cpp` covers its edge cases.

Decision (2026-09-27): **accepted as a GCC false positive and not
suppressed.** A strict GCC build is therefore expected to show exactly one
warning, and anything more is new. Revisit if the code around
`CurrentPreP = NextPreP` changes, or if a newer GCC reports it differently.

## What Remains

Nothing: the strict-warning work is closed. The remaining diagnostic is
accepted (above). The sanitizer runs and `test_myarray` replaced the
planned reproducer and the `operator=` audit.

## Validation Gates Used

Run after each warning-reduction batch:

- `cmake --build build`
- `ctest --test-dir build --output-on-failure`
- strict clean rebuild with log capture

- `test_golden_batch` must pass: exact output must match `master`
  from before the cleanup.
- periodically, a sanitizer build:
  `cmake -S . -B build-asan -DTRAINS_SANITIZE=ON -DTRAINS_FAST_MATH=OFF`
  then `cmake --build build-asan` and `ctest --test-dir build-asan`

Current test status: `ctest` passes (`13/13`), both normally and under
ASan + UBSan.

## Behavior Equivalence With `master`

The golden corpus (`tests/golden/braids.txt`) was run on the pre-cleanup
code (`master`) and on this branch:

- At 6 digits, the committed test output (853 lines) is byte-identical.
- At 12 digits, with a full graph dump for every entry (4855 lines), it is
  also byte-identical under the default `-O3 -ffast-math`.

So the cast and type-boundary cleanup did not change results. Without
fast-math, one entry's graph dump starts a vertex's cyclic edge order and
its gate list at a different point. The structure is equivalent; this is
floating-point tie-breaking, not a regression.

## Clang

Checked with Clang 18.1 (2026-09-27), in the default, strict and sanitizer
configurations. All 14 tests pass in each, including the byte-identical
golden test.

- Default flags: no warnings.
- Strict profile: 72 warnings at first. 60 of them were four GCC-only
  flags (`-Wduplicated-cond`, `-Wduplicated-branches`, `-Wlogical-op`,
  `-Wuseless-cast`) being passed to Clang; `CMakeLists.txt` now adds them
  for GCC only. 16 were `-Wdouble-promotion` on `double` literals used as
  `decimal` (Clang also flags constants, which GCC does not); these now have
  an `L` suffix, and the inexact tolerance literals (`STARTTOL`, and
  `train.cpp`'s `TOL`) have an explicit `static_cast<decimal>` so they keep
  their exact value. 6 were `;` after namespace-scope function bodies
  (Clang's `-Wextra-semi` covers these), now removed. Now: 0 warnings.
- These fixes leave the generated code unchanged: `objdump -d` is identical
  for GCC's `libtrains.a`, `frontend` and `train`, and for Clang's
  `libtrains.a`.
- ASan + UBSan: clean.
- Clang does not report the `-Wnull-dereference` that GCC does, which
  further supports the false-positive reading.

## Bugs Found Along the Way

- `src/train.cpp` has printed `Thurston type = Unknown` for every braid
  since e1f1467 (2014). That commit commented out the side-effecting call
  `FindTrainTrack()` along with an unused variable. Fixed on `master`
  (ffd000b, tests in c51da7c).
- `edge` and `vertex` (`trains/edgevert.h`) left their scalar members
  uninitialized. `edgelist`/`vertexlist` allocate them with `new T[n]` and
  copy them while shifting in `_Remove`. UBSan reported loading garbage into
  `bool Flag`. Fixed with default member initializers; the output is
  unchanged.
- `src/frontend.cpp`: an off-by-one heap overflow in `Parse` (a 20-byte
  token buffer allowed 20 characters plus the NUL), a `strcpy` overflow
  into `Filename[20]`, and an unbounded `cin >> Filename`. Any filename of
  20 or more characters corrupted memory. Fixed by sizing the buffers to
  the 200-character input line and bounding the reads with `setw`.
  Regression test: `test_frontend_long_token` (only meaningful under ASan).
