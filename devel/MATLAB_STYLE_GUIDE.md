# MATLAB_STYLE_GUIDE.md - AI Agent Guidelines for Matlab code in Braidlab

This document provides guidelines for AI coding agents working on the Braidlab project.

---

## Project Overview

**Braidlab** is a MATLAB package for analyzing data using braids. It provides tools for working with braids, loops, and train tracks in the context of topological dynamics.

- **Language:** MATLAB (primary), C/C++ (MEX extensions)
- **License:** GNU General Public License v3
- **Authors:** Jean-Luc Thiffeault, Marko Budisic
- **Repository:** https://github.com/jeanluct/braidlab

---

## MATLAB Coding Style Guidelines

### General Principles

1. **Clarity over cleverness** - Write clear, readable code
2. **Document thoroughly** - All public functions need comprehensive help text
3. **Maintain consistency** - Follow existing patterns in the codebase
4. **Test carefully** - Visual and functional testing for plotting/graphics code
5. **Write well** - Spell-check and proofread comments and help messages

**Note:** This guide summarizes key patterns from the codebase. For additional details, see `devel/STYLE.md`.

### File Organization

#### File Headers

All MATLAB files must include:

1. **Help documentation** (for public functions/classes)
2. **License block** (enclosed in `% <LICENSE` ... `% LICENSE>`)
3. **Copyright notice** with years and authors

**Example:**
```matlab
function output = myfunction(input, varargin)
%MYFUNCTION   Brief one-line description.
%   Detailed description of what the function does, starting with the
%   basic usage pattern.
%
%   OUTPUT = MYFUNCTION(INPUT) basic usage.
%
%   OUTPUT = MYFUNCTION(INPUT,'PropName',VALUE,...) usage with options.
%
%   Valid properties are:
%     PropertyName1    Description of property 1
%     PropertyName2    Description of property 2
%
%   Examples:
%     result = myfunction(data);
%     result = myfunction(data, 'Option', value);
%
%   See also RELATEDFUNCTION1, RELATEDFUNCTION2.

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   https://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2026  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
%                            Marko Budisic          <mbudisic@gmail.com>
%
%   This file is part of Braidlab.
%
%   Braidlab is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   Braidlab is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with Braidlab.  If not, see <https://www.gnu.org/licenses/>.
% LICENSE>

% Function implementation starts here
```

#### Class Files

Class definition files should include:
- Class-level documentation before `classdef`
- License block after documentation
- Properties and methods organized logically

**Example:**
```matlab
%CLASSNAME   Brief description of the class.
%   Detailed description of what the class represents and its purpose.
%
%   The class CLASSNAME has the following data members:
%
%    'property1'   Description of property1
%    'property2'   Description of property2
%
%   In addition, CLASSNAME has the dependent properties:
%
%    'depProp1'    Description of dependent property
%
%   METHODS('CLASSNAME') shows a list of methods.
%
%   See also RELATEDCLASS, CONSTRUCTOR.

% <LICENSE ... LICENSE>

classdef classname < baseclass
  properties
    property1 = defaultval;  % Brief comment
  end
  properties (Dependent = true)
    depProp1
  end
  
  methods
    % Constructor and methods...
  end
end
```

### Code Formatting

#### Indentation and Spacing

- **Use 2 spaces for indentation** (not tabs)
- **Align continuation lines** logically
- **Blank lines** to separate logical sections (marked with `%%` or `%% Comment`)

**Example:**
```matlab
function result = example(input)

parser = inputParser;

%% Specify parameters

parser.addRequired('input', @isnumeric);
parser.addParameter('Option1', 'default', @ischar);
parser.addParameter('Option2', 10, @(x) isnumeric(x) && isscalar(x));

parser.parse(input, varargin{:});
options = parser.Results;

%% Process input

if options.Option2 > 0
  result = input * options.Option2;
else
  result = input;
end

end
```

#### Line Length

- **Aim for 78 characters** per line (unless compelling reason like long URL)
- **Break long lines** at logical points (after commas, operators)
- **Align continuation lines** with opening delimiter or indent 2 spaces
- **No tabs** - always use spaces
- **Delete trailing whitespace** at end of lines
- **Every file should end with a linebreak** (but no extra blank lines at end)

