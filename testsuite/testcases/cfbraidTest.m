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

classdef cfbraidTest < matlab.unittest.TestCase

  methods (Test)

    %% Constructor tests

    function test_constructor_frombraid(testCase)
      % Convert a regular braid to a cfbraid.
      br = braidlab.braid([1 2 -3]);
      cfb = braidlab.cfbraid(br);
      testCase.verifyEqual(cfb.delta, -1);
      testCase.verifyEqual(cfb.factors{1}, int32([2 3 2]));
      testCase.verifyEqual(cfb.factors{2}, int32([2 1 3 2]));
      testCase.verifyEqual(cfb.n, br.n);
    end

    function test_constructor_copy(testCase)
      % Copy constructor.
      cfb = braidlab.cfbraid([1 2 -3]);
      cfb2 = cfb;
      testCase.verifyEqual(cfb, cfb2);
    end

    function test_constructor_fromword(testCase)
      % Create from generators.
      cfb = braidlab.cfbraid([1 2 -3]);
      cfb2 = braidlab.cfbraid([1 2 -3]);
      testCase.verifyEqual(cfb, cfb2);
    end

    function test_constructor_extrastring(testCase)
      % Create from generators with extra string.
      cfb = braidlab.cfbraid([1 2 -3]);
      cfb2 = braidlab.cfbraid([1 2 -3], 5);
      testCase.verifyTrue(cfb ~= cfb2);
      testCase.verifyEqual(cfb2.n, 5);
    end

    function test_constructor_empty(testCase)
      % Create from empty array.
      cfb = braidlab.cfbraid([]);
      cfb2 = braidlab.cfbraid([]);
      testCase.verifyEqual(cfb, cfb2);
      testCase.verifyTrue(braidlab.braid(cfb) == braidlab.braid([]));
    end

    function test_constructor_empty_extrastring(testCase)
      % Create empty with extra string.
      cfb = braidlab.cfbraid([]);
      cfb2 = braidlab.cfbraid([], 2);
      testCase.verifyTrue(cfb ~= cfb2);
    end

    %% Constructor error tests

    function test_constructor_error_badgen(testCase)
      % Out of range generator.
      testCase.verifyError(@() braidlab.cfbraid([1 2 -3], 2), ...
                           'BRAIDLAB:cfbraid:cfbraid:badgen');
    end

    function test_constructor_error_braid_n(testCase)
      % Can't override n when creating from a braid.
      br = braidlab.braid([1 2 -3]);
      testCase.verifyError(@() braidlab.cfbraid(br, 2), ...
                           'BRAIDLAB:cfbraid:cfbraid:badarg');
    end

    function test_constructor_error_cfbraid_n(testCase)
      % Can't override n when creating from a cfbraid.
      cfb = braidlab.cfbraid([1 2 -3]);
      testCase.verifyError(@() braidlab.cfbraid(cfb, 4), ...
                           'BRAIDLAB:cfbraid:cfbraid:badarg');
    end

    %% Conversion tests

    function test_conversion_tobraid(testCase)
      % Convert back to braid.
      br = braidlab.braid([1 2 -3]);
      cfb = braidlab.cfbraid(br);
      br2 = braidlab.braid(cfb);
      testCase.verifyTrue(br == br2);
    end

    function test_conversion_tobraid_formula(testCase)
      % Verify conversion formula: braid = D^delta * factors.
      cfb = braidlab.cfbraid([1 2 3 1 2], 5);
      br = braidlab.braid(cfb);
      testCase.verifyClass(br, 'braidlab.braid');
      testCase.verifyEqual(br.n, cfb.n);
      D = braidlab.braid('halftwist', cfb.n);
      expected = D^cfb.delta * braidlab.braid(cell2mat(cfb.factors), cfb.n);
      testCase.verifyEqual(br, expected);
    end

    %% Equality tests

    function test_eq_equal(testCase)
      % Test equality of same cfbraids.
      cfb1 = braidlab.cfbraid([1 2 -3]);
      cfb2 = braidlab.cfbraid([1 2 -3]);
      testCase.verifyTrue(cfb1 == cfb2);
    end

    function test_eq_notequal(testCase)
      % Test inequality of different cfbraids.
      cfb1 = braidlab.cfbraid([1 2 -3]);
      cfb2 = braidlab.cfbraid([1 2 -3], 5);
      testCase.verifyTrue(cfb1 ~= cfb2);
    end

    %% istrivial tests

    function test_istrivial_empty(testCase)
      % Empty cfbraid is trivial.
      cfb = braidlab.cfbraid([]);
      testCase.verifyTrue(istrivial(cfb));
    end

    function test_istrivial_empty_extrastring(testCase)
      % Empty cfbraid with extra strings is trivial.
      cfb = braidlab.cfbraid([], 5);
      testCase.verifyTrue(istrivial(cfb));
    end

    function test_istrivial_nontrivial(testCase)
      % Non-empty cfbraid is not trivial.
      cfb = braidlab.cfbraid([1 2 -3]);
      testCase.verifyFalse(istrivial(cfb));
    end

    %% ispositive tests

    function test_ispositive_positive(testCase)
      % Test positive braid.
      cfb = braidlab.cfbraid([1 2 3 2 4 -2]);
      testCase.verifyTrue(ispositive(cfb));
    end

    function test_ispositive_negative(testCase)
      % Test braid with negative delta.
      cfb = braidlab.cfbraid([1 2 -3]);
      testCase.verifyFalse(ispositive(cfb));
    end

    %% length tests

    function test_length_empty(testCase)
      % Length of empty cfbraid is zero.
      cfb = braidlab.cfbraid([], 5);
      testCase.verifyEqual(length(cfb), 0);
    end

    function test_length_nonempty(testCase)
      % Length of non-empty cfbraid.
      cfb = braidlab.cfbraid([1 2 -3]);
      testCase.verifyEqual(length(cfb), 13);
    end

    %% char tests

    function test_char_empty(testCase)
      % Test char for trivial braid.
      cfb = braidlab.cfbraid([]);
      testCase.verifyEqual(char(cfb), '< e >');
    end

    function test_char_nonempty(testCase)
      % Test char for non-trivial braid.
      cfb = braidlab.cfbraid([1 2 -3]);
      str = char(cfb);
      testCase.verifyTrue(contains(str, 'D^'));
    end

    %% conjtest tests

    function test_conjtest_samebraid(testCase)
      % Test that a braid is conjugate to itself.
      br = braidlab.braid([1 2], 4);
      isconj = conjtest(br, br);
      testCase.verifyTrue(isconj);
    end

    function test_conjtest_conjugatebraids(testCase)
      % Test conjugate braids.
      br1 = braidlab.braid([1 2], 4);
      c = braidlab.braid([1], 4);
      br2 = c * br1 * c.inv;
      isconj = conjtest(br1, br2);
      testCase.verifyTrue(isconj);
    end

    function test_conjtest_returnsconjugator(testCase)
      % Test that conjtest returns conjugating braid.
      br1 = braidlab.braid([1 2], 4);
      br2 = braidlab.braid([1 -2 1 2 2 -1], 4);
      [isconj, C] = conjtest(br1, br2);
      testCase.verifyTrue(isconj);
      testCase.verifyTrue(inv(C) * br1 * C == br2);
    end

    function test_conjtest_notconjugate(testCase)
      % Test non-conjugate braids.
      br1 = braidlab.braid([1 1], 3);
      br2 = braidlab.braid([1 2], 3);
      isconj = conjtest(br1, br2);
      testCase.verifyFalse(isconj);
    end

  end
end
