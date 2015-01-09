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

classdef taffyTest < matlab.unittest.TestCase

  methods (Test)
    function test_taffy(testCase)
      addpath ../../doc/examples
      import braidlab.braid

      b = taffy('3rods');
      testCase.verifyEqual(b,braid([-2 1 1 -2]))
      [t,entr] = tntype(b);
      testCase.verifyEqual(t,'pseudo-Anosov')

      b = taffy('4rods');
      testCase.verifyEqual(b,braid([1 3 2 2 1 3]))

      b = taffy('6rods-bad');
      testCase.verifyEqual(b,braid([2 1 2 4 5 4 3 3 2 1 2 4 5 4]))
      t = tntype(b);
      testCase.verifyEqual(t,'reducible')

      b = taffy('6rods');
      testCase.verifyEqual(b,braid([3 2 1 2 4 5 4 3 3 2 1 2 5 4 5 3]))
      [t,entr] = tntype(b);
      testCase.verifyEqual(t,'pseudo-Anosov')

      % The four particles are initially aligned exactly along the y axis.
      testCase.verifyError(@() taffy('4rods',pi/2), ...
                           'BRAIDLAB:braid:colorbraiding:coincidentprojection')

      % Perturb projection a bit.
      b = taffy('4rods',pi/2 + .01);
      testCase.verifyEqual(b,braid([-2 2 1 3 2 -3 -1 3 1 2 1 3]))
      testCase.verifyEqual(compact(b),braid([3 1 2 2 3 1]))
    end
  end
end
