% <LICENSE
%   Copyright (c) 2013, 2014 Jean-Luc Thiffeault
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
    e1ex
    e2ex
    e3ex
    e4ex
  end

  methods (TestMethodSetup)
    function createBraid(testCase)
      import braidlab.braid
      testCase.b1 = braid([1 -2]);
      testCase.b2 = braid([1 1 -2 -2]);
      testCase.b3 = braid('VenzkePsi',16);
      testCase.b4 = braid([1 2 -3],5);
      testCase.b5 = braid([1 2]);  % finite-order (zero entropy)
      testCase.e1ex = 2*log((1+sqrt(5))/2);
      testCase.e2ex = 2*log(1+sqrt(2));
      testCase.e3ex = 0.166609316967714;
      testCase.e4ex = 0.831442945529311;
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
      testCase.verifyWarning(@() entropy(testCase.b3,tol), ...
                             'BRAIDLAB:braid:entropy:noconv');
      % Increase the maximum number of iterations.
      e = entropy(testCase.b3,tol,1000);
      testCase.verifyTrue(abs(e - testCase.e3ex) < tol);
    end

    function test_low_entropy(testCase)
      % Test entropy on Venzke's low-entropy braids.
      % Stricter tolerance requires more maximum iterations.
      tol = 1e-8;
      for n = 7:16
        b = braidlab.braid('psi',n);
        etr = entropy(b,'trains');
        e = entropy(b,tol,2000);

        % Polynomials from Venzke's thesis, page 53.
        c = zeros(1,n+1);
        c(1) = 1; c(n+1) = 1;
        if mod(n,2) == 1
          k = (n-1)/2;
          c(n+1-(k+1)) = -2; c(n+1-(k)) = -2;
        elseif mod(n,4) == 0
          k = n/4;
          c(n+1-(2*k+1)) = -2; c(n+1-(2*k-1)) = -2;
        elseif mod(n,8) == 2
          k = (n-2)/8;
          c(n+1-(4*k+3)) = -2; c(n+1-(4*k-1)) = -2;
        elseif mod(n,8) == 6
          k = (n-6)/8;
          c(n+1-(4*k+5)) = -2; c(n+1-(4*k+1)) = -2;
        end
        % Could also solve for the Perron root this way:
        %p = @(x) c*x.^(n+1:-1:1).';
        %opts = optimoptions(@fsolve,'Display','off',...
        %                    'TolX',1e-20,'TolFun',1e-20);
        %ee = log(fsolve(p,2,opts));
        ee = log(max(abs(roots(c))));
        testCase.verifyTrue(abs(e - ee) < tol);
        % The train track method is very precise.
        testCase.verifyTrue(abs(etr - ee) < 1e-14);
      end
    end
  end
end
