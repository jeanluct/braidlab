# Braidlab Style Guide

If you wish to participate in developing Braidlab, these are the project
style guidelines. The easiest way to comply is often to copy an existing
file of the same type and follow its patterns.

## General

- No tabs; always use spaces.
- Delete trailing whitespace at end of lines and files.
- Every file should end with a line break (but no extra blank lines at end).
- Break lines around 78 characters unless there is a clear reason not to
  (for example, long URLs).
- Use two-space indentation in blocks.
- If a comment is a full sentence, capitalize and punctuate it.
- Spell-check and proofread comments and help messages.

## Version control

- See <https://github.com/jeanluct/braidlab/wiki/braidlab-workflow>.
- Create a branch off `develop` for new features or bug fixes, named
  `issXXX-short-description` where `XXX` is the tracker issue number.
- If a bug targets an existing release and will be part of a maintenance
  release, create a release branch off `master` (for example
  `release-X.Y.Z-branch`), merge into that release branch and into
  `develop`, and do not merge into `master` until release time.
- Use descriptive commit messages. If multiline, make the first line a short
  summary.
- Commit messages should use proper punctuation and explain why the change is
  being made.
- When relevant, refer to tracker issues with `#` in the message body or
  title (for example `#45`) so related work is easier to trace.
- Phrases like `closes issue #45` or `resolves issue #45` auto-close issues,
  so use them carefully.

## Build system and packaging files

- Keep compile/link build logic in `CMakeLists.txt`.
- Keep package install layout logic in `cmake/BraidlabPackage.cmake`.
- Keep bundled GMP logic in `cmake/BraidlabBundledGMP.cmake`.
- Avoid mixing these concerns in one place unless there is a clear reason.

## MATLAB `.m` files

- Use this formatting pattern for function help:

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

- Use three spaces between the bold function name and one-line summary, and
  three-space indentation in help text, matching MATLAB style.
- One-line summaries should have punctuation.
- Optional flags should use capitalization like `'PropertyName','value'`:
  property name capitalized, value not.
- If a file contains more than one function, prefer `function ... function`
  style (not `function ... end`) to avoid an extra indentation level.
- Separate functions with a `% ===...===` line (see
  `+braidlab/@braid/subbraid.m`).
- Avoid global variables when possible. If needed, use
  `BRAIDLAB_global_variable_name` with the variable suffix lowercase.

## C/C++ files

- Braidlab-specific macros and compiler flags should be
  `BRAIDLAB_COMPILER_FLAG` (uppercase).
- In MEX files, use MATLAB index-size macros:
  - `mwSize` for array sizes,
  - `mwIndex` for indexing,
  - `mwSignedIndex` for index differences.

See:

- <https://www.mathworks.com/help/matlab/apiref/mwsize.html>
- <https://www.mathworks.com/help/matlab/apiref/mwindex.html>
- <https://www.mathworks.com/help/matlab/apiref/mwsignedindex.html>
