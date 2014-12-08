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

classdef databraidTest < matlab.unittest.TestCase

  properties
    dbr
  end

  methods (TestMethodSetup)
    function createDatabraid(testCase)
      import braidlab.databraid

      data = load('testdata','XY','ti');
      testCase.dbr = databraid( data.XY, data.ti );
    end
  end

  methods (Test)
    function test_databraid_ftbe(testCase)
      dbr = testCase.dbr;
      testCase.verifyEqual(dbr.ftbe('method','proj'), ...
                           dbr.ftbe('method','nonproj'),...
                           'AbsTol',1e-12);
    end
  end
end
