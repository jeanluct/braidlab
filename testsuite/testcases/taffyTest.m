% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   https://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2026  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
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

classdef taffyTest < matlab.unittest.TestCase

  methods (TestClassSetup)
    function addExampleFolderToPath(testCase)
      % The taffy routine is in the examples folder.
      testCase.addTeardown(@path, addpath(fullfile(pwd, '../../examples')));
    end
  end

  methods (Test)

    %% 3-rod taffy tests

    function test_3rods_braid(testCase)
      % Test 3-rod taffy braid.
      br = taffy('3rods');
      expected = braidlab.braid([-2 1 1 -2]);
      testCase.verifyEqual(br, expected);
    end

    function test_3rods_pseudoanosov(testCase)
      % Test 3-rod taffy is pseudo-Anosov.
      br = taffy('3rods');
      tn = train(br);
      testCase.verifyEqual(tn.tntype, 'pseudo-Anosov');
      close(gcf);
    end

    %% 4-rod taffy tests

    function test_4rods_braid(testCase)
      % Test 4-rod taffy braid.
      % Parallel code can return different generators, but same braids (#116).
      br = taffy('4rods');
      expected = braidlab.braid([1 3 2 2 1 3]);
      testCase.verifyTrue(br == expected);
      close(gcf);
    end

    function test_4rods_coincident(testCase)
      % Test 4-rod taffy with coincident projection.
      % The four particles are initially aligned exactly along the y axis.
      testCase.verifyError(@() taffy('4rods', pi/2), ...
                           'BRAIDLAB:braid:colorbraiding:coincidentprojection');
    end

    function test_4rods_perturbedprojection(testCase)
      % Test 4-rod taffy with perturbed projection angle.
      br = taffy('4rods', pi/2 + 0.01);
      expected = braidlab.braid([-2 2 1 3 2 -3 -1 3 1 2 1 3]);
      % Parallel code can return different generators, but same braids (#116).
      testCase.verifyTrue(br == expected);
      close(gcf);
    end

    %% 6-rod taffy tests

    function test_6rods_braid(testCase)
      % Test 6-rod taffy braid.
      % Parallel code can return different generators, but same braids (#116).
      br = taffy('6rods');
      expected = braidlab.braid([3 2 1 2 4 5 4 3 3 2 1 2 5 4 5 3]);
      testCase.verifyTrue(br == expected);
      close(gcf);
    end

    function test_6rods_pseudoanosov(testCase)
      % Test 6-rod taffy is pseudo-Anosov.
      br = taffy('6rods');
      tn = train(br);
      testCase.verifyEqual(tn.tntype, 'pseudo-Anosov');
      close(gcf);
    end

    function test_6rodsbad_braid(testCase)
      % Test 6-rod-bad taffy braid.
      % Parallel code can return different generators, but same braids (#116).
      br = taffy('6rods-bad');
      expected = braidlab.braid([2 1 2 4 5 4 3 3 2 1 2 4 5 4]);
      testCase.verifyTrue(br == expected);
      close(gcf);
    end

    function test_6rodsbad_reducible(testCase)
      % Test 6-rod-bad taffy is reducible.
      br = taffy('6rods-bad');
      tn = train(br);
      testCase.verifyEqual(tn.tntype, 'reducible');
      close(gcf);
    end

  end
end
