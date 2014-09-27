function [varargout] = cyclemat(b,varargin)
%CYCLEMAT   Matrix of cyclic effective linear action of a braid.
%   M = CYCLEMAT(B) returns the sparse matrix M, which is the product of the
%   matrices in the limit cycle obtained from CYCLE(B).
%
%   [M,PERIOD] = CYCLEMAT(B) also returns the period.
%
%   The matrix M is representative of the asymptotic behavior of the braid
%   action on loops.  In particular, its largest eigenvalue (in absolute
%   value), to the power 1/PERIOD, corresponds to the dilatation of braid if
%   it contains at least one pseudo-Anosov component.
%
%   CYCLEMAT(B,L) uses the initial loop L (default loop(B.n)) for the
%   iteration.
%
%   CYCLEMAT(B,...,MAXIT,NCONVREQ) passes MAXIT and NCONVREQ to BRAID.CYCLE.
%   Either argument can be replaced by [] to use its default value.
%
%   MI = CYCLEMAT(B,...,'iterates') or CYCLEMAT(B,...,'iter') returns a cell
%   arrary MI with PERIOD elements, each containing the matrix of an iterate
%   from the limit cycle.  The matrix M above is MI{PERIOD}*...*MI{1}.
%
%   This is a method for the BRAID class.
%   See also BRAID, LOOP, BRAID.CYCLE, BRAID.LINACT.

% <LICENSE
%   Copyright (c) 2013, 2014 Jean-Luc Thiffeault
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

doiter = false;
for i = 1:length(varargin)
  if ischar(varargin{i})
    if any(strcmpi(varargin{i},{'iterates','iter'}))
      doiter = true;
      varargin(i) = []; % delete string element from cell.
      break
    end
  end
end

% Find the limit cycle.
[pn,it] = cycle(b,varargin{:});
period = size(pn,1);

nn = sqrt(size(pn,2));
if floor(nn) ~= nn
  error('BRAIDLAB:braid:cyclemat:badsize','Bad column size for iterates.');
end

% Reconstruct matrices of the linear action.
M = cell(1,period);
for i = 1:period
  M{i} = reshape(pn(i,:),[nn nn]);
end

if ~doiter
  % Take their product.
  MM = M{1};
  for i = 2:period
    MM = M{i} * MM;
  end
  M = MM;
end

varargout{1} = M;

if nargout > 1, varargout{2} = size(pn,1); end
if nargout > 2, varargout{3} = it; end
