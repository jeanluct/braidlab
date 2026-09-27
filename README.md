*trains* is a C++ library originally written by **[Toby Hall](https://www.liverpool.ac.uk/people/toby-hall)**.   It is an implementation of Bestvina and Handel's algorithm for determining train tracks of surface homeomorphisms (Topology **34** (1995), 109-140).

As Toby only maintains a version of *trains* with a graphical interface for Windows, this is based on the last command-line version (trains4).  **Toby Hall is not responsible for bugs in this GitHub version of the software, since he is not involved in its maintenance.**

The code is maintained by **[Jean-Luc Thiffeault](https://people.math.wisc.edu/~thiffeault/)**.  It is being updated to run on current C++ compilers.

## Building

The project builds with CMake. The top-level `Makefile` is a backwards-compatible wrapper around CMake.

- Preferred CMake flow:
  - `cmake -S . -B build`
  - `cmake --build build`
- Back-compatible Make targets:
  - `make` (build library + executables)
  - `make lib` (build static library only)
  - `make test` (build, then run the test suite)
  - `make strict` (clean rebuild with strict warnings, see below)
  - `make asan` (build and test with sanitizers, see below)
  - `make clean`
  - `make distclean` (also removes the other `build-*` directories)

The main build directory `build/` (the one `make` uses) keeps the traditional
layout: `lib/libtrains.a`, `src/frontend` and `src/train`. Any other build
directory keeps its outputs inside itself (for example `build-asan/frontend`),
so extra configurations never overwrite the main build. This is controlled by
the CMake option `TRAINS_IN_TREE_OUTPUTS`, which is on by default only for
`build/`.

### Optional strict warnings profile

Enable additional compile-time checks without changing default behavior:

- `make strict`, or equivalently:
  - `cmake -S . -B build-strict -DTRAINS_STRICT_WARNINGS=ON`
  - `cmake --build build-strict`

This adds an extended warning set for GNU/Clang (`-Wextra`, `-Wpedantic`,
`-Wconversion`, `-Wsign-conversion`, etc.) and `/W4` on MSVC.

### Optional sanitizer build

Build and run the tests with AddressSanitizer and UndefinedBehaviorSanitizer
(GNU/Clang):

- `make asan`, or equivalently:
  - `cmake -S . -B build-asan -DTRAINS_SANITIZE=ON -DTRAINS_FAST_MATH=OFF`
  - `cmake --build build-asan`
  - `ctest --test-dir build-asan --output-on-failure`

### Running tests (CTest)

The project includes a CTest-compatible suite under `tests/` focused on library
coverage (array utilities, braids/horseshoe parsing, graph setup and transforms,
matrix operations, batch processing, and supporting components).

- `cmake -S . -B build`
- `cmake --build build`
- `ctest --test-dir build --output-on-failure`
