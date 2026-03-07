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
- `test_visual_inspection.m` - Interactive visual tests with pauses
- `test_debug_component.m` - Debugging component closure issues
- `test_debug.m` - General debugging
- `test_deep_debug.m` - Deep debugging of loop structure
- `test_segment_dump.m` - Dumps segment information
- `test_component_assignment.m` - Tests component discovery logic
- `diagnose_segments.m` - Diagnostic utility for segment analysis

## Test Images

- `visual_test_*.png` - Output from visual review tests
- `test*.png` - Various test outputs
- `debug_components.png` - Component debugging visualization

## Status

**Phase 1: Core Architecture Refactor** - ✅ COMPLETE (2026-03-07)
**Phase 2: Enhanced Spacing Control** - ✅ COMPLETE (2026-03-07)

Completed phases:
- ✅ Phase 1.1: Extract geometry computation  
- ✅ Phase 1.2: Coordinate-only helpers
- ✅ Phase 1.3: Segment ordering with DFS
- ✅ Phase 1.4: Switch to patch objects
- ✅ Phase 2.1: Add spacing parameters
- ✅ Phase 2.2: Improve layout algorithm
- ✅ Phase 2.3: Test spacing control

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

### Test Results

All tests passing:
- ✅ `test_visual_review.m` - Visual regression (5 test cases, no warnings)
- ✅ `test_patch_handles.m` - Handle type, count, properties verification
- ✅ `test_component_assignment.m` - Component discovery logic
- ✅ `test_spacing_control.m` - Spacing parameters (7 test cases, 8 images)

### Next Steps

Ready for Phase 3: Handle return system (already complete from Phase 1.4!)
Moving to Phase 4: Fill loop interiors (#144)
