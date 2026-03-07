# Comprehensive Refactoring Plan for `loop.plot`

**Date:** 2026-03-07  
**Target File:** `+braidlab/@loop/plot.m`  
**Current Implementation:** 484 lines

---

## Executive Summary

Complete refactor of the `loop.plot` method to address four GitHub issues (#129, #141, #133, #144) and incorporate partial work from two feature branches (`iss129-improve-loop-plot`, `iss141-handle-for-loop-plot`). The refactor will modernize the architecture, improve flexibility, and align with MATLAB plotting conventions.

---

## Current State Analysis

### Existing Implementation
- **Location:** `+braidlab/@loop/plot.m` (484 lines)
- **Core Function:** Plots loops using Dynnikov coordinates
- **Architecture:** 
  - Plots punctures as filled circles using `patch()`
  - Draws loop segments incrementally using `joinpoints()` helper
  - Segments plotted out of topological order (semicircles → above segments → below segments)
  - Each segment plotted with separate `plot()` call
- **Helper Functions:**
  - `getcoords(L)`: Extracts n, b, M, N coordinates
  - `joinpoints(mine, next, positions, gaps, options)`: Plots individual segments (semicircles or lines)

### Current Options
- `LineColor`, `LineStyle`, `LineWidth`: Loop appearance
- `PunctureColor`, `PunctureEdgeColor`, `PunctureEdgeWidth`, `PunctureSize`: Puncture appearance
- `PuncturePositions`: Custom puncture positions (default: integers on x-axis)
- `BasePointColor`: Color for basepoint puncture
- `Components`: Plot connected components in different colors

### Known Issues

#### Issue #129: Improve spacing control
- **Problem:** Puncture size adjustable, but doesn't adjust loop spacing around punctures
- **Current behavior:** Gap = `min(space_between_loop_lines)/2`
- **Need:** Flexible, user-controllable spacing options
- **Milestone:** release-4.0
- **Branch:** `iss129-improve-loop-plot` (3 lines changed, comments added)

#### Issue #141: Output handles for loop plot
- **Problem:** No way to get handles to plotted objects
- **Use case:** Modify loop segments programmatically, extract coordinates
- **Current:** No return value
- **Milestone:** release-3.3
- **Branch:** `iss141-handle-for-loop-plot` (significant progress)
  - Function signature changed to `function [varargout] = plot(...)`
  - Collects XY coordinates per component in cell array `XYcomp{}`
  - Introduced `divideComponents` flag
  - Started `linksort.m` for segment ordering (incomplete)
  - Modified `joinpoints()` to return coordinates instead of plotting directly

#### Issue #133: Handle multiple loops
- **Problem:** `loop.plot` fails uninformatively when passed loop vector
- **Current:** Assertion error with message to use `plot(L(k))`
- **Milestone:** release-3.3
- **Potential solutions:**
  - **Option A:** Plot all loops on same axes with different colors (return cell array or concatenated array of handles)
  - **Option B:** Create subplot grid, one loop per subplot (return axes handles)
  - **Option C:** Keep current behavior (error on vector input, require manual iteration)
- **Decision:** **Deferred** - note options in plan, decide during implementation

#### Issue #144: Fill interior of loops
- **Problem:** No option to fill the space inside loops
- **Use case:** Easier visualization of loop action
- **Dependency:** Requires #141 (handles) for proper implementation
- **Milestone:** release-4.0

---

## Goals and Requirements

### Primary Goals
1. Return graphics handles following MATLAB conventions
2. Enable flexible spacing control for punctures and loops
3. Support filling loop interiors
4. Improve code architecture and maintainability
5. Maintain backward compatibility with existing code

### Design Principles
- **MATLAB Convention Alignment:** Follow native `plot()` behavior
  - Return column vector of handles (N×1)
  - One handle per loop component
  - Use `patch()` objects for natural closed-curve representation
  - Coordinates accessible via `get(h(i), 'XData')` and `get(h(i), 'YData')`
- **Separation of Concerns:** Separate geometry computation from rendering
- **Backward Compatibility:** Existing code without handle capture continues to work
- **Clean API:** Simple, intuitive interface following MATLAB patterns

---

## Technical Architecture

### Key Architectural Changes

#### 1. Geometry Computation (New)
**New private method:** `computeLoopGeometry(L, options)`

**Purpose:** Separate geometry calculation from rendering

**Inputs:**
- `L`: Loop object
- `options`: Parsed options structure

**Outputs:**
```matlab
geom.numComponents     % Number of connected components
geom.components(i).X   % X coordinates (ordered, closed path)
geom.components(i).Y   % Y coordinates (ordered, closed path)
geom.components(i).id  % Component ID
geom.punctures.X       % Puncture X positions
geom.punctures.Y       % Puncture Y positions
geom.punctures.radius  % Puncture radii for drawing
```

**Benefits:**
- Testable independently
- Reusable for other methods
- Clear separation of concerns
- Enables both plotting and coordinate extraction

#### 2. Segment Ordering Algorithm (Critical)
**Problem:** Current implementation plots segments out of topological order:
1. All semicircles
2. All "above" line segments  
3. All "below" line segments

**Solution:** Implement topological traversal
- Start at arbitrary point on component
- Follow loop continuously around punctures
- Build ordered list of (x,y) coordinates
- Close path: ensure `last_point == first_point`

**Implementation approach:**
- Build connectivity graph of segment endpoints
- Use graph traversal (DFS/BFS) to order segments
- Handle both semicircles and straight segments
- Maintain proper orientation (avoid self-intersections)

#### 3. Refactored `joinpoints()` Helper
**Current signature:**
```matlab
joinpoints(mine, next, positions, gaps, options)  % plots directly
```

**New signature:**
```matlab
[x, y] = joinpoints(mine, next, positions, gaps)  % returns coordinates
```

**Changes:**
- Remove all `plot()` calls
- Return coordinate arrays instead
- Remove `options` parameter (not needed for geometry)
- Keep semicircle/line logic unchanged
- Maintain same coordinate generation algorithm

#### 4. Handle Return System
**Function signature:**
```matlab
function h = plot(L, varargin)
```

**Return value:**
- Column vector (N×1) of graphics handles
- One `patch` object per loop component
- Empty `[]` if no components
- Follows MATLAB convention: `h = plot(x, sin(x), x, cos(x))` returns 2×1 array

**Implementation:**
```matlab
h = zeros(numComponents, 1);  % Pre-allocate
for i = 1:numComponents
    h(i) = patch(X{i}, Y{i}, color, ...);
end
```

**User access to coordinates:**
```matlab
xdata = get(h(1), 'XData');
ydata = get(h(1), 'YData');
```

No separate coordinate output argument needed.

---

## Implementation Plan

### Phase 1: Core Architecture Refactor

**Status:** Phase 1.1-1.3 ✅ COMPLETE (2026-03-07)

#### 1.1 Extract Geometry Computation ✅ COMPLETE
- **Task:** Create `computeLoopGeometry()` private method
- **Location:** New private method in `@loop` folder or within `plot.m`
- **Implementation:**
  - Move coordinate extraction logic from main `plot()`
  - Compute puncture positions, gaps, radii
  - **Do not** compute component ordering yet (that's Phase 1.3)
  - Return structured data (see Technical Architecture §1)
- **Testing:** Unit test with known loop coordinates

#### 1.2 Refactor `joinpoints()` Helper ✅ COMPLETE
- **Task:** Change from plotting to coordinate return
- **Completed:** Renamed to `computeSemicircle()` and `computeLine()` for clarity
- **Changes:**
  ```matlab
  % OLD:
  joinpoints([p, idx1], [p+1, idx2], positions, gaps, options)
  % plots directly with options.LineColor, etc.
  
  % NEW:
  [x, y] = joinpoints([p, idx1], [p+1, idx2], positions, gaps)
  % returns coordinate arrays
  ```
- **Implementation:**
  - Keep semicircle generation logic (lines 451-457)
  - Keep straight line logic (lines 472-473)
  - Remove all `plot()` calls
  - Remove `if options.Components` branches
  - Return `[x, y]` arrays
- **Testing:** Verify coordinate generation matches current implementation

#### 1.3 Implement Segment Ordering ✅ COMPLETE
- **Task:** Order segments to form continuous, closed paths per component
- **Completed:** Implemented DFS-based component discovery in `orderSegmentsByComponent()`
  - Builds global vertex-to-segment adjacency map
  - Discovers connected components from scratch (ignores pre-assigned vertex components)
  - Uses greedy traversal within nested `traverseComponent()` helper
  - All test cases pass - multi-component loops close properly
- **Testing:** ✅ Visual verification complete - all loops render correctly
- **Challenge:** Current code uses hash table (`keytohash`) to map segment→component
  - Semicircles: lines 230-239
  - Above segments: lines 265-300
  - Below segments: lines 328-364
- **Algorithm:**
  1. Build segment list with component assignments (existing logic)
  2. For each component:
     - Build connectivity graph: segment_end(i) → segment_start(j)
     - Find starting segment (arbitrary choice)
     - Traverse graph to build ordered segment list
     - Call `joinpoints()` for each segment in order
     - Concatenate coordinates: `[x1, x2, x3, ...]`
     - Close path: append first point if needed
  3. Return ordered coordinate arrays per component
- **Reference:** Partial work in `iss141-handle-for-loop-plot` branch
  - `devel/tests/iss141-handle-for-loop-plot/linksort.m` (incomplete)
  - Concept: "sort linked two-tuples"
- **Testing:** Visual verification (loops should look identical to current)

#### 1.4 Integrate Geometry Computation into Main Plot ⏳ TODO
- **Task:** Switch from `plot()` to `patch()` objects for rendering
- **Flow:**
  ```matlab
  function h = plot(L, varargin)
      % Parse options (existing)
      % Compute geometry
      geom = computeLoopGeometry(L, options);
      
      % Plot punctures (existing logic, lines 189-211)
      
      % Plot loop components (NEW)
      h = zeros(geom.numComponents, 1);
      for i = 1:geom.numComponents
          h(i) = patch(geom.components(i).X, ...
                       geom.components(i).Y, ...
                       compcolors(i,:), ...
                       'EdgeColor', options.LineColor, ...
                       'LineWidth', options.LineWidth, ...
                       'LineStyle', options.LineStyle, ...
                       'FaceColor', 'none');  % No fill yet
      end
      
      % Restore hold state, axis settings (existing)
  end
  ```
- **Testing:** Regression tests - all existing plots should look identical

---

### Phase 2: Enhanced Spacing Control (#129)

#### 2.1 Add New Spacing Options
**New parameters:**

```matlab
parser.addParameter('PunctureGap', [], @(x) isempty(x) || (isnumeric(x) && isscalar(x) && x > 0));
parser.addParameter('PunctureGapVector', [], @(x) isempty(x) || (isnumeric(x) && isvector(x)));
parser.addParameter('PunctureRadius', [], @(x) isempty(x) || (isnumeric(x) && isscalar(x) && x > 0));
```

**Parameter descriptions:**
- `PunctureGap`: Scalar multiplier for gap spacing (default: auto-calculated from `min(space)/2`)
- `PunctureGapVector`: Per-puncture gap sizes (n×1 vector, overrides `PunctureGap`)
- `PunctureRadius`: Explicit puncture radius (overrides automatic sizing)

**Default behavior (backward compatible):**
- If no spacing options specified → use current algorithm (line 152)
- If `PunctureGap` specified → `pgap = PunctureGap * ones(n,1)`
- If `PunctureGapVector` specified → use as-is (must be length n)

#### 2.2 Improve Layout Algorithm
**Current logic (lines 147-161):**
```matlab
space_between_loop_lines = diff(puncture_position(:,2));
for i = 1:n-1
  space_between_loop_lines(i) = ...
    space_between_loop_lines(i)/(max(M_coord(i), N_coord(i)) + 1);
end
pgap = min(space_between_loop_lines)/2 + zeros(n,1);
```

**Improvements:**
1. Make visual puncture radius independent of loop spacing
2. Allow `PunctureSize` to control display size only
3. Use `PunctureRadius` or `PunctureGap` to control loop spacing
4. Add validation: ensure gaps don't cause overlaps

**Implementation:**
```matlab
% Visual puncture radius (for drawing only)
if isempty(options.PunctureRadius)
    visual_radius = <current algorithm>;
else
    visual_radius = options.PunctureRadius;
end

% Loop spacing gaps (affects loop layout)
if ~isempty(options.PunctureGapVector)
    pgap = options.PunctureGapVector(:);
    assert(length(pgap) == n, 'PunctureGapVector must have length n');
elseif ~isempty(options.PunctureGap)
    pgap = options.PunctureGap * ones(n, 1);
else
    % Current auto-calculation (backward compatible)
    pgap = min(space_between_loop_lines)/2 + zeros(n,1);
end
```

#### 2.3 Testing
- Test with various gap settings
- Verify no overlaps
- Visual regression: default behavior unchanged
- Test edge cases: very small/large gaps

---

### Phase 3: Handle Return System (#141)

#### 3.1 Function Signature
**Change:**
```matlab
% OLD:
function plot(L, varargin)

% NEW:
function h = plot(L, varargin)
```

**Documentation update (lines 1-24):**
```matlab
%PLOT   Plot a loop.
%   PLOT(L) plots a representative of the equivalence class
%   defined by the loop L.
%
%   H = PLOT(L,...) returns a column vector of handles to the plotted
%   loop components. Each handle is a patch object corresponding to one
%   connected component of the loop. Use GET(H(i),'XData') and 
%   GET(H(i),'YData') to access coordinates.
%
%   PLOT(L,'PropName',VALUE,...) can be used to set property PropName to
%   VALUE.  Valid properties are
%   ...
```

#### 3.2 Handle Creation Strategy
**Use `patch()` objects:**
- Naturally represent closed curves
- Built-in support for fills (needed for Phase 4)
- Can control edge and face independently
- Follows MATLAB graphics conventions

**Implementation (integrated with Phase 1.4):**
```matlab
h = zeros(numComponents, 1);
for i = 1:numComponents
    if options.Components
        edgecolor = compcolors(i,:);
    else
        edgecolor = options.LineColor;
    end
    
    h(i) = patch(geom.components(i).X, ...
                 geom.components(i).Y, ...
                 'EdgeColor', edgecolor, ...
                 'LineWidth', options.LineWidth, ...
                 'LineStyle', options.LineStyle, ...
                 'FaceColor', 'none');  % No fill (yet)
end
```

#### 3.3 Backward Compatibility
**When handle not requested:**
```matlab
% User code:
plot(L, 'LineColor', 'r');  % No output capture

% Still works - handles created internally but discarded
% Standard MATLAB behavior
```

**When handle requested:**
```matlab
% User code:
h = plot(L);
xdata = get(h(1), 'XData');
ydata = get(h(1), 'YData');
plot(xdata*2, ydata*2, 'r--');  % Reuse coordinates
```

#### 3.4 Testing
- Test handle return for 1, 2, 3+ components
- Verify handle type: `class(h) == 'matlab.graphics.primitive.Patch'`
- Verify size: `size(h) == [N, 1]` for N components
- Test coordinate access via `get()`
- Test handle modification: `set(h(1), 'EdgeColor', 'r')`
- Verify backward compatibility: no-output calls still work

---

### Phase 4: Fill Loop Interiors (#144)

#### 4.1 Add Fill Options
**New parameters:**
```matlab
parser.addParameter('FillLoop', false, @islogical);
parser.addParameter('FillColor', [], @(x) isempty(x) || iscolor(x));
parser.addParameter('FillAlpha', 0.3, @(x) isnumeric(x) && isscalar(x) && x >= 0 && x <= 1);
```

**Parameter descriptions:**
- `FillLoop`: Enable loop interior filling (default: false)
- `FillColor`: Fill color (default: lighter version of edge color)
- `FillAlpha`: Fill transparency, 0=transparent, 1=opaque (default: 0.3)

#### 4.2 Implementation
**Modify patch creation (from Phase 3.2):**
```matlab
h = zeros(numComponents, 1);
for i = 1:numComponents
    if options.Components
        edgecolor = compcolors(i,:);
    else
        edgecolor = options.LineColor;
    end
    
    % Determine fill color
    if options.FillLoop
        if isempty(options.FillColor)
            % Auto-generate lighter version of edge color
            fillcolor = min(edgecolor * 1.5, 1);  % Lighten
        else
            fillcolor = options.FillColor;
        end
        facecolor = fillcolor;
    else
        facecolor = 'none';
    end
    
    h(i) = patch(geom.components(i).X, ...
                 geom.components(i).Y, ...
                 'EdgeColor', edgecolor, ...
                 'LineWidth', options.LineWidth, ...
                 'LineStyle', options.LineStyle, ...
                 'FaceColor', facecolor, ...
                 'FaceAlpha', options.FillAlpha);
end
```

#### 4.3 Testing
- Test fill on/off
- Test custom fill colors
- Test alpha transparency
- Test with multiple components
- Test with `Components` option (different colors per component)
- Visual verification: filled loops easier to see (per issue description)

---

### Phase 5: Multiple Loop Support (#133)

**Status:** Decision deferred

**Options documented for future implementation:**

#### Option A: Plot all loops on same axes
**Behavior:**
```matlab
L = [loop1, loop2, loop3];  % 1×3 loop vector
h = plot(L);
% Plots all 3 loops on current axes with hold on
% h is cell array: h{1} = handles for loop1, h{2} for loop2, etc.
% OR: h is concatenated array [h1; h2; h3; ...] (simpler but loses loop boundaries)
```

**Implementation sketch:**
```matlab
if length(L) > 1
    holdstate = ishold;
    h = cell(length(L), 1);
    for k = 1:length(L)
        if k > 1, hold on; end
        h{k} = plot(L(k), varargin{:});
    end
    if ~holdstate, hold off; end
    return
end
```

**Pros:** Simple, follows hold paradigm, all loops visible together  
**Cons:** May be cluttered, need color cycling strategy

#### Option B: Create subplot grid
**Behavior:**
```matlab
L = [loop1, loop2, loop3, loop4];
h = plot(L);
% Creates 2×2 subplot grid
% Each subplot contains one loop
% h is array of axes handles
```

**Implementation sketch:**
```matlab
if length(L) > 1
    nrows = ceil(sqrt(length(L)));
    ncols = ceil(length(L) / nrows);
    for k = 1:length(L)
        h(k) = subplot(nrows, ncols, k);
        plot(L(k), varargin{:});
        title(['Loop ' num2str(k)]);
    end
    return
end
```

**Pros:** Each loop clearly separated, good for comparison  
**Cons:** Takes over entire figure, less flexible

#### Option C: Keep current behavior (error)
**Behavior:**
```matlab
L = [loop1, loop2];
plot(L);
% Error: 'Argument cannot be a loop vector. Use plot(L(k)) to plot the k-th loop.'
```

**Current implementation (lines 81-84):**
```matlab
assert( size(L.coords,1) == 1, ...
        'BRAIDLAB:loop:plot:multiloop',...
        ['Argument cannot be a loop vector. ' ...
         'Use plot(L(k)) to plot the k-th loop.'] );
```

**Pros:** Simplest, forces explicit user control  
**Cons:** Less convenient, uninformative error (per issue #133)

**Recommendation:** Improve error message even if keeping Option C, or implement Option A for convenience.

**Decision point:** Discuss with users/collaborators before implementing.

---

## Branch Management Strategy

### Current Branches
- `iss129-improve-loop-plot`: 3 lines changed (comments only)
- `iss141-handle-for-loop-plot`: ~100 lines changed (significant refactoring started)

### Recommended Approach

**Option 1: New refactor branch (Recommended)**
- Create `refactor-loop-plot` from `develop`
- Implement all phases from scratch with lessons learned
- Cherry-pick useful commits from iss141 if applicable
- Easier to manage, clean history

**Option 2: Build on iss141**
- Continue on `iss141-handle-for-loop-plot` branch
- Merge in `iss129-improve-loop-plot` changes
- Complete the refactoring
- Messier history but preserves existing work

**Recommendation:** **Option 1** - Start fresh with clean architecture, informed by iss141's approach but not constrained by its partial implementation.

### Workflow
1. Create `refactor-loop-plot` branch from `develop`
2. Implement Phase 1 (core refactor)
3. Implement Phase 2 (spacing)
4. Implement Phase 3 (handles)
5. Implement Phase 4 (fill)
6. (Defer Phase 5 pending decision)
7. Comprehensive testing
8. Documentation updates
9. Merge to `develop`
10. Close issues #129, #141, #144
11. Update/close iss129 and iss141 branches

---

## Testing Strategy

### Unit Tests
- **Geometry computation:** Test `computeLoopGeometry()` with known inputs
- **Segment ordering:** Verify continuous, closed paths
- **Coordinate extraction:** Compare with current implementation
- **Options parsing:** Test all new parameters

### Integration Tests
- **Handle return:** Verify correct number, type, size of handles
- **Coordinate access:** Test `get(h, 'XData')`, `get(h, 'YData')`
- **Handle modification:** Test `set(h, 'EdgeColor', 'r')`, etc.
- **Spacing control:** Test gap parameters produce expected layouts
- **Fill feature:** Test fill on/off, colors, alpha

### Regression Tests
- **Visual regression:** Compare rendered output with current implementation
  - Same loops should look identical (default parameters)
  - Pixel-level comparison or manual inspection
- **Backward compatibility:** Ensure existing code runs unchanged
  - No output capture: `plot(L)` still works
  - All current options still work
  - No visual changes for default parameters

### Edge Cases
- Single puncture loops
- Zero b-coordinates
- Large number of components
- Extreme gap sizes (very small, very large)
- Empty loops (if possible)
- Complex multi-component loops

### Performance Tests
- Compare execution time: refactored vs. current
- Should be comparable or faster (fewer plot calls)
- Test with large loops (many punctures, high intersection numbers)

---

## Documentation Updates

### Code Documentation

#### Updated help text (lines 1-24)
```matlab
%PLOT   Plot a loop.
%   PLOT(L) plots a representative of the equivalence class
%   defined by the loop L. Loops are drawn as closed curves around
%   punctures on the disk.
%
%   H = PLOT(L,...) returns a column vector of handles to the plotted
%   loop components. Each handle is a patch object corresponding to one
%   connected component of the loop. Coordinates can be accessed via
%   GET(H(i),'XData') and GET(H(i),'YData').
%
%   PLOT(L,'PropName',VALUE,...) can be used to set property PropName to
%   VALUE.  Valid properties are
%
%   LineColor          The edge color used to draw the loop.
%   LineStyle          The edge line style.
%   LineWidth          The edge line width.
%   PunctureColor      The color of the punctures.
%   PunctureEdgeColor  The color of the boundary of the punctures.
%   PunctureEdgeWidth  The width of the boundary of the punctures.
%   PunctureSize       The size of the punctures.
%   PuncturePositions  A vector of positions for the punctures, one
%                      coordinate pair per row.  The default is to have
%                      the punctures at integer values on the X-axis.
%   PunctureGap        Scalar multiplier for spacing between loop lines
%                      at punctures. Overrides automatic calculation.
%   PunctureGapVector  Per-puncture gap sizes (n×1 vector). Overrides
%                      PunctureGap if both specified.
%   PunctureRadius     Explicit puncture radius. Overrides automatic sizing.
%   BasePointColor     The color of the basepoint puncture, if any.
%   Components         [true/false] Plot connected components in
%                      different colors. LineColor and LineStyle are ignored.
%   FillLoop           [true/false] Fill the interior of loops (default: false).
%   FillColor          Color for loop interior fill. Default: lighter version
%                      of edge color.
%   FillAlpha          Transparency of fill, 0=transparent, 1=opaque (default: 0.3).
%
%   Examples:
%     L = loop([1 0 0 0]);
%     plot(L);                           % Basic plot
%     h = plot(L, 'LineColor', 'r');     % Red loop, return handle
%     plot(L, 'FillLoop', true);         % Filled loop
%     plot(L, 'PunctureGap', 0.5);       % Custom spacing
%
%   This is a method for the LOOP class.
%   See also LOOP, LOOP.LOOP.
```

#### Internal function documentation
- Update `getcoords()` documentation
- Update `joinpoints()` documentation (new signature)
- Add documentation for `computeLoopGeometry()` (new)

### User Guide Updates
- Add section on handle usage and coordinate extraction
- Add examples of custom spacing
- Add examples of filled loops
- Add note about multiple loops (pending Phase 5 decision)
- Update any existing examples that might be affected

### CHANGELOG
```markdown
## [Unreleased]

### Added
- Handle return system for `loop.plot`: returns column vector of patch handles (#141)
- Coordinate access via standard MATLAB `get()`: `get(h, 'XData')`, `get(h, 'YData')` (#141)
- Fill option for loop interiors: `FillLoop`, `FillColor`, `FillAlpha` parameters (#144)
- Enhanced spacing control: `PunctureGap`, `PunctureGapVector`, `PunctureRadius` parameters (#129)

### Changed
- **BREAKING (minor):** `loop.plot` now returns handles by default (suppress with `~` if needed)
- Refactored internal architecture: separated geometry computation from rendering
- Loops now drawn as continuous `patch` objects instead of piecewise segments
- Improved segment ordering: follows topological loop structure

### Fixed
- Loop segments now properly ordered for continuous traversal (#141)
- Better spacing control decouples visual puncture size from loop layout (#129)

### Deprecated
- None (fully backward compatible for users not capturing handles)

### Removed
- None

### Notes
- Issue #133 (multiple loop support) deferred for future release
```

---

## Risk Assessment

### High Risk Areas
1. **Segment ordering algorithm**
   - **Risk:** Complex graph traversal, potential for bugs
   - **Mitigation:** Extensive testing, visual verification, unit tests
   
2. **Backward compatibility**
   - **Risk:** Changed rendering might subtly alter existing plots
   - **Mitigation:** Regression tests, side-by-side comparisons
   
3. **Performance**
   - **Risk:** Refactored code might be slower
   - **Mitigation:** Performance benchmarks, optimize if needed

### Medium Risk Areas
1. **Handle return with no output capture**
   - **Risk:** May break existing code if users check `nargout`
   - **Mitigation:** Follow MATLAB convention (always compute handles)
   
2. **Spacing parameter interactions**
   - **Risk:** Multiple spacing options may conflict or confuse
   - **Mitigation:** Clear documentation, validation, sensible defaults

### Low Risk Areas
1. **Fill feature** - additive, no impact if not used
2. **New helper functions** - internal, well-tested
3. **Documentation** - worst case: needs updates

---

## Success Criteria

### Functional Requirements
- ✓ Returns handles following MATLAB conventions
- ✓ Handles are `patch` objects, one per component
- ✓ Coordinates accessible via `get(h, 'XData')`, `get(h, 'YData')`
- ✓ Spacing control via `PunctureGap`, `PunctureGapVector`, `PunctureRadius`
- ✓ Fill option works: `FillLoop`, `FillColor`, `FillAlpha`
- ✓ Backward compatible: existing code runs unchanged

### Code Quality
- ✓ Clean architecture: geometry separated from rendering
- ✓ Well-documented: help text, comments, examples
- ✓ Well-tested: unit, integration, regression tests
- ✓ Maintainable: clear structure, modular design

### Performance
- ✓ Execution time comparable to current implementation
- ✓ No performance regressions for typical use cases

### Documentation
- ✓ Updated help text with all options
- ✓ Usage examples in documentation
- ✓ CHANGELOG entries
- ✓ User guide updates

### Issue Resolution
- ✓ Closes #141 (handle return)
- ✓ Closes #129 (spacing control)
- ✓ Closes #144 (fill loops)
- ⏸ Defers #133 (multiple loops) with documented options

---

## Timeline Estimate

### Phase 1: Core Architecture (2-3 days)
- 1.1 Extract geometry computation: 4-6 hours
- 1.2 Refactor joinpoints: 2-3 hours
- 1.3 Segment ordering: 6-8 hours (most complex)
- 1.4 Integration: 3-4 hours
- Testing: 4-5 hours

### Phase 2: Spacing Control (1 day)
- 2.1 Add options: 2 hours
- 2.2 Layout algorithm: 3-4 hours
- Testing: 2-3 hours

### Phase 3: Handle Return (0.5 days)
- 3.1-3.3 Implementation: 2 hours (mostly done in Phase 1)
- Testing: 2 hours

### Phase 4: Fill Feature (0.5 days)
- 4.1 Add options: 1 hour
- 4.2 Implementation: 2 hours
- Testing: 1 hour

### Documentation & Testing (1 day)
- Help text updates: 1 hour
- User guide: 2 hours
- Comprehensive testing: 4 hours
- Bug fixes: 1 hour

### Total: ~5-6 days of focused development

---

## Next Steps

1. **Review this plan** with stakeholders
2. **Decide on Phase 5** (multiple loops) - implement now or defer?
3. **Decide on branch strategy** - new branch or build on iss141?
4. **Create feature branch** from `develop`
5. **Begin Phase 1.1** - extract geometry computation
6. **Iterative development** - implement, test, refine
7. **Documentation** - update as you go
8. **Final review** - code review, testing, merge to develop
9. **Close issues** - #129, #141, #144
10. **Release** - target version 3.3 or 4.0 (check milestones)

---

## Appendix: Reference Files

### Files to Modify
- `+braidlab/@loop/plot.m` (primary target)

### Files to Review
- `+braidlab/@loop/loop.m` (class definition)
- Existing loop tests (if any)
- User guide documentation

### Reference Branches
- `iss129-improve-loop-plot`
  - Commit: 305c32b
  - Changes: 3 lines (comments)
  
- `iss141-handle-for-loop-plot`
  - Commit: f5d38fb
  - Changes: ~100 lines (significant refactoring)
  - New test files in `devel/tests/iss141-handle-for-loop-plot/`

### Reference Issues
- #129: https://github.com/jeanluct/braidlab/issues/129
- #141: https://github.com/jeanluct/braidlab/issues/141
- #133: https://github.com/jeanluct/braidlab/issues/133
- #144: https://github.com/jeanluct/braidlab/issues/144

---

**End of Plan**
