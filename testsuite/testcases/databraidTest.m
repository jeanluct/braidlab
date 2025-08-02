% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   https://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2025  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
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

classdef databraidTest < matlab.unittest.TestCase

  properties
    dbrtest
  end

  methods (TestMethodSetup)
    function create_databraid(testCase)
      import braidlab.databraid

      data = load('testdata','XY','ti');
      testCase.dbrtest = databraid(data.XY,data.ti);
    end
  end

  methods (Test)
    function test_databraid_constructor(testCase)
      import braidlab.databraid

      % TODO: here test different forms of constructor.

      % Not enough input arguments.
      testCase.verifyError(@() databraid, ...
                           'BRAIDLAB:databraid:databraid:badarg');
      % Too many input arguments.
      % The error message id changed name from R2016b.
      maxver = '9.1.0.441655'; maxrel = '2016b';
      if verLessThan('matlab', maxver)
        maxrhs_id = 'MATLAB:maxrhs';
      else
        maxrhs_id = 'MATLAB:TooManyInputs';
      end
      testCase.verifyError(@() databraid(1,1,1,1),maxrhs_id);
      % Wrong number of crossing times.
      testCase.verifyError(@() databraid([1 2],1), ...
                           'BRAIDLAB:databraid:check_tcross:badtimes');
      % Decreasing crossing times.
      testCase.verifyError(@() databraid([1 2],[1 0]), ...
                           'BRAIDLAB:databraid:check_tcross:badtimes');
      % Simultaneous times for noncommuting generators.
      testCase.verifyError(@() databraid([1 2],[1 1]), ...
                           'BRAIDLAB:databraid:sort_sim_tcross:badsimtimes');
      % Simultaneous times for *commuting* generators is ok.
      databraid([1 3],[1 1]);

      % However all the generators have to pairwise commute.
      % This shouldn't work: see issue #94.
      testCase.verifyError(@() databraid([4 1 3],[1 1 1]), ...
                           'BRAIDLAB:databraid:sort_sim_tcross:badsimtimes');

      % A more complicated example with two simultaneous blocks.  The first
      % has the generators [5 1 3], which is fine, the second [7 6], which
      % is not.
      testCase.verifyError(@() ...
                           databraid([ 1  2  3 5 1 3 4 5 6 7 6], ...
                                     [-3 -2 -1 1 1 1 2 3 4 5 5]), ...
                           'BRAIDLAB:databraid:sort_sim_tcross:badsimtimes')
      % Replace 7 by 8: now [8 6] commute, and it's ok.
      databraid([1 2 3 5 1 3 4 5 6 8 6],[-3 -2 -1 1 1 1 2 3 4 5 5]);
    end

    function test_databraid_eq(testCase)
      import braidlab.databraid

      b1 = databraid([1 2],[1 2]);
      b2 = databraid([1 2],[2 3]);
      testCase.verifyTrue(b1 ~= b2);
      % Crossing times must match for equality.
      b2.tcross = [1 2];
      testCase.verifyTrue(b1 == b2);
      % These braids are equal, but they must be lexicographically equal
      % to match as databraids.
      b1 = braidlab.databraid([1 2 -2 3],[1 2 3 4]);
      b2 = braidlab.databraid([1 3],[1 4]);
      testCase.verifyTrue(b1 ~= b2);

      % These should be equal: see issue #97.
      b1 = braidlab.databraid([1 2 -3  5 -7 6],[1 2 3 3 3 4]);
      b2 = braidlab.databraid([1 2  5 -7 -3 6],[1 2 3 3 3 4]);
      testCase.verifyTrue(b1 == b2);
    end

    function test_databraid_mtimes(testCase)
      import braidlab.databraid

      % Here the last tcrossing ime of b1 is after the first crossing
      % time of b2.
      b1 = databraid([1 2],[1 3]);
      b2 = databraid([1 2],[2 4]);
      testCase.verifyError(@() b1*b2,'BRAIDLAB:databraid:mtimes:notchrono');

      % This is ok: the last generator of b1 commutes with the first of
      % b2, even though they have the same crossing time.
      b1 = databraid([1 3],[1 2]);
      b2 = databraid([5 2],[2 3]);
      b12 = b1*b2; %#ok<NASGU>
      % This is not ok: the generators at the ends don't commute.
      b1 = databraid([1 3],[1 2]);
      b2 = databraid([4 2],[2 3]);
      testCase.verifyError(@() b1*b2, ...
                           'BRAIDLAB:databraid:sort_sim_tcross:badsimtimes');
      % This shouldn't work: 6 and 5 don't commute.  See issue #98.
      b1 = databraid([1 5 3],[1 2 2]);
      b2 = databraid([6 2],[2 3]);
      testCase.verifyError(@() b1*b2, ...
                           'BRAIDLAB:databraid:sort_sim_tcross:badsimtimes')
    end

    function test_databraid_ftbe(testCase)
      dbr = testCase.dbrtest;
      testCase.verifyEqual(dbr.ftbe('method','proj'), ...
                           dbr.ftbe('method','nonproj'),...
                           'AbsTol',1e-12);
    end

    function test_databraid_hidden(testCase)
      % Make sure some hidden methods inherited from braid class give error.
      dbr = testCase.dbrtest;
      testCase.verifyError(@() mpower(dbr,2), ...
                           'BRAIDLAB:databraid:mpower:undefined');
      testCase.verifyError(@() inv(dbr), ...
                           'BRAIDLAB:databraid:inv:undefined');
      testCase.verifyError(@() entropy(dbr), ...
                           'BRAIDLAB:databraid:entropy:undefined');
      testCase.verifyError(@() complexity(dbr), ...
                           'BRAIDLAB:databraid:complexity:undefined');
    end

    function test_databraid_compact(testCase)
      % See issue #95.
      b1 = compact(braidlab.databraid([1 2 -2 3],[1 2 3 4]));
      b2 = braidlab.databraid([1 3],[1 4]);
      testCase.verifyTrue(b1 == b2);
    end

    function test_databraid_tensor(testCase)
      % See issue #93.
      b = braidlab.databraid([1 2]);
      bb = tensor(b,b);
      bb2 = braidlab.databraid([1 4 2 5],[1 1 2 2]);
      testCase.verifyTrue(bb == bb2);
      bbb = tensor(b,b,b);
      bbb2 = braidlab.databraid([1 4 7 2 5 8],[1 1 1 2 2 2]);
      testCase.verifyTrue(bbb == bbb2);
    end

    function test_databraid_subbraid(testCase)

    %% Test that Matlab and MEX subbraids return the same result
      n = testCase.dbrtest.n;
      substrands = 1:2:n;

      global BRAIDLAB_braid_nomex
      flagstate = BRAIDLAB_braid_nomex;

      BRAIDLAB_braid_nomex = false;
      subMat = testCase.dbrtest.subbraid(substrands);
      BRAIDLAB_braid_nomex = true;
      subMex = testCase.dbrtest.subbraid(substrands);

      testCase.verifyTrue( lexeq(subMat,subMex) );
      testCase.verifyEqual( subMat,subMex );

      % unset global flag
      BRAIDLAB_braid_nomex = flagstate;
      if isempty(flagstate)
        clear global BRAIDLAB_braid_nomex
      end

    end
  end
end
