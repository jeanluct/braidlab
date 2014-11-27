function ul = looplist(varargin)
%LOOPLIST   Make a list of loops.
%   U = LOOPLIST(VMIN,VMAX) returns a list of loops with indices bounded
%   from below by the vector VMIN, and from above by the vector VMAX.
%
%   U = LOOPLIST(N,IMIN,IMAX) returns loops with N punctutes, with entries
%   bounded by the scalars IMIN and IMAX.

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   http://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2015  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
%                            Marko Budisic         <marko@math.wisc.edu>
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

badbounds = {'BRAIDLAB:loop:looplist:badarg' ...
             'Lower bounds must be less than or equal to upper.'};
toomany = {'BRAIDLAB:loop:looplist:toomanyarg', ...
           'Too many arguments.'};
toofew = {'BRAIDLAB:loop:looplist:toofewarg', ...
           'Too few arguments.'};

if ~isscalar(varargin{1})
  vmin = varargin{1}; vmax = varargin{2};

  if nargin < 2, error(toofew{:}); end
  if nargin > 2, error(toomany{:}); end
  if ~isvector(vmin)
    error(badbounds{1},'Arguments cannot be arrays.')
  end
  if any(size(vmin) ~= size(vmax))
    error(badbounds{1},'Vectors must have same size.')
  end
  if any(vmin > vmax), error(badbounds{:}); end

  ul = looplist_helper(varargin{1:2});

  return
end

if nargin < 3, error(toofew{:}); end
if nargin > 3, error(toomany{:}); end

n = varargin{1}; imin = varargin{2}; imax = varargin{3};

if ~isscalar(imin) || ~isscalar(imax)
  error(badbounds{1},'Bounds must be scalars.')
end

if imin > imax, error(badbounds{:}); end

ul = looplist_helper(imin*ones(1,2*n-4),imax*ones(1,2*n-4));
