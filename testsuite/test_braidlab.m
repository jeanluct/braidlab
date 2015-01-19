function res = test_braidlab(nomex)
%TEST_BRAIDLAB   Run a suite of braidlab unit tests.
%   TEST_BRAIDLAB runs several unit tests for braidlad (default).
%
%   TEST_BRAIDLAB('NoMEX') runs unit tests without MEX functionality.

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

% Unit Testing Framework not implemented prior to 2013a.
minver =  '8.1.0'; minrel = '2013a';
if verLessThan('matlab', minver)
  error('BRAIDLAB:test_braidlab:minver',...
        'Testsuite requires Matlab version >= %s (%s).',minver,minrel)
end

import matlab.unittest.*

braidlab.prop('reset');

tcfolder = [pwd '/testcases/'];

if nargin < 1 || isempty(nomex)
  clear global BRAIDLAB_loop_nomex
  clear global BRAIDLAB_braid_nomex
  if ~braidlab.util.assertmex(['+braidlab/@braid/private/compact_helper'])
    msg = ['Requested MEX tests but braidlab looks uncompiled.  ' ...
           'Either compile braidlab or pass ''nomex'' to test_braidlab; ' ...
           'otherwise there will be LOTS of errors.'];
    warning(msg);
    pause(1);
  end
  disp('Testing braidlab with MEX algorithms.');
else
  % disable MEX algorithms
  global BRAIDLAB_loop_nomex; %#ok<TLEV>
  global BRAIDLAB_braid_nomex; %#ok<TLEV>
  BRAIDLAB_braid_nomex = true;
  BRAIDLAB_loop_nomex = true;
  disp('Testing braidlab without MEX algorithms.');
end

suite = TestSuite.fromFolder(tcfolder);
%suite = TestSuite.fromFile([tcfolder 'annbraidTest.m']);
%suite = TestSuite.fromFile([tcfolder 'braidTest.m']);
%suite = TestSuite.fromFile([tcfolder 'cfbraidTest.m']);
%suite = TestSuite.fromFile([tcfolder 'compactTest.m']);
%suite = TestSuite.fromFile([tcfolder 'conjtestTest.m']);
%suite = TestSuite.fromFile([tcfolder 'cycleTest.m']);
%suite = TestSuite.fromFile([tcfolder 'databraidTest.m']);
%suite = TestSuite.fromFile([tcfolder 'entropyTest.m']);
%suite = TestSuite.fromFile([tcfolder 'loopTest.m']);
%suite = TestSuite.fromFile([tcfolder 'taffyTest.m']);
runner = TestRunner.withTextOutput;
res = runner.run(suite);

disp('Unsetting global variables BRAIDLAB_*_nomex');
clear global BRAIDLAB_loop_nomex
clear global BRAIDLAB_braid_nomex
