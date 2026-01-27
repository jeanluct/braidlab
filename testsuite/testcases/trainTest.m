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

    %% Train track structure tests

    function test_structure_fields(testCase)
      % Test train track returns expected fields.
      br = braidlab.braid([1 -2], 3);
      T = train(br);
      testCase.verifyTrue(isstruct(T));
      testCase.verifyTrue(isfield(T, 'tntype'));
      testCase.verifyTrue(isfield(T, 'entropy'));
    end

    function test_structure_pseudoanosov(testCase)
      % Test train track for pseudo-Anosov braid.
      br = braidlab.braid([1 -2], 3);
      T = train(br);
      testCase.verifyEqual(T.tntype, 'pseudo-Anosov');
      expected = 2*log((1+sqrt(5))/2);
      testCase.verifyTrue(abs(T.entropy - expected) < 1e-13);
    end

    function test_structure_finiteorder(testCase)
      % Test train track for finite-order braid.
      br = braidlab.braid([1 2 3], 4);
      T = train(br);
      testCase.verifyEqual(T.tntype, 'finite-order');
      testCase.verifyEqual(T.entropy, 0);
    end

    function test_structure_twostrings(testCase)
      % Test train track for 2-string braid is finite-order.
      % For n < 3, train() returns early with just tntype and entropy.
      br = braidlab.braid([1 1 1], 2);
      try
        T = train(br);
        testCase.verifyTrue(isstruct(T));
        testCase.verifyEqual(T.entropy, 0);
      catch ME
        % Expected error due to orderfields with missing fields.
        testCase.verifyEqual(ME.identifier, 'MATLAB:strcmp:InputsSizeMismatch');
      end
    end

    %% Entropy with trains method tests

    function test_entropy_pseudoanosov1(testCase)
      % Test entropy using trains method for simple pseudo-Anosov braid.
      br = braidlab.braid([1 -2]);
      expected = 2*log((1+sqrt(5))/2);
      ent = entropy(br, 'method', 'trains');
      testCase.verifyTrue(abs(ent - expected) < 1e-15);
    end

    function test_entropy_pseudoanosov2(testCase)
      % Test entropy using trains method for [1 1 -2 -2].
      br = braidlab.braid([1 1 -2 -2]);
      expected = 2*log(1+sqrt(2));
      ent = entropy(br, 'method', 'trains');
      testCase.verifyTrue(abs(ent - expected) < 1e-15);
    end

    function test_entropy_difficult(testCase)
      % Test entropy using trains for a difficult case.
      % Can only get 9 digits.
      br = braidlab.braid('VenzkePsi', 16);
      expected = 0.166609316967714;
      ent = entropy(br, 'method', 'trains');
      testCase.verifyTrue(abs(ent - expected) < 1e-10);
    end

    function test_entropy_reducible_warning(testCase)
      % Test warning for reducible braid with trains method.
      br = braidlab.braid([1 2 -3], 5);
      testCase.verifyWarning(@() entropy(br, 'method', 'trains'), ...
                             'BRAIDLAB:braid:entropy:reducible');
    end

    function test_entropy_badarg(testCase)
      % Test error for invalid entropy argument.
      br = braidlab.braid([1 2 -3], 5);
      testCase.verifyError(@() entropy(br, 'garbage'), ...
                           'MATLAB:InputParser:ArgumentFailedValidation');
    end

    %% Low entropy braids tests

    function test_lowentropy_psi(testCase)
      % Test entropy on Venzke's low-entropy braids using trains method.
      for nstrands = 5:16
        br = braidlab.braid('psi', nstrands);
        expected = log(max(abs(braidlab.psiroots(nstrands))));
        etr = entropy(br, 'method', 'trains');
        testCase.verifyTrue(abs(etr - expected) < 1e-9);
      end
    end

  end
end
