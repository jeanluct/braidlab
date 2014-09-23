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

% Note: this testuite will work with or without GMP compiled, but runs at
% least 10 times slower without it.

classdef cycleTest < matlab.unittest.TestCase

  properties
    % Names of some predefined test cases.
    b1
    b2
    bpsi12
    period1
    period2
    periodpsi12
    it1
    it1b
    it2
    it12
    itpsi12
    M11
    M2
    polypsi12;
  end

  methods (TestMethodSetup)
    function createBraid(testCase)
      import braidlab.braid
      testCase.b1 = braid([1 2]);
      testCase.b2 = braid([1 2 3]);
      testCase.period1 = 3;
      testCase.period2 = 4;
      testCase.periodpsi12 = 5;
      testCase.it1 = 20;
      testCase.it1b = 35;
      testCase.it2 = 26;
      testCase.it12 = 74;
      testCase.itpsi12 = 44;
      testCase.bpsi12 = braid('psi',12);
      testCase.M11 = [0 0 -1 0;0 1 0 0;1 -1 -1 0;0 1 1 1];
      testCase.M2 = [
          0    -1     1     0     1     0
          1     0     1     0     1     0
          0     0     1     0     0     0
          0     1    -1     1    -1     0
          1     0     0     0     1     0
          0    -1     3     0     1     1];
      testCase.polypsi12 = [1 -13 73 -231 450 -552 416 -209 221 -489 783 ...
                    -900 783 -489 221 -209 416 -552 450 -231 73 -13 1];
    end
  end

  methods (Test)
    function test_cycle(testCase)
      [pn1,it1] = cycle(testCase.b1); %#ok<*PROP>
      [pn2,it2] = cycle(testCase.b2);
      [pn12,it12] = cycle(tensor(testCase.b1,testCase.b2));

      % Check periods.
      testCase.verifyEqual(size(pn1,1),testCase.period1);
      testCase.verifyEqual(size(pn2,1),testCase.period2);
      testCase.verifyEqual(size(pn12,1),testCase.period1*testCase.period2);
      % Check iterations for convernce.
      testCase.verifyEqual(it1,testCase.it1);
      testCase.verifyEqual(it2,testCase.it2);
      testCase.verifyEqual(it12,testCase.it12);

      % Request more consecutive convergences (10).
      [pn1b,it1b] = cycle(testCase.b1,[],10);
      testCase.verifyEqual(pn1,pn1b);
      testCase.verifyEqual(it1b,testCase.it1b);

      % Request too many consecutive convergences for the number of iterations.
      testCase.verifyError(@() cycle(testCase.b2,10,10), ...
                           'BRAIDLAB:braid:cycle:noconv');

      % Unknown flag.
      testCase.verifyError(@() cycle(testCase.b2,'garbage'), ...
                           'BRAIDLAB:braid:cycle:badarg');

      % Explicitly verify one matrix.
      M11 = full(linact(testCase.b1,pn1(1,:)));
      testCase.verifyEqual(M11,testCase.M11);

      % Matrix for each iterate.
      M1cell = cell(1,size(pn1,1));
      for i = 1:size(pn1,1)
        M1cell{i} = linact(testCase.b1,pn1(i,:));
      end
      M1cell2 = cyclemat(testCase.b1,'iter');
      testCase.verifyEqual(M1cell,M1cell2);

      % Explicitly verify the matrix for the full cycle.
      M2 = cyclemat(testCase.b2);
      testCase.verifyEqual(full(M2),testCase.M2);

      % Verify a more difficult characteristic polynomial.
      [Mpsi12,periodpsi12,itpsi12] = cyclemat(testCase.bpsi12);
      testCase.verifyEqual(periodpsi12,testCase.periodpsi12);
      testCase.verifyEqual(itpsi12,testCase.itpsi12);
      testCase.verifyEqual(charpoly(Mpsi12),testCase.polypsi12);
    end
  end
end
