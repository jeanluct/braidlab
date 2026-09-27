# Optional build modes

The everyday build is described in the top-level `README.md` (`make`,
`make test`). This file covers the extra configurations used during
development. Each uses its own build directory, so it never disturbs the
main build.

## Build directory layout

The main build directory `build/` (the one `make` uses) keeps the traditional
layout: `lib/libtrains.a`, `src/frontend` and `src/train`. Any other build
directory keeps its outputs inside itself (for example `build-asan/frontend`),
so extra configurations never overwrite the main build. This is controlled by
the CMake option `TRAINS_IN_TREE_OUTPUTS`, which is on by default only for
`build/` (and always set by the Makefile). `make distclean` removes every
`build-*` directory.

## Strict warnings profile

Enable additional compile-time checks without changing default behavior:

- `make strict`, or equivalently:
  - `cmake -S . -B build-strict -DTRAINS_STRICT_WARNINGS=ON`
  - `cmake --build build-strict --target clean`
  - `cmake --build build-strict 2>&1 | tee strict-warnings-latest.log`

This adds an extended warning set for GNU/Clang (`-Wextra`, `-Wpedantic`,
`-Wconversion`, `-Wsign-conversion`, etc.; a few GCC-only flags are added for
GCC alone) and `/W4` on MSVC. A strict GCC build should report exactly one
warning, an accepted false positive; a strict Clang build none. See
`STRICT_WARNINGS_STATUS.md`.

## Sanitizer build

Build and run the tests with AddressSanitizer and UndefinedBehaviorSanitizer
(GNU/Clang):

- `make asan`, or equivalently:
  - `cmake -S . -B build-asan -DTRAINS_SANITIZE=ON -DTRAINS_FAST_MATH=OFF`
  - `cmake --build build-asan`
  - `ctest --test-dir build-asan --output-on-failure`

## Clang

Any configuration can be built with Clang by choosing the compiler when the
build directory is first configured, for example:

- `cmake -S . -B build-clang -DCMAKE_CXX_COMPILER=clang++`
- `cmake --build build-clang`
- `ctest --test-dir build-clang --output-on-failure`

Add `-DTRAINS_STRICT_WARNINGS=ON` or `-DTRAINS_SANITIZE=ON` as above.
