# AGENTS.md - AI Agent Guide for Braidlab

This document helps AI coding agents understand Braidlab's architecture, mathematical foundations, and codebase structure.

---

## What is Braidlab?

**Braidlab** is a MATLAB package for analyzing data using mathematical braids and topological dynamics. It's used by researchers studying fluid mixing, dynamical systems, and topological data analysis.

### Core Concepts

1. **Braids**: Represent the intertwining of strands over time (e.g., particle trajectories in fluids)
2. **Loops**: Closed curves on a punctured disk, encoded in Dynnikov coordinates
3. **Train Tracks**: Combinatorial structures representing surface homeomorphisms
4. **Mapping Classes**: Equivalence classes of homeomorphisms under isotopy

### Scientific Purpose

- Analyze mixing and stirring in fluid flows
- Compute topological entropy of dynamical systems  
- Study knots, links, and surface homeomorphisms
- Extract topological information from trajectory data

---

## Project Structure

```
braidlab/
├── +braidlab/          # Main package namespace
│   ├── @braid/        # Braid class and methods
│   ├── @loop/         # Loop class and methods
│   ├── @databraid/    # Data-driven braid extraction
│   ├── @cfbraid/      # Conjugacy-free braids
│   ├── @annbraid/     # Annular braids
│   └── *.m            # Package-level functions
├── extern/            # External dependencies (C/C++ code)
│   ├── trains/        # Toby Hall's train track implementation
│   ├── cbraid/        # Jae Choon Cha's braid algorithms
│   └── ThreadPool/    # C++ threading utilities
├── devel/             # Development resources
│   ├── tests/         # Test scripts and examples
│   ├── STYLE.md       # Coding style guidelines
│   └── LOOP_PLOT_REFACTOR_PLAN.md  # Current refactoring plan
├── doc/               # User guide (LaTeX)
└── Makefile           # Build system for MEX files
```

### Key Classes

#### `@braid` - Braid Class
- **Purpose**: Represents braids as sequences of generator crossings
- **Storage**: Word form (e.g., `[1 2 -3]` means σ₁σ₂σ₃⁻¹)
- **Key Methods**: `entropy`, `train`, `loopcoords`, `compact`
- **MEX Integration**: Performance-critical operations in C++

#### `@loop` - Loop Class (CURRENT WORK)
- **Purpose**: Represents topological loops using Dynnikov coordinates
- **Storage**: Vector `[a,b]` of length `2N-4` for N punctures
- **Coordinates**: 
  - `a` vector (length N-2): intersection numbers with certain arcs
  - `b` vector (length N-2): winding numbers around punctures
- **Key Methods**: 
  - `plot`: Visualizes loop on punctured disk **(being refactored)**
  - `update`: Updates loop under braid action
  - `loopsigma`: Action of braid generator on loop
- **Multi-component**: Can represent multiple disjoint loops

---

## Mathematical Background

### Dynnikov Coordinates

Loops are encoded as integer vectors `[a₁, ..., aₙ₋₂, b₁, ..., bₙ₋₂]` representing:

- **a-coordinates**: Intersection counts with specific arcs
- **b-coordinates**: Winding behavior around punctures

This encoding is canonical up to isotopy and makes computation efficient.

### Loop Visualization

The `loop.plot` method converts Dynnikov coordinates to geometric curves:

1. **Punctures**: Points on x-axis at integer positions (or custom)
2. **Semicircles**: C-shaped and D-shaped arcs around punctures  
3. **Line Segments**: Connect loops between adjacent punctures
4. **Components**: Separate disjoint loops (different colors)

**Current Challenge**: Segments plotted piecemeal, out of topological order.
**Refactoring Goal**: Order segments properly, return handles, enable fills.

---

## Current Refactoring: `loop.plot`

You are working on **`+braidlab/@loop/plot.m`** - a major refactoring to:

