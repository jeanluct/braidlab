function res = test_braidlab(nomex)
%TEST_BRAIDLAB   Run a suite of braidlab unit tests.
%   TEST_BRAIDLAB runs several unit tests for braidlad (default).
%
%   TEST_BRAIDLAB('NoMEX') runs unit tests without MEX functionality.

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

% Unit Testing Framework not implemented prior to 2013a.
minver =  '8.1.0'; minrel = '2013a';
if verLessThan('matlab', minver)
  error('BRAIDLAB:test_braidlab:minver',...
        'Testsuite requires Matlab version >= %s (%s).',minver,minrel)
end

import matlab.unittest.*

braidlab.prop('reset');

% Get the folder where this script is located.
scriptpath = fileparts(mfilename('fullpath'));
tcfolder = [scriptpath '/testcases/'];

if nargin < 1 || isempty(nomex)
  clear global BRAIDLAB_loop_nomex
  clear global BRAIDLAB_braid_nomex
  if ~braidlab.util.assertmex('+braidlab/@braid/private/compact_helper')
    msg = ['Requested MEX tests but braidlab appears uncompiled.  ' ...
           'Either compile braidlab or pass ''NoMEX'' to test_braidlab; ' ...
           'otherwise there will be LOTS of errors.'];
    warning('BRAIDLAB:test_braidlab:mex_uncompiled',msg);
    pause(1);
  end
  disp('Testing braidlab with MEX algorithms.');
elseif strcmpi(nomex,'NoMEX')
  % Disable MEX algorithms.
  global BRAIDLAB_loop_nomex; %#ok<*GVMIS,TLEV>
  global BRAIDLAB_braid_nomex; %#ok<TLEV>
  BRAIDLAB_braid_nomex = true;
  BRAIDLAB_loop_nomex = true;
  disp('Testing braidlab without MEX algorithms.');
else
  error('BRAIDLAB:test_braidlab:badarg', ...
        'Unknown option ''%s''.',nomex)
end

% Create test suite with explicit test modules
% Skip tests that completely depend on MEX when running in nomex mode.
suites = {};

% Always included tests.
suites{end+1} = TestSuite.fromFile([tcfolder 'braidTest.m']);
suites{end+1} = TestSuite.fromFile([tcfolder 'annbraidTest.m']);
suites{end+1} = TestSuite.fromFile([tcfolder 'databraidTest.m']);
suites{end+1} = TestSuite.fromFile([tcfolder 'loopTest.m']);
suites{end+1} = TestSuite.fromFile([tcfolder 'utilTest.m']);
suites{end+1} = TestSuite.fromFile([tcfolder 'cycleTest.m']);
suites{end+1} = TestSuite.fromFile([tcfolder 'entropyTest.m']);

% Tests that require MEX.
if ~(nargin >= 1 && strcmpi(nomex,'NoMEX'))
  suites{end+1} = TestSuite.fromFile([tcfolder 'cfbraidTest.m']);
  suites{end+1} = TestSuite.fromFile([tcfolder 'compactTest.m']);
  suites{end+1} = TestSuite.fromFile([tcfolder 'conjtestTest.m']);
  suites{end+1} = TestSuite.fromFile([tcfolder 'randomwalkTest.m']);
  suites{end+1} = TestSuite.fromFile([tcfolder 'taffyTest.m']);
  suites{end+1} = TestSuite.fromFile([tcfolder 'trainTest.m']);
else
  disp(['Skipping MEX-dependent tests: ' ...
        'cfbraidTest, compactTest, conjtestTest, ' ...
        'randomwalkTest, taffyTest, trainTest.']);
end

% Combine all test suites.
suite = [suites{:}];
runner = TestRunner.withTextOutput;
res = runner.run(suite);

disp('Unsetting global variables BRAIDLAB_*_nomex');
clear global BRAIDLAB_loop_nomex
clear global BRAIDLAB_braid_nomex
