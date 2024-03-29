function [varargout] = linact(b,l,N)
%LINACT   Effective linear action of a braid on a loop.
%   M = LINACT(B,L) returns the sparse matrix M giving the effective linear
%   action of the braid B on the loop L.  This means that the
%   piecewise-linear action B*L is equal to the matrix-vector multiplication
%   M*L.coords' for this particular loop L.
%
%   M = LINACT(B) uses L = LOOP(B.n,'basepoint').
%
%   [M,L2] = LINACT(B,L) also returns the loop L2 = B*L.
%
%   M = LINACT(B,OPSIGN,N) uses instead a vector OPSIGN of pos/neg operations in the
%   piecewise-linear action, as given by [~,OPSIGN] = B*L for some loop L.  The
%   loop dimension N defaults to 2*B.n-2.
%
%   This is a method for the BRAID class.
%   See also BRAID, LOOP, BRAID.MTIMES, BRAID.CYCLE.

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   http://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2021  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
%                            Marko Budisic          <marko@clarkson.edu>
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
%   along with Braidlab.  If not, see <http://www.gnu.org/licenses/>.
% LICENSE>

maxopSign = 5;

if nargin < 2, l = braidlab.loop(b.n,'bp'); end

if isa(l,'braidlab.loop')
  if isscalar(l)
    [l2,opSign] = b*l; %#ok<RHSFN>
    varargout{1} = update_rules_matrix(b,opSign,size(l.coords,2));
    if nargout > 1, varargout{2} = l2; end
  else
    error('BRAIDLAB:braid:linact:novector','Does not vectorize over loops.')
  end
elseif isnumeric(l)
  if min(size(l)) == 1
    if length(l) ~= maxopSign*length(b)
      error('BRAIDLAB:braid:linact:badarg','Bad length for OPSIGN.')
    end

    if nargin < 3, N = 2*b.n-2; end

    if mod(N,2)
      error('BRAIDLAB:braid:linact:badarg','N must be even.')
    end

    if N < 2*b.n-4
      error('BRAIDLAB:braid:linact:badarg','N is too small for this braid.')
    end

    varargout{1} = update_rules_matrix(b,l,N);

    if nargout > 1
      error('BRAIDLAB:braid:linact:badout', ...
            'Cannot return second loop argument for OPSIGN input.');
    end
  else
    error('BRAIDLAB:braid:linact:novector','Does not vectorize over OPSIGN.')
  end
end
