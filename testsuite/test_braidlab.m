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

% Unit Testing Framework not implemented prior to 2013a.
minver =  '8.1.0'; minrel = '2013a';
if verLessThan('matlab', minver)
  error('BRAIDLAB:test_braidlab:minver',...
        'Testsuite requires Matlab version >= %s (%s).',minver,minrel)
end

import matlab.unittest.*

suite = TestSuite.fromFolder([pwd '/testcases']);
%suite = TestSuite.fromClass(?braidTest);
%suite = TestSuite.fromClass(?loopTest);
%suite = TestSuite.fromClass(?conjtestTest);
%suite = TestSuite.fromClass(?compactTest);
%suite = TestSuite.fromClass(?entropyTest);
%suite = TestSuite.fromClass(?cycleTest);
runner = TestRunner.withTextOutput;
res = runner.run(suite) %#ok<NOPTS>
