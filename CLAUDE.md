# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository.

## What this is

C++ implementation of the Bestvina–Handel train-track algorithm for surface
homeomorphisms (punctured-disc braids), originally by Toby Hall (trains4,
command-line version). Maintained by Jean-Luc Thiffeault. Current work is
modernizing it for current compilers: warning cleanup, tests, and bug hunting.
Behavior should stay unchanged unless a change is explicitly intended.

## Build and test

CMake is canonical. The top-level `Makefile` is a thin wrapper
(`make`, `make lib`, `make clean`, `make distclean`).

    cmake -S . -B build && cmake --build build
    ctest --test-dir build --output-on-failure
    ctest --test-dir build -R test_graph_io --output-on-failure   # one test
    ctest --test-dir build -L graph                               # by label

Outputs go into the source tree, not `build/`: `lib/libtrains.a`,
`src/frontend` (the interactive program), and `src/train` (a non-interactive
`train <strings> <generators...>`). `src/Makefile` and the `src/*.o` files are
leftovers from the old build.

Strict-warning profile (separate build dir by convention):

    cmake -S . -B build-strict -DTRAINS_STRICT_WARNINGS=ON
    cmake --build build-strict --target clean
    cmake --build build-strict 2>&1 | tee strict-warnings-phaseN.log

Sanitizer build (ASan + UBSan; run it after any nontrivial change):

    cmake -S . -B build-asan -DTRAINS_SANITIZE=ON -DTRAINS_FAST_MATH=OFF
    cmake --build build-asan && ctest --test-dir build-asan

`TRAINS_FAST_MATH` (default ON) adds `-ffast-math`. The library is built with
`-O3`. **Every build directory writes the same in-tree `src/frontend`,
`src/train` and `lib/libtrains.a`**, so building `build-asan` or
`build-strict` overwrites the normal binaries. Rebuild the directory whose
binaries you want to run or test last.

## Warning-cleanup status

`STRICT_WARNINGS_STATUS.md` is the single source of truth. The count went
from 369 to 1. The remaining one is a `-Wnull-dereference` in an STL-inlined
path through `MyArray::operator=`. `IMPROVEMENTS.md` has the prioritized
roadmap: integer/type policy, domain type aliases, checked conversions,
`MyArray` edge-case tests, a sanitizer lane, and golden algorithm regressions.
`todo.md` is the user's top-level checklist. Keep these documents up to date
when landing related work. Code touched in a change should stay clean under
the strict profile.

## Architecture

Everything is in `namespace trains`. Headers are in `trains/`, sources in
`src/`. Include them as `"trains/foo.h"`, relative to the repo root.

- **`graph`** (`trains/graph.h`) is the central class. Its implementation is
  split by concern: `Graphset.cpp` (setup from braids, printing, save/load),
  `graph.cpp` (moves: split, collapse, fold, subdivide, valence-two
  isotopy), `Graputil.cpp` (utilities, derivatives, turns, gates,
  singularities), and `Graphalg.cpp` (the Bestvina–Handel steps:
  `PullTight`, `CollapseInvariantForest`, `PerformValenceTwoIsotopies`,
  `AbsorbIntoP`, `MakeIrreducible`, `FoldToDecreaseLambda`, and the driver
  `FindTrainTrack`; also `FindReduction` and `FindTrack`).
- `edgevert.*` holds edges and vertices (`edgelist`/`vertexlist`).
  `embedding.*` tracks embedding info. `Matrix.*` builds transition matrices
  and computes growth. `braid.*`/`hshoe.*` parse braids and horseshoe words.
  `ttt.*` is the train-track-type output. `Batch.*` does batch processing.
  `help.*` holds the interactive help text.
- **`MyArray<T>`** (`trains/newarray.h`; `intarray` = `MyArray<long>`) wraps
  `std::vector` with an origin that defaults to **1**. `operator[]`
  **auto-grows** the array on out-of-range access. `TopIndex()` is the last
  valid index. Loops conventionally run `for (i = 1; i <= TopIndex(); ++i)`.
  Edge labels are signed: `-L` is edge `L` reversed. Edge images are
  `intarray`s of labels, and `Invert` reverses and negates.
- **Globals `TOL` (a `decimal`, i.e. `long double`) and `GrowthCheck` are
  declared in the headers but defined by each executable** (`train.cpp`,
  `frontend.cpp`). Tests get them from `tests/test_runtime.cpp`. Any new
  binary that links `libtrains` must define them.
- Errors: the `THROW(msg, n)` macro in `trains/General.h` throws
  `trains::Error`. `TRY`/`CATCH` are macro aliases. `uint` is
  `unsigned int`.
- Platform macros (`VS2005`, `__WINDOWSVERSION`, `__UNIXVERSION`) and
  `__CHARPOLY` (undefined in `General.h`) gate legacy code paths. Only the
  Unix path is built here.

## Integer types

`trains/types.h` names the integer kinds: `EdgeLabel` (signed `long`; `-L`
is edge `L` reversed), `EdgeIndex`/`VertexIndex` (1-based positions in
`graph::Edges`/`Vertices`), `VertexLabel`, `PunctureIndex` (0 means none),
and `BraidGenerator`. They are plain typedefs, so they document intent
without enforcing it. The rules:

- Use the aliases in new or changed signatures and data members. Counts
  stay `uint`, and `size_t` is used only when iterating STL containers
  directly.
- Never overload a function on two integer types (for example `long` versus
  `uint`): the argument's type silently chooses the function. Use distinct
  names instead (`IsPeripheralLabel` versus `IsPeripheralIndex`).
- Convert once at a boundary with `static_cast`, not repeatedly inside
  expressions.
- Don't name a local variable after an alias. `-Wshadow` flags it in the
  strict build, and the code already uses `EIndex`, `VIndex` and `VLabel`
  for such locals.
- For a purely type-level change, check that
  `objdump -d --no-show-raw-insn lib/libtrains.a` is unchanged.

## Tests

`tests/` contains one CTest executable per area, using the minimal
`CHECK_TRUE`/`CHECK_EQ`/`check_close` macros in `tests/test_util.h`; there is
no external framework. `tests/COVERAGE.md` maps tests to library functions.
Integration tests drive `frontend` (piped stdin) and `train` (a regex on its
output).

`test_golden_batch` is the behavior-preservation gate. It runs
`tests/golden/braids.txt` through frontend's `run` command (batch output
goes to stderr) via `tests/golden/run_golden.cmake`, and requires
byte-identical output to `tests/golden/braids.expected`. That file was
generated from `master` before the warning cleanup. Regenerate it only for
an intended behavior change, and explain the diff in the commit. Growth is
printed at 6 digits because it is only converged to about 1e-9 and varies
with fast-math.

New test executables must be registered in `tests/CMakeLists.txt` with
`test_runtime.cpp` and a `LABELS` property.

## Reference

`doc/trainhelp.pdf` is the original user manual.
