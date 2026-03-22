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

classdef utilTest < matlab.unittest.TestCase

  methods (Test)

    %% validateflag tests

    function test_validateflag_partial(testCase)
      % Test partial matching.
      import braidlab.util.validateflag
      result = validateflag('int', 'intaxis', 'minlength', ...
                            {'trains', 'train-tracks', 'bh'});
      testCase.verifyMatches(result, 'intaxis');
    end

    function test_validateflag_case(testCase)
      % Test case-insensitive matching.
      import braidlab.util.validateflag
      result = validateflag('INT', 'intaxis', 'minlength', ...
                            {'trains', 'train-tracks', 'bh'});
      testCase.verifyMatches(result, 'intaxis');
    end

    function test_validateflag_alternate(testCase)
      % Test matching alternate name.
      import braidlab.util.validateflag
      result = validateflag('bh', 'intaxis', 'minlength', ...
                            {'trains', 'train-tracks', 'bh'});
      testCase.verifyMatches(result, 'trains');
    end

    function test_validateflag_unmatched(testCase)
      % Test unmatched string throws error.
      import braidlab.util.validateflag
      testCase.verifyError(@() validateflag('int'), ...
                           'BRAIDLAB:validateflag:flaginvalid');
    end

    function test_validateflag_exactmatch(testCase)
      % Test exact match.
      import braidlab.util.validateflag
      result = validateflag('minlength', 'intaxis', 'minlength');
      testCase.verifyMatches(result, 'minlength');
    end

    %% checkvpi tests

    function test_checkvpi_noerror(testCase)
      % Test checkvpi runs without error.
      import braidlab.util.checkvpi
      testCase.verifyWarningFree(@() checkvpi());
    end

    function test_checkvpi_vpiexists(testCase)
      % Test that VPI class exists after checkvpi.
      import braidlab.util.checkvpi
      checkvpi();
      testCase.verifyTrue(exist('vpi', 'file') > 0);
    end

    %% getAvailableThreadNumber tests

    function test_getthreads_positive(testCase)
      % Test getAvailableThreadNumber returns positive integer.
      import braidlab.util.getAvailableThreadNumber
      nthreads = getAvailableThreadNumber();
      testCase.verifyGreaterThan(nthreads, 0);
      testCase.verifyTrue(floor(nthreads) == nthreads);
    end

    %% assertmex tests

    function test_assertmex_nonexisting(testCase)
      % Test assertmex returns false for non-existing MEX file.
      import braidlab.util.assertmex
      result = assertmex('nonexistent_mex_file_xyz');
      testCase.verifyFalse(result);
    end

    %% debugmsg tests

    function test_debugmsg_noerror(testCase)
      % Test debugmsg runs without error.
      import braidlab.util.debugmsg
      testCase.verifyWarningFree(@() debugmsg('test message', 999));
    end

    %% prop tests

    function test_prop_returns_struct(testCase)
      % Test prop with no arguments returns struct.
      braidlab.prop('reset');
      p = braidlab.prop();
      testCase.verifyTrue(isstruct(p));
    end

    function test_prop_default_fields(testCase)
      % Test prop struct has expected fields.
      braidlab.prop('reset');
      p = braidlab.prop();
      testCase.verifyTrue(isfield(p, 'GenRotDir'));
      testCase.verifyTrue(isfield(p, 'GenLoopActDir'));
      testCase.verifyTrue(isfield(p, 'GenPlotOverUnder'));
      testCase.verifyTrue(isfield(p, 'BraidPlotDir'));
      testCase.verifyTrue(isfield(p, 'BraidAbsTol'));
      testCase.verifyTrue(isfield(p, 'LoopCoordsBasePoint'));
    end

    function test_prop_default_values(testCase)
      % Test prop default values.
      braidlab.prop('reset');
      testCase.verifyEqual(braidlab.prop('GenRotDir'), 1);
      testCase.verifyEqual(braidlab.prop('GenLoopActDir'), 'lr');
      testCase.verifyEqual(braidlab.prop('GenPlotOverUnder'), true);
      testCase.verifyEqual(braidlab.prop('BraidPlotDir'), 'bt');
      testCase.verifyEqual(braidlab.prop('BraidAbsTol'), 1e-10);
      testCase.verifyEqual(braidlab.prop('LoopCoordsBasePoint'), 'right');
    end

    function test_prop_set_genrotdir(testCase)
      % Test setting GenRotDir property.
      braidlab.prop('reset');
      braidlab.prop('GenRotDir', -1);
      testCase.verifyEqual(braidlab.prop('GenRotDir'), -1);
      braidlab.prop('reset');
    end

    function test_prop_set_genloopactdir(testCase)
      % Test setting GenLoopActDir property.
      braidlab.prop('reset');
      braidlab.prop('GenLoopActDir', 'rl');
      testCase.verifyEqual(braidlab.prop('GenLoopActDir'), 'rl');
      braidlab.prop('reset');
    end

    function test_prop_set_braidplotdir(testCase)
      % Test setting BraidPlotDir property.
      braidlab.prop('reset');
      braidlab.prop('BraidPlotDir', 'lr');
      testCase.verifyEqual(braidlab.prop('BraidPlotDir'), 'lr');
      braidlab.prop('reset');
    end

    function test_prop_set_braidabstol(testCase)
      % Test setting BraidAbsTol property.
      braidlab.prop('reset');
      braidlab.prop('BraidAbsTol', 1e-5);
      testCase.verifyEqual(braidlab.prop('BraidAbsTol'), 1e-5);
      braidlab.prop('reset');
    end

    function test_prop_set_loopcoordsbasepoint(testCase)
      % Test setting LoopCoordsBasePoint property.
      braidlab.prop('reset');
      braidlab.prop('LoopCoordsBasePoint', 'left');
      testCase.verifyEqual(braidlab.prop('LoopCoordsBasePoint'), 'left');
      braidlab.prop('reset');
    end

    function test_prop_dehornoy_option(testCase)
      % Test 'dehornoy' sets basepoint to left and GenRotDir to -1.
      braidlab.prop('reset');
      braidlab.prop('LoopCoordsBasePoint', 'dehornoy');
      testCase.verifyEqual(braidlab.prop('LoopCoordsBasePoint'), 'left');
      testCase.verifyEqual(braidlab.prop('GenRotDir'), -1);
      braidlab.prop('reset');
    end

    function test_prop_reset(testCase)
      % Test reset restores default values.
      braidlab.prop('GenRotDir', -1);
      braidlab.prop('BraidAbsTol', 1e-3);
      braidlab.prop('reset');
      testCase.verifyEqual(braidlab.prop('GenRotDir'), 1);
      testCase.verifyEqual(braidlab.prop('BraidAbsTol'), 1e-10);
    end

    function test_prop_badarg_error(testCase)
      % Test error for unknown property name.
      testCase.verifyError(@() braidlab.prop('garbage'), ...
                           'BRAIDLAB:prop:badarg');
    end

  end
end
