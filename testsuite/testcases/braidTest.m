% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   http://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2017  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
%                            Marko Budisic          <marko@clarkson.edu>
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

classdef braidTest < matlab.unittest.TestCase

  properties
    b1
    b2
    b3
    id
    pure
    dbr
    XYcoincend
  end

  %methods (TestClassSetup)
  %  function addbraidFolderToPath(testCase)
  %    testCase.addTeardown(@path, addpath(fullfile(pwd,'..')));
  %  end
  %end

  methods (TestMethodSetup)
    function createBraid(testCase)
      import braidlab.braid
      testCase.b1 = braid([1 -2 3 5],7);
      testCase.b2 = braid([1 2 4 6],7);
      testCase.b3 = braid([1 -2 3 5 2 1 2 -1 -2 -1],7);
      testCase.id = braid([],7);
      testCase.pure = braid([1 -2 1 -2 1 -2]);

      % trajectories with coincident coordinates
      % at the last time slice
      testCase.XYcoincend = zeros(2,2,3);
      testCase.XYcoincend(1,:,1) = [0 1];
      testCase.XYcoincend(2,:,1) = [1 3];
      testCase.XYcoincend(1,:,2) = [1 0];
      testCase.XYcoincend(2,:,2) = [1 0];
      testCase.XYcoincend(1,:,3) = [2 0];
      testCase.XYcoincend(2,:,3) = [2 0];
      testCase.XYcoincend = braidlab.closure(testCase.XYcoincend);

    end
  end

  methods (Test)
    function test_braid_constructor(testCase)
      b = testCase.b1;
      testCase.verifyEqual(b.word,int32([1 -2 3 5]));
      testCase.verifyEqual(b.n,7);

      % Zero is not a valid generator value.
      testCase.verifyError(@() braidlab.braid([0 0 1]), ...
                           'BRAIDLAB:braid:setword:badarg');

      b = braidlab.braid('halftwist',5);
      testCase.verifyEqual(b.word,int32([4 3 2 1 4 3 2 4 3 4]));

      rng(1);
      b = braidlab.braid('random',5,7);
      testCase.verifyEqual(b,braidlab.braid([-2 2 -3 -2 -3 -1 -4]));

      testCase.verifyError(@() braidlab.braid('garbage'), ...
                           'BRAIDLAB:braid:braid:badarg');

      b = braidlab.braid('HironakaKin',3,1);
      testCase.verifyEqual(b,braidlab.braid([1 2 3 3 2 1 1 2 3 4]));

      testCase.verifyError(@() braidlab.braid('HironakaKin',4), ...
                           'BRAIDLAB:braid:braid:badarg');

      testCase.verifyError(@() braidlab.braid('VenzkePsi',4), ...
                           'BRAIDLAB:braid:braid:badarg');

      b = braidlab.braid('VenzkePsi',5);
      testCase.verifyEqual(b,braidlab.braid([4 3 2 1 4 3 2 1 -1 -2]));
      b = braidlab.braid('VenzkePsi',6);
      testCase.verifyEqual(b,braidlab.braid([5 4 3 2 1 5 4 3 5 4]));

      % Too many input arguments for creating a braid from data.
      testCase.verifyError(@() braidlab.braid(zeros(3,2,4),1,1), ...
                           'BRAIDLAB:braid:braid:badarg');

      % Creating a braid from a two-dimensional array is assumed to be a
      % single-particle dataset.  Print a warning, though.
      testCase.verifyWarning(@() braidlab.braid([1 2;2 3;-1 3]), ...
                             'BRAIDLAB:braid:braid:onetraj');

      % Two particles have a coincident position.
      XY = zeros(4,2,2);
      testCase.verifyError(@() braidlab.braid(XY), ...
                           'BRAIDLAB:braid:colorbraiding:coincidentparticles');
      % Now they only coincide in the default projection.
      XY(:,2,2) = 2;
      testCase.verifyError(@() braidlab.braid(XY), ...
                           'BRAIDLAB:braid:colorbraiding:coincidentprojection');
      % Changing the projection gets rid of the error.
      testCase.verifyTrue(braidlab.braid(XY,.1) == ...
                          braidlab.braid([],2));

      % Coincidence at the end of interval - see GitHub Iss #109.
      testCase.verifyError(@() braidlab.braid(testCase.XYcoincend), ...
                           'BRAIDLAB:braid:colorbraiding:coincidentprojection');
    end

    function test_braid_from_randomwalk(testCase)
      rng(1);
      XY = braidlab.randomwalk(4,2,1);
      % The data doesn't close, so braid creation errors.
      testCase.verifyWarning(@() braidlab.braid(XY), ...
                             'BRAIDLAB:braid:colorbraiding:notclosed');
      b = braidlab.braid(braidlab.closure(XY));
      testCase.verifyEqual(b,braidlab.braid([1 -3 -2 3 1 2 3 1 2]));

      b = braidlab.braid(braidlab.closure(braidlab.randomwalk(4,2,1)),pi/4);
      testCase.verifyEqual(b,braidlab.braid([1  3  2 -1 -3  1 -2 -3 -1]));
    end

    function test_braid_equal(testCase)
      testCase.verifyTrue(testCase.b1 == testCase.b3);
      testCase.verifyFalse(testCase.b1 ~= testCase.b3);
      testCase.verifyTrue(testCase.id == braidlab.braid([1 -1],7));
    end

    function test_braid_lexequal(testCase)
      testCase.verifyTrue(testCase.b1 == testCase.b1);
      testCase.verifyFalse(testCase.b1 ~= testCase.b1);
    end

    function test_braid_istrivial(testCase)
      testCase.verifyFalse(istrivial(testCase.b1));
      testCase.verifyTrue(istrivial(testCase.id));
    end

    function test_braid_ispure(testCase)
      testCase.verifyFalse(ispure(testCase.b1));
      testCase.verifyTrue(ispure(testCase.pure));
      testCase.verifyTrue(ispure(testCase.id));
    end

    function test_braid_mtimes(testCase)
      b = testCase.b1*testCase.b2;
      testCase.verifyEqual(b,braidlab.braid([1 -2 3 5 1 2 4 6]));
    end

    function test_braid_mpower(testCase)
      b = testCase.b1^3;
      testCase.verifyEqual(b,braidlab.braid([1 -2 3 5 1 -2 3 5 1 -2 3 5],7));
    end

    function test_braid_inv(testCase)
      testCase.verifyEqual(testCase.b1.inv,braidlab.braid([-5 -3 2 -1],7));
      testCase.verifyTrue(testCase.id.inv == testCase.id);
    end

    function test_braid_perm(testCase)
      testCase.verifyEqual(testCase.b1.perm,[2 3 4 1 6 5 7]);
      testCase.verifyEqual(testCase.id.perm,1:7);
    end

    function test_braid_writhe(testCase)
      testCase.verifyEqual(testCase.b1.writhe,2);
      testCase.verifyEqual(testCase.id.writhe,0);
    end

    function test_braid_length(testCase)
      testCase.verifyEqual(testCase.b1.length,4);
      testCase.verifyEqual(testCase.id.length,0);
    end

    function test_braid_subbraid(testCase)
      b = testCase.b3;
      bsub = braidlab.braid([3 1 -1],4);
      testCase.verifyEqual(b.subbraid(3:6),bsub);
      testCase.verifyTrue(lexeq(b.subbraid(3:6),bsub));
    end
  end
end
