# Test Files for loop.plot Refactoring

This directory contains test scripts and output images created during the
`refactor-loop-plot` branch development.

## Test Scripts

- `test_phase1_1.m` - Tests for Phase 1.1 (geometry extraction)
- `test_phase1_3.m` - Tests for Phase 1.3 (segment ordering)
- `test_fix.m` - Tests for endpoint matching fix
- `test_visual_review.m` - Visual inspection tests (creates PNG outputs)
- `test_patch_handles.m` - Tests for Phase 1.4 (patch object return)
- `test_spacing_control.m` - Tests for Phase 2 (spacing control parameters)
- `test_fill_loops.m` - Tests for Phase 4 (fill loop interiors)
- `test_unit_helpers.m` - **Unit tests for helper functions and features**
- `test_visual_inspection.m` - Interactive visual tests with pauses
- `test_debug_component.m` - Debugging component closure issues
- `test_debug.m` - General debugging
- `test_deep_debug.m` - Deep debugging of loop structure
- `test_segment_dump.m` - Dumps segment information
- `test_component_assignment.m` - Tests component discovery logic
- `diagnose_segments.m` - Diagnostic utility for segment analysis

## Test Images

- `visual_test_*.png` - Output from visual review tests
- `spacing_test_*.png` - Output from spacing control tests
- `fill_test_*.png` - Output from fill loop tests
- `test*.png` - Various test outputs
- `debug_components.png` - Component debugging visualization

## Status

**Phase 1: Core Architecture Refactor** - ✅ COMPLETE (2026-03-07)
**Phase 2: Enhanced Spacing Control (#129)** - ✅ COMPLETE (2026-03-07)
**Phase 3: Handle Return System (#141)** - ✅ COMPLETE (2026-03-07)
**Phase 4: Fill Loop Interiors (#144)** - ✅ COMPLETE (2026-03-07)

Completed phases:
- ✅ Phase 1.1: Extract geometry computation  
- ✅ Phase 1.2: Coordinate-only helpers
- ✅ Phase 1.3: Segment ordering with DFS
- ✅ Phase 1.4: Switch to patch objects
- ✅ Phase 2.1: Add spacing parameters
- ✅ Phase 2.2: Improve layout algorithm
- ✅ Phase 2.3: Test spacing control
- ✅ Phase 3: Handle return (completed in Phase 1.4)
- ✅ Phase 4.1: Add fill options
- ✅ Phase 4.2: Implement fill logic
- ✅ Phase 4.3: Test fill functionality

### Completed Work

### Completed Work

**1. Geometry computation separation:**
- Created `computeLoopGeometry()` to separate coordinate calculation from rendering
- Created `computeSemicircle()` and `computeLine()` helpers
- All geometry computed before any rendering

**2. Multi-component loop closure bug (FIXED):**
- **Root cause:** The original algorithm used pre-assigned `geom.component` IDs
  from vertex components, but vertex components don't correspond 1-to-1 with
  loop components (44 vertices vs 13 segments in test case).
- **Solution:** Completely rewrote `orderSegmentsByComponent()` to discover
  connected components from scratch using DFS on a global vertex-to-segment
  adjacency map.
- **Result:** All test cases now pass - both simple and complex multi-component
  loops close properly with no warnings.

**3. Patch object rendering:**
- Switched from `plot()` to `patch()` for all loop rendering
- Returns column vector (N×1) of patch handles
- Coordinates accessible via `get(h,'XData')` and `get(h,'YData')`
- `FaceColor` set to `'none'` (no fill yet - that's Phase 4)
- Backward compatible - works without output capture

**4. Enhanced spacing control (#129):**
- Added `PunctureGap` parameter (scalar gap multiplier)
- Added `PunctureGapVector` parameter (per-puncture gaps)
- Added `PunctureRadius` parameter (explicit puncture size)
- All parameters validated with clear error messages
- Maintains backward compatibility - defaults unchanged

**5. Fill loop interiors (#144):**
- Added `FillLoop` parameter (enable/disable filling)
- Added `FillColor` parameter (custom fill color, default: auto-generated)
- Added `FillAlpha` parameter (transparency 0-1, default: 0.3)
- Auto-color generation: 50% blend of edge color with white
- Handles both character colors ('b', 'r') and RGB triplets
- Works correctly with Components option (different fills per component)

### Test Results

**Permanent Test Suite (`testsuite/testcases/loopTest.m`):**
- ✅ Added 13 new plot method tests to permanent test suite
- ✅ All 86 tests in loopTest.m pass (73 existing + 13 new)

**Development Tests (this directory):**
- ✅ `test_visual_review.m` - Visual regression (5 test cases, no warnings)
- ✅ `test_patch_handles.m` - Handle type, count, properties verification
- ✅ `test_component_assignment.m` - Component discovery logic
- ✅ `test_spacing_control.m` - Spacing parameters (7 test cases, 8 images)
- ✅ `test_fill_loops.m` - Fill functionality (8 test cases, 8 images)
- ✅ `test_unit_helpers.m` - Unit tests (13 tests, all passing)
  - **Note:** Core functionality now tested in permanent testsuite

### Unit Test Coverage

**Permanent Testsuite (`testsuite/testcases/loopTest.m`):**

Added 13 comprehensive plot method tests (lines 525-682):

1. **test_plot_returns_closed_path** - Simple loop produces closed path
2. **test_plot_multicomponent_closed** - Multi-component loops all close
3. **test_plot_handle_return_type** - Returns patch objects in column vector
4. **test_plot_coordinate_access** - XData/YData accessible via handles
5. **test_plot_puncture_gap_affects_geometry** - Gap parameter changes extent
6. **test_plot_puncture_gap_vector** - Per-puncture gap control works
7. **test_plot_puncture_gap_validation** - Rejects negative gaps
8. **test_plot_puncture_gap_vector_validation** - Rejects wrong-size vectors
9. **test_plot_fill_color_auto_generation** - Auto-lightens edge color
10. **test_plot_fill_color_custom** - Custom fill color works
11. **test_plot_fill_alpha_control** - Alpha transparency control
12. **test_plot_puncture_positions** - Custom positions affect geometry
13. **test_plot_error_multiloop** - Errors on loop vectors (pre-existing)

**Development tests (`test_unit_helpers.m`):**

The `test_unit_helpers.m` file provides comprehensive unit testing:

**Geometry Computation Tests:**
1. Simple loop produces closed path
2. Complex loop produces closed paths for all components

**Component Ordering Tests:**
3. Multi-component loops are properly separated and closed

**Spacing Control Tests:**
4. Puncture positioning affects geometry
5. Gap parameter affects loop geometry
6. GapVector parameter provides per-puncture control
7. PunctureGap validation (rejects negative values)
8. PunctureGapVector validation (rejects wrong-size vectors)

**Fill Functionality Tests:**
9. Fill color auto-generation (50% blend with white)
10. Custom fill color specification
11. Fill alpha transparency control (0 to 1)

**Handle Return Tests:**
12. Handle return type (patch) and count (column vector)
13. Coordinate access via handles (XData/YData)

### Next Steps

**Phase 5: Multiple Loop Support (#133)** - DEFERRED pending design decision

Refactoring is complete for issues #129, #141, and #144!
Ready to merge to `develop` branch after final review.
