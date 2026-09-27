# Test Coverage for `trains` Library

This document summarizes how the CTest suite exercises the core library code.

## Scope and intent

The suite is library-first. It focuses on:

- core data structures and utility logic
- braid/horseshoe parsing and conversion paths
- graph construction, mutation, I/O, and matrix/track analysis paths
- batch-processing entry points

The command-line programs are treated as thin wrappers and are only lightly
smoke-tested.

## Test map

## `test_newarray_embedding`

Exercises:

- `trains/newarray.h`
  - generic `tighten(...)`
  - `MyArray` operations: `Tighten`, `Invert`, `Replace`, `CyclicTighten`
- `src/embedding.cpp`
  - `EmbeddingInformation` append/prepend composition
  - path tightening and stream output formatting

## `test_braid_horseshoe_batch`

Exercises:

- `src/braid.cpp`
  - `braid::Set(uint, intarray)`
  - stream extraction (`operator>>`)
  - `braid::Permute`
  - conversion from horseshoe (`braid::Set(horseshoe&)`)
- `src/hshoe.cpp`
  - `horseshoe::FindPermutation`
- `src/Batch.cpp`
  - `BatchProcess(std::istream&, int)`
  - command parsing/dispatch for representative batch commands

## `test_graph_setup`

Exercises:

- `src/Graphset.cpp`
  - `graph::IdentityGraph`
  - `graph::ActOn`
  - `graph::Set(braid&)`
  - `graph::BoundaryPeripheralSet(braid&)`
  - `graph::ReLabel`
  - `graph::SanityCheck`

## `test_graph_matrix`

Exercises:

- `src/Matrix.cpp`
  - transition matrix construction (`matrix(graph&, ...)`)
  - size and matrix access paths
- `src/Graputil.cpp`
  - `graph::TransitionMatrix` in `raw`, `maple`, `latex` modes
  - `graph::HasIrreducibleMatrix`
  - `graph::FindTrack`

## `test_graph_io`

Exercises:

- `src/Graphset.cpp`
  - `graph::Save`
  - `graph::Load(std::string)` and stream-backed load internals
  - round-trip structural invariants via `SanityCheck`

## `test_graph_algorithms`

Exercises:

- `src/Graputil.cpp`
  - `graph::FindTypes`
  - irreducibility check path
  - `graph::FindTrack`
- `src/graph.cpp`
  - `graph::PullTight`
  - mutating paths validated with post-check `SanityCheck`

## `test_misc_components`

Exercises:

- `src/General.cpp`
  - `LowerCase`
  - `Error` class basics
- `src/edgevert.cpp`
  - `edge::Set` / getters
  - `vertex::Set` / getters
  - `edgelist`/`vertexlist` indexing paths
- `src/help.cpp`
  - `Help(topic)` non-interactive topic dispatch path

## `test_frontend_horseshoe_ttt` (integration smoke)

Exercises a short scripted `frontend` session and confirms the horseshoe ->
train -> TTT flow runs end-to-end. This gives integration coverage around:

- horseshoe input command path
- train-track computation invocation from frontend
- TTT output path (`src/ttt.cpp`)

## `test_myarray`

Edge cases of `MyArray<T>` (`trains/newarray.h`):

- assignment: empty/non-empty in each direction, self-assignment, deep copy,
  repeated assignment under mutation (the `MakeIrreducible` pattern)
- 1-based indexing, zero-filled auto-growth on read and write, `Find`,
  `Add` vs `SureAdd`
- `Rotate`: wrap-around, negative angles, empty and single-element arrays,
  and the rotate-then-remove idiom in `graph::Collapse`
- `Remove`, `Insert`, `Split`, `Append`/`Prepend`, `RemoveAll`, `Replace`
  with an empty array, `Invert` edge cases
- `Tighten`/`CyclicTighten` nesting and full cancellation
- `Agrees`/`AgreesTo` with prefixes and empty arrays
- `arrayiterator` cyclic wrap for pre- and post-increment

## Other integration tests

- `test_train_*`: one braid per Thurston type through `train`.
- `test_frontend_long_token`: tokens over 20 characters (a past buffer
  overflow; only meaningful under `TRAINS_SANITIZE`).
- `test_golden_batch`: exact output of the corpus in `tests/golden/`
  against pre-cleanup `master`. See `CLAUDE.md`.

## Notes on boundaries

- The suite aims for broad behavioral coverage of major library modules, not
  exhaustive branch coverage of every legacy edge case.
- Some highly interactive/error-only branches are not fully enumerated.
- If deeper coverage is needed, the current split by concern (`setup`, `io`,
  `matrix`, `algorithms`, `batch`, etc.) is intended to make targeted expansion
  straightforward.
