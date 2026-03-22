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

% Note: this testsuite will work with or without GMP compiled, but runs at
% least 10 times slower without it.

classdef cycleTest < matlab.unittest.TestCase

  methods (Test)

    %% Basic tests

    function test_basic_output(testCase)
      % Test basic cycle computation returns expected outputs.
      br = braidlab.braid([1 2], 3);
      [M, period, it] = cycle(br);
      testCase.verifyTrue(issparse(M) || isnumeric(M));
      testCase.verifyGreaterThan(period, 0);
      testCase.verifyGreaterThan(it, 0);
    end

    function test_basic_period(testCase)
      % Test that cycle returns positive integer period.
      br = braidlab.braid([1 2], 3);
      [~, period] = cycle(br);
      testCase.verifyTrue(isnumeric(period));
      testCase.verifyGreaterThan(period, 0);
    end

    %% Period tests

    function test_period_b1(testCase)
      % Test period for braid [1 2].
      br = braidlab.braid([1 2]);
      [~, period] = cycle(br);
      testCase.verifyEqual(period, 3);
    end

    function test_period_b2(testCase)
      % Test period for braid [1 2 3].
      br = braidlab.braid([1 2 3]);
      [~, period] = cycle(br);
      testCase.verifyEqual(period, 4);
    end

    function test_period_tensor(testCase)
      % Test period for tensor product is product of periods.
      br1 = braidlab.braid([1 2]);
      br2 = braidlab.braid([1 2 3]);
      [~, period] = cycle(tensor(br1, br2));
      testCase.verifyEqual(period, 3*4);
    end

    function test_period_psi12(testCase)
      % Test period for psi(12) braid.
      br = braidlab.braid('psi', 12);
      [~, period] = cycle(br);
      testCase.verifyEqual(period, 5);
    end

    %% Iteration count tests

    function test_iterations_b1(testCase)
      % Test iteration count for braid [1 2].
      br = braidlab.braid([1 2]);
      [~, ~, it] = cycle(br);
      testCase.verifyEqual(it, 20);
    end

    function test_iterations_b2(testCase)
      % Test iteration count for braid [1 2 3].
      br = braidlab.braid([1 2 3]);
      [~, ~, it] = cycle(br);
      testCase.verifyEqual(it, 26);
    end

    function test_iterations_tensor(testCase)
      % Test iteration count for tensor product.
      br1 = braidlab.braid([1 2]);
      br2 = braidlab.braid([1 2 3]);
      [~, ~, it] = cycle(tensor(br1, br2));
      testCase.verifyEqual(it, 74);
    end

    function test_iterations_psi12(testCase)
      % Test iteration count for psi(12) braid.
      br = braidlab.braid('psi', 12);
      [~, ~, it] = cycle(br);
      testCase.verifyEqual(it, 44);
    end

    %% Initial loop tests

    function test_initialloop_specifiedloop(testCase)
      % Specify initial loop.
      br = braidlab.braid([1 2 3]);
      [~, period] = cycle(br, braidlab.loop([1 2 3 4 5 6]));
      testCase.verifyEqual(period, 4);
    end

    %% Convergence parameter tests

    function test_convergence_moreconvergences(testCase)
      % Request more consecutive convergences (10).
      br = braidlab.braid([1 2]);
      [M1] = cycle(br);
      [M1b, ~, it] = cycle(br, [], 10);
      testCase.verifyEqual(M1, M1b);
      testCase.verifyEqual(it, 35);
    end

    %% Matrix output tests

    function test_matrix_b1(testCase)
      % Verify one matrix in the cycle for braid [1 2].
      br = braidlab.braid([1 2]);
      M1it = cycle(br, 'iter');
      expected = [0 0 -1 0; 0 1 0 0; 1 -1 -1 0; 0 1 1 1];
      testCase.verifyEqual(full(M1it{1}), expected);
    end

    function test_matrix_b1_product(testCase)
      % Check the product of matrices in cycle equals full matrix.
      br = braidlab.braid([1 2]);
      [M1] = cycle(br);
      M1it = cycle(br, 'iter');
      testCase.verifyEqual(M1it{3}*M1it{2}*M1it{1}, M1);
    end

    function test_matrix_b2(testCase)
      % Verify the matrix for full cycle of braid [1 2 3].
      br = braidlab.braid([1 2 3]);
      [M2] = cycle(br);
      expected = [
          0    -1     1     0     1     0
          1     0     1     0     1     0
          0     0     1     0     0     0
          0     1    -1     1    -1     0
          1     0     0     0     1     0
          0    -1     3     0     1     1];
      testCase.verifyEqual(full(M2), expected);
    end

    function test_matrix_b2_product(testCase)
      % Verify product of iterate matrices equals full matrix.
      br = braidlab.braid([1 2 3]);
      [M2] = cycle(br);
      M2it = cycle(br, 'iter');
      testCase.verifyEqual(full(M2it{4}*M2it{3}*M2it{2}*M2it{1}), full(M2));
    end

    %% Characteristic polynomial tests

    function test_charpoly_psi12(testCase)
      % Verify characteristic polynomial for psi(12).
      br = braidlab.braid('psi', 12);
      [M] = cycle(br);
      expected = [1 -13 73 -231 450 -552 416 -209 221 -489 783 ...
                  -900 783 -489 221 -209 416 -552 450 -231 73 -13 1];
      testCase.verifyEqual(charpoly(M), expected);
    end

    %% Iterates option tests

    function test_iterates_cellarray(testCase)
      % Test cycle with Iterates option returns cell array.
      br = braidlab.braid([1 2], 3);
      MI = cycle(br, 'Iterates');
      testCase.verifyTrue(iscell(MI));
      testCase.verifyGreaterThan(length(MI), 0);
    end

    function test_iterates_iter(testCase)
      % Test cycle with 'iter' abbreviation.
      br = braidlab.braid([1 2], 3);
      MI = cycle(br, 'iter');
      testCase.verifyTrue(iscell(MI));
    end

    %% Error and warning tests

    function test_error_noconv(testCase)
      % Request too many consecutive convergences for iterations.
      br = braidlab.braid([1 2 3]);
      testCase.verifyError(@() cycle(br, 12, 3), ...
                           'BRAIDLAB:braid:cycle:noconv');
    end

    function test_error_badarg(testCase)
      % Unknown flag.
      br = braidlab.braid([1 2 3]);
      testCase.verifyError(@() cycle(br, 'garbage'), ...
                           'BRAIDLAB:braid:cycle:badarg');
    end

    function test_warning_longcycle(testCase)
      % Too few maxit for known cycle bound.
      testCase.verifyWarning(@() cycle(braidlab.braid([1 2], 17)), ...
                             'BRAIDLAB:braid:cycle:longcycle');
    end

  end
end
