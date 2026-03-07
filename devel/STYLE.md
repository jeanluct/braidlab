# BRAIDLAB STYLE GUIDE

If you wish to participate in developing Braidlab, below are some
stylistic guidelines to adhere to.  The easiest way to ensure
compliance, of course, is to simply start a new file by copying an
appropriate existing one.


## GENERAL

* No tabs; always use spaces instead.
* Delete extra whitespace at the end of lines, or at the end of files.
* Every file should end with a linebreak (but no extra blank lines at the end).
* Break lines at 78 characters unless there is a compelling reason not
  to (e.g., long URL).
* Indentation in blocks is two spaces.
* If a comment is a full sentence, capitalize and punctuate accordingly.
* Please spell-check and proofread your comments and help messages!
  We're not animals: we try to write well.


## VERSION CONTROL

* See https://github.com/jeanluct/braidlab/wiki/braidlab-workflow.
* Create a branch off develop to implement a new feature or bugfix.
  The branch should be named issXXX-short-description, where XXX is
  its tracker issue number.
* When a bug relates to an exisiting release, and will be part of a
  maintenance release (X.X.1), then first create a release branch
  (X.X.1) off master, then merge into that branch and into develop
  when you're done.  Do not merge into master until the release is
  ready.
* Use a descriptive log message for commits.  If you use more than one
  line (which is fine), the first line should be a summary.
* The log message should have proper punctuation and end with a period.
* When relevant, refer to issues on the GitHub tracker using #.  Put
  the number at the very start so a sequence of related commits are
  more visible.  Example: "#45: Start implementing new feature X."
* Using "closes issue #45" or "resolves issue #45" will automatically
  resolve an issue.  This is a good thing to add to a log message, but
  be careful not to say "does not resolve issue #45"!


## MATLAB .m FILES

### File Headers

All MATLAB files must include:

1. **Help documentation** (for public functions/classes)
2. **License block** (enclosed in `% <LICENSE` ... `% LICENSE>`)
3. **Copyright notice** with years and authors

Example:

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

### Help Text Format

Here is an example of formatting for function help:

```matlab
function [varargout] = tntype(b)
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
%   T. Hall, "Train: A C++ program for computing train tracks of surface
%   homeomorphisms," https://www.liverpool.ac.uk/~tobyhall/T_Hall.html
%
%   W. P. Thurston, "On the geometry and dynamics of diffeomorphisms of
%   surfaces," Bull. Am. Math. Soc. 19 (1988), 417-431.
%
%   This is a method for the BRAID class.
%   See also BRAID, BRAID.ENTROPY.
```

Note that three spaces are used between the bold function name and
the one-line summary.  Three spaces are also used for indenting
thereafter.  This is to be consistent with Matlab style.  The
one-line summary has punctuation.

### Property/Value Pairs

* Optional flags should have the capitalization
  'PropertyName','value'.  That is, the property itself is
  capitalized, but not the value.

### Function Syntax

* When a file contain more than one function, do not use the
  function...end syntax.  Instead, use the function...function syntax.
  This is to avoid having to indent the first level in the file.
  Separate the functions with a line "% ===...===", as in
  @braid/subbraid.m, for example.

Example:

```matlab
function mainfunction(input)
  % Main function implementation
  result = helperfunction(data);

% ============================================================================
function output = helperfunction(input)
%% helperfunction(input)
%
% Helper function that does X.

output = process(input);
```

### Operators and Spacing

* **Spaces around binary operators:** `a + b`, `x = y`, `i:n`
* **No space after unary operators:** `-x`, `~flag`
* **No space inside parentheses/brackets:** `array(i)`, `[1 2 3]`
* **Function call spacing:** NO space after commas in function arguments:
  - Correct: `hypot(x,y)`, `linspace(0,2*pi,100)`, `plot(x,y,'r-')`
  - Wrong: `hypot(x, y)`, `linspace(0, 2*pi, 100)`, `plot(x, y, 'r-')`
* **Parens:** No space before `(`: `hypot(x,y)` not `hypot (x,y)`.
* **One-liners:** OK for simple conditionals and loops: `if nargin > 0, a = 1; end`, `for j = 1:N, x(j) = i; end`

Example:

```matlab
x = a + b - c;           % Binary operators
y = -x;                  % Unary operator
z = func(a,b,c);         % Function call (no spaces after commas)
array = [1 2 3; 4 5 6];  % Matrix
idx = 1:10;              % Range
```

### Naming Conventions

* **Variables and functions:** Use descriptive names with lowercase and underscores for multi-word names: `puncture_position`, `loop_curve_x`
* **Short names acceptable** for standard usage: `n`, `i`, `j`, `x`, `y`
* **Classes:** Usually lowercase: `braid`, `loop`
* **Methods:** lowercase: `plot`, `entropy`, `loopsigma`

### Comments

* Use `%%` for major section comments
* Use `%` for inline comments
* Align related inline comments vertically when possible
* Comment intent, not obvious code
* If a comment is a full sentence, capitalize and punctuate accordingly

Example:

```matlab
%% Parse input arguments

%% Compute components and assign colors to them

% Cycle through each puncture.
for p = 1:n
  % Determine number of semicircles at the present loop
  if p == n
    nl = M_coord(n);  % This is equal to N_coord(n)
  else
    nl = b_coord(p);
  end
end
```

### Error Handling

Use `assert` for validation with proper error IDs:

```matlab
assert(size(L.coords, 1) == 1, ...
       'BRAIDLAB:loop:plot:multiloop', ...
       ['Argument cannot be a loop vector. ' ...
        'Use plot(L(k)) to plot the k-th loop.']);
```

Error ID format: `'BRAIDLAB:classname:methodname:errortype'`

Examples:
- `'BRAIDLAB:loop:plot:multiloop'`
- `'BRAIDLAB:braid:entropy:invalidarg'`

### Input Parsing

Use `inputParser` for functions with options:

```matlab
parser = inputParser;
parser.addRequired('input1', @validationFunction);
parser.addParameter('ParameterName', defaultValue, @validationFunction);
parser.parse(input1, varargin{:});
options = parser.Results;
```

### Graphics and Plotting

* Return handles when useful for user manipulation
* Follow MATLAB conventions: column vector of handles
* Use `patch()` for closed shapes that might be filled
* Use `plot()` for simple line drawings

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

### Global Variables

* Global variables should be avoided as much as possible, but if they
  are needed should be of the form BRAIDLAB_global_variable_name, with
  the latter part in all lowercase.


## C/C++ FILES

* Braidlab-specific macros and compiler flags should have the form
  BRAIDLAB_COMPILER_FLAG, all in uppercase.
* In MEX files use the Matlab macros mwSize for size of arrays and
  mwIndex for indexing into them.  Use mwSignedIndex for differences
  between indices.  See
    https://www.mathworks.com/help/matlab/apiref/mwsize.html
    https://www.mathworks.com/help/matlab/apiref/mwindex.html
    https://www.mathworks.com/help/matlab/apiref/mwsignedindex.html
