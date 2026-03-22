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

classdef conjtestTest < matlab.unittest.TestCase

  methods (Test)

    %% Self-conjugacy tests

    function test_self_conjugate(testCase)
      % A braid is conjugate to itself.
      br = braidlab.braid([1 2 -3], 4);
      isconj = conjtest(br, br);
      testCase.verifyTrue(isconj);
    end

    function test_self_identity(testCase)
      % Identity is conjugate to itself.
      br = braidlab.braid([], 4);
      isconj = conjtest(br, br);
      testCase.verifyTrue(isconj);
    end

    %% Conjugate braids tests

    function test_conjugate_simple(testCase)
      % Test conjugate braids with simple conjugator.
      br1 = braidlab.braid([1 2], 4);
      c = braidlab.braid([1], 4);
      br2 = c * br1 * c.inv;
      isconj = conjtest(br1, br2);
      testCase.verifyTrue(isconj);
    end

    function test_conjugate_returnsconjugator(testCase)
      % Test that conjtest returns the conjugating braid.
      br1 = braidlab.braid([1 2], 4);
      br2 = braidlab.braid([1 -2 1 2 2 -1], 4);
      [isconj, C] = conjtest(br1, br2);
      testCase.verifyTrue(isconj);
      testCase.verifyTrue(inv(C) * br1 * C == br2);
    end

    function test_conjugate_projection(testCase)
      % Verify independence on projection line.  Braids should be conjugate.
      load('testdata', 'XY', 'ti')
      XY = XY(1:length(ti), :, :);
      XY = braidlab.closure(XY);

      br1 = braidlab.braid(XY);
      br1c = br1.compact;
      br2 = braidlab.braid(XY, -pi/4 + 1e-8);
      br2c = br2.compact;

      [conj, C] = conjtest(br1c, br2c);
      testCase.verifyTrue(conj, 'Braids are not conjugate.');
      testCase.verifyEqual(C, braidlab.braid([-3 -2 -3 -1 -2 -3 1 2 1 2]));
    end

    %% Non-conjugate braids tests

    function test_nonconjugate_different(testCase)
      % Test non-conjugate braids.
      br1 = braidlab.braid([1 1], 3);
      br2 = braidlab.braid([1 2], 3);
      isconj = conjtest(br1, br2);
      testCase.verifyFalse(isconj);
    end

    function test_nonconjugate_differentn(testCase)
      % Braids with different n cannot be conjugate.
      br1 = braidlab.braid([1 2], 4);
      br2 = braidlab.braid([1 2], 5);
      isconj = conjtest(br1, br2);
      testCase.verifyFalse(isconj);
    end

    function test_nonconjugate_trivial_nontrivial(testCase)
      % Trivial braid is not conjugate to non-trivial braid.
      br1 = braidlab.braid([], 4);
      br2 = braidlab.braid([1 2], 4);
      isconj = conjtest(br1, br2);
      testCase.verifyFalse(isconj);
    end

    %% Length tests (for projection-independent braids)

    function test_length_projection1(testCase)
      % Verify braid lengths for projection angle 0.
      load('testdata', 'XY', 'ti')
      XY = XY(1:length(ti), :, :);
      XY = braidlab.closure(XY);

      br = braidlab.braid(XY);
      brc = br.compact;
      testCase.verifyEqual(br.length, 894);
      testCase.verifyEqual(brc.length, 14);
    end

    function test_length_projection2(testCase)
      % Verify braid lengths for projection angle -pi/4.
      load('testdata', 'XY', 'ti')
      XY = XY(1:length(ti), :, :);
      XY = braidlab.closure(XY);

      br = braidlab.braid(XY, -pi/4 + 1e-8);
      brc = br.compact;
      testCase.verifyEqual(br.length, 400);
      testCase.verifyEqual(brc.length, 12);
    end

    %% Compact equality tests

    function test_compact_equality(testCase)
      % Verify compact braids are equal to originals.
      load('testdata', 'XY', 'ti')
      XY = XY(1:length(ti), :, :);
      XY = braidlab.closure(XY);

      br1 = braidlab.braid(XY);
      br1c = br1.compact;
      testCase.verifyTrue(br1 == br1c, 'Something went wrong when compacting.');

      br2 = braidlab.braid(XY, -pi/4 + 1e-8);
      br2c = br2.compact;
      testCase.verifyTrue(br2 == br2c, 'Something went wrong when compacting.');
    end

    %% Error tests

    function test_error_coincidentprojection(testCase)
      % Verify error on coincident projection.
      load('testdata', 'XY', 'ti')
      XY = XY(1:length(ti), :, :);
      XY = braidlab.closure(XY);

      testCase.verifyError(@() braidlab.braid(XY, pi/4), ...
                           'BRAIDLAB:braid:colorbraiding:coincidentprojection');
    end

  end
end
