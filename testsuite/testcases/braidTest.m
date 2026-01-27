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

classdef braidTest < matlab.unittest.TestCase

  properties
    b1
    b2
    b3
    id
    pure
    dbr
    XYcoincend
  end

  methods (TestMethodSetup)
    function createBraid(testCase)
      import braidlab.braid
      testCase.b1 = braid([1 -2 3 5],7);
      testCase.b2 = braid([1 2 4 6],7);
      testCase.b3 = braid([1 -2 3 5 2 1 2 -1 -2 -1],7);
      testCase.id = braid([],7);
      testCase.pure = braid([1 -2 1 -2 1 -2]);

      % Trajectories with coincident coordinates at the last time slice.
      testCase.XYcoincend = zeros(2,2,3);
      testCase.XYcoincend(1,:,1) = [0 1];
      testCase.XYcoincend(2,:,1) = [1 3];
      testCase.XYcoincend(1,:,2) = [1 0];
      testCase.XYcoincend(2,:,2) = [1 0];
      testCase.XYcoincend(1,:,3) = [2 0];
      testCase.XYcoincend(2,:,3) = [2 0];
      testCase.XYcoincend = braidlab.closure(testCase.XYcoincend);
    end
  end

  methods (Test)

    %% Constructor tests

    function test_constructor_from_word(testCase)
      % Test basic constructor from word array.
      b = testCase.b1;
      testCase.verifyEqual(b.word,int32([1 -2 3 5]));
      testCase.verifyEqual(b.n,7);
    end

    function test_constructor_zero_generator_error(testCase)
      % Test that zero is not a valid generator value.
      testCase.verifyError(@() braidlab.braid([0 0 1]), ...
                           'BRAIDLAB:braid:setword:badarg');
    end

    function test_constructor_halftwist(testCase)
      % Test HalfTwist named constructor.
      b = braidlab.braid('halftwist',5);
      testCase.verifyEqual(b.word,int32([4 3 2 1 4 3 2 4 3 4]));
    end

    function test_constructor_random(testCase)
      % Test random braid constructor.
      rng(1);
      b = braidlab.braid('random',5,7);
      testCase.verifyEqual(b,braidlab.braid([-2 2 -3 -2 -3 -1 -4]));
    end

    function test_constructor_invalid_string_error(testCase)
      % Test that invalid string argument errors.
      testCase.verifyError(@() braidlab.braid('garbage'), ...
                           'BRAIDLAB:braid:braid:badarg');
    end

    function test_constructor_hironakakin(testCase)
      % Test HironakaKin named constructor.
      b = braidlab.braid('HironakaKin',3,1);
      testCase.verifyEqual(b,braidlab.braid([1 2 3 3 2 1 1 2 3 4]));
    end

    function test_constructor_hironakakin_error(testCase)
      % Test HironakaKin with invalid parameters.
      testCase.verifyError(@() braidlab.braid('HironakaKin',4), ...
                           'BRAIDLAB:braid:braid:badarg');
    end

    function test_constructor_venzkepsi_error(testCase)
      % Test VenzkePsi with invalid n.
      testCase.verifyError(@() braidlab.braid('VenzkePsi',4), ...
                           'BRAIDLAB:braid:braid:badarg');
    end

    function test_constructor_venzkepsi(testCase)
      % Test VenzkePsi named constructor.
      b = braidlab.braid('VenzkePsi',5);
      testCase.verifyEqual(b,braidlab.braid([4 3 2 1 4 3 2 1 -1 -2]));
      b = braidlab.braid('VenzkePsi',6);
      testCase.verifyEqual(b,braidlab.braid([5 4 3 2 1 5 4 3 5 4]));
    end

    function test_constructor_too_many_args_error(testCase)
      % Test that too many input arguments errors.
      testCase.verifyError(@() braidlab.braid(zeros(3,2,4),1,1), ...
                           'BRAIDLAB:braid:braid:badarg');
    end

    function test_constructor_single_trajectory_warning(testCase)
      % Test that 2D array assumed single-particle warns.
      XY = [1 2;2 3;1 2];
      testCase.verifyWarning(@() braidlab.braid(XY), ...
                             'BRAIDLAB:braid:braid:onetraj');
    end

    function test_constructor_complex_trajectory(testCase)
      % Test complex trajectory input (particles on complex plane).
      XY = [1 2;2 3;1 2];
      Z = complex(XY);
      testCase.verifyWarningFree(@() braidlab.braid(Z));
      testCase.verifyEqual(braidlab.braid(Z).n,2);
    end

    function test_constructor_coincident_particles_error(testCase)
      % Test that coincident particles error.
      XY = zeros(4,2,2);
      testCase.verifyError(@() braidlab.braid(XY), ...
                           'BRAIDLAB:braid:colorbraiding:coincidentparticles');
    end

    function test_constructor_coincident_projection_error(testCase)
      % Test that coincident projection errors.
      XY = zeros(4,2,2);
      XY(:,2,2) = 2;
      testCase.verifyError(@() braidlab.braid(XY), ...
                           'BRAIDLAB:braid:colorbraiding:coincidentprojection');
      % Changing the projection gets rid of the error.
      testCase.verifyTrue(braidlab.braid(XY,.1) == braidlab.braid([],2));
    end

    function test_constructor_coincident_end_error(testCase)
      % Test coincidence at end of interval errors (GitHub Issue #109).
      testCase.verifyError(@() braidlab.braid(testCase.XYcoincend), ...
                           'BRAIDLAB:braid:colorbraiding:coincidentprojection');
    end

    function test_constructor_default_empty(testCase)
      % Test default empty constructor returns trivial braid with n=1.
      b = braidlab.braid();
      testCase.verifyEqual(b.n,1);
      testCase.verifyTrue(isempty(b.word));
      testCase.verifyTrue(istrivial(b));
    end

    function test_constructor_empty_word_various_n(testCase)
      % Test empty braid with different string counts.
      for n = 2:5
        b = braidlab.braid([],n);
        testCase.verifyEqual(b.n,n);
        testCase.verifyTrue(isempty(b.word));
        testCase.verifyTrue(istrivial(b));
      end
    end

    function test_constructor_copy(testCase)
      % Test that braid(braid_obj) creates correct copy.
      br1 = braidlab.braid([1 -2 3],5);
      br2 = braidlab.braid(br1);

      testCase.verifyEqual(br1,br2);
      testCase.verifyEqual(br1.word,br2.word);
      testCase.verifyEqual(br1.n,br2.n);

      % Modifying copy doesn't affect original.
      br2.word = int32([2 3]);
      testCase.verifyNotEqual(br1,br2);
    end

    function test_constructor_copy_preserves_n(testCase)
      % Test that copy constructor preserves n.
      br1 = braidlab.braid([1],10);
      br2 = braidlab.braid(br1);
      testCase.verifyEqual(br2.n,10);
    end

    function test_constructor_min_string_count(testCase)
      % Test minimum non-trivial braid group (n=2).
      b = braidlab.braid([1 -1 1],2);
      testCase.verifyEqual(b.n,2);
      testCase.verifyEqual(b.word,int32([1 -1 1]));
    end

    function test_constructor_explicit_n_matches_generator_max(testCase)
      % Test that explicit n matches or exceeds max absolute generator.
      br1 = braidlab.braid([1 2 3],5);
      testCase.verifyEqual(br1.n,5);

      br2 = braidlab.braid([1 2 3]);
      testCase.verifyEqual(br2.n,4); % max(abs([1 2 3]))+1 = 4.
    end

    function test_constructor_normal_distribution(testCase)
      % Test normal/binomial distribution braid constructor.
      % Requires Statistics Toolbox.
      if ~exist('binornd','file')
        return
      end
      rng(42);
      b = braidlab.braid('normal',5,10);
      testCase.verifyEqual(b.n,5);
      testCase.verifyEqual(length(b.word),10);
      % All generators should be in valid range.
      testCase.verifyTrue(all(abs(b.word) >= 1));
      testCase.verifyTrue(all(abs(b.word) <= 4));
    end

    %% Named braid tests

    function test_named_fulltwist(testCase)
      % Test FullTwist/Delta2 with various string counts.
      for n = 3:5
        b = braidlab.braid('FullTwist',n);
        d = braidlab.braid('HalfTwist',n);
        expected = braidlab.braid([d.word d.word]);
        testCase.verifyEqual(b,expected);
      end
    end

    function test_named_fulltwist_equals_halftwist_squared(testCase)
      % Test FullTwist is square of HalfTwist.
      n = 5;
      ft = braidlab.braid('FullTwist',n);
      ht = braidlab.braid('HalfTwist',n);
      expected = ht^2;
      testCase.verifyTrue(lexeq(ft,expected));
    end

    function test_named_halftwist_properties(testCase)
      % Test HalfTwist/Delta properties.
      b = braidlab.braid('HalfTwist',5);
      % Half-twist should have n*(n-1)/2 generators.
      testCase.verifyEqual(length(b.word),5*4/2);

      % Half-twist is positive (all generators positive).
      testCase.verifyTrue(all(b.word > 0));
    end

    function test_named_hironakakin_explicit_params(testCase)
      % Test HironakaKin with explicit M,N parameters.
      b = braidlab.braid('HironakaKin',2,3);
      testCase.verifyEqual(b.n,6); % m+n+1 = 2+3+1 = 6.

      b = braidlab.braid('HK',1,2);  % Test alternate name.
      testCase.verifyEqual(b.n,4);
    end

    function test_named_hironakakin_implicit_params(testCase)
      % Test HironakaKin with implicit parameters (odd/even cases).
      b_odd = braidlab.braid('HironakaKin',7);
      % For odd n=7: m=(7-3)/2=2, n=(7+1)/2=4, total strings = 2+4+1 = 7.
      testCase.verifyEqual(b_odd.n,7);

      b_even = braidlab.braid('HironakaKin',6);
      % For even n=6: m=(6+2)/2=4, n=(6-4)/2=1, total strings = 4+1+1 = 6.
      testCase.verifyEqual(b_even.n,6);
    end

    function test_named_venzkepsi_special_cases(testCase)
      % Test VenzkePsi for special case n=6.
      b = braidlab.braid('VenzkePsi',6);
      testCase.verifyEqual(b,braidlab.braid([5 4 3 2 1 5 4 3 5 4]));

      % Test Psi alias.
      b_alias = braidlab.braid('Psi',6);
      testCase.verifyEqual(b,b_alias);
    end

    function test_named_venzkepsi_various_n(testCase)
      % Test VenzkePsi for different modular conditions.
      % n=7: odd, so L repeated 2k+1 times with k=3, so 7 times.
      b7 = braidlab.braid('VenzkePsi',7);
      testCase.verifyEqual(b7.n,7);

      % n=8: divisible by 4.
      b8 = braidlab.braid('VenzkePsi',8);
      testCase.verifyEqual(b8.n,8);

      % n=10: even, 10 mod 8 = 2.
      b10 = braidlab.braid('VenzkePsi',10);
      testCase.verifyEqual(b10.n,10);
    end

    %% Knot constructor tests

    function test_knot_from_codes(testCase)
      % Test creating braids from various knot codes.
      knot_codes = {'3_1', '5_2', '7_1'};

      for k = 1:length(knot_codes)
        b = braidlab.braid(knot_codes{k});
        testCase.verifyClass(b,'braidlab.braid');
        testCase.verifyTrue(~isempty(b.word));
      end
    end

    function test_knot_invalid_code_error(testCase)
      % Test that invalid knot codes error.
      testCase.verifyError(@() braidlab.braid('99_99'), ...
                           'BRAIDLAB:braid:braid:badarg');
      testCase.verifyError(@() braidlab.braid('invalid'), ...
                           'BRAIDLAB:braid:braid:badarg');
    end

    function test_knot_small_knots(testCase)
      % Test that small knots can be constructed.
      b_trefoil = braidlab.braid('3_1');
      testCase.verifyGreaterThan(length(b_trefoil.word),0);

      b_figure8 = braidlab.braid('4_1');
      testCase.verifyGreaterThan(length(b_figure8.word),0);

      % Verify they are different knots.
      testCase.verifyNotEqual(b_trefoil,b_figure8);
    end

    %% Trajectory input tests

    function test_trajectory_complex(testCase)
      % Test complex trajectory input (particles on complex plane).
      Z = [1+2i 2+3i; 2+1i 3+2i; 1+2i 2+3i];
      b = braidlab.braid(Z);
      testCase.verifyEqual(b.n,2);
      testCase.verifyClass(b,'braidlab.braid');
    end

    function test_trajectory_projection_angles(testCase)
      % Test trajectory construction with different projection angles.
      XY = zeros(4,2,2);
      XY(:,:,1) = [0 0; 1 0.5; 1.5 1; 0 0];
      XY(:,:,2) = [0.5 0; 1.5 0.5; 2 1; 0.5 0];

      for angle = [0, pi/6, pi/4]
        try
          b = braidlab.braid(XY,angle);
          testCase.verifyClass(b,'braidlab.braid');
          testCase.verifyEqual(b.n,2);
        catch me
          % Skip if coincident projection for this angle.
          if ~strcmp(me.identifier, ...
                     'BRAIDLAB:braid:colorbraiding:coincidentprojection')
            rethrow(me);
          end
        end
      end
    end

    function test_trajectory_invalid_projection_error(testCase)
      % Test that invalid projection angles error.
      XY = zeros(3,2,2);
      XY(:,:,1) = [0 0; 1 1; 0 0];
      XY(:,:,2) = [1 0; 0 1; 1 0];

      % NaN projection angle should error.
      testCase.verifyError(@() braidlab.braid(XY,NaN), ...
                           'MATLAB:BRAIDLAB:databraid:expectedFinite');

      % Inf projection angle should error.
      testCase.verifyError(@() braidlab.braid(XY,Inf), ...
                           'MATLAB:BRAIDLAB:databraid:expectedFinite');
    end

    function test_trajectory_with_nans_error(testCase)
      % Test that trajectory with NaN values errors.
      XY = zeros(3,2,2);
      XY(:,:,1) = [0 0; 1 1; 0 0];
      XY(:,:,2) = [1 0; NaN 1; 1 0];

      testCase.verifyError(@() braidlab.braid(XY), ...
                           'MATLAB:BRAIDLAB:braid:expectedFinite');
    end

    function test_trajectory_with_infs_error(testCase)
      % Test that trajectory with Inf values errors.
      XY = zeros(3,2,2);
      XY(:,:,1) = [0 0; 1 1; 0 0];
      XY(:,:,2) = [1 0; Inf 1; 1 0];

      testCase.verifyError(@() braidlab.braid(XY), ...
                           'MATLAB:BRAIDLAB:braid:expectedFinite');
    end

    function test_trajectory_3d_from_complex(testCase)
      % Test that complex trajectory is converted to 3D correctly.
      Z = [1+2i 2+3i; 2+1i 3+2i; 1+2i 2+3i];
      br1 = braidlab.braid(Z);

      % Manually create equivalent 3D trajectory.
      XY = zeros(3,2,2);
      XY(:,1,1) = real(Z(:,1));
      XY(:,2,1) = imag(Z(:,1));
      XY(:,1,2) = real(Z(:,2));
      XY(:,2,2) = imag(Z(:,2));
      br2 = braidlab.braid(XY);

      testCase.verifyEqual(br1,br2);
    end

    function test_trajectory_word_is_int32(testCase)
      % Test that braid from trajectory creates int32 word.
      XY = zeros(2,2,2);
      XY(1,:,:) = [0 0; 1 0].';
      XY(2,:,:) = [0 0; 1 0].';

      b = braidlab.braid(braidlab.closure(XY));
      testCase.verifyClass(b.word,'int32');
    end

    %% Generator range tests

    function test_generator_within_bounds(testCase)
      % Test that generators are correctly bounded by n.
      b = braidlab.braid([1 2 3 4],6);

      % All generators should satisfy -n < g < n.
      testCase.verifyTrue(all(abs(b.word) < b.n));
    end

    function test_generator_negative(testCase)
      % Test that negative generators are properly handled.
      b = braidlab.braid([-1 -2 -3],5);

      testCase.verifyTrue(all(b.word < 0));
      testCase.verifyTrue(all(abs(b.word) < b.n));
    end

    function test_generator_max_determines_n(testCase)
      % Test that max generator determines minimum n.
      b = braidlab.braid([1 3 2 -3],5);

      % n should be at least max(abs(word))+1 = 4.
      testCase.verifyGreaterThanOrEqual(b.n,4);
    end

    function test_generator_at_boundary(testCase)
      % Test generators at boundary |g| = n-1.
      b = braidlab.braid([4 -4 3 -3],5);

      % Max absolute value is 4, so n must be at least 5.
      testCase.verifyEqual(b.n,5);

      % All generators should be valid.
      testCase.verifyTrue(all(abs(b.word) <= b.n-1));
    end

    function test_generator_boundary_various_n(testCase)
      % Test generators exactly at boundary (n-1).
      for n = 3:7
        % Create generators [1, 2, ..., n-1, -(n-1)].
        gens = [1:n-1 -(n-1)];
        b = braidlab.braid(gens,n);

        testCase.verifyEqual(b.n,n);
        testCase.verifyTrue(all(abs(b.word) <= n-1));
      end
    end

    %% Data type tests

    function test_word_int32_from_double(testCase)
      % Test that word is converted to int32 from double input.
      b = braidlab.braid([1.0 2.0 3.0]);
      testCase.verifyClass(b.word,'int32');
      testCase.verifyEqual(b.word,int32([1 2 3]));
    end

    function test_word_int32_from_single(testCase)
      % Test that word is converted to int32 from single input.
      b = braidlab.braid(single([1 2 3]));
      testCase.verifyClass(b.word,'int32');
      testCase.verifyEqual(b.word,int32([1 2 3]));
    end

    function test_word_int32_from_int64(testCase)
      % Test that word is converted to int32 from int64 input.
      b = braidlab.braid(int64([1 2 3]));
      testCase.verifyClass(b.word,'int32');
      testCase.verifyEqual(b.word,int32([1 2 3]));
    end

    function test_word_int32_preserved(testCase)
      % Test that int32 input remains int32.
      input_word = int32([1 -2 3 -4]);
      b = braidlab.braid(input_word);
      testCase.verifyClass(b.word,'int32');
      testCase.verifyEqual(b.word,input_word);
    end

    function test_word_empty_is_int32(testCase)
      % Test that empty word is int32.
      b = braidlab.braid([],5);
      testCase.verifyClass(b.word,'int32');
      testCase.verifyTrue(isempty(b.word));
    end

    function test_word_large_values_int32(testCase)
      % Test that large word values are converted to int32.
      b = braidlab.braid([100 -100 50],150);
      testCase.verifyClass(b.word,'int32');
      testCase.verifyEqual(b.word,int32([100 -100 50]));
    end

    function test_word_named_braid_is_int32(testCase)
      % Test that special named braids create int32 word.
      br1 = braidlab.braid('HalfTwist',5);
      testCase.verifyClass(br1.word,'int32');

      br2 = braidlab.braid('Random',6,10);
      testCase.verifyClass(br2.word,'int32');

      br3 = braidlab.braid('VenzkePsi',6);
      testCase.verifyClass(br3.word,'int32');
    end

    function test_word_copy_preserves_int32(testCase)
      % Test that copying a braid preserves int32 type.
      br1 = braidlab.braid([1 2 3]);
      br2 = braidlab.braid(br1);

      testCase.verifyClass(br1.word,'int32');
      testCase.verifyClass(br2.word,'int32');
    end

    %% Property n tests

    function test_n_copy_and_change(testCase)
      % Test copying a braid and setting n.
      b = testCase.b1;
      b_copy = braidlab.braid(b);
      b_copy.n = 10;
      testCase.verifyEqual(b_copy.n,10);
      testCase.verifyEqual(b_copy.word,b.word);

      % Setting n too small for existing generators should error.
      testCase.verifyError(@() setfield(b_copy,'n',3), ...
                           'BRAIDLAB:braid:setn:badarg');
    end

    function test_n_set_valid_increase(testCase)
      % Test increasing n to valid value.
      b = braidlab.braid([1 2],4);
      b.n = 10;
      testCase.verifyEqual(b.n,10);
    end

    function test_n_set_invalid_decrease_error(testCase)
      % Test decreasing n below minimum required errors.
      b = braidlab.braid([1 2 3],5);
      testCase.verifyError(@() setfield(b,'n',3), ...
                           'BRAIDLAB:braid:setn:badarg');
    end

    function test_n_too_small_for_generators_error(testCase)
      % Test that setting n too small for existing generators fails.
      b = braidlab.braid([1 2 3],5);

      % Try to set n smaller than max(abs(word))+1.
      testCase.verifyError(@() setfield(b,'n',2), ...
                           'BRAIDLAB:braid:setn:badarg');
    end

    %% eq method tests

    function test_eq_basic(testCase)
      % Test basic equality.
      testCase.verifyTrue(testCase.b1 == testCase.b3);
      testCase.verifyFalse(testCase.b1 ~= testCase.b3);
      testCase.verifyTrue(testCase.id == braidlab.braid([1 -1],7));
    end

    function test_eq_different_n_same_word(testCase)
      % Test equality of braids with same word but different n.
      br1 = braidlab.braid([1 2],4);
      br2 = braidlab.braid([1 2],5);
      testCase.verifyFalse(br1 == br2);
      testCase.verifyTrue(br1 ~= br2);
    end

    function test_eq_empty_braids(testCase)
      % Test equality of two identity braids.
      br1 = braidlab.braid([],5);
      br2 = braidlab.braid([],5);
      testCase.verifyTrue(br1 == br2);
    end

    function test_eq_identity_vs_cancelling(testCase)
      % Test that cancelling generators equal identity.
      br1 = braidlab.braid([],4);
      br2 = braidlab.braid([1 -1],4);
      testCase.verifyTrue(br1 == br2);
    end

    %% lexeq method tests

    function test_lexeq_basic(testCase)
      % Test basic lexical equality.
      testCase.verifyTrue(testCase.b1 == testCase.b1);
      testCase.verifyFalse(testCase.b1 ~= testCase.b1);
    end

    function test_lexeq_identical(testCase)
      % Test lexeq on identical braids.
      b = braidlab.braid([1 2 3],5);
      testCase.verifyTrue(lexeq(b,b));
    end

    function test_lexeq_different_word_same_braid(testCase)
      % Test lexeq on equivalent but lexically different braids.
      br1 = braidlab.braid([1 -1 2],4);
      br2 = braidlab.braid([2],4);
      % They are equal as braids.
      testCase.verifyTrue(br1 == br2);
      % But not lexically equal.
      testCase.verifyFalse(lexeq(br1,br2));
    end

    function test_lexeq_different_n(testCase)
      % Test lexeq on braids with different n.
      br1 = braidlab.braid([1 2],4);
      br2 = braidlab.braid([1 2],5);
      testCase.verifyFalse(lexeq(br1,br2));
    end

    %% istrivial method tests

    function test_istrivial_basic(testCase)
      % Test basic istrivial.
      testCase.verifyFalse(istrivial(testCase.b1));
      testCase.verifyTrue(istrivial(testCase.id));
    end

    function test_istrivial_from_cancelling_generators(testCase)
      % Test that equal and opposite generators reduce trivially.
      b = braidlab.braid([1 -1 1 -1],3);
      testCase.verifyTrue(istrivial(b));
    end

    function test_istrivial_complex_reduction(testCase)
      % Test istrivial on complex reducible braid.
      b = braidlab.braid([1 2 -2 -1],4);
      testCase.verifyTrue(istrivial(b));
    end

    function test_istrivial_far_commuting(testCase)
      % Test braid with far commuting generators.
      b = braidlab.braid([1 3 -1 -3],5);
      testCase.verifyTrue(istrivial(b));
    end

    %% ispure method tests

    function test_ispure_basic(testCase)
      % Test basic ispure.
      testCase.verifyFalse(ispure(testCase.b1));
      testCase.verifyTrue(ispure(testCase.pure));
      testCase.verifyTrue(ispure(testCase.id));
    end

    function test_ispure_sigma_squared(testCase)
      % Test that sigma_i^2 is pure.
      b = braidlab.braid([1 1],3);
      testCase.verifyTrue(ispure(b));
    end

    function test_ispure_commutator(testCase)
      % Test that squared commutator-like braid is pure.
      % A braid is pure if its permutation is the identity.
      b = braidlab.braid([1 1 2 2 -1 -1 -2 -2],4);
      testCase.verifyTrue(ispure(b));
    end

    %% mtimes method tests

    function test_mtimes_basic(testCase)
      % Test basic multiplication.
      b = testCase.b1*testCase.b2;
      testCase.verifyEqual(b,braidlab.braid([1 -2 3 5 1 2 4 6]));
    end

    function test_mtimes_identity_left(testCase)
      % Test multiplying identity on left.
      ident = braidlab.braid([],4);
      b = braidlab.braid([1 2],4);
      c = ident * b;
      testCase.verifyTrue(lexeq(c,b));
    end

    function test_mtimes_identity_right(testCase)
      % Test multiplying identity on right.
      ident = braidlab.braid([],4);
      b = braidlab.braid([1 2],4);
      c = b * ident;
      testCase.verifyTrue(lexeq(c,b));
    end

    function test_mtimes_inverse(testCase)
      % Test that b * inv(b) is trivial.
      b = braidlab.braid([1 2 -3],5);
      c = b * b.inv;
      testCase.verifyTrue(istrivial(c));
    end

    function test_mtimes_associative(testCase)
      % Test associativity of multiplication.
      br1 = braidlab.braid([1],4);
      br2 = braidlab.braid([2],4);
      br3 = braidlab.braid([3],4);
      left = (br1 * br2) * br3;
      right = br1 * (br2 * br3);
      testCase.verifyTrue(left == right);
    end

    %% mpower method tests

    function test_mpower_basic(testCase)
      % Test basic power.
      b = testCase.b1^3;
      testCase.verifyEqual(b,braidlab.braid([1 -2 3 5 1 -2 3 5 1 -2 3 5],7));
    end

    function test_mpower_negative(testCase)
      % Test negative powers.
      b = braidlab.braid([1 2],4);
      b_inv = b^(-1);
      testCase.verifyEqual(b_inv,b.inv);
      testCase.verifyTrue((b * b_inv) == braidlab.braid([],4));
    end

    function test_mpower_zero(testCase)
      % Test zero power returns identity.
      b = braidlab.braid([1 2 3],5);
      b0 = b^0;
      testCase.verifyTrue(isempty(b0.word));
      testCase.verifyEqual(b0.n,5);
    end

    function test_mpower_negative_multiple(testCase)
      % Test multiple negative powers.
      b = braidlab.braid([1],3);
      b_neg2 = b^(-2);
      expected = braidlab.braid([-1 -1],3);
      testCase.verifyTrue(lexeq(b_neg2,expected));
    end

    %% inv method tests

    function test_inv_basic(testCase)
      % Test basic inverse.
      testCase.verifyEqual(testCase.b1.inv,braidlab.braid([-5 -3 2 -1],7));
      testCase.verifyTrue(testCase.id.inv == testCase.id);
    end

    function test_inv_double_inverse(testCase)
      % Test that double inverse returns original.
      b = braidlab.braid([1 -2 3],5);
      testCase.verifyTrue(lexeq(b.inv.inv,b));
    end

    function test_inv_empty(testCase)
      % Test inverse of identity braid.
      b = braidlab.braid([],5);
      testCase.verifyTrue(isempty(b.inv.word));
      testCase.verifyEqual(b.inv.n,5);
    end

    %% perm method tests

    function test_perm_basic(testCase)
      % Test basic permutation.
      testCase.verifyEqual(testCase.b1.perm,[2 3 4 1 6 5 7]);
      testCase.verifyEqual(testCase.id.perm,1:7);
    end

    function test_perm_single_generator(testCase)
      % Test permutation of single generator.
      b = braidlab.braid([1],3);
      testCase.verifyEqual(b.perm,[2 1 3]);
    end

    function test_perm_negative_generator(testCase)
      % Test that negative generator gives same permutation as positive.
      b_pos = braidlab.braid([2],4);
      b_neg = braidlab.braid([-2],4);
      testCase.verifyEqual(b_pos.perm,b_neg.perm);
    end

    function test_perm_composition(testCase)
      % Test permutation composition.
      br1 = braidlab.braid([1],3);
      br2 = braidlab.braid([2],3);
      b12 = br1 * br2;
      % Compute expected permutation manually.
      % br1: [2 1 3], br2: [1 3 2].
      % Composition: apply br1 then br2.
      testCase.verifyEqual(b12.perm,[2 3 1]);
    end

    %% writhe method tests

    function test_writhe_basic(testCase)
      % Test basic writhe.
      testCase.verifyEqual(testCase.b1.writhe,2);
      testCase.verifyEqual(testCase.id.writhe,0);
    end

    function test_writhe_positive(testCase)
      % Test writhe of all positive generators.
      b = braidlab.braid([1 2 3],5);
      testCase.verifyEqual(b.writhe,3);
    end

    function test_writhe_negative(testCase)
      % Test writhe of all negative generators.
      b = braidlab.braid([-1 -2 -3],5);
      testCase.verifyEqual(b.writhe,-3);
    end

    function test_writhe_mixed(testCase)
      % Test writhe of mixed positive and negative generators.
      b = braidlab.braid([1 -1 2 -2 3],5);
      testCase.verifyEqual(b.writhe,1);
    end

    %% length method tests

    function test_length_basic(testCase)
      % Test basic length.
      testCase.verifyEqual(testCase.b1.length,4);
      testCase.verifyEqual(testCase.id.length,0);
    end

    function test_length_empty(testCase)
      % Test length of empty braid.
      b = braidlab.braid([],5);
      testCase.verifyEqual(length(b),0);
    end

    function test_length_single(testCase)
      % Test length of single generator.
      b = braidlab.braid([1],5);
      testCase.verifyEqual(length(b),1);
    end

    function test_length_multiple(testCase)
      % Test length of multiple generators.
      b = braidlab.braid([1 -2 3 -4 5],7);
      testCase.verifyEqual(length(b),5);
    end

    %% subbraid method tests

    function test_subbraid_basic(testCase)
      % Test basic subbraid.
      b = testCase.b3;
      bsub = braidlab.braid([3 1 -1],4);
      testCase.verifyEqual(b.subbraid(3:6),bsub);
      testCase.verifyTrue(lexeq(b.subbraid(3:6),bsub));
    end

    function test_subbraid_extraction(testCase)
      % Test basic subbraid extraction.
      b = braidlab.braid([1 2 3 4],6);
      bs = subbraid(b,[2 3 4]);
      testCase.verifyClass(bs,'braidlab.braid');
      testCase.verifyEqual(bs.n,3);
    end

    function test_subbraid_all_strings(testCase)
      % Test subbraid with all strings returns equivalent braid.
      b = braidlab.braid([1 2],4);
      bs = subbraid(b,1:4);
      testCase.verifyTrue(b == bs);
    end

    function test_subbraid_single_string(testCase)
      % Test subbraid with single string is trivial.
      b = braidlab.braid([1 2 3],5);
      bs = subbraid(b,[3]);
      testCase.verifyTrue(istrivial(bs));
      testCase.verifyEqual(bs.n,1);
    end

    function test_subbraid_nonadjacent(testCase)
      % Test subbraid with non-adjacent strings.
      b = braidlab.braid([1 3],5);
      bs = subbraid(b,[1 2 4 5]);
      testCase.verifyEqual(bs.n,4);
    end

    %% char method tests

    function test_char_nonempty(testCase)
      % Test char conversion for non-empty braid.
      b = braidlab.braid([1 -2 3]);
      str = char(b);
      testCase.verifyTrue(contains(str,'<'));
      testCase.verifyTrue(contains(str,'>'));
      testCase.verifyTrue(contains(str,'1'));
      testCase.verifyTrue(contains(str,'-2'));
      testCase.verifyTrue(contains(str,'3'));
    end

    function test_char_empty(testCase)
      % Test char conversion for identity braid.
      b = braidlab.braid([],5);
      str = char(b);
      testCase.verifyEqual(str,'< e >');
    end

    %% gencount method tests

    function test_gencount_basic(testCase)
      % Test basic generator counting.
      b = braidlab.braid([1 1 2 -1 -2 -2],4);
      [c,i] = gencount(b);
      % Generators are -3,-2,-1,1,2,3 for n=4.
      testCase.verifyEqual(length(c),6);
      testCase.verifyEqual(length(i),6);
      testCase.verifyEqual(sum(c),length(b));
    end

    function test_gencount_distribution(testCase)
      % Test that gencount returns correct distribution.
      b = braidlab.braid([1 1 1 -2 -2],4);
      [c,i] = gencount(b);
      % Find counts for specific generators.
      idx1 = find(i == 1);
      idx_neg2 = find(i == -2);
      testCase.verifyEqual(c(idx1),3);
      testCase.verifyEqual(c(idx_neg2),2);
    end

    function test_gencount_empty(testCase)
      % Test gencount on identity braid.
      b = braidlab.braid([],4);
      [c,i] = gencount(b);
      testCase.verifyEqual(sum(c),0);
      testCase.verifyEqual(length(i),6); % -3,-2,-1,1,2,3 for n=4.
    end

    %% tensor method tests

    function test_tensor_basic(testCase)
      % Test basic tensor product.
      br1 = braidlab.braid([1],3);
      br2 = braidlab.braid([1],3);
      c = tensor(br1,br2);
      testCase.verifyEqual(c.n,6);
      testCase.verifyEqual(c.word,int32([1 4]));
    end

    function test_tensor_preserves_order(testCase)
      % Test that tensor preserves order of braids.
      br1 = braidlab.braid([1 2],4);
      br2 = braidlab.braid([1],3);
      c = tensor(br1,br2);
      testCase.verifyEqual(c.n,7);
      % br1's generators unchanged, br2's generators shifted by br1.n.
      testCase.verifyEqual(c.word,int32([1 2 5]));
    end

    function test_tensor_identity(testCase)
      % Test tensor with identity braid.
      br1 = braidlab.braid([1 2],4);
      br2 = braidlab.braid([],3);
      c = tensor(br1,br2);
      testCase.verifyEqual(c.n,7);
      testCase.verifyEqual(c.word,int32([1 2]));
    end

    function test_tensor_multiple(testCase)
      % Test tensor product of three braids.
      br1 = braidlab.braid([1],2);
      br2 = braidlab.braid([1],2);
      br3 = braidlab.braid([1],2);
      c = tensor(br1,br2,br3);
      testCase.verifyEqual(c.n,6);
      testCase.verifyEqual(c.word,int32([1 3 5]));
    end

    function test_tensor_negative_generators(testCase)
      % Test tensor with negative generators.
      br1 = braidlab.braid([-1],3);
      br2 = braidlab.braid([-1 -2],4);
      c = tensor(br1,br2);
      testCase.verifyEqual(c.n,7);
      testCase.verifyEqual(c.word,int32([-1 -4 -5]));
    end

    %% burau method tests

    function test_burau_default(testCase)
      % Test Burau representation with default parameter.
      b = braidlab.braid([1],3);
      M = burau(b);
      testCase.verifyEqual(size(M),[2 2]);
    end

    function test_burau_identity(testCase)
      % Test Burau representation of identity braid.
      b = braidlab.braid([],4);
      M = burau(b);
      testCase.verifyEqual(M,eye(3));
    end

    function test_burau_abs_option(testCase)
      % Test Burau representation with Abs option.
      b = braidlab.braid([1 2],4);
      M = burau(b,'Abs');
      testCase.verifyTrue(all(M(:) >= 0));
    end

    function test_burau_numeric_parameter(testCase)
      % Test Burau representation with numeric parameter.
      b = braidlab.braid([1],3);
      t = exp(1i*pi/3);
      M = burau(b,t);
      testCase.verifyEqual(size(M),[2 2]);
    end

    %% alexpoly method tests

    function test_alexpoly_trefoil(testCase)
      % Test Alexander polynomial of trefoil knot.
      % Requires Wavelet Toolbox or Symbolic Toolbox.
      if ~exist('laurpoly','file') && ~license('test','Symbolic_Toolbox')
        return
      end
      b = braidlab.braid('3_1');
      p = alexpoly(b);
      testCase.verifyTrue(~isempty(p));
    end

    function test_alexpoly_unknot(testCase)
      % Test Alexander polynomial of unknot (trivial braid).
      % Requires Wavelet Toolbox or Symbolic Toolbox.
      if ~exist('laurpoly','file') && ~license('test','Symbolic_Toolbox')
        return
      end
      b = braidlab.braid([1 -1],2);
      p = alexpoly(b);
      testCase.verifyTrue(~isempty(p));
    end

    %% lk method tests

    function test_lk_basic(testCase)
      % Test basic Lawrence-Krammer representation.
      b = braidlab.braid([1],3);
      M = lk(b);
      % Matrix dimension is n*(n-1)/2 = 3*2/2 = 3.
      testCase.verifyEqual(size(M),[3 3]);
    end

    function test_lk_identity(testCase)
      % Test Lawrence-Krammer representation of identity.
      b = braidlab.braid([],4);
      M = lk(b);
      testCase.verifyEqual(size(M),[6 6]);
      testCase.verifyEqual(M,eye(6));
    end

    function test_lk_two_strings(testCase)
      % Test Lawrence-Krammer for 2-string braid.
      b = braidlab.braid([1 1],2);
      M = lk(b);
      testCase.verifyEqual(size(M),[1 1]);
    end

  end
end
