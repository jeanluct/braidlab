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
    function test_braid_constructor(testCase)
      import braidlab.braid
      import braidlab.cfbraid

      % Convert a regular braid to a cfbraid.
      b = braid([1 2 -3]);
      cfb = cfbraid(b);
      testCase.verifyEqual(cfb.delta,-1);
      testCase.verifyEqual(cfb.factors{1},int32([2 3 2]));
      testCase.verifyEqual(cfb.factors{2},int32([2 1 3 2]));
      testCase.verifyEqual(cfb.n,b.n);

      % Copy constructor.
      cfb2 = cfb;
      testCase.verifyEqual(cfb,cfb2);

      % Convert back to braid.
      b2 = braid(cfb);
      testCase.verifyTrue(b == b2);

      % Create from generators, with extra string.
      cfb2 = cfbraid([1 2 -3]);
      testCase.verifyEqual(cfb,cfb2);

      % Create from generators, with extra string.
      cfb2 = cfbraid([1 2 -3],5);
      testCase.verifyTrue(cfb ~= cfb2);
      testCase.verifyTrue(cfb2.n == 5);

      % Out of range generator.
      testCase.verifyError(@() cfbraid([1 2 -3],2), ...
                           'BRAIDLAB:cfbraid:cfbraid:badgen')

      % Can't override n when creating from a braid or cfbraid.
      testCase.verifyError(@() cfbraid(b,2), ...
                           'BRAIDLAB:cfbraid:cfbraid:badarg');
      testCase.verifyError(@() cfbraid(cfb,4), ...
                           'BRAIDLAB:cfbraid:cfbraid:badarg');

      % Create from empty array.
      cfb = cfbraid([]);
      cfb2 = cfbraid([]);
      testCase.verifyEqual(cfb,cfb2);
      testCase.verifyTrue(braid(cfb) == braid([]));
      cfb2 = cfbraid([],2);
      testCase.verifyTrue(cfb ~= cfb2);
      testCase.verifyTrue(istrivial(cfb));
      testCase.verifyTrue(istrivial(cfb2));
    end

    function test_methods(testCase)
      import braidlab.cfbraid;

      % Test remaining methods.  Note that conjtest is tested separately.
      testCase.verifyTrue(ispositive(cfbraid([1 2 3 2 4 -2])));
      testCase.verifyTrue(istrivial(cfbraid([],5)));
      testCase.verifyEqual(length(cfbraid([1 2 -3])),13);
      testCase.verifyEqual(length(cfbraid([],5)),0);
    end

    function test_braid_from_cfbraid(testCase)
      % Test converting a cfbraid to braid.
      import braidlab.cfbraid %#ok<SIMPT>
      import braidlab.braid %#ok<SIMPT>

      % Create a simple cfbraid from a word.
      cf = cfbraid([1 2 3 1 2],5);

      % Convert to braid.
      b = braid(cf);

      % Verify it's a braid and has correct number of strings.
      testCase.verifyClass(b,'braidlab.braid');
      testCase.verifyEqual(b.n,cf.n);

      % The resulting braid should be delta^delta * factors.
      D = braid('halftwist',cf.n);
      expected = D^cf.delta * braid(cell2mat(cf.factors),cf.n);
      testCase.verifyEqual(b,expected);
    end

    function test_conjtest_same_braid(testCase)
      % Test that a braid is conjugate to itself.
      b = braidlab.braid([1 2],4);
      isconj = conjtest(b,b);
      testCase.verifyTrue(isconj);
    end

    function test_conjtest_conjugate_braids(testCase)
      % Test conjugate braids.
      br1 = braidlab.braid([1 2],4);
      c = braidlab.braid([1],4);
      br2 = c * br1 * c.inv;
      isconj = conjtest(br1,br2);
      testCase.verifyTrue(isconj);
    end

    function test_conjtest_returns_conjugator(testCase)
      % Test that conjtest returns conjugating braid.
      br1 = braidlab.braid([1 2],4);
      br2 = braidlab.braid([1 -2  1 2  2 -1],4);
      [isconj,C] = conjtest(br1,br2);
      testCase.verifyTrue(isconj);
      testCase.verifyTrue(inv(C) * br1 * C == br2);
    end
  end
end
