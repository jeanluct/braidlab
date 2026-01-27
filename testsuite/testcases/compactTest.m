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

classdef compactTest < matlab.unittest.TestCase

  methods (Test)

    %% Identity braid tests

    function test_identity_empty(testCase)
      % Verify that compacting the trivial braid returns the trivial braid.
      br = braidlab.braid([], 5);
      testCase.verifyTrue(isempty(br.compact.word));
    end

    function test_identity_fromtrajectory(testCase)
      % Verify that compacting trivial braid from trajectory is trivial.
      br = braidlab.braid(cat(3, [0 0], [1 1]), 5);
      testCase.verifyTrue(isempty(br.compact.word));
    end

    function test_identity_simple(testCase)
      % Verify that compacting gives trivial braid in simple cases.
      br = braidlab.braid([1 -2 2 -1]);
      testCase.verifyTrue(isempty(br.compact.word));
    end

    function test_identity_braidrelation(testCase)
      % Verify that braid relation compacts to trivial.
      br = braidlab.braid([1 2 1 -2 -1 -2], 5);
      testCase.verifyTrue(isempty(br.compact.word));
    end

    function test_identity_preserves_n(testCase)
      % Test that compact preserves string count for identity.
      br = braidlab.braid([1 -1], 10);
      c = compact(br);
      testCase.verifyEqual(c.n, 10);
    end

    %% Cancellation tests

    function test_cancel_adjacent(testCase)
      % Test that compact reduces cancelling generators.
      br = braidlab.braid([1 -1 2 -2 3], 5);
      c = compact(br);
      testCase.verifyEqual(c, braidlab.braid([3], 5));
    end

    function test_cancel_nested(testCase)
      % Test compact on nested cancellations.
      br = braidlab.braid([1 2 -2 -1], 4);
      c = compact(br);
      testCase.verifyTrue(istrivial(c));
    end

    function test_cancel_multiple(testCase)
      % Test multiple cancellations.
      br = braidlab.braid([1 -1 1 -1 1 -1], 3);
      c = compact(br);
      testCase.verifyTrue(istrivial(c));
    end

    %% Preservation tests

    function test_preserve_equality(testCase)
      % Test compact on braid with no obvious reductions.
      br = braidlab.braid([1 2 3], 5);
      c = compact(br);
      testCase.verifyTrue(br == c);
    end

    function test_preserve_random(testCase)
      % Verify that compacting doesn't change the braid (random).
      rng('default')
      nstrands = 10;
      ngen = 30;
      for i = 1:100
        br = braidlab.braid('random', nstrands, ngen);
        c = compact(br);
        testCase.verifyTrue(br == c, 'Braids not equal after compacting.');
      end
    end

    %% Output format tests

    function test_output_emptyword(testCase)
      % Test that compact of identity has empty word.
      br = braidlab.braid([], 5);
      c = compact(br);
      testCase.verifyTrue(isempty(c.word));
      testCase.verifyEqual(c.n, 5);
    end

    function test_output_class(testCase)
      % Test that compact returns a braid.
      br = braidlab.braid([1 2 3], 4);
      c = compact(br);
      testCase.verifyClass(c, 'braidlab.braid');
    end

    function test_output_shorter(testCase)
      % Test that compact produces shorter or equal word.
      br = braidlab.braid([1 -1 2 3], 4);
      c = compact(br);
      testCase.verifyLessThanOrEqual(length(c.word), length(br.word));
    end

  end
end
