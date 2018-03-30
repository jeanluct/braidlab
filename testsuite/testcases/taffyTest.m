% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   http://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2018  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
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

classdef taffyTest < matlab.unittest.TestCase

  properties
    b3rods
    b4rods
    b6rodsbad
    b6rods
    b4rods2
  end

  methods (TestClassSetup)
    function addExampleFolderToPath(testCase)
      % The taffy routine is in the examples folder.
      testCase.addTeardown(@path,addpath(fullfile(pwd,'../../doc/examples')));
    end
  end

  methods (TestMethodSetup)
    function create_taffy_braids(testCase)
      import braidlab.braid

      testCase.b3rods = braid([-2 1 1 -2]);
      testCase.b4rods = braid([1 3 2 2 1 3]);
      testCase.b6rodsbad = braid([2 1 2 4 5 4 3 3 2 1 2 4 5 4]);
      testCase.b6rods = braid([3 2 1 2 4 5 4 3 3 2 1 2 5 4 5 3]);
      testCase.b4rods2 = braid([-2 2 1 3 2 -3 -1 3 1 2 1 3]);
    end
  end

  methods (Test)
    function test_taffy(testCase)
      import braidlab.braid

      b = taffy('3rods');
      testCase.verifyEqual(b,testCase.b3rods)
      [t,entr] = tntype(b);
      testCase.verifyEqual(t,'pseudo-Anosov')

      b = taffy('4rods');
      % Parallel code can return different generators, but same braids (#116).
      %testCase.verifyEqual(b,testCase.b4rods)
      testCase.verifyTrue(b == testCase.b4rods)

      b = taffy('6rods-bad');
      % Parallel code can return different generators, but same braids (#116).
      %testCase.verifyEqual(b,testCase.b6rodsbad)
      testCase.verifyTrue(b == testCase.b6rodsbad)
      t = tntype(b);
      testCase.verifyEqual(t,'reducible')

      b = taffy('6rods');
      % Parallel code can return different generators, but same braids (#116).
      %testCase.verifyEqual(b,testCase.b6rods)
      testCase.verifyTrue(b == testCase.b6rods)
      [t,entr] = tntype(b);
      testCase.verifyEqual(t,'pseudo-Anosov')

      % The four particles are initially aligned exactly along the y axis.
      testCase.verifyError(@() taffy('4rods',pi/2), ...
                           'BRAIDLAB:braid:colorbraiding:coincidentprojection')

      % Perturb projection a bit.
      b = taffy('4rods',pi/2 + .01);
      % Parallel code can return different generators, but same braids (#116).
      %testCase.verifyEqual(b,testCase.b4rods2)
      testCase.verifyTrue(b == testCase.b4rods2)

      close(gcf)
    end
  end
end
