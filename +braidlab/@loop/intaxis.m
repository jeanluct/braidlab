function l = intaxis(obj)
%INTAXIS   The number of intersections of a loop with the real axis.
%   I = INTAXIS(L) computes the minimum number of intersections of a
%   loop L with the real axis.
%
%   Intaxis is computed by formula (5) in Thiffeault, Chaos, 2010.
%
%
%   This is a method for the LOOP class.
%   See also LOOP, LOOP.MINLENGTH, LOOP.INTERSEC.

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   https://github.com/jeanluct/braidlab
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
%   along with Braidlab.  If not, see <https://www.gnu.org/licenses/>.
% LICENSE>

validateattributes(obj, {'braidlab.loop'},{'scalar'},'intersec');

%% determine if mex should be attempted
global BRAIDLAB_loop_nomex
if ~exist('BRAIDLAB_loop_nomex') || ...
      isempty(BRAIDLAB_loop_nomex) || ...
      BRAIDLAB_loop_nomex == false
  usematlab = false;
else
  usematlab = true;
end

%% use MEX computation
if ~usematlab
  try
    l = length_helper(obj.coords.', 1);
    usematlab = false;
  catch me
    warning(me.identifier, [ me.message ...
                    ' Reverting to Matlab intaxis'] );
    usematlab = true;
  end
end

%% use Matlab code if MEX is off or if MEX code fails
if usematlab == true
  [a,b] = obj.ab;

  % The number of intersections before/after the first and last punctures.
  % See Hall & Yurttas (2009).
  cumb = [zeros(size(b,1),1) cumsum(b,2)];
  b0 = -max(abs(a) + max(b,0) + cumb(:,1:end-1),[],2);
  bn1 = -b0 - sum(b,2);

  % The number of intersections with the real axis.
  l = sum(abs(b),2) + sum(abs(a(:,2:end)-a(:,1:end-1)),2) ...
      + abs(a(:,1)) + abs(a(:,end)) + abs(b0) + abs(bn1);
end

assert( all( l >= 0 ), 'BRAIDLAB:loop:intaxis:negativeresult', ...
        'Loop intaxis must never be negative');
