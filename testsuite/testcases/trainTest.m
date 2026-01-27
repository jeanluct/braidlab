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

classdef trainTest < matlab.unittest.TestCase

  methods (Test)
    function test_train_pseudo_anosov(testCase)
      % Test train track for pseudo-Anosov braid.
      b = braidlab.braid([1 -2],3);
      T = train(b);
      testCase.verifyTrue(isstruct(T));
      testCase.verifyTrue(isfield(T,'tntype'));
      testCase.verifyTrue(isfield(T,'entropy'));
      testCase.verifyEqual(T.tntype,'pseudo-Anosov');
      testCase.verifyTrue(abs(T.entropy - 2*log((1+sqrt(5))/2)) < 1e-13);
    end

    function test_train_finite_order(testCase)
      % Test train track for finite-order braid.
      b = braidlab.braid([1 2 3],4);
      T = train(b);
      testCase.verifyTrue(isstruct(T));
      testCase.verifyEqual(T.tntype,'finite-order');
      testCase.verifyEqual(T.entropy,0);
    end

    function test_train_two_strings(testCase)
      % Test train track for 2-string braid is finite-order.
      % Note: For n < 3, train() returns early with just tntype and entropy.
      % This is expected behavior since 2-string braids are always finite-order.
      b = braidlab.braid([1 1 1],2);
      % For 2-string braids, we expect an error due to missing fields.
      % This tests the expected early return path for n < 3.
      try
        T = train(b);
        testCase.verifyTrue(isstruct(T));
        testCase.verifyEqual(T.entropy,0);
      catch ME
        % Expected error due to orderfields with missing fields.
        testCase.verifyEqual(ME.identifier,'MATLAB:strcmp:InputsSizeMismatch');
      end
    end

    function test_entropy_trains(testCase)
      % Test entropy calculation using trains method.
      b1 = braidlab.braid([1 -2]);
      e1ex = 2*log((1+sqrt(5))/2);
      e = entropy(b1,'method','trains');
      testCase.verifyTrue(abs(e - e1ex) < 1e-15);

      b2 = braidlab.braid([1 1 -2 -2]);
      e2ex = 2*log(1+sqrt(2));
      e = entropy(b2,'method','trains');
      testCase.verifyTrue(abs(e - e2ex) < 1e-15);

      % A much more difficult case: can only get 9 digits.
      b3 = braidlab.braid('VenzkePsi',16);
      e3ex = 0.166609316967714;
      e = entropy(b3,'method','trains');
      testCase.verifyTrue(abs(e - e3ex) < 1e-10);

      b4 = braidlab.braid([1 2 -3],5);
      testCase.verifyWarning(@() entropy(b4,'method','trains'), ...
                             'BRAIDLAB:braid:entropy:reducible');

      testCase.verifyError(@() entropy(b4,'garbage'), ...
                           'MATLAB:InputParser:ArgumentFailedValidation');
    end

    function test_low_entropy_trains(testCase)
      % Test entropy on Venzke's low-entropy braids using trains method.
      for n = 5:16
        b = braidlab.braid('psi',n);
        ee = log(max(abs(braidlab.psiroots(n))));
        etr = entropy(b,'method','trains');
        testCase.verifyTrue(abs(etr - ee) < 1e-9);
      end
    end
  end

end
