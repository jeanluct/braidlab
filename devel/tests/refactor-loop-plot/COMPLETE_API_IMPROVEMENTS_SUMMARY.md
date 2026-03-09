# Loop.plot API Improvements - Complete Summary

## Overview

Two significant API improvements were implemented for the `loop.plot` method to make it more intuitive and concise:

1. **LineGap Parameter Consolidation**: Unified `PunctureGap` (scalar) and `PunctureGapVector` (vector) into a single `LineGap` parameter
2. **Auto-Enable Fill Behavior**: Automatically enable filling when `FillColor` or `FillAlpha` is specified

---

## Improvement 1: LineGap Parameter Consolidation

### Problem
The old API had redundant parameters for controlling line spacing:
- `PunctureGap` - scalar gap value
- `PunctureGapVector` - vector of per-puncture gaps

### Solution
Single unified `LineGap` parameter that accepts:
- **Scalar**: `plot(L, 'LineGap', 0.15)` → uniform gap at all punctures
- **Vector**: `plot(L, 'LineGap', [0.1; 0.2; 0.1; 0.2])` → per-puncture gaps
- **Empty** (default): Auto-calculated based on loop topology

### API Changes (Breaking - Acceptable)

| Old API | New API |
|---------|---------|
| `plot(L, 'PunctureGap', 0.15)` | `plot(L, 'LineGap', 0.15)` |
| `plot(L, 'PunctureGapVector', [0.1; 0.2; 0.1; 0.2])` | `plot(L, 'LineGap', [0.1; 0.2; 0.1; 0.2])` |

### Rationale for Name Change
"LineGap" better reflects what the parameter controls: spacing between **loop strands/lines** at punctures, not puncture positions themselves.

---

## Improvement 2: Auto-Enable Fill Behavior

### Problem
The old API required redundant `FillLoop=true` when specifying fill appearance:
```matlab
plot(L, 'FillLoop', true, 'FillColor', [1 1 0]);
plot(L, 'FillLoop', true, 'FillAlpha', 0.5);
```

### Solution
Automatically enable filling when `FillColor` or `FillAlpha` is specified:
```matlab
plot(L, 'FillColor', [1 1 0]);        % FillLoop auto-enabled
plot(L, 'FillAlpha', 0.5);            % FillLoop auto-enabled
```

### API Changes (Non-Breaking, Backward Compatible)

| Old API | New API | Old API Still Works? |
|---------|---------|---------------------|
| `plot(L, 'FillLoop', true, 'FillColor', [1 1 0])` | `plot(L, 'FillColor', [1 1 0])` | ✅ Yes |
| `plot(L, 'FillLoop', true, 'FillAlpha', 0.5)` | `plot(L, 'FillAlpha', 0.5)` | ✅ Yes |
| `plot(L, 'FillLoop', true)` | *(unchanged)* | ✅ Yes |

### Edge Cases
- **Override behavior**: `plot(L, 'FillLoop', false, 'FillColor', 'r')` → Loop IS filled (FillColor wins)
- **Default unchanged**: `plot(L)` → Loop is NOT filled (backward compatible)
- **Color names work**: `plot(L, 'FillColor', 'cyan')` → Auto-enables filling

---

## Combined Benefits

### Before (Old API)
```matlab
% Verbose and redundant
plot(L, 'PunctureGap', 0.15, 'FillLoop', true, 'FillColor', [1 1 0], 'FillAlpha', 0.5);
```

### After (New API)
```matlab
% Concise and intuitive
plot(L, 'LineGap', 0.15, 'FillColor', [1 1 0], 'FillAlpha', 0.5);
```

### Advantages
1. **More intuitive**: User intent is clearer
2. **Less verbose**: Fewer parameters required
3. **Better naming**: `LineGap` accurately describes function
4. **Backward compatible**: Old fill API still works (only LineGap is breaking)
5. **Consistent**: Matches MATLAB conventions for graphics parameters

---

## Implementation Details

### Files Modified

#### Main Implementation
**`+braidlab/@loop/plot.m`**
- Lines 11-40: Updated documentation for both improvements
- Lines 44-52: Updated examples to demonstrate new API
- Lines 104-115: Replaced `PunctureGap`/`PunctureGapVector` with `LineGap` parameter
- Lines 127-133: Added auto-enable logic for fill parameters
- Lines 189-215: Updated gap processing logic for `LineGap`

