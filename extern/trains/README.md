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
  - `make strict` (clean rebuild with strict warnings)
  - `make asan` (build and test with sanitizers)
  - `make clean`
  - `make distclean` (also removes the other `build-*` directories)

`make` leaves the library in `lib/libtrains.a` and the executables in
`src/frontend` and `src/train`.

The optional development builds (strict warnings, sanitizers, Clang) are
described in [`devel/BUILDING.md`](devel/BUILDING.md).

### Running tests (CTest)

The project includes a CTest-compatible suite under `tests/` focused on library
coverage (array utilities, braids/horseshoe parsing, graph setup and transforms,
matrix operations, batch processing, and supporting components).

- `cmake -S . -B build`
- `cmake --build build`
- `ctest --test-dir build --output-on-failure`
