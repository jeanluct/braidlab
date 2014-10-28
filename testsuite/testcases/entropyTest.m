% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   http://bitbucket.org/jeanluc/braidlab/
%
%   Copyright (C) 2013--2014  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
%                             Marko Budisic         <marko@math.wisc.edu>
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
      e = entropy(testCase.b1,'trains');
      testCase.verifyTrue(abs(e - testCase.e1ex) < 1e-15);

      e = entropy(testCase.b2,'trains');
      testCase.verifyTrue(abs(e - testCase.e2ex) < 1e-15);

      % A much more difficult case: can only get 9 digits.
      e = entropy(testCase.b3,'trains');
      testCase.verifyTrue(abs(e - testCase.e3ex) < 1e-10);

      testCase.verifyWarning(@() entropy(testCase.b4,'trains'), ...
                             'BRAIDLAB:braid:entropy:reducible');

      testCase.verifyError(@() entropy(testCase.b4,'garbage'), ...
                           'BRAIDLAB:braid:entropy:badarg');
    end

    function test_entropy_iter(testCase)
      for tol = [1e-6 1e-10 1e-12 1e-14]
        e = entropy(testCase.b1,tol);
        testCase.verifyTrue(abs(e - testCase.e1ex) < tol);

        e = entropy(testCase.b2,tol);
        testCase.verifyTrue(abs(e - testCase.e2ex) < tol);

        e = entropy(testCase.b4,tol);
        testCase.verifyTrue(abs(e - testCase.e4ex) < tol);
      end

      tol = 1e-6;
      testCase.verifyWarning(@() entropy(testCase.b5,tol), ...
                             'BRAIDLAB:braid:entropy:noconv');
      % Low-entropy braid with too few iterations.
      testCase.verifyWarning(@() entropy(testCase.b3,tol,100), ...
                             'BRAIDLAB:braid:entropy:noconv');
      % The default gives enough iterations.
      e = entropy(testCase.b3,tol);
      testCase.verifyTrue(abs(e - testCase.e3ex) < tol);

      % Try a braid with more than 100 strings, so the maximum number of
      % iterations is determined by asymptotic spectral gap.  Have to use
      % higher tolerance, since the entropy converges slowly.
      e = entropy(testCase.b6,.01*tol);
      testCase.verifyTrue(abs(e - testCase.e6ex) < tol);

      % Specify 0 tolerance: should not issue a warning about lack of
      % convergence.
      testCase.verifyWarningFree(@() entropy(testCase.b5,0,10));
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
          testCase.verifyWarningFree(@() b.entropy(tol));
        end
      end
    end

    function test_low_entropy(testCase)
      % Test entropy on Venzke's low-entropy braids.
      % Stricter tolerance requires more maximum iterations.
      tol = 1e-8;
      for n = 5:16
        b = braidlab.braid('psi',n);
        etr = entropy(b,'trains');
        e = entropy(b,tol);

        ee = log(max(abs(braidlab.psiroots(n))));
        testCase.verifyTrue(abs(e - ee) < tol);
        testCase.verifyTrue(abs(etr - ee) < 1e-9);
      end
    end
    
    function test_entropy_complexity(testCase)
      % Test that complexity and one-iterate entropy are the same.
        len = 40;
        for n = 3:20
          b = braidlab.braid('random',n,len);
          
          diagnostic = sprintf('len = %d, n = %d, word = %s', ...
                        len,n,mat2str(b.word) );

          % minlength computation
          testCase.verifyEqual(b.entropy(0,1,0,1), b.complexity(1), ...
                               'AbsTol',1e-12,  ['minlength: ' diagnostic]); 
          
          % intaxis computation
          testCase.verifyEqual(b.entropy(0,1,0,0), b.complexity(0), ...
                               'AbsTol',1e-12, ['intaxis: ' diagnostic]);
        end
    end
  end
end
