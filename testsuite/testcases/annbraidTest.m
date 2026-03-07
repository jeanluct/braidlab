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

classdef annbraidTest < matlab.unittest.TestCase

  properties
    ab1m2   % Test annbraid [1 -2].
  end

  methods (TestMethodSetup)
    function create_annbraid(testCase)
      import braidlab.annbraid

      testCase.ab1m2 = annbraid([1 -2]);
    end
  end

  methods (Test)

    %% Constructor tests

    function test_constructor_from_braid(testCase)
      % Test constructor from braid (adds a string).
      import braidlab.annbraid
      import braidlab.braid

      b = annbraid(braid([1 -2]));
      testCase.verifyEqual(braid(b),braid([1 -2],4));
    end

    function test_constructor_empty(testCase)
      % Test empty annbraid constructor.
      import braidlab.annbraid

      b = annbraid([]);
      testCase.verifyTrue(istrivial(b));
      testCase.verifyEqual(b.n,2);
      testCase.verifyEqual(b.nann,1);
    end

    function test_constructor_empty_with_n(testCase)
      % Test empty annbraid with specified string count.
      import braidlab.annbraid

      b = annbraid([],4);
      testCase.verifyEqual(b.nann,4);
    end

    function test_constructor_random(testCase)
      % Test random annbraid constructor.
      import braidlab.annbraid

      rng('default');
      b = annbraid('random',5,5);
      testCase.verifyEqual(b.word,int32([1 2 -3 5 5]));
      testCase.verifyEqual(b.n,6);  % Has a basepoint.
    end

    function test_constructor_from_word(testCase)
      % Test annbraid from word array.
      import braidlab.annbraid
      import braidlab.braid

      b = annbraid([1 -2]);
      testCase.verifyEqual(b.word,int32([1 -2]));
      % Convert to braid.
      testCase.verifyEqual(braid(b),braid([1 2 2 -1 -2 -2]));
    end

    function test_constructor_from_word_with_n(testCase)
      % Test annbraid from word not involving basepoint.
      import braidlab.annbraid
      import braidlab.braid

      b = annbraid([1 -2],3);
      testCase.verifyEqual(b.word,int32([1 -2]));
      % Convert to braid: equal to same generators when not involving basepoint.
      testCase.verifyEqual(braid(b),braid([1 -2],4));
    end

    function test_constructor_set_nann(testCase)
      % Test setting nann property.
      import braidlab.annbraid

      b = annbraid([1 -2],3);
      b.nann = 2;
      testCase.verifyEqual(b.n,3);
    end

    function test_constructor_error_bad_string_arg(testCase)
      % Test that unsupported string arguments error.
      import braidlab.annbraid

      testCase.verifyError(@() annbraid('halftwist'), ...
                           'BRAIDLAB:annbraid:annbraid:badstrarg');
    end

    %% Property tests

    function test_property_n(testCase)
      % Test n property (total strings including basepoint).
      ab = testCase.ab1m2;
      testCase.verifyEqual(ab.n,3);
    end

    function test_property_nann(testCase)
      % Test nann property (annular strings, excluding basepoint).
      ab = testCase.ab1m2;
      testCase.verifyEqual(ab.nann,2);
    end

    function test_property_word(testCase)
      % Test word property.
      ab = testCase.ab1m2;
      testCase.verifyEqual(ab.word,int32([1 -2]));
    end

    %% Conversion tests

    function test_convert_to_braid(testCase)
      % Test converting annbraid to braid.
      import braidlab.annbraid
      import braidlab.braid

      ab = annbraid([1 -2 3],4);
      b = braid(ab);

      testCase.verifyClass(b,'braidlab.braid');
      testCase.verifyEqual(b.n,ab.n);
    end

    function test_convert_to_braid_simple(testCase)
      % Test converting simple annbraid to braid.
      import braidlab.annbraid
      import braidlab.braid

      ab = testCase.ab1m2;
      b = braid(ab);
      testCase.verifyClass(b,'braidlab.braid');
    end

    %% mtimes method tests

    function test_mtimes_annbraid_times_braid(testCase)
      % Test annbraid times braid returns braid.
      import braidlab.braid

      ab = testCase.ab1m2;
      b = braid([1 2]);
      testCase.verifyTrue(isa(ab*b,'braidlab.braid'));
    end

    function test_mtimes_braid_times_annbraid(testCase)
      % Test braid times annbraid returns braid.
      import braidlab.braid

      ab = testCase.ab1m2;
      b = braid([1 2]);
      testCase.verifyTrue(isa(b*ab,'braidlab.braid'));
    end

    function test_mtimes_annbraid_times_annbraid(testCase)
      % Test annbraid times annbraid returns annbraid.
      import braidlab.annbraid

      ab = testCase.ab1m2;
      testCase.verifyTrue(isa(ab*ab,'braidlab.annbraid'));
      testCase.verifyEqual(ab*ab,annbraid([1 -2 1 -2]));
    end

    function test_mtimes_on_loop_error_no_basepoint(testCase)
      % Test that acting on loop without basepoint errors.
      import braidlab.loop

      ab = testCase.ab1m2;
      l = loop(ab.n);
      testCase.verifyError(@() ab*l, 'BRAIDLAB:annbraid:mtimes:nobasepoint');
    end

    function test_mtimes_on_loop_with_basepoint(testCase)
      % Test acting on loop with basepoint.
      import braidlab.loop

      ab = testCase.ab1m2;
      l = loop(ab.nann,'bp');
      l2 = ab*l;
      testCase.verifyEqual(l2,loop([2 -1],'bp'));
    end

    %% inv method tests

    function test_inv_basic(testCase)
      % Test inverse of annbraid.
      import braidlab.annbraid

      ab = testCase.ab1m2;
      ab_inv = inv(ab);
      testCase.verifyEqual(ab_inv,annbraid([2 -1]));
    end

    function test_inv_double_inverse(testCase)
      % Test that double inverse returns original.
      import braidlab.annbraid

      ab = testCase.ab1m2;
      testCase.verifyEqual(inv(inv(ab)),ab);
    end

    %% mpower method tests

    function test_mpower_positive(testCase)
      % Test positive power of annbraid.
      import braidlab.annbraid

      ab = testCase.ab1m2;
      ab2 = ab^2;
      testCase.verifyEqual(ab2,annbraid([1 -2 1 -2]));
    end

    function test_mpower_negative(testCase)
      % Test negative power of annbraid.
      import braidlab.annbraid

      ab = testCase.ab1m2;
      ab_inv = ab^(-1);
      testCase.verifyEqual(ab_inv,annbraid([2 -1]));
    end

    function test_mpower_zero(testCase)
      % Test zero power returns identity.
      import braidlab.annbraid

      ab = testCase.ab1m2;
      ab0 = ab^0;
      testCase.verifyTrue(istrivial(ab0));
    end

    %% perm method tests

    function test_perm_basic(testCase)
      % Test permutation (drops basepoint since it shouldn't move).
      ab = testCase.ab1m2;
      testCase.verifyEqual(perm(ab),[1 2]);
    end

    function test_perm_identity(testCase)
      % Test permutation of identity annbraid.
      import braidlab.annbraid

      ab = annbraid([],3);
      testCase.verifyEqual(perm(ab),1:3);
    end

    %% Hidden inherited method tests

    function test_hidden_tensor_error(testCase)
      % Test that tensor method errors for annbraid.
      ab = testCase.ab1m2;
      testCase.verifyError(@() tensor(ab,ab), ...
                           'BRAIDLAB:annbraid:tensor:undefined');
    end

    function test_hidden_subbraid_error(testCase)
      % Test that subbraid method errors for annbraid.
      ab = testCase.ab1m2;
      testCase.verifyError(@() subbraid(ab), ...
                           'BRAIDLAB:annbraid:subbraid:undefined');
    end

    %% istrivial method tests

    function test_istrivial_identity(testCase)
      % Test istrivial on identity annbraid.
      import braidlab.annbraid

      ab = annbraid([]);
      testCase.verifyTrue(istrivial(ab));
    end

    function test_istrivial_nontrivial(testCase)
      % Test istrivial on non-identity annbraid.
      ab = testCase.ab1m2;
      testCase.verifyFalse(istrivial(ab));
    end

    %% compact method tests (annbraid-specific behavior)

    function test_compact_braid_vs_annbraid_commuting(testCase)
      % Test that generators n-1 and 1 commute for braids but not annbraids.
      import braidlab.annbraid
      import braidlab.braid

      % Generators n-1 and 1 commute for ordinary braids...
      br = braid([1 3 -1 -3]);
      testCase.verifyTrue(istrivial(br));
      % ...but not for annbraids.
      ab = annbraid([1 3 -1 -3]);
      testCase.verifyFalse(istrivial(ab));
    end

    function test_compact_braid_vs_annbraid_relation(testCase)
      % Test braid relation behavior differs for annbraids.
      import braidlab.annbraid
      import braidlab.braid

      % When generator n-1 is involved, braid relation holds for braids...
      br = braid([1 2 1 -2 -1 -2]);
      testCase.verifyTrue(istrivial(br));
      % ...but not for annbraids.
      ab = annbraid([1 2 1 -2 -1 -2]);
      testCase.verifyFalse(istrivial(ab));
    end

    function test_compact_respects_annbraid_rules(testCase)
      % Test that compact respects annbraid-specific rules.
      import braidlab.annbraid
      import braidlab.braid

      global BRAIDLAB_braid_nomex %#ok<GVMIS>
      if isempty(BRAIDLAB_braid_nomex) || ~BRAIDLAB_braid_nomex
        br1 = braid([1 3 -1 -3]);
        br2 = braid([1 2 1 -2 -1 -2]);
        ab1 = annbraid([1 3 -1 -3]);
        ab2 = annbraid([1 2 1 -2 -1 -2]);

        testCase.verifyTrue(lexeq(compact(br1),braid([],4)));
        testCase.verifyTrue(lexeq(compact(br2),braid([],3)));
        testCase.verifyFalse(lexeq(compact(ab1),braid([],4)));
        testCase.verifyFalse(lexeq(compact(ab2),braid([],3)));
      else
        testCase.assumeTrue(false, ...
          'Skipping compact test when BRAIDLAB_braid_nomex is set.');
      end
    end

  end
end