**Example:**
```matlab
% Good: aligned with opening parenthesis
result = somefunction(argument1, argument2, argument3, ...
                      argument4, argument5);

% Good: indented continuation
verylongvariablename = anotherlongfunction(arg1, arg2, ...
  arg3, arg4);

% Good: breaking at logical operators
if condition1 && condition2 && ...
   condition3 && condition4
  % do something
end
```

#### Operators and Delimiters

- **Spaces around binary operators:** `a + b`, `x = y`, `i:n`
- **No space after unary operators:** `-x`, `~flag`
- **No space inside parentheses/brackets:** `array(i)`, `[1 2 3]`
- **Function call spacing:** NO space after commas in function arguments:
  - Correct: `hypot(x,y)`, `linspace(0,2*pi,100)`, `plot(x,y,'r-')`
  - Wrong: `hypot(x, y)`, `linspace(0, 2*pi, 100)`, `plot(x, y, 'r-')`
- **Parens:** No space before `(`: `hypot(x,y)` not `hypot (x,y)`.
- **One-liners:** OK for simple conditionals and loops: `if nargin > 0, a = 1; end`, `for j = 1:N, x(j) = i; end`

**Example:**
```matlab
x = a + b - c;           % Binary operators
y = -x;                  % Unary operator
z = func(a,b,c);         % Function call
array = [1 2 3; 4 5 6];  % Matrix
idx = 1:10;              % Range
```

### Naming Conventions

#### Variables and Functions

- **Use descriptive names:** `puncture_position`, `num_components`
- **Lowercase with underscores** for multi-word names: `loop_curve_x`
- **Short names acceptable** for standard usage: `n`, `i`, `j`, `x`, `y`
- **Avoid single letters** except for: counters, coordinates, standard math notation

**Examples:**
```matlab
n = 10;                          % Standard: number of items
puncture_position = [0; 1; 2];   % Multi-word
loop_curve_x = linspace(0, 1);   % Multi-word
for i = 1:n                      % Counter
  result(i) = process(data(i));
end
```

#### Constants

- **UPPERCASE** for true constants: `MAX_ITERATIONS`
- **Or descriptive lowercase** for configuration values: `default_color`

#### Classes and Methods

- **lowecase for class names:** `braid`, `loop` (rare, usually lowercase)
- **lowercase for methods:** `plot`, `entropy`, `loopsigma`
- **Method names match MATLAB conventions** when similar functionality exists

### Comments

#### Section Comments

Use `%%` for major sections:

```matlab
%% Parse input arguments

%% Compute components and assign colors to them

%% Draw semicircles
```

#### Inline Comments

- **Use `%` for inline comments**
- **Align related inline comments** vertically when possible
- **Comment intent, not obvious code**

**Example:**
```matlab
% Good: explains intent
pgap = min(space_between_loop_lines)/2;  % Use half minimum spacing

% Avoid: states the obvious
x = x + 1;  % Increment x by 1
```

#### Function-level Comments

Document what the code does, especially for complex logic:

```matlab
% Cycle through each puncture.
for p = 1:n
  % Determine number of semicircles at the present loop
  if p == n
    nl = M_coord(n); % this is equal to N_coord(n)
  else
    nl = b_coord(p);
  end
  
  % Draw this number of semicircles taking into account the direction
  % (left/right) around the puncture.
  for sc = 1:abs(nl)
    % ... drawing code
  end
end
```

### Error Handling

#### Use `assert` for Validation

```matlab
assert(size(L.coords, 1) == 1, ...
       'BRAIDLAB:loop:plot:multiloop', ...
       ['Argument cannot be a loop vector. ' ...
        'Use plot(L(k)) to plot the k-th loop.']);
```

#### Error ID Format

`'BRAIDLAB:classname:methodname:errortype'`

**Examples:**
- `'BRAIDLAB:loop:plot:multiloop'`
- `'BRAIDLAB:braid:entropy:invalidarg'`

#### Error Messages

- **Be specific and helpful**
- **Suggest solutions** when applicable
- **Use proper grammar and punctuation**