#### Test Suite
**`testsuite/testcases/loopTest.m`**
- Updated 4 LineGap tests (renamed from puncture_gap tests)
- Updated 3 fill tests (simplified to use auto-enable)
- Added 3 new auto-enable tests
- **Total**: 89 tests (added 3 new)

**`devel/tests/refactor-loop-plot/test_unit_helpers.m`**
- Updated 4 LineGap tests
- Updated 3 fill tests
- **Total**: 13 tests

**`devel/tests/refactor-loop-plot/test_spacing_control.m`**
- Updated entire file for LineGap parameter
- **Total**: 7 tests

### Verification Scripts Created
1. `verify_linegap_parameter.m` - LineGap functionality verification
2. `verify_auto_fill_enable.m` - Auto-fill behavior verification
3. `LINEGAP_MIGRATION_SUMMARY.md` - LineGap documentation
4. `AUTO_FILL_ENABLE_SUMMARY.md` - Auto-fill documentation

---

## Test Results

| Test Suite | Tests | Status |
|------------|-------|--------|
| Main test suite (`loopTest.m`) | 89 | ✅ All pass |
| Helper unit tests | 13 | ✅ All pass |
| Spacing control tests | 7 | ✅ All pass |
| LineGap verification | 6 | ✅ All pass |
| Auto-fill verification | 7 | ✅ All pass |
| Combined comprehensive | 9 | ✅ All pass |
| **TOTAL** | **131** | **✅ 100% pass** |

---

## Breaking vs. Non-Breaking Changes

### Breaking Changes (LineGap)
- ❌ `PunctureGap` parameter removed
- ❌ `PunctureGapVector` parameter removed
- ✅ `LineGap` parameter added (accepts scalar or vector)

**Migration Required**: Replace `PunctureGap`/`PunctureGapVector` with `LineGap`

### Non-Breaking Changes (Auto-Fill)
- ✅ `FillLoop=true` with `FillColor`/`FillAlpha` still works (backward compatible)
- ✅ Default behavior (no fill) unchanged
- ✅ New concise API is purely additive

**Migration Optional**: Can simplify code but not required

---

## Migration Guide

### LineGap (Required)

```matlab
% OLD - will error
plot(L, 'PunctureGap', 0.15);
plot(L, 'PunctureGapVector', [0.1; 0.2; 0.1; 0.2]);

% NEW - required change
plot(L, 'LineGap', 0.15);
plot(L, 'LineGap', [0.1; 0.2; 0.1; 0.2]);
```

### Auto-Fill (Optional)

```matlab
% OLD - still works but verbose
plot(L, 'FillLoop', true, 'FillColor', [1 1 0]);

% NEW - simpler (optional improvement)
plot(L, 'FillColor', [1 1 0]);
```

---

## Examples

### Basic Usage
```matlab
L = loop([1 0 0 0]);

% Simple plot
plot(L);

% Colored edge
plot(L, 'LineColor', 'r');

% Custom line spacing (uniform)
plot(L, 'LineGap', 0.15);

% Custom line spacing (per-puncture)
plot(L, 'LineGap', [0.1; 0.2; 0.1; 0.2]);

% Filled loop
plot(L, 'FillColor', [1 1 0]);

% Semi-transparent fill
plot(L, 'FillAlpha', 0.5);

% Everything combined
plot(L, 'LineGap', 0.15, 'FillColor', [1 0 0], 'FillAlpha', 0.7);
```

### Handle Access
```matlab
% Get handle to modify later
h = plot(L, 'FillColor', 'cyan');

% Extract coordinates
xdata = get(h, 'XData');
ydata = get(h, 'YData');

% Modify appearance
set(h, 'FaceColor', [1 0 1]);
set(h, 'FaceAlpha', 0.8);
```

---

## Future Considerations

1. **CHANGELOG.md**: Document these API changes
2. **External docs**: Update any external documentation/examples
3. **Other parameters**: Could apply similar consolidation to other redundant parameters (deferred for now)

---

**Completed**: 2026-03-08  
**Total Tests**: 131 (all passing)  
**Breaking Changes**: LineGap only (acceptable)  
**Backward Compatibility**: Fill API fully compatible  
**Status**: ✅ Ready for review and merge
