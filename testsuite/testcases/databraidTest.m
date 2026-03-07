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

    %% Constructor tests

    function test_constructor_noarg(testCase)
      % Not enough input arguments.
      import braidlab.databraid
      testCase.verifyError(@() databraid, ...
                           'BRAIDLAB:databraid:databraid:badarg');
    end

    function test_constructor_toomanyargs(testCase)
      % Too many input arguments.
      import braidlab.databraid
      % The error message id changed name from R2016b.
      maxver = '9.1.0.441655'; maxrel = '2016b'; %#ok<NASGU>
      if verLessThan('matlab', maxver)
        maxrhs_id = 'MATLAB:maxrhs';
      else
        maxrhs_id = 'MATLAB:TooManyInputs';
      end
      testCase.verifyError(@() databraid(1,1,1,1), maxrhs_id);
    end

    function test_constructor_wrongtimes(testCase)
      % Wrong number of crossing times.
      import braidlab.databraid
      testCase.verifyError(@() databraid([1 2],1), ...
                           'BRAIDLAB:databraid:check_tcross:badtimes');
    end

    function test_constructor_decreasingtimes(testCase)
      % Decreasing crossing times.
      import braidlab.databraid
      testCase.verifyError(@() databraid([1 2],[1 0]), ...
                           'BRAIDLAB:databraid:check_tcross:badtimes');
    end

    function test_constructor_simultaneous_noncommuting(testCase)
      % Simultaneous times for noncommuting generators.
      import braidlab.databraid
      testCase.verifyError(@() databraid([1 2],[1 1]), ...
                           'BRAIDLAB:databraid:sort_sim_tcross:badsimtimes');
    end

    function test_constructor_simultaneous_commuting(testCase)
      % Simultaneous times for *commuting* generators is ok.
      import braidlab.databraid
      db = databraid([1 3],[1 1]);
      testCase.verifyEqual(db.word, int32([1 3]));
    end

    function test_constructor_simultaneous_pairwise(testCase)
      % All the generators have to pairwise commute.  Issue #94.
      import braidlab.databraid
      testCase.verifyError(@() databraid([4 1 3],[1 1 1]), ...
                           'BRAIDLAB:databraid:sort_sim_tcross:badsimtimes');
    end

    function test_constructor_simultaneous_blocks(testCase)
      % A more complicated example with two simultaneous blocks.  The first
      % has the generators [5 1 3], which is fine, the second [7 6], which
      % is not.
      import braidlab.databraid
      testCase.verifyError(@() ...
                           databraid([ 1  2  3 5 1 3 4 5 6 7 6], ...
                                     [-3 -2 -1 1 1 1 2 3 4 5 5]), ...
                           'BRAIDLAB:databraid:sort_sim_tcross:badsimtimes')
    end

    function test_constructor_simultaneous_blocks_commute(testCase)
      % Replace 7 by 8: now [8 6] commute, and it's ok.
      import braidlab.databraid
      db = databraid([1 2 3 5 1 3 4 5 6 8 6],[-3 -2 -1 1 1 1 2 3 4 5 5]);
      testCase.verifyEqual(db.n, 11);
    end

    function test_constructor_from_braid(testCase)
      % Construct from a braid object.
      import braidlab.databraid
      br = braidlab.braid([1 2 3], 4);
      db = databraid(br, [1 2 3]);
      testCase.verifyEqual(db.word, int32([1 2 3]));
      testCase.verifyEqual(db.tcross, [1 2 3]);
      testCase.verifyEqual(db.n, 4);
    end

    function test_constructor_from_braid_defaulttimes(testCase)
      % Construct from a braid with default times.
      import braidlab.databraid
      br = braidlab.braid([1 2 -1], 3);
      db = databraid(br);
      testCase.verifyEqual(db.tcross, [1 2 3]);
    end

    function test_constructor_from_word(testCase)
      % Construct from a generator word.
      import braidlab.databraid
      db = databraid([1 2 1], [0.1 0.2 0.3]);
      testCase.verifyEqual(db.word, int32([1 2 1]));
      testCase.verifyEqual(db.tcross, [0.1 0.2 0.3]);
    end

    %% Properties tests

    function test_properties_tcross(testCase)
      % Test tcross property.
      import braidlab.databraid
      db = databraid([1 2],[1 2]);
      testCase.verifyEqual(db.tcross, [1 2]);
    end

    function test_properties_n(testCase)
      % Test n property (inherited).
      import braidlab.databraid
      db = databraid([3 -2 1],[1 2 3]);
      testCase.verifyEqual(db.n, 4);
    end

    function test_properties_word(testCase)
      % Test word property (inherited).
      import braidlab.databraid
      db = databraid([1 -2 1],[1 2 3]);
      testCase.verifyEqual(db.word, int32([1 -2 1]));
    end

    %% Conversion tests

    function test_conversion_tobraid(testCase)
      % Convert databraid to braid.
      import braidlab.databraid
      db = databraid([1 2 -1],[1 2 3]);
      br = braidlab.braid(db);
      testCase.verifyClass(br, 'braidlab.braid');
      testCase.verifyEqual(br.word, int32([1 2 -1]));
      testCase.verifyEqual(br.n, 3);
    end

    %% Equality tests

    function test_eq_different_tcross(testCase)
      % Crossing times must match for equality.
      import braidlab.databraid
      db1 = databraid([1 2],[1 2]);
      db2 = databraid([1 2],[2 3]);
      testCase.verifyTrue(db1 ~= db2);
    end

    function test_eq_same_tcross(testCase)
      % Same generators and times.
      import braidlab.databraid
      db1 = databraid([1 2],[1 2]);
      db2 = databraid([1 2],[1 2]);
      testCase.verifyTrue(db1 == db2);
    end

    function test_eq_lexicographic(testCase)
      % These braids are equal, but they must be lexicographically equal
      % to match as databraids.
      db1 = braidlab.databraid([1 2 -2 3],[1 2 3 4]);
      db2 = braidlab.databraid([1 3],[1 4]);
      testCase.verifyTrue(db1 ~= db2);
    end

    function test_eq_simultaneous_issue97(testCase)
      % These should be equal: see issue #97.
      db1 = braidlab.databraid([1 2 -3  5 -7 6],[1 2 3 3 3 4]);
      db2 = braidlab.databraid([1 2  5 -7 -3 6],[1 2 3 3 3 4]);
      testCase.verifyTrue(db1 == db2);
    end

    %% mtimes tests

    function test_mtimes_nonchronological(testCase)
      % Last crossing time of b1 is after first crossing time of b2.
      import braidlab.databraid
      db1 = databraid([1 2],[1 3]);
      db2 = databraid([1 2],[2 4]);
      testCase.verifyError(@() db1*db2,'BRAIDLAB:databraid:mtimes:notchrono');
    end

    function test_mtimes_commuting_endpoints(testCase)
      % Last generator of b1 commutes with first of b2, same crossing time.
      import braidlab.databraid
      db1 = databraid([1 3],[1 2]);
      db2 = databraid([5 2],[2 3]);
      db12 = db1*db2;
      testCase.verifyEqual(db12.word, int32([1 3 5 2]));
      testCase.verifyEqual(db12.tcross, [1 2 2 3]);
    end

    function test_mtimes_noncommuting_endpoints(testCase)
      % Generators at the ends don't commute.
      import braidlab.databraid
      db1 = databraid([1 3],[1 2]);
      db2 = databraid([4 2],[2 3]);
      testCase.verifyError(@() db1*db2, ...
                           'BRAIDLAB:databraid:sort_sim_tcross:badsimtimes');
    end

    function test_mtimes_issue98(testCase)
      % 6 and 5 don't commute.  See issue #98.
      import braidlab.databraid
      db1 = databraid([1 5 3],[1 2 2]);
      db2 = databraid([6 2],[2 3]);
      testCase.verifyError(@() db1*db2, ...
                           'BRAIDLAB:databraid:sort_sim_tcross:badsimtimes')
    end

    function test_mtimes_onloop(testCase)
      % Action of databraid on a loop.
      import braidlab.databraid
      db = databraid([1 2],[1 2]);
      lo = braidlab.loop(3);
      lo2 = db*lo;
      testCase.verifyClass(lo2, 'braidlab.loop');
    end

    %% ftbe tests

    function test_ftbe_proj_vs_nonproj(testCase)
      dbr = testCase.dbrtest;
      testCase.verifyEqual(dbr.ftbe('method','proj'), ...
                           dbr.ftbe('method','nonproj'),...
                           'AbsTol',1e-12);
    end

    %% compact tests

    function test_compact_issue95(testCase)
      % See issue #95.
      db1 = compact(braidlab.databraid([1 2 -2 3],[1 2 3 4]));
      db2 = braidlab.databraid([1 3],[1 4]);
      testCase.verifyTrue(db1 == db2);
    end

    function test_compact_preservestimes(testCase)
      % Verify compact preserves relevant crossing times.
      import braidlab.databraid
      db = databraid([1 -1 2],[1 2 3]);
      dbc = compact(db);
      testCase.verifyEqual(dbc.word, int32(2));
      testCase.verifyEqual(dbc.tcross, 3);
    end

    %% tensor tests

    function test_tensor_two(testCase)
      % See issue #93.
      db = braidlab.databraid([1 2]);
      dbdb = tensor(db,db);
      dbdb2 = braidlab.databraid([1 4 2 5],[1 1 2 2]);
      testCase.verifyTrue(dbdb == dbdb2);
    end

    function test_tensor_three(testCase)
      db = braidlab.databraid([1 2]);
      dbdbdb = tensor(db,db,db);
      dbdbdb2 = braidlab.databraid([1 4 7 2 5 8],[1 1 1 2 2 2]);
      testCase.verifyTrue(dbdbdb == dbdbdb2);
    end

    %% trunc tests

    function test_trunc_badarg(testCase)
      import braidlab.databraid
      db = databraid([1 2 3],[1 2 3]);
      testCase.verifyError(@() trunc(db), ...
                           'BRAIDLAB:databraid:trunc:badarg');
    end

    function test_trunc_emptyinterval(testCase)
      import braidlab.databraid
      db = databraid([1 2 3],[1 2 3]);
      testCase.verifyError(@() trunc(db,[]), ...
                           'BRAIDLAB:databraid:trunc:badarg');
    end

    function test_trunc_scalar(testCase)
      % Truncate to tcross <= interval.
      import braidlab.databraid
      db = databraid([1 2 3],[1 2 3]);
      dbt = trunc(db, 2);
      testCase.verifyEqual(dbt.word, int32([1 2]));
      testCase.verifyEqual(dbt.tcross, [1 2]);
    end

    function test_trunc_interval(testCase)
      % Truncate to interval.
      import braidlab.databraid
      db = databraid([1 2 3 4],[1 2 3 4]);
      dbt = trunc(db, [2 3]);
      testCase.verifyEqual(dbt.word, int32([2 3]));
      testCase.verifyEqual(dbt.tcross, [2 3]);
    end

    %% subbraid tests

    function test_subbraid_mex(testCase)
      % Skip this test if MEX algorithms are disabled globally.
      global BRAIDLAB_braid_nomex %#ok<GVMIS>
      if ~isempty(BRAIDLAB_braid_nomex) && BRAIDLAB_braid_nomex
        testCase.assumeTrue(false, ...
          'Skipping MEX-specific test when BRAIDLAB_braid_nomex is set.');
      end

      % Test that Matlab and MEX subbraids return the same result
      nstrands = testCase.dbrtest.n;
      substrands = 1:2:nstrands;

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

    function test_subbraid_tcross(testCase)
      % Verify subbraid preserves crossing times.
      import braidlab.databraid
      db = databraid([1 2 1],[1 2 3]);
      dbs = db.subbraid([1 2]);
      % Generator 1 crosses strands 1-2, generator 2 crosses 2-3 (not in sub).
      % The third gen [1] crosses 1-2, but the strands have moved.
      testCase.verifyEqual(dbs.tcross, 1);
      testCase.verifyEqual(dbs.word, int32(1));
    end

    %% Hidden inherited methods tests

    function test_hidden_mpower(testCase)
      dbr = testCase.dbrtest;
      testCase.verifyError(@() mpower(dbr,2), ...
                           'BRAIDLAB:databraid:mpower:undefined');
    end

    function test_hidden_inv(testCase)
      dbr = testCase.dbrtest;
      testCase.verifyError(@() inv(dbr), ...
                           'BRAIDLAB:databraid:inv:undefined');
    end

    function test_hidden_entropy(testCase)
      dbr = testCase.dbrtest;
      testCase.verifyError(@() entropy(dbr), ...
                           'BRAIDLAB:databraid:entropy:undefined');
    end

    function test_hidden_complexity(testCase)
      dbr = testCase.dbrtest;
      testCase.verifyError(@() complexity(dbr), ...
                           'BRAIDLAB:databraid:complexity:undefined');
    end

    function test_hidden_conjtest(testCase)
      dbr = testCase.dbrtest;
      testCase.verifyError(@() conjtest(dbr,dbr), ...
                           'BRAIDLAB:databraid:conjtest:undefined');
    end

    function test_hidden_cycle(testCase)
      dbr = testCase.dbrtest;
      testCase.verifyError(@() cycle(dbr), ...
                           'BRAIDLAB:databraid:cycle:undefined');
    end

  end
end
