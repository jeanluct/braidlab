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

classdef annbraidTest < matlab.unittest.TestCase

  properties
    ab1m2
  end

  methods (TestMethodSetup)
    function create_annbraid(testCase)
      import braidlab.annbraid

      testCase.ab1m2 = annbraid([1 -2]);
    end
  end

  methods (Test)
    function test_annbraid_constructor(testCase)
      import braidlab.annbraid
      import braidlab.braid

      % Add a string to a braid.
      b = annbraid(braid([1 -2]));
      testCase.verifyEqual(braid(b),braid([1 -2],4));

      % Empty annbraid
      b = annbraid([]);
      testCase.verifyTrue(istrivial(b))
      testCase.verifyEqual(b.n,2);
      testCase.verifyEqual(b.nann,1);
      b = annbraid([],4);
      testCase.verifyEqual(b.nann,4);

      % Random annbraid
      rng('default')
      b = annbraid('random',5,5);
      testCase.verifyEqual(b.word,int32([1 2 -3 5 5]));
      testCase.verifyEqual(b.n,6);  % has a basepoint

      % Other string arguments not supported.
      testCase.verifyError(@() annbraid('halftwist'), ...
                           'BRAIDLAB:annbraid:annbraid:badstrarg')

      % annbraid from a word
      b = annbraid([1 -2]);
      testCase.verifyEqual(b.word,int32([1 -2]));
      % Convert to braid.
      testCase.verifyEqual(braid(b),braid([1 2 2 -1 -2 -2]));
      % Again but not involving the basepoint.
      b = annbraid([1 -2],3);
      testCase.verifyEqual(b.word,int32([1 -2]));
      % Convert to braid: this time equal to same generators.
      testCase.verifyEqual(braid(b),braid([1 -2],4));
      % Can set number of strings to 2+1:
      b.nann = 2;
      testCase.verifyEqual(b.n,3);
    end

    function test_annbraid_mtimes(testCase)
      import braidlab.annbraid
      import braidlab.braid
      import braidlab.loop

      ab = testCase.ab1m2;
      b = braid([1 2]);
      % annbraid times braid is a braid.
      testCase.verifyTrue(isa(ab*b,'braidlab.braid'))
      % braid times annbraid is a braid.
      testCase.verifyTrue(isa(b*ab,'braidlab.braid'))
      % annbraid times annbraid is an annbraid.
      testCase.verifyTrue(isa(ab*ab,'braidlab.annbraid'))
      testCase.verifyEqual(ab*ab,annbraid([1 -2 1 -2]))

      % Act on a loop without basepoint is an error.
      l = loop(ab.n);
      testCase.verifyError(@() ab*l, 'BRAIDLAB:annbraid:mtimes:nobasepoint')

      % Ok with basepoint.
      l = loop(ab.nann,'bp');
      l2 = ab*l;
      testCase.verifyEqual(l2,loop([2 -1],'bp'))
    end

    function test_inv_mpower(testCase)
      import braidlab.annbraid

      ab = testCase.ab1m2;
      % inv and mpower act only on word (no conversion to braid).
      ab2 = ab^2;
      testCase.verifyEqual(ab2,annbraid([1 -2 1 -2]))
      ab2 = inv(ab);
      testCase.verifyEqual(ab2,annbraid([2 -1]))
    end

    function test_perm(testCase)
      import braidlab.annbraid

      % perm drops the basepoint, since it shouldn't move.
      ab = testCase.ab1m2;
      testCase.verifyEqual(perm(ab),[1 2])
    end

    function test_annbraid_hidden(testCase)
      % Make sure some hidden methods inherited from braid class give error.
      ab = testCase.ab1m2;
      testCase.verifyError(@() tensor(ab,ab), ...
                           'BRAIDLAB:annbraid:tensor:undefined');
      testCase.verifyError(@() subbraid(ab), ...
                           'BRAIDLAB:annbraid:subbraid:undefined');
    end

    function test_annbraid_compact(testCase)
      import braidlab.annbraid
      import braidlab.braid

      % See issue #99.
      % The generators n-1 and 1 commute for ordinary braids...
      b1 = braid([1 3 -1 -3]);
      testCase.verifyTrue(istrivial(b1))
      % ...but not for annbraids.
      ab1 = annbraid([1 3 -1 -3]);
      testCase.verifyTrue(~istrivial(ab1))

      % Similaly, when generator n-1 is involved the braid relation holds
      % for ordinary braids...
      b2 = braid([1 2 1 -2 -1 -2]);
      testCase.verifyTrue(istrivial(b2))
      % ...but not for annbraids.
      ab2 = annbraid([1 2 1 -2 -1 -2]);
      testCase.verifyTrue(~istrivial(ab2))

      % Compact should respect this.
      testCase.verifyTrue(lexeq(compact(b1),braid([],4)))
      testCase.verifyTrue(lexeq(compact(b2),braid([],3)))
      testCase.verifyTrue(~lexeq(compact(ab1),braid([],4)))
      testCase.verifyTrue(~lexeq(compact(ab2),braid([],3)))
    end
  end
end
