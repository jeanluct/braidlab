# Test Files for loop.plot Refactoring

This directory contains test scripts and output images created during the
`refactor-loop-plot` branch development.

## Test Scripts

- `test_phase1_1.m` - Tests for Phase 1.1 (geometry extraction)
- `test_phase1_3.m` - Tests for Phase 1.3 (segment ordering)
- `test_fix.m` - Tests for endpoint matching fix
- `test_visual_review.m` - Visual inspection tests (creates PNG outputs)
- `test_visual_inspection.m` - Interactive visual tests with pauses
- `test_debug_component.m` - Debugging component closure issues
- `test_debug.m` - General debugging
- `test_deep_debug.m` - Deep debugging of loop structure
- `test_segment_dump.m` - Dumps segment information

## Test Images

- `visual_test_*.png` - Output from visual review tests
- `test*.png` - Various test outputs
- `debug_components.png` - Component debugging visualization

## Known Issues

As of 2026-03-07, there is a known bug in the segment ordering algorithm
(`orderSegmentsByComponent`) where multi-component loops are not properly
closed. Component 1 completes correctly but Component 2 remains open.

See warnings in test output:
- Component 1: Path incomplete at step 11/18
- Component 2: Path incomplete at step 9/26

The algorithm stops early when all connections to a vertex are marked as
used, suggesting either incorrect component assignment or a flaw in the
traversal logic.
