function out = sumg( varargin )
%SUMG   Guarded integer sum.
%   Test that sum operation does not enter overflow.
%   In matlab, there is no "overflow", but there is "cropping"
%
%   e.g.
%
%   maxint + 1 = maxint
%   (maxint + 2) - 3 = maxint - 3
%   maxint + (2 - 3) = maxint - 1

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   http://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2024  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
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
%   along with Braidlab.  If not, see <http://www.gnu.org/licenses/>.
% LICENSE>

if length(varargin) == 1 % single argument returns input value
  out = varargin{1};
elseif length(varargin) > 2
  % More than two arguments recurse binomially;
  % consider sorting to improve results,
  % e.g., ( 1 - 1 ) + maxint    will not overflow
  %       ( 1 + maxint) - 1     will overflow
  out = sumg( varargin{1:floor(end/2)}, sumg(varargin{floor(end/2)+1:end}) );
else % two arguments are added
  a1 = varargin{1}; a2 = varargin{2};
  out = a1 + a2; % regular input

  % We will perform the check only on integers
  if isinteger(out) % Note that VPI type fails this check, which is ok.
    % For integers, we have an upper and a lower boundary.
    if ~( out > intmin(class(out)) && out < intmax(class(out)) )
      error('BRAIDLAB:braid:sumg:overflow',...
            'Summation of %d and %d has overflowed.', a1, a2)
    end
  end
end