1. **Return handles** (Issue #141) - Allow programmatic access to plotted objects
2. **Improve spacing** (Issue #129) - Better control over puncture gaps
3. **Fill loops** (Issue #144) - Optionally fill loop interiors
4. **Handle multiple loops** (Issue #133) - Plot loop vectors (deferred)

### Current Implementation (484 lines)

**Architecture:**
- `getcoords(L)`: Extract n, a, b, M, N from Dynnikov coords
- `joinpoints(mine, next, positions, gaps, options)`: Plot individual segments
- Main loop: Draws punctures → semicircles → line segments (above) → line segments (below)

**Problem:** Segments drawn out of order, can't easily create one handle per component.

### Refactoring Plan

See `devel/LOOP_PLOT_REFACTOR_PLAN.md` for detailed 5-phase plan:

- **Phase 1**: Separate geometry computation from rendering, order segments properly
- **Phase 2**: Add spacing control parameters
- **Phase 3**: Return handles (column vector of patch objects)
- **Phase 4**: Add fill options
- **Phase 5**: Multiple loops (deferred)

**Key Insight**: Use MATLAB `patch` objects (not `plot`) for closed curves with fill support.

---

## Code Organization Patterns

### MATLAB Package Structure

Braidlab uses `+package` namespacing:
```matlab
% User code:
import braidlab.*
b = braid([1 2 -3]);
L = loop([1 0 0 0]);
plot(L);
```

### Class Methods in `@classname/`

Each class has its own directory:
```
@loop/
├── loop.m          # Class definition and constructor
├── plot.m          # Plot method (CURRENT FOCUS)
├── update.m        # Update under braid action
├── loopsigma.m     # Generator action
└── ...             # Other methods
```

### Helper Functions

Private helpers at end of file, separated by `% ===...===`:
```matlab
function main(input)
  % Main implementation
  result = helper(data);

% ============================================================================
function output = helper(input)
  % Helper implementation
```

---

## Key Dependencies

### External Libraries (in `extern/`)

1. **Trains** - Train track algorithms (C)
   - Bestvina-Handel algorithm
   - Thurston-Nielsen classification
   
2. **CBraid** - Fast braid algorithms (C++)
   - Braid conjugacy
   - Normal forms
   
3. **ThreadPool** - C++ multithreading
   - Parallel computation of braid entropy

### MATLAB Requirements

- **Minimum**: R2014b (for modern object-oriented features)
- **MEX Support**: Requires C/C++ compiler for building from source
- **Toolboxes**: None required (pure MATLAB + MEX)

---

## Testing Approach

### For `loop.plot` Refactoring

1. **Visual Regression**: Compare plots before/after refactoring
2. **Functional Tests**: Test handle return, coordinate access
3. **Edge Cases**: Single puncture, zero b-coords, many components
4. **Backward Compatibility**: Existing code must work unchanged

### Test Location

```
devel/tests/iss141-handle-for-loop-plot/
├── test_loop_handles.m
├── plot_handles.m
└── linksort.m (incomplete)
```

---

## Common Tasks

### Understanding Existing Code

1. **Read class documentation**: `help braidlab.loop`
2. **Check method list**: `methods('braidlab.loop')`
3. **Example usage**: See `doc/braidlab_guide.pdf`
4. **Test suite**: Look in `testsuite`

### Making Changes

1. **Create feature branch**: `issXXX-description` from `develop`
2. **Follow style guide**: See `devel/STYLE.md` and `devel/MATLAB_STYLE_GUIDE.md`
3. **Test thoroughly**: Visual + functional tests
4. **Update documentation**: Help text + CHANGELOG.md

### Building MEX Files

```bash
make          # Build all MEX files
make clean    # Clean build artifacts
```

---

## Important Conventions

### Coordinate Systems

- **Dynnikov coordinates**: `[a, b]` integer vectors
- **Puncture positions**: Default at `(1,0), (2,0), ..., (n,0)`
- **Vertex indices**: Integers excluding 0
  - Positive = above puncture
  - Negative = below puncture

### Error Handling

```matlab
assert(condition, 'BRAIDLAB:class:method:errortype', 'Message.');
```

Example: `'BRAIDLAB:loop:plot:multiloop'`

### Options Parsing

Use `inputParser` for all public functions with options:
```matlab
parser = inputParser;
parser.addRequired('input', @validator);
parser.addParameter('Option', default, @validator);
parser.parse(input, varargin{:});
options = parser.Results;
```

---

## References

### Documentation

- **User Guide**: `doc/braidlab_guide.pdf` (comprehensive manual)
- **arXiv**: https://arxiv.org/abs/1410.0849
- **Wiki**: https://github.com/jeanluct/braidlab/wiki

### Key Papers

1. **Dynnikov (2002)**: Original Dynnikov coordinate paper
2. **Hall & Yurttas (2009)**: Topological entropy of braids
3. **Thiffeault (2010)**: Braids of particle trajectories

### Style Guides

- **MATLAB Style**: `devel/MATLAB_STYLE_GUIDE.md` (detailed formatting)
- **Braidlab Style**: `devel/STYLE.md` (project-specific conventions)
- **Workflow**: https://github.com/jeanluct/braidlab/wiki/braidlab-workflow

---

## Quick Start for AI Agents

### Before Coding

1. ✓ Read this AGENTS.md
2. ✓ Review `devel/LOOP_PLOT_REFACTOR_PLAN.md` (current task)
3. ✓ Check `devel/STYLE.md` and `devel/MATLAB_STYLE_GUIDE.md`
4. ✓ Look at existing code in `+braidlab/@loop/`

### During Coding

1. Follow the refactoring plan phases
2. Test incrementally (visual + functional)
3. Document as you go (help text, comments)
4. Maintain backward compatibility

### Before Committing

1. Test all changes thoroughly
2. Update help documentation
3. Check CHANGELOG.md
4. Verify code style compliance

---

## Getting Help

- **Issues**: https://github.com/jeanluct/braidlab/issues
- **Maintainer**: Jean-Luc Thiffeault (jeanluc@math.wisc.edu)
- **Current Task**: See `devel/LOOP_PLOT_REFACTOR_PLAN.md`

---

**Last Updated**: 2026-03-07  
**Current Branch**: `refactor-loop-plot`  
**Current Task**: Phase 1 - Core architecture refactor of `loop.plot`
