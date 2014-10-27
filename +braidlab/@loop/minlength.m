function l = minlength(obj)
%MINLENGTH   The minimum length of a loop.
%   LEN = MINLENGTH(L) computes the minimum length of a loop, assuming
%   the loop has zero thickness, and the punctures have zero size and
%   are one unit apart.
%
%   This is a method for the LOOP class.
%   See also LOOP, LOOP.INTAXIS, BRAID.COMPLEXITY.

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   http://bitbucket.org/jeanluc/braidlab/
%
%   Copyright (C) 2013--2014  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
%                             Marko Budisic         <marko@math.wisc.edu>
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
    l = length_helper(obj.coords.', 2);
    usematlab = false;
  catch me
    warning(me.identifier, [ me.message ...
                    ' Reverting to Matlab minlength'] );
    usematlab = true;
  end
end

%% use Matlab code if MEX is off or if MEX code fails
if usematlab == true
  % compute intersection numbers
  [~,nu] = obj.intersec;
  % sum intersection numbers along rows
  l = sum(nu,2);
end

assert( all( l >= 0 ), 'BRAIDLAB:loop:minlength:negativeresult', ...
        'Loop minlength must never be negative');
