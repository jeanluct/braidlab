function [varargout] = lapoly(b,x,varargin)
%LAPOLY   Characteristic polynomial of effective linear action of a braid.
%   P = LAPOLY(B) returns the characteristic polynomial P of the matrix
%   corresponding to the limit cycle obtained from LACYCLE(B).  The
%   polynomial is in standard Matlab form as a vector of coefficients, with
%   the highest power listed first.
%
%   [M,PERIOD] = LAPOLY(B) also returns the period.
%
%   The polynomial P is representative of the asymptotic behavior of the
%   braid action on loops.  In particular, its largest root, to the power
%   1/PERIOD, corresponds to the dilatation of braid.
%
%   P = LAPOLY(B,X) returns P as a polynomial in the symbolic
%   variable X = sym('x').
%
%   LAPOLY(B,X,MAXIT,NCONVREQ) passes MAXIT and NCONVREQ to
%   BRAID.LACYCLE.
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


if nargin < 2, x = []; end

% Get defaults for maxit and nconvreq from lacycle.
if nargin < 3, varargin = {[]}; end

[varargout{1:nargout}] = lamat(b,varargin{:});

varargout{1} = charpoly(varargout{1},x);
