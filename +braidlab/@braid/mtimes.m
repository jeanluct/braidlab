function [out,varargout] = mtimes(b1,b2)
%MTIMES   Multiply two braids together or act on a loop with a braid.
%   C = B1*B2, where B1 and B2 are braid objects, returns the product of
%   the two braids.  The product is the group operation in the braid
%   group (braid concatenation).
%
%   L2 = B*L, where B is a braid and L is a loop object, returns a new
%   loop L2 given by the action of B on L.  L can also be a column
%   vector of loops.
%
%   [L2,M] = B*L also returns the sparse matrix M giving the effective
%   linear action of the braid B on the loop L.  This means that the
%   piecewise-linear action B*L is equal to the matrix-vector
%   multiplication M*L.coords' for this particular loop L.
%
%   This is a method for the BRAID class.
%   See also BRAID, BRAID.INV, BRAID.MPOWER, LOOP.

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   https://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2025  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
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

if isa(b2,'braidlab.annbraid')
  % If b2 is an annbraid, the product is a plain braid.
  out = mtimes(b1,b2.braid);
elseif isa(b2,'braidlab.braid')
  % If b2 is also a braid, the product is simple concatenation.
  out = braidlab.braid([b1.word b2.word],max(b1.n,b2.n));
elseif isa(b2,'braidlab.loop')
  % Action of braid on a loop.
  %
  % Have to define this here, rather than in the loop class, since the
  % braid goes on the left, and Matlab determines which overloaded
  % function to call by looking at the first argument.
  if ~isscalar(b2)
    % Can't act on array of loops with a braid.
    % This is very inefficient, and can be done instead with a
    % scalar containing an array of loop coordinates.
    error('BRAIDLAB:braid:mtimes:notscalar', ...
          ['Action of braid on nonscalar loop array not supported.' ...
           '  Instead use matrix of loop.coords.  ' ...
           'Try ''help loop.loop''.'])
  end
  if b1.n > b2.totaln
    error('BRAIDLAB:braid:mtimes:badgen', ...
          'Braid has too many strings for the loop.')
  end
  if b2.basepoint
    p = b1.perm;
    p = [p (length(p)+1):b2.totaln];
    if p(b2.basepoint) ~= b2.basepoint
      error('BRAIDLAB:braid:mtimes:fixbp', ...
            'Braid cannot move the basepoint.')
    end
  end
  % If generators are defined counterclockwise, then invert the generators.
  if braidlab.prop('GenRotDir') == -1
    b1.word = -b1.word;
  end
  if strcmpi(braidlab.prop('GenLoopActDir'),'rl')
    b1.word = b1.word(end:-1:1);
  end
  if nargout < 2
    out = loopsigma(b1.word,b2.coords,b1.n);
    out = braidlab.loop(out,'bp',b2.basepoint);
  else
    [out,opsigns] = loopsigma(b1.word,b2.coords,b1.n);
    out = braidlab.loop(out,'bp',b2.basepoint);
    varargout{1} = linact(b1,opsigns,size(b2(1).coords,2));
  end
else
  error('BRAIDLAB:braid:mtimes:badobject', ...
        'Cannot act with a braid on this object.')
end
