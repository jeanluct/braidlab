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
    dbrtest
    dbrnutest
  end

  methods (Static)
    function verifyErrorWithCause( obj, trigger, name, cause )
      if ischar(cause)
        cause = {cause};
      end
      obj.verifyThat( trigger, ...
                      matlab.unittest.constraints.Throws(...
                          name, 'CausedBy', cause ) );
    end
  end


  methods (TestMethodSetup)
    %% matrix version of inputs (for uniform sampled data)
    function create_uniform_databraid(testCase)
      import braidlab.databraid

      data = load('testdata','XY','ti');
      testCase.dbrtest = databraid(data.XY,data.ti);
    end
    % %% cell version of inputs (for non-uniform sampled data)
    % function create_nonuniform_databraid(testCase)
    %   import braidlab.databraid

    %   % for now, these are the same trajectories as in the testdata_matrix
    %   % except that they are packaged as cells
    %   data = load('testdata_cell','XY','ti');
    %   testCase.dbrnutest = databraid(data.XY,data.ti);
    % end

  end

  methods (Test)
    function test_databraid_constructor(testCase)
      import braidlab.databraid

      % TODO: here test different forms of constructor.
      verifyBadArgWCause = @(f,c)databraidTest.verifyErrorWithCause( ...
          testCase, f, 'BRAIDLAB:databraid:databraid:badarg',...
          c );

      % Not enough input arguments.
      testCase.verifyError(@() databraid, ...
                           'BRAIDLAB:databraid:databraid:badparse');
      % Wrong number of crossing times.
      verifyBadArgWCause(@() databraid([1 2],1), ...
                         'BRAIDLAB:databraid:check_tcross:badtimes');
      % Decreasing crossing times.
      verifyBadArgWCause(@() databraid([1 2],[1 0]), ...
                         'BRAIDLAB:databraid:check_tcross:badtimes');
      % Simultaneous times for noncommuting generators.
      verifyBadArgWCause(@() databraid([1 2],[1 1]), ...
                         'BRAIDLAB:databraid:sort_sim_tcross:badsimtimes');

      % Simultaneous times for *commuting* generators is ok.
      databraid([1 3],[1 1]);

      % However all the generators have to pairwise commute.
      % This shouldn't work: see issue #94.
      verifyBadArgWCause(@() databraid([4 1 3],[1 1 1]), ...
                         'BRAIDLAB:databraid:sort_sim_tcross:badsimtimes');

      % A more complicated example with two simultaneous blocks.  The first
      % has the generators [5 1 3], which is fine, the second [7 6], which
      % is not.
      verifyBadArgWCause(@() ...
                         databraid([ 1  2  3 5 1 3 4 5 6 7 6], ...
                                   [-3 -2 -1 1 1 1 2 3 4 5 5]), ...
                         'BRAIDLAB:databraid:sort_sim_tcross:badsimtimes');
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
      import matlab.unittest.constraints.Throws

      % Here the last tcrossing ime of b1 is after the first crossing
      % time of b2.
      b1 = databraid([1 2],[1 3]);
      b2 = databraid([1 2],[2 4]);
      databraidTest.verifyErrorWithCause(testCase, @()b1*b2, ...
                           'BRAIDLAB:databraid:mtimes:invalidproduct',...
                           'BRAIDLAB:databraid:check_tcross:badtimes');

      % This is ok: the last generator of b1 commutes with the first of
      % b2, even though they have the same crossing time.
      b1 = databraid([1 3],[1 2]);
      b2 = databraid([5 2],[2 3]);
      b12 = b1*b2; %#ok<NASGU>
                   % This is not ok: the generators at the ends don't commute.
      b1 = databraid([1 3],[1 2]);
      b2 = databraid([4 2],[2 3]);

      databraidTest.verifyErrorWithCause(testCase, @()b1*b2, ...
                           'BRAIDLAB:databraid:mtimes:invalidproduct',...
                           'BRAIDLAB:databraid:sort_sim_tcross:badsimtimes');

      % This shouldn't work: 6 and 5 don't commute.  See issue #98.
      b1 = databraid([1 5 3],[1 2 2]);
      b2 = databraid([6 2],[2 3]);

      databraidTest.verifyErrorWithCause(testCase, @()b1*b2, ...
                           'BRAIDLAB:databraid:mtimes:invalidproduct',...
                           'BRAIDLAB:databraid:sort_sim_tcross:badsimtimes');

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
