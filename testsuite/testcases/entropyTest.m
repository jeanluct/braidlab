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

classdef entropyTest < matlab.unittest.TestCase

  methods (Test)

    %% Basic entropy tests

    function test_basic_finiteorder(testCase)
      % Test entropy of finite-order braid is zero.
      br = braidlab.braid([], 4);
      ent = entropy(br);
      testCase.verifyEqual(ent, 0);
    end

    function test_basic_twostrings(testCase)
      % Test entropy of 2-string braid is zero.
      br = braidlab.braid([1 1 1], 2);
      ent = entropy(br);
      testCase.verifyEqual(ent, 0);
    end

    function test_basic_pseudoanosov(testCase)
      % Test entropy of pseudo-Anosov braid is positive.
      % The braid [1 2 -3] is known to be pseudo-Anosov.
      br = braidlab.braid([1 2 -3], 4);
      ent = entropy(br);
      testCase.verifyGreaterThan(ent, 0);
    end

    function test_basic_trefoil(testCase)
      % Test entropy of trefoil knot braid.
      br = braidlab.braid('3_1');
      ent = entropy(br);
      % Trefoil is finite-order (periodic), so entropy is 0.
      testCase.verifyEqual(ent, 0);
    end

    %% Tolerance tests

    function test_tolerance_b1(testCase)
      % Test entropy with multiple tolerances for braid [1 -2].
      br = braidlab.braid([1 -2]);
      expected = 2*log((1+sqrt(5))/2);
      for tol = [1e-6 1e-10 1e-12 1e-14]
        ent = entropy(br, 'Tol', tol);
        testCase.verifyTrue(abs(ent - expected) < tol);
      end
    end

    function test_tolerance_b2(testCase)
      % Test entropy with multiple tolerances for braid [1 1 -2 -2].
      br = braidlab.braid([1 1 -2 -2]);
      expected = 2*log(1+sqrt(2));
      for tol = [1e-6 1e-10 1e-12 1e-14]
        ent = entropy(br, 'Tol', tol);
        testCase.verifyTrue(abs(ent - expected) < tol);
      end
    end

    function test_tolerance_b4(testCase)
      % Test entropy with multiple tolerances for braid [1 2 -3].
      br = braidlab.braid([1 2 -3], 5);
      expected = 0.831442945529311;
      for tol = [1e-6 1e-10 1e-12 1e-14]
        ent = entropy(br, 'Tol', tol);
        testCase.verifyTrue(abs(ent - expected) < tol);
      end
    end

    function test_tolerance_specified(testCase)
      % Test entropy computation with specified tolerance.
      br = braidlab.braid([1 2 -3], 4);
      ent = entropy(br, 'Tol', 1e-4);
      testCase.verifyGreaterThan(ent, 0);
    end

    %% Warning tests

    function test_warning_noconv_finiteorder(testCase)
      % Finite-order braid should warn about non-convergence.
      br = braidlab.braid([1 2]);  % finite-order
      testCase.verifyWarning(@() entropy(br, 'Tol', 1e-6), ...
                             'BRAIDLAB:braid:entropy:noconv');
    end

    function test_warning_noconv_fewiter(testCase)
      % Low-entropy braid with too few iterations.
      br = braidlab.braid('VenzkePsi', 16);
      testCase.verifyWarning(@() entropy(br, 'Tol', 1e-6, 'MaxIt', 100), ...
                             'BRAIDLAB:braid:entropy:noconv');
    end

    function test_warning_zerotol(testCase)
      % Specify 0 tolerance: should not issue warning about lack of convergence.
      br = braidlab.braid([1 2]);
      testCase.verifyWarningFree(@() entropy(br, 'Tol', 0, 'MaxIt', 10));
    end

    function test_warning_finite(testCase)
      % Using 'finite' flag should not issue warning.
      br = braidlab.braid([1 2]);
      testCase.verifyWarningFree(@() entropy(br, 'finite', 'MaxIt', 10));
    end

    %% Low entropy braid tests (require MEX)

    function test_lowentropy_venzkepsi16(testCase)
      % Test low-entropy Venzke braid (requires MEX for speed).
      global BRAIDLAB_braid_nomex %#ok<GVMIS>
      if ~isempty(BRAIDLAB_braid_nomex) && BRAIDLAB_braid_nomex
        testCase.assumeTrue(false, ...
          'Skipping MEX-specific test when BRAIDLAB_braid_nomex is set.');
      end
      br = braidlab.braid('VenzkePsi', 16);
      tol = 1e-6;
      expected = 0.166609316967714;
      ent = entropy(br, 'Tol', tol);
      testCase.verifyTrue(abs(ent - expected) < tol);
    end

    function test_lowentropy_venzkepsi101(testCase)
      % Test braid with >100 strings (requires MEX for speed).
      global BRAIDLAB_braid_nomex %#ok<GVMIS>
      if ~isempty(BRAIDLAB_braid_nomex) && BRAIDLAB_braid_nomex
        testCase.assumeTrue(false, ...
          'Skipping MEX-specific test when BRAIDLAB_braid_nomex is set.');
      end
      br = braidlab.braid('VenzkePsi', 101);
      tol = 1e-6;
      expected = 0.026080318192290;
      ent = entropy(br, 'Tol', 0.01*tol);
      testCase.verifyTrue(abs(ent - expected) < tol);
    end

    function test_lowentropy_psi(testCase)
      % Test entropy on Venzke's low-entropy braids.
      tol = 1e-8;
      for nstrands = 5:16
        br = braidlab.braid('psi', nstrands);
        ent = entropy(br, 'Tol', tol);
        expected = log(max(abs(braidlab.psiroots(nstrands))));
        testCase.verifyTrue(abs(ent - expected) < tol);
      end
    end

    %% Convergence tests

    function test_convergence_random(testCase)
      % Verify iterative method converges to required tolerance.
      % Uses random braids (checked to contain no finite-order/parabolic).
      rng('default')
      len = 50;
      tol = 1e-8;
      Nreal = 30;
      for r = 1:Nreal
        for nstrands = 4:10
          br = braidlab.braid('random', nstrands, len);
          testCase.verifyWarningFree(@() br.entropy('Tol', tol));
        end
      end
    end

    %% Huge entropy tests

    function test_huge_l2norm(testCase)
      % Test braid with enormous entropy using l2norm.  Issue #138.
      tol = 1e-6;
      br0 = braidlab.braid([1 -2]);
      entr0 = entropy(br0);
      Nrep = 2000;
      entr = entropy(br0^Nrep, 'Tol', tol, 'Length', 'l2norm');
      testCase.verifyTrue(abs(entr - Nrep*entr0)/entr < tol);
    end

    function test_huge_intaxis(testCase)
      % Test braid with enormous entropy using intaxis.  Issue #138.
      tol = 1e-6;
      br0 = braidlab.braid([1 -2]);
      entr0 = entropy(br0);
      Nrep = 2000;
      entr = entropy(br0^Nrep, 'Tol', tol, 'Length', 'intaxis');
      testCase.verifyTrue(abs(entr - Nrep*entr0)/entr < tol);
    end

    function test_huge_minlen(testCase)
      % Test braid with enormous entropy using minlen.  Issue #138.
      tol = 1e-6;
      br0 = braidlab.braid([1 -2]);
      entr0 = entropy(br0);
      Nrep = 2000;
      entr = entropy(br0^Nrep, 'Tol', tol, 'Length', 'minlen');
      testCase.verifyTrue(abs(entr - Nrep*entr0)/entr < tol);
    end

    %% Complexity comparison tests

    function test_complexity_minlength(testCase)
      % Test that complexity and one-iterate entropy are the same (minlength).
      len = 40;
      for nstrands = 3:20
        br = braidlab.braid('random', nstrands, len);
        diagnostic = sprintf('len = %d, n = %d, word = %s', ...
                      len, nstrands, mat2str(br.word));
        testCase.verifyEqual(br.entropy('onestep', 'length', 'minlength'), ...
                             br.complexity('length', 'minlength'), ...
                             'AbsTol', 1e-12, ['minlength: ' diagnostic]);
      end
    end

    function test_complexity_intaxis(testCase)
      % Test that complexity and one-iterate entropy are the same (intaxis).
      len = 40;
      for nstrands = 3:20
        br = braidlab.braid('random', nstrands, len);
        diagnostic = sprintf('len = %d, n = %d, word = %s', ...
                      len, nstrands, mat2str(br.word));
        testCase.verifyEqual(br.entropy('onestep', 'length', 'intaxis'), ...
                             br.complexity, ...
                             'AbsTol', 1e-12, ['intaxis: ' diagnostic]);
      end
    end

    %% psiroots tests

    function test_psiroots_returns_roots(testCase)
      % Test psiroots returns roots by default.
      e = braidlab.psiroots(5);
      testCase.verifyTrue(isnumeric(e));
      testCase.verifyTrue(~isempty(e));
    end

    function test_psiroots_sorted_descending(testCase)
      % Test psiroots returns roots sorted by descending magnitude.
      e = braidlab.psiroots(7);
      mags = abs(e);
      testCase.verifyEqual(mags, sort(mags, 'descend'));
    end

    function test_psiroots_poly_option(testCase)
      % Test psiroots with 'Poly' option returns polynomial coefficients.
      c = braidlab.psiroots(5, 'Poly');
      testCase.verifyTrue(isnumeric(c));
      testCase.verifyEqual(c(1), 1);  % Leading coefficient is 1.
      testCase.verifyEqual(c(end), 1);  % Constant term is 1.
    end

    function test_psiroots_polynomial_option(testCase)
      % Test psiroots with 'Polynomial' option.
      c = braidlab.psiroots(6, 'Polynomial');
      testCase.verifyTrue(isnumeric(c));
    end

    function test_psiroots_consistent_roots_poly(testCase)
      % Test that roots of polynomial match psiroots output.
      n = 8;
      e = braidlab.psiroots(n);
      c = braidlab.psiroots(n, 'Poly');
      e_from_poly = roots(c);
      % Sort both the same way for comparison.
      [~,i] = sort(abs(e_from_poly), 'descend');
      e_from_poly = e_from_poly(i);
      testCase.verifyEqual(e, e_from_poly, 'AbsTol', 1e-12);
    end

    function test_psiroots_badarg_error(testCase)
      % Test error for n < 3.
      testCase.verifyError(@() braidlab.psiroots(2), ...
                           'BRAIDLAB:psiroots:badarg');
    end

    function test_psiroots_bad_flag_error(testCase)
      % Test error for unknown flag.
      testCase.verifyError(@() braidlab.psiroots(5, 'garbage'), ...
                           'BRAIDLAB:psiroots');
    end

    function test_psiroots_n3_special(testCase)
      % Test n=3 case has 2 roots (degree 2 polynomial).
      e = braidlab.psiroots(3);
      testCase.verifyEqual(length(e), 2);
    end

    function test_psiroots_n6_special(testCase)
      % Test n=6 exceptional case.
      c = braidlab.psiroots(6, 'Poly');
      % The n=6 case has a special polynomial.
      testCase.verifyEqual(c, [1 1 -1 -4 -4 -1 1 1]);
    end

    function test_psiroots_largest_gives_entropy(testCase)
      % Test largest root gives entropy of psi braid.
      global BRAIDLAB_braid_nomex
      testCase.assumeTrue(isempty(BRAIDLAB_braid_nomex), ...
        'Skipping MEX-specific test when BRAIDLAB_braid_nomex is set.');
      for n = 5:10
        e = braidlab.psiroots(n);
        expected_entropy = log(max(abs(e)));
        br = braidlab.braid('psi', n);
        actual_entropy = entropy(br, 'method', 'trains');
        testCase.verifyEqual(actual_entropy, expected_entropy, 'AbsTol', 1e-9);
      end
    end

  end
end
