function [varargout] = lamat(b,varargin)
%LAMAT   Matrix of cyclic effective linear action of a braid.
%   M = LAMAT(B) returns the sparse matrix M, which is the product of the
%   matrices in the limit cycle obtained from LACYCLE(B).
%
%   [M,PERIOD] = LAMAT(B) also returns the period.
%
%   The matrix M is representative of the asymptotic behavior of the braid
%   action on loops.  In particular, its largest eigenvalue, to the power
%   1/PERIOD, corresponds to the dilatation of braid.
%
%   LAMAT(B,MAXIT,NCONVREQ) passes MAXIT and NCONVREQ to BRAID.LACYCLE.
%
%   This is a method for the BRAID class.
%   See also BRAID, LOOP, BRAID.LACYCLE, BRAID.LAPOLY.

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


% Get defaults for maxit and nconvreq from lacycle.
if nargin < 2, varargin = {[]}; end

% Find the limit cycle.
[pn,it] = lacycle(b,varargin{:});
period = size(pn,1);

% Reconstruct matrices of the linear action, take their product.
M = linact(b,pn(1,:));
for i = 2:period
  M = linact(b,pn(i,:)) * M;
end

varargout{1} = M;

if nargout > 1, varargout{2} = size(pn,1); end
if nargout > 2, varargout{3} = it; end
