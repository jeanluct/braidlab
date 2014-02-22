function M = lamat(b,maxit,nconvreq)
%LAMAT   Final matrix of cyclic effective linear action of a braid.
%   P = LAMAT(B) returns the last sparse matrix M in the limit cycle
%   obtained from LACYCLE(B).
%
%   This matrix is representative of the asymptotic behavior of the braid
%   action on loops.  In particular, its largest eigenvalue corresponds to
%   the dilatation of braid.
%
%   P = LAMAT(B,MAXIT,NCONVREQ) passes MAXIT and NCONVREQ to BRAID.LACYCLE.
%
%   This is a method for the BRAID class.
%   See also BRAID, LOOP, BRAID.LACYCLE, BRAID.LAMAT.

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
if nargin < 2, maxit = []; end
if nargin < 3, nconvreq = []; end

pn = lacycle(b,maxit,nconvreq);

% Get matrix from the last iterate.
M = linact(b,pn(end,:));
