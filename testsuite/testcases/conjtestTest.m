% Verify independence on projection line.
% Braids should be conjugate.

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   http://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2015  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
%                            Marko Budisic         <marko@math.wisc.edu>
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
    b1
    b2
    b1c
    b2c
  end

  methods (TestMethodSetup)
    function createBraids(testCase)
      load('testdata','XY','ti')
      XY = XY(1:length(ti),:,:); %#ok<NODEF>
      % Close the braid.
      XY = braidlab.closure(XY);

      testCase.b1 = braidlab.braid(XY);
      testCase.b1c = testCase.b1.compact;
      testCase.verifyThat(@() braidlab.braid(XY,[],pi/4), ...
                          matlab.unittest.constraints.Throws('BRAIDLAB:braid:braid:badcurves',...
                                 'CausedBy',...
                                 {'BRAIDLAB:braid:colorbraiding:coincidentprojection'}) );      
      testCase.b2 = braidlab.braid(XY,[],-pi/4 + 1e-8);
      testCase.b2c = testCase.b2.compact;
    end
  end

  methods (Test)
    function test_length(testCase)
      testCase.verifyEqual(testCase.b1.length,894);
      testCase.verifyEqual(testCase.b1c.length,14);
      testCase.verifyEqual(testCase.b2.length,400);
      testCase.verifyEqual(testCase.b2c.length,12);
    end

    function test_compact(testCase)
      testCase.verifyTrue(testCase.b1 == testCase.b1c,...
                          'Something went wrong when compacting b1.');
      testCase.verifyTrue(testCase.b2 == testCase.b2c,...
                          'Something went wrong when compacting b2.');
    end

    function test_conj(testCase)
      [conj,C] = conjtest(testCase.b1c,testCase.b2c);
      testCase.verifyTrue(conj,'Braids are not conjugate.');
      testCase.verifyEqual(C,braidlab.braid([-3 -2 -3 -1 -2 -3 1 2 1 2]));
    end
  end
end