### Input Parsing

Use `inputParser` for functions with options:

```matlab
parser = inputParser;

% Required arguments
parser.addRequired('input1', @validationFunction);

% Optional parameters
parser.addParameter('ParameterName', defaultValue, @validationFunction);

parser.parse(input1, varargin{:});
options = parser.Results;
```

### Graphics and Plotting

#### Handle Management

- **Return handles** when useful for user manipulation
- **Follow MATLAB conventions:** column vector of handles
- **Use `patch()` for closed shapes** that might be filled
- **Use `plot()` for simple line drawings**

#### Hold State

Always preserve and restore hold state:

```matlab
holdstate = ishold;

% Plotting code...
hold on;
% More plotting...

if ~holdstate
  hold off;
end
```

#### Axis Management

Set axis properties after plotting:

```matlab
if ~holdstate
  hold off;
  axis equal;
  ax = axis;
  sc = 0.1 * max([ax(2)-ax(1) ax(4)-ax(3)]);
  axis([ax(1)-sc ax(2)+sc ax(3)-sc ax(4)+sc]);
end
```

### Helper Functions

#### Function Syntax

- **When file contains multiple functions:** Do NOT use `function...end` syntax
- **Instead:** Use `function...function` syntax (avoid indenting first level)
- **Separate functions** with a line of `% ===...===`
- **Reference:** See `@braid/subbraid.m` for example

**Example:**
```matlab
function mainfunction(input)
  % Main function implementation
  result = helperfunction(data);

% ============================================================================
function output = helperfunction(input)
%% helperfunction(input)
%
% Helper function that does X.
% 
% Inputs: ...
% Outputs: ...

output = process(input);
```

### Global Variables

- **Avoid global variables** as much as possible
- **If needed:** Use format `BRAIDLAB_global_variable_name`
  - `BRAIDLAB_` prefix in uppercase
  - Rest in lowercase with underscores

---

## C/C++ Guidelines (for MEX files)

### Naming Conventions

- **Macros and compiler flags:** `BRAIDLAB_COMPILER_FLAG` (all uppercase)

### MATLAB-specific Types

Use MATLAB-provided types in MEX files:
- **`mwSize`** for array sizes
- **`mwIndex`** for array indexing
- **`mwSignedIndex`** for differences between indices

**References:**
- https://www.mathworks.com/help/matlab/apiref/mwsize.html
- https://www.mathworks.com/help/matlab/apiref/mwindex.html
- https://www.mathworks.com/help/matlab/apiref/mwsignedindex.html

---

## Testing Guidelines

### Visual Testing

For plotting and graphics code:

1. **Create test scripts** in `devel/tests/`
2. **Compare output** with previous versions visually
3. **Test edge cases:** empty data, single elements, large datasets
4. **Document expected behavior** in test files

### Regression Testing

When refactoring:

1. **Preserve existing behavior** for default parameters
2. **Test backward compatibility** - old code should still work
3. **Document any breaking changes** clearly

### Test Organization

```
devel/tests/
  iss###-description/
    test_feature.m
    README.md
    expected_output.png (if visual)
```

---

## Documentation

### Help Text

- **First line:** ALL CAPS function name, brief description (appears in lookfor)
  - **Three spaces** between function name and summary (consistent with MATLAB style)
  - **Three spaces** for indenting thereafter
- **Usage patterns:** Show basic to advanced usage
- **Parameters:** List and describe all options
- **Property/value pairs:** Use capitalization `'PropertyName', value'` (capitalize property, not value)
- **Examples:** Provide concrete, runnable examples
- **See also:** Reference related functions
- **References:** Include citations when appropriate

**Example from `tntype.m`:**
```matlab
%TNTYPE   Thurston-Nielsen type of a braid.
%   T = TNTYPE(B) returns the Thurston-Nielsen type of a braid B.  The braid
%   is regarded as labeling an isotopy class on the punctured disk.  The
%   type T can take the values 'finite-order', 'reducible', or
%   'pseudo-Anosov', following the Thurston-Nielsen classification theorem.
%
%   [T,ENTR] = TNTYPE(B) also returns the entropy ENTR of the braid.
%
%   TNTYPE uses Toby Hall's implementation of the Bestvina-Handel algorithm.
%
%   References:
%
%   M. Bestvina and M. Handel, "Train-Tracks for surface homeomorphisms,"
%   Topology 34 (1995), 109-140.
%
%   This is a method for the BRAID class.
%   See also BRAID, BRAID.ENTROPY.
```

