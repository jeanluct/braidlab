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

classdef randomwalkTest < matlab.unittest.TestCase

  methods (Test)

    %% Output format tests

    function test_output_size(testCase)
      % Test output array size.
      rng(1);
      nparticles = 4;
      nsteps = 10;
      XY = braidlab.randomwalk(nparticles, nsteps, 0.1);
      testCase.verifyEqual(size(XY), [nsteps+1, 2, nparticles]);
    end

    function test_output_class(testCase)
      % Test output is numeric array.
      rng(1);
      XY = braidlab.randomwalk(3, 5, 0.1);
      testCase.verifyTrue(isnumeric(XY));
    end

    %% Domain tests

    function test_domain_square(testCase)
      % Test square domain (default).
      rng(1);
      XY = braidlab.randomwalk(4, 100, 0.1, 'square');
      % All points should be in [0,1] x [0,1].
      testCase.verifyGreaterThanOrEqual(min(XY(:)), 0);
      testCase.verifyLessThanOrEqual(max(XY(:)), 1);
    end

    function test_domain_disk(testCase)
      % Test disk domain.
      rng(1);
      XY = braidlab.randomwalk(4, 100, 0.1, 'disk');
      % All points should be within unit disk.
      for k = 1:size(XY, 3)
        r = sqrt(XY(:,1,k).^2 + XY(:,2,k).^2);
        testCase.verifyLessThanOrEqual(max(r), 1 + 0.1);  % Allow for step size.
      end
    end

    function test_domain_plane(testCase)
      % Test plane domain (unbounded).
      rng(1);
      XY = braidlab.randomwalk(4, 10, 0.1, 'plane');
      testCase.verifyEqual(size(XY, 1), 11);
    end

    %% Initial conditions tests

    function test_initial_fromX0(testCase)
      % Test with specified initial positions.
      X0 = [0.2 0.4 0.6 0.8; 0.5 0.5 0.5 0.5];
      XY = braidlab.randomwalk(X0, 5, 0.01);
      % Check initial positions match.
      for k = 1:4
        testCase.verifyEqual(squeeze(XY(1,:,k))', X0(:,k), 'AbsTol', 1e-10);
      end
    end

    %% Braid from randomwalk tests

    function test_braid_notclosed(testCase)
      % Data doesn't close, so braid creation warns.
      rng(1);
      XY = braidlab.randomwalk(4, 2, 1);
      testCase.verifyWarning(@() braidlab.braid(XY), ...
                             'BRAIDLAB:braid:colorbraiding:notclosed');
    end

    function test_braid_closed(testCase)
      % Test braid from closed randomwalk.
      rng(1);
      XY = braidlab.randomwalk(4, 2, 1);
      br = braidlab.braid(braidlab.closure(XY));
      testCase.verifyEqual(br, braidlab.braid([1 -3 -2 3 1 2 3 1 2]));
    end

    function test_braid_projectionangle(testCase)
      % Test braid with projection angle.
      rng(1);
      XY = braidlab.closure(braidlab.randomwalk(4, 2, 1));
      br = braidlab.braid(XY, pi/4);
      testCase.verifyEqual(br, braidlab.braid([2 -3 -2 1 2 3 1 2 1]));
    end

    function test_braid_pureclosure(testCase)
      % Test braid from pure closure.
      rng(1);
      XY = braidlab.randomwalk(4, 2, 1);
      br = braidlab.braid(braidlab.closure(XY, 'pure'));
      testCase.verifyEqual(br, braidlab.braid([1 -3 -2 3 1 2 3 1 2 1 3 2]));
      testCase.verifyTrue(br.ispure);
    end

    %% Error tests

    function test_error_noparticles(testCase)
      % Test error with no particles.
      testCase.verifyError(@() braidlab.randomwalk(0, 10, 0.1), ...
                           'BRAIDLAB:randomwalk:badarg');
    end

    function test_error_nosteps(testCase)
      % Test error with no steps.
      testCase.verifyError(@() braidlab.randomwalk(4, 0, 0.1), ...
                           'BRAIDLAB:randomwalk:badarg');
    end

    function test_error_badeps(testCase)
      % Test error with non-positive epsilon.
      testCase.verifyError(@() braidlab.randomwalk(4, 10, 0), ...
                           'BRAIDLAB:randomwalk:badarg');
      testCase.verifyError(@() braidlab.randomwalk(4, 10, -0.1), ...
                           'BRAIDLAB:randomwalk:badarg');
    end

    function test_error_baddomain(testCase)
      % Test error with unknown domain.
      testCase.verifyError(@() braidlab.randomwalk(4, 10, 0.1, 'unknown'), ...
                           'BRAIDLAB:randomwalk:badarg');
    end

  end
end
