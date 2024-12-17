% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   http://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2024  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
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
%   along with Braidlab.  If not, see <http://www.gnu.org/licenses/>.
% LICENSE>

classdef entropyTest < matlab.unittest.TestCase

  properties
    b1
    b2
    b3
    b4
    b5
    b6
    e1ex
    e2ex
    e3ex
    e4ex
    e6ex
  end

  methods (TestMethodSetup)
    function createBraid(testCase)
      import braidlab.braid
      testCase.b1 = braid([1 -2]);
      testCase.b2 = braid([1 1 -2 -2]);
      testCase.b3 = braid('VenzkePsi',16);
      testCase.b4 = braid([1 2 -3],5);
      testCase.b5 = braid([1 2]);  % finite-order (zero entropy)
      testCase.b6 = braid('VenzkePsi',101);
      testCase.e1ex = 2*log((1+sqrt(5))/2);
      testCase.e2ex = 2*log(1+sqrt(2));
      testCase.e3ex = 0.166609316967714;
      testCase.e4ex = 0.831442945529311;
      testCase.e6ex = 0.026080318192290;
    end
  end

  methods (Test)
    function test_entropy_trains(testCase)
      e = entropy(testCase.b1,'method','trains');
      testCase.verifyTrue(abs(e - testCase.e1ex) < 1e-15);

      e = entropy(testCase.b2,'method','trains');
      testCase.verifyTrue(abs(e - testCase.e2ex) < 1e-15);

      % A much more difficult case: can only get 9 digits.
      e = entropy(testCase.b3,'method','trains');
      testCase.verifyTrue(abs(e - testCase.e3ex) < 1e-10);

      testCase.verifyWarning(@() entropy(testCase.b4,'method','trains'), ...
                             'BRAIDLAB:braid:entropy:reducible');

      testCase.verifyError(@() entropy(testCase.b4,'garbage'), ...
                           'MATLAB:InputParser:ArgumentFailedValidation');
    end

    function test_entropy_iter(testCase)
      for tol = [1e-6 1e-10 1e-12 1e-14]
        e = entropy(testCase.b1,'Tol',tol);
        testCase.verifyTrue(abs(e - testCase.e1ex) < tol);

        e = entropy(testCase.b2,'Tol',tol);
        testCase.verifyTrue(abs(e - testCase.e2ex) < tol);

        e = entropy(testCase.b4,'Tol',tol);
        testCase.verifyTrue(abs(e - testCase.e4ex) < tol);
      end

      tol = 1e-6;
      testCase.verifyWarning(@() entropy(testCase.b5,'Tol',tol), ...
                             'BRAIDLAB:braid:entropy:noconv');
      % Low-entropy braid with too few iterations.
      testCase.verifyWarning(@() entropy(testCase.b3,...
                                         'Tol',tol, ...
                                         'MaxIt', 100), ...
                             'BRAIDLAB:braid:entropy:noconv');
      % The default gives enough iterations.
      e = entropy(testCase.b3,'Tol',tol);
      testCase.verifyTrue(abs(e - testCase.e3ex) < tol);

      % Try a braid with more than 100 strings, so the maximum number of
      % iterations is determined by asymptotic spectral gap.  Have to use
      % higher tolerance, since the entropy converges slowly.
      global BRAIDLAB_braid_nomex
      if isempty(BRAIDLAB_braid_nomex) || ~BRAIDLAB_braid_nomex
        % Skip this test if not using MEX.
        e = entropy(testCase.b6,'Tol',.01*tol);
        testCase.verifyTrue(abs(e - testCase.e6ex) < tol);
      end

      % Specify 0 tolerance: should not issue a warning about lack of
      % convergence.
      testCase.verifyWarningFree(@() entropy(testCase.b5,'Tol',0, ...
                                             'MaxIt',10));
      testCase.verifyWarningFree(@() entropy(testCase.b5, ...
                                             'finite', 'MaxIt',10));
    end

    function test_entropy_iter_conv(testCase)
      % Verify that the iterative method always converges to the required
      % tolerance, using the default number of steps, unless the braid is
      % parabolic, finite-order, or reducible with no finite-order
      % component.
      %
      % This particular random set has been checked to contain no
      % finite-order or parabolic braids, which are rare for long random
      % braids.
      rng('default')
      len = 50; tol = 1e-8; Nreal = 30;
      for r = 1:Nreal
        for n = 4:10
          b = braidlab.braid('random',n,len);
          testCase.verifyWarningFree(@() b.entropy('Tol',tol));
        end
      end
    end

    function test_low_entropy(testCase)
      % Test entropy on Venzke's low-entropy braids.
      % Stricter tolerance requires more maximum iterations.
      tol = 1e-8;
      for n = 5:16
        b = braidlab.braid('psi',n);
        etr = entropy(b,'method','trains');
        e = entropy(b,'Tol',tol);

        ee = log(max(abs(braidlab.psiroots(n))));
        testCase.verifyTrue(abs(e - ee) < tol);
        testCase.verifyTrue(abs(etr - ee) < 1e-9);
      end
    end

    function test_huge_entropy(testCase)
      % Test a braid with enormous entropy, which would overflow even one
      % application of the update rules.
      % See issue #138.
      tol = 1e-6;
      % The simplest pA braid and its entropy.
      b0 = braidlab.braid([1 -2]);
      entr0 = entropy(b0);
      % Number of repetitions of the braid.
      % This gives a braid with entropy about 1925!
      Nrep = 2000;
      entr = entropy(b0^Nrep,'Tol',tol,'Length','l2norm');
      testCase.verifyTrue(abs(entr - Nrep*entr0)/entr < tol);
      entr = entropy(b0^Nrep,'Tol',tol,'Length','intaxis');
      testCase.verifyTrue(abs(entr - Nrep*entr0)/entr < tol);
      entr = entropy(b0^Nrep,'Tol',tol,'Length','minlen');
      testCase.verifyTrue(abs(entr - Nrep*entr0)/entr < tol);
    end

    function test_entropy_complexity(testCase)
      % Test that complexity and one-iterate entropy are the same.
        len = 40;
        for n = 3:20
          b = braidlab.braid('random',n,len);

          diagnostic = sprintf('len = %d, n = %d, word = %s', ...
                        len,n,mat2str(b.word) );

          % minlength computation
          testCase.verifyEqual(b.entropy('onestep','length','minlength'), ...
                               b.complexity('length','minlength'), 'AbsTol',1e-12, ...
                               ['minlength: ' diagnostic]);

          % intaxis computation
          testCase.verifyEqual(b.entropy('onestep','length','intaxis'), ...
                               b.complexity, ...
                               'AbsTol',1e-12, ['intaxis: ' diagnostic]);
        end
    end
end
end