### Code Comments

- **Explain WHY, not WHAT** (unless what is unclear)
- **Document assumptions** and constraints
- **Note TODOs and FIXMEs** explicitly

**Example:**
```matlab
% TODO: Keep punctures same size (need special gap near x-axis).
% FIXME: This fails when n < 3
```

---

## Version Control

### Branch Naming

- **Feature branches:** `feature-description` or `iss###-description`
- **Bug fixes:** `fix-description` or `bug###-description`
- **Refactoring:** `refactor-description`

**Examples:**
- `iss141-handle-for-loop-plot`
- `refactor-loop-plot`
- `fix-memory-leak`

### Commit Messages

- **First line:** Brief summary (50 chars or less)
- **Body:** Detailed explanation if needed
- **Reference issues:** `#45` at start for visibility, `closes #123`, `resolves #456`
- **Proper punctuation:** End with a period
- **Be careful:** Don't say "does not resolve issue #45" (will auto-close!)

**Example:**
```
#141: Add handle return to loop.plot method

Implement Phase 3 of refactoring plan: return column vector of patch
handles, one per loop component. Users can access coordinates via
get(h, 'XData') and get(h, 'YData').

Resolves #141.
```

### Workflow

See https://github.com/jeanluct/braidlab/wiki/braidlab-workflow for detailed workflow.

---

## Project-Specific Notes

### Namespace

Braidlab uses MATLAB package namespacing:
- Classes in `+braidlab/` folder
- Use `import braidlab.*` or call as `braidlab.classname`

### MEX Files

- **C/C++ code** in `extern/` for performance-critical components
- **Makefiles** for compilation
- **Test MEX thoroughly** - errors can crash MATLAB

### Dependencies

External code in `extern/`:
- `trains/` - Toby Hall's Trains
- `cbraid/` - Jae Choon Cha's CBraid  
- `ThreadPool/` - C++ thread pooling
- Others listed in README.md

### MATLAB Version Compatibility

- **Target:** MATLAB R2014b or later (check existing code)
- **Avoid bleeding-edge features** - maintain compatibility
- **Test on multiple versions** when possible

---

## Common Patterns in Braidlab

### Dynnikov Coordinates

Loops represented by coordinates `[a, b]` of length `2*N-4`:
- `a` vector: length `N-2`
- `b` vector: length `N-2`

### Component Handling

Many objects (loops, braids) can have multiple components:
- Use **hash tables** to track component membership
- Color components differently when plotting

### Object-Oriented Design

- Classes use **value semantics** (not handle classes)
- **Dependent properties** for computed values
- **Custom display** methods for pretty printing

---

## When in Doubt

1. **Look at existing code** - maintain consistency
2. **Check the user guide** (`doc/braidlab_guide.pdf`)
3. **Reference issues/PRs** for design decisions
4. **Ask questions** in commit messages or comments

---

## Quick Checklist

Before submitting code:

- [ ] Help documentation complete and follows format
- [ ] License block included
- [ ] Code follows style guidelines (2-space indent, naming conventions)
- [ ] Error messages are clear and helpful
- [ ] Backward compatibility maintained (or breaking changes documented)
- [ ] Visual/functional tests performed
- [ ] Comments explain intent, not just mechanics
- [ ] No debugging code (e.g., `disp()`, `keyboard()`) left in

---

## Contact

- **Project maintainer:** Jean-Luc Thiffeault (jeanluc@math.wisc.edu)
- **Issues:** https://github.com/jeanluct/braidlab/issues
- **Documentation:** https://github.com/jeanluct/braidlab/raw/master/doc/braidlab_guide.pdf

---

**Last updated:** 2026-03-07  
**For:** Braidlab refactor-loop-plot branch
