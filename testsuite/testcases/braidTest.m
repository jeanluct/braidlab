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

  %methods (TestClassSetup)
  %  function addbraidFolderToPath(testCase)
  %    testCase.addTeardown(@path, addpath(fullfile(pwd,'..')));
  %  end
  %end

  methods (TestMethodSetup)
    function createBraid(testCase)
      import braidlab.braid
      testCase.b1 = braid([1 -2 3 5],7);
      testCase.b2 = braid([1 2 4 6],7);
      testCase.b3 = braid([1 -2 3 5 2 1 2 -1 -2 -1],7);
      testCase.id = braid([],7);
      testCase.pure = braid([1 -2 1 -2 1 -2]);

      % trajectories with coincident coordinates
      % at the last time slice
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
    function test_braid_constructor(testCase)
      b = testCase.b1;
      testCase.verifyEqual(b.word,int32([1 -2 3 5]));
      testCase.verifyEqual(b.n,7);

      % Zero is not a valid generator value.
      testCase.verifyError(@() braidlab.braid([0 0 1]), ...
                           'BRAIDLAB:braid:setword:badarg');

      b = braidlab.braid('halftwist',5);
      testCase.verifyEqual(b.word,int32([4 3 2 1 4 3 2 4 3 4]));

      rng(1);
      b = braidlab.braid('random',5,7);
      testCase.verifyEqual(b,braidlab.braid([-2 2 -3 -2 -3 -1 -4]));

      testCase.verifyError(@() braidlab.braid('garbage'), ...
                           'BRAIDLAB:braid:braid:badarg');

      b = braidlab.braid('HironakaKin',3,1);
      testCase.verifyEqual(b,braidlab.braid([1 2 3 3 2 1 1 2 3 4]));

      testCase.verifyError(@() braidlab.braid('HironakaKin',4), ...
                           'BRAIDLAB:braid:braid:badarg');

      testCase.verifyError(@() braidlab.braid('VenzkePsi',4), ...
                           'BRAIDLAB:braid:braid:badarg');

      b = braidlab.braid('VenzkePsi',5);
      testCase.verifyEqual(b,braidlab.braid([4 3 2 1 4 3 2 1 -1 -2]));
      b = braidlab.braid('VenzkePsi',6);
      testCase.verifyEqual(b,braidlab.braid([5 4 3 2 1 5 4 3 5 4]));

      % Too many input arguments for creating a braid from data.
      testCase.verifyError(@() braidlab.braid(zeros(3,2,4),1,1), ...
                           'BRAIDLAB:braid:braid:badarg');

      % Creating a braid from a two-dimensional array is assumed to be a
      % single-particle dataset.  Print a warning, though.
      XY = [1 2;2 3;1 2];
      testCase.verifyWarning(@() braidlab.braid(XY), ...
                             'BRAIDLAB:braid:braid:onetraj');

      % However, if we cast the trajectory to complex, then assumed to be
      % two particles on the real axis in the complex plane.
      Z = complex(XY);
      testCase.verifyWarningFree(@() braidlab.braid(Z));
      testCase.verifyEqual(braidlab.braid(Z).n,2);

      % Two particles have a coincident position.
      XY = zeros(4,2,2);
      testCase.verifyError(@() braidlab.braid(XY), ...
                           'BRAIDLAB:braid:colorbraiding:coincidentparticles');
      % Now they only coincide in the default projection.
      XY(:,2,2) = 2;
      testCase.verifyError(@() braidlab.braid(XY), ...
                           'BRAIDLAB:braid:colorbraiding:coincidentprojection');
      % Changing the projection gets rid of the error.
      testCase.verifyTrue(braidlab.braid(XY,.1) == ...
                          braidlab.braid([],2));

      % Coincidence at the end of interval - see GitHub Iss #109.
      testCase.verifyError(@() braidlab.braid(testCase.XYcoincend), ...
                           'BRAIDLAB:braid:colorbraiding:coincidentprojection');
    end

    function test_braid_equal(testCase)
      testCase.verifyTrue(testCase.b1 == testCase.b3);
      testCase.verifyFalse(testCase.b1 ~= testCase.b3);
      testCase.verifyTrue(testCase.id == braidlab.braid([1 -1],7));
    end

    function test_braid_lexequal(testCase)
      testCase.verifyTrue(testCase.b1 == testCase.b1);
      testCase.verifyFalse(testCase.b1 ~= testCase.b1);
    end

    function test_braid_istrivial(testCase)
      testCase.verifyFalse(istrivial(testCase.b1));
      testCase.verifyTrue(istrivial(testCase.id));
    end

    function test_braid_ispure(testCase)
      testCase.verifyFalse(ispure(testCase.b1));
      testCase.verifyTrue(ispure(testCase.pure));
      testCase.verifyTrue(ispure(testCase.id));
    end

    function test_braid_mtimes(testCase)
      b = testCase.b1*testCase.b2;
      testCase.verifyEqual(b,braidlab.braid([1 -2 3 5 1 2 4 6]));
    end

    function test_braid_mpower(testCase)
      b = testCase.b1^3;
      testCase.verifyEqual(b,braidlab.braid([1 -2 3 5 1 -2 3 5 1 -2 3 5],7));
    end

    function test_braid_inv(testCase)
      testCase.verifyEqual(testCase.b1.inv,braidlab.braid([-5 -3 2 -1],7));
      testCase.verifyTrue(testCase.id.inv == testCase.id);
    end

    function test_braid_perm(testCase)
      testCase.verifyEqual(testCase.b1.perm,[2 3 4 1 6 5 7]);
      testCase.verifyEqual(testCase.id.perm,1:7);
    end

    function test_braid_writhe(testCase)
      testCase.verifyEqual(testCase.b1.writhe,2);
      testCase.verifyEqual(testCase.id.writhe,0);
    end

    function test_braid_length(testCase)
      testCase.verifyEqual(testCase.b1.length,4);
      testCase.verifyEqual(testCase.id.length,0);
    end

    function test_braid_subbraid(testCase)
      b = testCase.b3;
      bsub = braidlab.braid([3 1 -1],4);
      testCase.verifyEqual(b.subbraid(3:6),bsub);
      testCase.verifyTrue(lexeq(b.subbraid(3:6),bsub));
    end

    %% Edge cases for string count

    function test_braid_min_string_count(testCase)
      % Test minimum non-trivial braid group (n=2).
      b = braidlab.braid([1 -1 1],2);
      testCase.verifyEqual(b.n,2);
      testCase.verifyEqual(b.word,int32([1 -1 1]));
    end

    function test_braid_copy_and_change_n(testCase)
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

    function test_braid_explicit_n_matches_generator_max(testCase)
      % Test that explicit n matches or exceeds max absolute generator.
      br1 = braidlab.braid([1 2 3],5);
      testCase.verifyEqual(br1.n,5);

      br2 = braidlab.braid([1 2 3]);
      testCase.verifyEqual(br2.n,4); % max(abs([1 2 3]))+1 = 4
    end

    %% Empty and trivial braids

    function test_braid_default_empty_constructor(testCase)
      % Test default empty constructor returns trivial braid with n=1.
      b = braidlab.braid();
      testCase.verifyEqual(b.n,1);
      testCase.verifyTrue(isempty(b.word));
      testCase.verifyTrue(istrivial(b));
    end

    function test_braid_empty_word_various_n(testCase)
      % Test empty braid with different string counts.
      for n = 2:5
        b = braidlab.braid([],n);
        testCase.verifyEqual(b.n,n);
        testCase.verifyTrue(isempty(b.word));
        testCase.verifyTrue(istrivial(b));
      end
    end

    function test_braid_trivial_from_cancelling_generators(testCase)
      % Test that equal and opposite generators reduce trivially.
      b = braidlab.braid([1 -1 1 -1],3);
      testCase.verifyTrue(istrivial(b));
    end

    %% Special named braids

    function test_braid_fulltwist(testCase)
      % Test FullTwist/Delta2 with various string counts.
      for n = 3:5
        b = braidlab.braid('FullTwist',n);
        d = braidlab.braid('HalfTwist',n);
        expected = braidlab.braid([d.word d.word]);
        testCase.verifyEqual(b,expected);
      end
    end

    function test_braid_halftwist_properties(testCase)
      % Test HalfTwist/Delta properties.
      b = braidlab.braid('HalfTwist',5);
      % Half-twist should have n*(n-1)/2 generators.
      testCase.verifyEqual(length(b.word),5*4/2);

      % Half-twist is positive (all generators positive).
      testCase.verifyTrue(all(b.word > 0));
    end

    function test_braid_hironakakin_explicit_params(testCase)
      % Test HironakaKin with explicit M,N parameters.
      b = braidlab.braid('HironakaKin',2,3);
      testCase.verifyEqual(b.n,6); % m+n+1 = 2+3+1 = 6.

      b = braidlab.braid('HK',1,2);  % Test alternate name.
      testCase.verifyEqual(b.n,4);
    end

    function test_braid_hironakakin_implicit_params(testCase)
      % Test HironakaKin with implicit parameters (odd/even cases).
      b_odd = braidlab.braid('HironakaKin',7);
      % For odd n=7: m=(7-3)/2=2, n=(7+1)/2=4, total strings = 2+4+1 = 7.
      testCase.verifyEqual(b_odd.n,7);

      b_even = braidlab.braid('HironakaKin',6);
      % For even n=6: m=(6+2)/2=4, n=(6-4)/2=1, total strings = 4+1+1 = 6.
      testCase.verifyEqual(b_even.n,6);
    end

    function test_braid_venzkepsi_special_cases(testCase)
      % Test VenzkePsi for special case n=6.
      b = braidlab.braid('VenzkePsi',6);
      testCase.verifyEqual(b,braidlab.braid([5 4 3 2 1 5 4 3 5 4]));

      % Test Psi alias.
      b_alias = braidlab.braid('Psi',6);
      testCase.verifyEqual(b,b_alias);
    end

    function test_braid_venzkepsi_various_n(testCase)
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

    function test_braid_copy_braid(testCase)
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

    %% Data input validation

    function test_braid_from_complex_trajectory(testCase)
      % Test complex trajectory input (particles on complex plane).
      Z = [1+2i 2+3i; 2+1i 3+2i; 1+2i 2+3i];
      b = braidlab.braid(Z);
      testCase.verifyEqual(b.n,2);
      testCase.verifyClass(b,'braidlab.braid');
    end

    function test_braid_trajectory_projection_angles(testCase)
      % Test trajectory construction with different projection angles.
      % Create non-coincident trajectories.
      XY = zeros(4,2,2);
      XY(:,:,1) = [0 0; 1 0.5; 1.5 1; 0 0];
      XY(:,:,2) = [0.5 0; 1.5 0.5; 2 1; 0.5 0];

      % Test different projection angles (skip pi/2 as it may create
      % coincidence).
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

    function test_braid_trajectory_invalid_projection(testCase)
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

    function test_braid_trajectory_with_nans(testCase)
      % Test that trajectory with NaN values errors.
      XY = zeros(3,2,2);
      XY(:,:,1) = [0 0; 1 1; 0 0];
      XY(:,:,2) = [1 0; NaN 1; 1 0];

      testCase.verifyError(@() braidlab.braid(XY), ...
                           'MATLAB:BRAIDLAB:braid:expectedFinite');
    end

    function test_braid_trajectory_with_infs(testCase)
      % Test that trajectory with Inf values errors.
      XY = zeros(3,2,2);
      XY(:,:,1) = [0 0; 1 1; 0 0];
      XY(:,:,2) = [1 0; Inf 1; 1 0];

      testCase.verifyError(@() braidlab.braid(XY), ...
                           'MATLAB:BRAIDLAB:braid:expectedFinite');
    end

    function test_braid_3d_trajectory_from_complex(testCase)
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

    % Knot representation
    function test_braid_from_knot_codes(testCase)
      % Test creating braids from various knot codes.
      knot_codes = {'3_1', '5_2', '7_1'};

      for k = 1:length(knot_codes)
        b = braidlab.braid(knot_codes{k});
        testCase.verifyClass(b,'braidlab.braid');
        testCase.verifyTrue(~isempty(b.word));
      end
    end

    function test_braid_from_invalid_knot_code(testCase)
      % Test that invalid knot codes error.
      testCase.verifyError(@() braidlab.braid('99_99'), ...
                           'BRAIDLAB:braid:braid:badarg');
      testCase.verifyError(@() braidlab.braid('invalid'), ...
                           'BRAIDLAB:braid:braid:badarg');
    end

    function test_braid_small_knots(testCase)
      % Test that small knots can be constructed.
      b_trefoil = braidlab.braid('3_1');
      testCase.verifyGreaterThan(length(b_trefoil.word),0);

      b_figure8 = braidlab.braid('4_1');
      testCase.verifyGreaterThan(length(b_figure8.word),0);

      % Verify they are different knots.
      testCase.verifyNotEqual(b_trefoil,b_figure8);
    end

    % Generator range constraints
    function test_braid_generators_within_bounds(testCase)
      % Test that generators are correctly bounded by n.
      b = braidlab.braid([1 2 3 4],6);

      % All generators should satisfy -n < g < n.
      testCase.verifyTrue(all(abs(b.word) < b.n));
    end

    function test_braid_negative_generators(testCase)
      % Test that negative generators are properly handled.
      b = braidlab.braid([-1 -2 -3],5);

      testCase.verifyTrue(all(b.word < 0));
      testCase.verifyTrue(all(abs(b.word) < b.n));
    end

    function test_braid_max_generator_determines_n(testCase)
      % Test that max generator determines minimum n.
      b = braidlab.braid([1 3 2 -3],5);

      % n should be at least max(abs(word))+1 = 4.
      testCase.verifyGreaterThanOrEqual(b.n,4);
    end

    function test_braid_boundary_generators(testCase)
      % Test generators at boundary |g| = n-1.
      b = braidlab.braid([4 -4 3 -3],5);

      % Max absolute value is 4, so n must be at least 5.
      testCase.verifyEqual(b.n,5);

      % All generators should be valid.
      testCase.verifyTrue(all(abs(b.word) <= b.n-1));
    end

    function test_braid_too_many_strings_for_generators_error(testCase)
      % Test that setting n too small for existing generators fails.
      b = braidlab.braid([1 2 3],5);

      % Try to set n smaller than max(abs(word))+1.
      testCase.verifyError(@() setfield(b,'n',2), ...
                           'BRAIDLAB:braid:setn:badarg');
    end

    function test_braid_generator_at_boundary(testCase)
      % Test generators exactly at boundary (n-1).
      for n = 3:7
        % Create generators [1, 2, ..., n-1, -(n-1)].
        gens = [1:n-1 -(n-1)];
        b = braidlab.braid(gens,n);

        testCase.verifyEqual(b.n,n);
        testCase.verifyTrue(all(abs(b.word) <= n-1));
      end
    end

    %% Data type verification

    function test_braid_word_always_int32_from_double(testCase)
      % Test that word is converted to int32 from double input.
      b = braidlab.braid([1.0 2.0 3.0]);
      testCase.verifyClass(b.word,'int32');
      testCase.verifyEqual(b.word,int32([1 2 3]));
    end

    function test_braid_word_always_int32_from_single(testCase)
      % Test that word is converted to int32 from single input.
      b = braidlab.braid(single([1 2 3]));
      testCase.verifyClass(b.word,'int32');
      testCase.verifyEqual(b.word,int32([1 2 3]));
    end

    function test_braid_word_always_int32_from_int64(testCase)
      % Test that word is converted to int32 from int64 input.
      b = braidlab.braid(int64([1 2 3]));
      testCase.verifyClass(b.word,'int32');
      testCase.verifyEqual(b.word,int32([1 2 3]));
    end

    function test_braid_word_already_int32(testCase)
      % Test that int32 input remains int32.
      input_word = int32([1 -2 3 -4]);
      b = braidlab.braid(input_word);
      testCase.verifyClass(b.word,'int32');
      testCase.verifyEqual(b.word,input_word);
    end

    function test_braid_empty_word_is_int32(testCase)
      % Test that empty word is int32.
      b = braidlab.braid([],5);
      testCase.verifyClass(b.word,'int32');
      testCase.verifyTrue(isempty(b.word));
    end

    function test_braid_large_word_int32_conversion(testCase)
      % Test that large word values are converted to int32.
      % int32 range is approximately -2.1e9 to 2.1e9.
      b = braidlab.braid([100 -100 50],150);
      testCase.verifyClass(b.word,'int32');
      testCase.verifyEqual(b.word,int32([100 -100 50]));
    end

    function test_braid_special_named_word_is_int32(testCase)
      % Test that special named braids create int32 word.
      br1 = braidlab.braid('HalfTwist',5);
      testCase.verifyClass(br1.word,'int32');

      br2 = braidlab.braid('Random',6,10);
      testCase.verifyClass(br2.word,'int32');

      br3 = braidlab.braid('VenzkePsi',6);
      testCase.verifyClass(br3.word,'int32');
    end

    function test_braid_trajectory_word_is_int32(testCase)
      % Test that braid from trajectory creates int32 word.
      XY = zeros(2,2,2);
      XY(1,:,:) = [0 0; 1 0].';
      XY(2,:,:) = [0 0; 1 0].';

      b = braidlab.braid(braidlab.closure(XY));
      testCase.verifyClass(b.word,'int32');
    end

    function test_braid_copy_preserves_int32(testCase)
      % Test that copying a braid preserves int32 type.
      br1 = braidlab.braid([1 2 3]);
      br2 = braidlab.braid(br1);

      testCase.verifyClass(br1.word,'int32');
      testCase.verifyClass(br2.word,'int32');
    end

    %% char method tests

    function test_braid_char_nonempty(testCase)
      % Test char conversion for non-empty braid.
      b = braidlab.braid([1 -2 3]);
      str = char(b);
      testCase.verifyTrue(contains(str,'<'));
      testCase.verifyTrue(contains(str,'>'));
      testCase.verifyTrue(contains(str,'1'));
      testCase.verifyTrue(contains(str,'-2'));
      testCase.verifyTrue(contains(str,'3'));
    end

    function test_braid_char_empty(testCase)
      % Test char conversion for identity braid.
      b = braidlab.braid([],5);
      str = char(b);
      testCase.verifyEqual(str,'< e >');
    end

    %% gencount method tests

    function test_braid_gencount_basic(testCase)
      % Test basic generator counting.
      b = braidlab.braid([1 1 2 -1 -2 -2],4);
      [c,i] = gencount(b);
      % Generators are -3,-2,-1,1,2,3 for n=4.
      testCase.verifyEqual(length(c),6);
      testCase.verifyEqual(length(i),6);
      testCase.verifyEqual(sum(c),length(b));
    end

    function test_braid_gencount_distribution(testCase)
      % Test that gencount returns correct distribution.
      b = braidlab.braid([1 1 1 -2 -2],4);
      [c,i] = gencount(b);
      % Find counts for specific generators.
      idx1 = find(i == 1);
      idx_neg2 = find(i == -2);
      testCase.verifyEqual(c(idx1),3);
      testCase.verifyEqual(c(idx_neg2),2);
    end

    function test_braid_gencount_empty(testCase)
      % Test gencount on identity braid.
      b = braidlab.braid([],4);
      [c,i] = gencount(b);
      testCase.verifyEqual(sum(c),0);
      testCase.verifyEqual(length(i),6); % -3,-2,-1,1,2,3 for n=4.
    end

    %% lexeq method tests

    function test_braid_lexeq_identical(testCase)
      % Test lexeq on identical braids.
      b = braidlab.braid([1 2 3],5);
      testCase.verifyTrue(lexeq(b,b));
    end

    function test_braid_lexeq_different_word_same_braid(testCase)
      % Test lexeq on equivalent but lexically different braids.
      b1 = braidlab.braid([1 -1 2],4);
      b2 = braidlab.braid([2],4);
      % They are equal as braids.
      testCase.verifyTrue(b1 == b2);
      % But not lexically equal.
      testCase.verifyFalse(lexeq(b1,b2));
    end

    function test_braid_lexeq_different_n(testCase)
      % Test lexeq on braids with different n.
      b1 = braidlab.braid([1 2],4);
      b2 = braidlab.braid([1 2],5);
      testCase.verifyFalse(lexeq(b1,b2));
    end

    %% mpower method tests

    function test_braid_mpower_negative(testCase)
      % Test negative powers.
      b = braidlab.braid([1 2],4);
      b_inv = b^(-1);
      testCase.verifyEqual(b_inv,b.inv);
      testCase.verifyTrue((b * b_inv) == braidlab.braid([],4));
    end

    function test_braid_mpower_zero(testCase)
      % Test zero power returns identity.
      b = braidlab.braid([1 2 3],5);
      b0 = b^0;
      testCase.verifyTrue(isempty(b0.word));
      testCase.verifyEqual(b0.n,5);
    end

    function test_braid_mpower_negative_multiple(testCase)
      % Test multiple negative powers.
      b = braidlab.braid([1],3);
      b_neg2 = b^(-2);
      expected = braidlab.braid([-1 -1],3);
      testCase.verifyTrue(lexeq(b_neg2,expected));
    end

    %% inv method tests

    function test_braid_inv_double_inverse(testCase)
      % Test that double inverse returns original.
      b = braidlab.braid([1 -2 3],5);
      testCase.verifyTrue(lexeq(b.inv.inv,b));
    end

    function test_braid_inv_empty(testCase)
      % Test inverse of identity braid.
      b = braidlab.braid([],5);
      testCase.verifyTrue(isempty(b.inv.word));
      testCase.verifyEqual(b.inv.n,5);
    end

    %% perm method tests

    function test_braid_perm_single_generator(testCase)
      % Test permutation of single generator.
      b = braidlab.braid([1],3);
      testCase.verifyEqual(b.perm,[2 1 3]);
    end

    function test_braid_perm_negative_generator(testCase)
      % Test that negative generator gives same permutation as positive.
      b_pos = braidlab.braid([2],4);
      b_neg = braidlab.braid([-2],4);
      testCase.verifyEqual(b_pos.perm,b_neg.perm);
    end

    function test_braid_perm_composition(testCase)
      % Test permutation composition.
      b1 = braidlab.braid([1],3);
      b2 = braidlab.braid([2],3);
      b12 = b1 * b2;
      % Compute expected permutation manually.
      % b1: [2 1 3], b2: [1 3 2].
      % Composition: apply b1 then b2.
      testCase.verifyEqual(b12.perm,[2 3 1]);
    end

    %% writhe method tests

    function test_braid_writhe_positive(testCase)
      % Test writhe of all positive generators.
      b = braidlab.braid([1 2 3],5);
      testCase.verifyEqual(b.writhe,3);
    end

    function test_braid_writhe_negative(testCase)
      % Test writhe of all negative generators.
      b = braidlab.braid([-1 -2 -3],5);
      testCase.verifyEqual(b.writhe,-3);
    end

    function test_braid_writhe_mixed(testCase)
      % Test writhe of mixed positive and negative generators.
      b = braidlab.braid([1 -1 2 -2 3],5);
      testCase.verifyEqual(b.writhe,1);
    end

    %% eq and ne method tests

    function test_braid_eq_different_n_same_word(testCase)
      % Test equality of braids with same word but different n.
      b1 = braidlab.braid([1 2],4);
      b2 = braidlab.braid([1 2],5);
      testCase.verifyFalse(b1 == b2);
      testCase.verifyTrue(b1 ~= b2);
    end

    function test_braid_eq_empty_braids(testCase)
      % Test equality of two identity braids.
      b1 = braidlab.braid([],5);
      b2 = braidlab.braid([],5);
      testCase.verifyTrue(b1 == b2);
    end

    function test_braid_eq_identity_vs_cancelling(testCase)
      % Test that cancelling generators equal identity.
      b1 = braidlab.braid([],4);
      b2 = braidlab.braid([1 -1],4);
      testCase.verifyTrue(b1 == b2);
    end

    %% set.n validation tests

    function test_braid_set_n_valid_increase(testCase)
      % Test increasing n to valid value.
      b = braidlab.braid([1 2],4);
      b.n = 10;
      testCase.verifyEqual(b.n,10);
    end

    function test_braid_set_n_invalid_decrease(testCase)
      % Test decreasing n below minimum required errors.
      b = braidlab.braid([1 2 3],5);
      testCase.verifyError(@() setfield(b,'n',3), ...
                           'BRAIDLAB:braid:setn:badarg');
    end

    %% Normal distribution braid constructor

    function test_braid_normal_distribution(testCase)
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

    %% FullTwist constructor

    function test_braid_fulltwist_equals_halftwist_squared(testCase)
      % Test FullTwist is square of HalfTwist.
      n = 5;
      ft = braidlab.braid('FullTwist',n);
      ht = braidlab.braid('HalfTwist',n);
      expected = ht^2;
      testCase.verifyTrue(lexeq(ft,expected));
    end

    %% Copy constructor preserves n

    function test_braid_copy_preserves_n(testCase)
      % Test that copy constructor preserves n.
      br1 = braidlab.braid([1],10);
      br2 = braidlab.braid(br1);
      testCase.verifyEqual(br2.n,10);
    end

    %% tensor method tests

    function test_braid_tensor_basic(testCase)
      % Test basic tensor product.
      br1 = braidlab.braid([1],3);
      br2 = braidlab.braid([1],3);
      c = tensor(br1,br2);
      testCase.verifyEqual(c.n,6);
      testCase.verifyEqual(c.word,int32([1 4]));
    end

    function test_braid_tensor_preserves_order(testCase)
      % Test that tensor preserves order of braids.
      br1 = braidlab.braid([1 2],4);
      br2 = braidlab.braid([1],3);
      c = tensor(br1,br2);
      testCase.verifyEqual(c.n,7);
      % br1's generators unchanged, br2's generators shifted by br1.n.
      testCase.verifyEqual(c.word,int32([1 2 5]));
    end

    function test_braid_tensor_identity(testCase)
      % Test tensor with identity braid.
      br1 = braidlab.braid([1 2],4);
      br2 = braidlab.braid([],3);
      c = tensor(br1,br2);
      testCase.verifyEqual(c.n,7);
      testCase.verifyEqual(c.word,int32([1 2]));
    end

    function test_braid_tensor_multiple(testCase)
      % Test tensor product of three braids.
      br1 = braidlab.braid([1],2);
      br2 = braidlab.braid([1],2);
      br3 = braidlab.braid([1],2);
      c = tensor(br1,br2,br3);
      testCase.verifyEqual(c.n,6);
      testCase.verifyEqual(c.word,int32([1 3 5]));
    end

    function test_braid_tensor_negative_generators(testCase)
      % Test tensor with negative generators.
      br1 = braidlab.braid([-1],3);
      br2 = braidlab.braid([-1 -2],4);
      c = tensor(br1,br2);
      testCase.verifyEqual(c.n,7);
      testCase.verifyEqual(c.word,int32([-1 -4 -5]));
    end

    %% burau method tests

    function test_braid_burau_default(testCase)
      % Test Burau representation with default parameter.
      b = braidlab.braid([1],3);
      M = burau(b);
      testCase.verifyEqual(size(M),[2 2]);
    end

    function test_braid_burau_identity(testCase)
      % Test Burau representation of identity braid.
      b = braidlab.braid([],4);
      M = burau(b);
      testCase.verifyEqual(M,eye(3));
    end

    function test_braid_burau_abs_option(testCase)
      % Test Burau representation with Abs option.
      b = braidlab.braid([1 2],4);
      M = burau(b,'Abs');
      testCase.verifyTrue(all(M(:) >= 0));
    end

    function test_braid_burau_numeric_parameter(testCase)
      % Test Burau representation with numeric parameter.
      b = braidlab.braid([1],3);
      t = exp(1i*pi/3);
      M = burau(b,t);
      testCase.verifyEqual(size(M),[2 2]);
    end

    %% alexpoly method tests

    function test_braid_alexpoly_trefoil(testCase)
      % Test Alexander polynomial of trefoil knot.
      % Requires Wavelet Toolbox or Symbolic Toolbox.
      if ~exist('laurpoly','file') && ~license('test','Symbolic_Toolbox')
        return
      end
      b = braidlab.braid('3_1');
      p = alexpoly(b);
      testCase.verifyTrue(~isempty(p));
    end

    function test_braid_alexpoly_unknot(testCase)
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

    function test_braid_lk_basic(testCase)
      % Test basic Lawrence-Krammer representation.
      b = braidlab.braid([1],3);
      M = lk(b);
      % Matrix dimension is n*(n-1)/2 = 3*2/2 = 3.
      testCase.verifyEqual(size(M),[3 3]);
    end

    function test_braid_lk_identity(testCase)
      % Test Lawrence-Krammer representation of identity.
      b = braidlab.braid([],4);
      M = lk(b);
      testCase.verifyEqual(size(M),[6 6]);
      testCase.verifyEqual(M,eye(6));
    end

    function test_braid_lk_two_strings(testCase)
      % Test Lawrence-Krammer for 2-string braid.
      b = braidlab.braid([1 1],2);
      M = lk(b);
      testCase.verifyEqual(size(M),[1 1]);
    end

    %% subbraid method tests

    function test_braid_subbraid_basic(testCase)
      % Test basic subbraid extraction.
      b = braidlab.braid([1 2 3 4],6);
      bs = subbraid(b,[2 3 4]);
      testCase.verifyClass(bs,'braidlab.braid');
      testCase.verifyEqual(bs.n,3);
    end

    function test_braid_subbraid_all_strings(testCase)
      % Test subbraid with all strings returns equivalent braid.
      b = braidlab.braid([1 2],4);
      bs = subbraid(b,1:4);
      testCase.verifyTrue(b == bs);
    end

    function test_braid_subbraid_single_string(testCase)
      % Test subbraid with single string is trivial.
      b = braidlab.braid([1 2 3],5);
      bs = subbraid(b,[3]);
      testCase.verifyTrue(istrivial(bs));
      testCase.verifyEqual(bs.n,1);
    end

    function test_braid_subbraid_nonadjacent(testCase)
      % Test subbraid with non-adjacent strings.
      b = braidlab.braid([1 3],5);
      bs = subbraid(b,[1 2 4 5]);
      testCase.verifyEqual(bs.n,4);
    end

    %% mtimes additional tests

    function test_braid_mtimes_identity_left(testCase)
      % Test multiplying identity on left.
      id = braidlab.braid([],4);
      b = braidlab.braid([1 2],4);
      c = id * b;
      testCase.verifyTrue(lexeq(c,b));
    end

    function test_braid_mtimes_identity_right(testCase)
      % Test multiplying identity on right.
      id = braidlab.braid([],4);
      b = braidlab.braid([1 2],4);
      c = b * id;
      testCase.verifyTrue(lexeq(c,b));
    end

    function test_braid_mtimes_inverse(testCase)
      % Test that b * inv(b) is trivial.
      b = braidlab.braid([1 2 -3],5);
      c = b * b.inv;
      testCase.verifyTrue(istrivial(c));
    end

    function test_braid_mtimes_associative(testCase)
      % Test associativity of multiplication.
      br1 = braidlab.braid([1],4);
      br2 = braidlab.braid([2],4);
      br3 = braidlab.braid([3],4);
      left = (br1 * br2) * br3;
      right = br1 * (br2 * br3);
      testCase.verifyTrue(left == right);
    end

    %% length method tests

    function test_braid_length_empty(testCase)
      % Test length of empty braid.
      b = braidlab.braid([],5);
      testCase.verifyEqual(length(b),0);
    end

    function test_braid_length_single(testCase)
      % Test length of single generator.
      b = braidlab.braid([1],5);
      testCase.verifyEqual(length(b),1);
    end

    function test_braid_length_multiple(testCase)
      % Test length of multiple generators.
      b = braidlab.braid([1 -2 3 -4 5],7);
      testCase.verifyEqual(length(b),5);
    end

    %% istrivial additional tests

    function test_braid_istrivial_complex_reduction(testCase)
      % Test istrivial on complex reducible braid.
      b = braidlab.braid([1 2 -2 -1],4);
      testCase.verifyTrue(istrivial(b));
    end

    function test_braid_istrivial_far_commuting(testCase)
      % Test braid with far commuting generators.
      b = braidlab.braid([1 3 -1 -3],5);
      testCase.verifyTrue(istrivial(b));
    end

    %% ispure additional tests

    function test_braid_ispure_sigma_squared(testCase)
      % Test that sigma_i^2 is pure.
      b = braidlab.braid([1 1],3);
      testCase.verifyTrue(ispure(b));
    end

    function test_braid_ispure_commutator(testCase)
      % Test that squared commutator-like braid is pure.
      % A braid is pure if its permutation is the identity.
      b = braidlab.braid([1 1 2 2 -1 -1 -2 -2],4);
      testCase.verifyTrue(ispure(b));
    end
  end
end
