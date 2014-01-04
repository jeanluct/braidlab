% Verify independence on projection line.
% Braids should be conjugate.

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

classdef conjtestTest < matlab.unittest.TestCase

  properties
    gen1
    gen2
    gen1c
    gen2c
  end

  methods (TestMethodSetup)
    function createBraids(testCase)
      load testdata
      XY = XY(1:length(ti),:,:);
      % Close the braid.
      XY = braidlab.closure(XY);

      testCase.gen1 = braidlab.braid(XY);
      testCase.gen1c = testCase.gen1.compact;
      testCase.verifyError(@() braidlab.braid(XY,pi/4), ...
			   'BRAIDLAB:braid:color_braiding:coincidentproj');
      testCase.gen2 = braidlab.braid(XY,-pi/4);
      testCase.gen2c = testCase.gen2.compact;
    end
  end

  methods (Test)
    function test_length(testCase)
      testCase.verifyEqual(testCase.gen1.length,894);
      testCase.verifyEqual(testCase.gen1c.length,14);
      testCase.verifyEqual(testCase.gen2.length,400);
      testCase.verifyEqual(testCase.gen2c.length,12);
    end

    function test_compact(testCase)
      testCase.verifyTrue(testCase.gen1 == testCase.gen1c,...
			  'Something went wrong when compacting gen1.');
      testCase.verifyTrue(testCase.gen2 == testCase.gen2c,...
			  'Something went wrong when compacting gen2.');
    end

    function test_conj(testCase)
      [conj,C] = conjtest(testCase.gen1c,testCase.gen2c);
      testCase.verifyTrue(conj,'Braids are not conjugate.');
      testCase.verifyEqual(C,braidlab.braid([-3 -2 -3 -1 -2 -3 1 2 1 2]));
    end
  end
end
