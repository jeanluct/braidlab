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

All tests passing:
- ✅ `test_visual_review.m` - Visual regression (5 test cases, no warnings)
- ✅ `test_patch_handles.m` - Handle type, count, properties verification
- ✅ `test_component_assignment.m` - Component discovery logic
- ✅ `test_spacing_control.m` - Spacing parameters (7 test cases, 8 images)
- ✅ `test_fill_loops.m` - Fill functionality (8 test cases, 8 images)

### Next Steps

**Phase 5: Multiple Loop Support (#133)** - DEFERRED pending design decision

Refactoring is complete for issues #129, #141, and #144!
Ready to merge to `develop` branch after final review.
