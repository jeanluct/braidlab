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

classdef loopTest < matlab.unittest.TestCase

  properties
    % Names of some predefined test cases.
    l1
    l2
    b
  end

  methods (TestMethodSetup)
    function createLoop(testCase)
      import braidlab.braid
      import braidlab.loop
      testCase.l1 = loop([1 -1 2 3]);
      testCase.l2 = loop([1 -1 2 3; 2 3 -1 2]);  % two loops (column)
      testCase.b = braid([1 -2 1 -2 1 -2]);
    end
  end

  methods (Test)
    function test_loop_constructor(testCase)
      % A simple loop.
      l = testCase.l1;
      testCase.verifyEqual(l.coords,[1 -1 2 3]);
      testCase.verifyEqual(l.a,[1 -1]);
      testCase.verifyEqual(l.b,[2 3]);
      [a,b] = l.ab; %#ok<*PROP>
      testCase.verifyEqual(a,[1 -1]);
      testCase.verifyEqual(b,[2 3]);
      % Create the same loop by specifying a,b.
      testCase.verifyEqual(l.a,braidlab.loop([1 -1],[2 3]).a);
      testCase.verifyEqual(l.b,braidlab.loop([1 -1],[2 3]).b);

      % A column vector of loops.
      l = testCase.l2;
      c12 = l.coords;
      testCase.verifyEqual(c12(1,:),[1 -1 2 3]);
      testCase.verifyEqual(c12(2,:),[2 3 -1 2]);
      % All loops the same dimension, so only one puncture size.
      testCase.verifyEqual(l.n,4);
      testCase.verifyEqual(l(2).n,4);

      % Can't make more dimensions than a matrix.
      testCase.verifyError(@()braidlab.loop(zeros(3,3,3)), ...
                           'BRAIDLAB:loop:loop:badarg')

      % The generating set of loops used to build loop coordinates.
      l = braidlab.loop(4);
      testCase.verifyEqual(l.coords,[0 0 0 -1 -1 -1]);

      % Trying to create from odd number of columns should error.
      testCase.verifyError(@()braidlab.loop([1 2 3]), ...
                           'BRAIDLAB:loop:loop:oddlength');
      testCase.verifyError(@()braidlab.loop([1 2 3; 4 5 6]), ...
                           'BRAIDLAB:loop:loop:oddlength');
      % Trying to create from different sizes of a,b should error.
      testCase.verifyError(@()braidlab.loop([1 2 3],[4 5]), ...
                           'BRAIDLAB:loop:loop:badsize')
      % Trying to create from different sizes of a,b should error.
      testCase.verifyError(@()braidlab.loop([1 2 3; 1 2 3],[4 5; 4 5]), ...
                           'BRAIDLAB:loop:loop:badsize')

      % Column vector of loops (bad idea, but no error).
      l0 = [braidlab.loop(testCase.l2.coords(1,:)) ; ...
            braidlab.loop(testCase.l2.coords(2,:))];
      % Subscripting is not allowed on vector... create scalar with
      % multiple loops instead.
      testCase.verifyError(@() l0(1), ...
                           'BRAIDLAB:loop:subsref:notscalar');
    end

    function test_loop_subscripts(testCase)
      l = braidlab.loop(zeros(2,4));
      l(2) = braidlab.loop(3);
      testCase.verifyEqual(l.coords(:),[0 0 0 0 0 -1 0 -1]');
      testCase.verifyEqual(l.n,4);
      testCase.verifyEqual(l(2).n,4);
      testCase.verifyEqual(l(2),braidlab.loop(3));

      % Create multiple loops by accessing an index.
      l2(2) = braidlab.loop(3);
      testCase.verifyEqual(l,l2);
      % Assign coordinates directly for one row.
      l2(2).coords = [1 2 3 4];
      testCase.verifyEqual(l2(2),braidlab.loop([1 2 3 4]));
      % Grow by one loop.
      l2(3).coords = -[1 2 3 4];
      testCase.verifyEqual(l2(3),braidlab.loop(-[1 2 3 4]));
      % Change one coordinate in 3rd loop.
      l2(3).coords(1) = 1;
      testCase.verifyEqual(l2(3),braidlab.loop(-[-1 2 3 4]));
      % Change two coordinates in 2nd loop.
      l2(2).coords(3:end) = [-6 -7];
      testCase.verifyEqual(l2(2),braidlab.loop([1 2 -6 -7]));

      % Verify minlength/intaxis vector functions.
      keyboard
      l = testCase.l2;
      testCase.verifyEqual(l.minlength,[22;24]);
      testCase.verifyEqual(l(1).minlength,22);
      testCase.verifyEqual(l(2).minlength,24);
      testCase.verifyEqual(minlength(l),[22;24]);
      testCase.verifyEqual(minlength(l(1)),22);
      testCase.verifyEqual(minlength(l(2)),24);

      testCase.verifyEqual(l.intaxis,[16;16]);
      testCase.verifyEqual(l(1).intaxis,16);
      testCase.verifyEqual(l(2).intaxis,16);
      testCase.verifyEqual(intaxis(l),[16;16]);
      testCase.verifyEqual(intaxis(l(1)),16);
      testCase.verifyEqual(intaxis(l(2)),16);

      inters = [3 5 5 3 12 8 2;-2 2 -3 3 8 10 6];
      testCase.verifyEqual(intersec(l),inters);
      testCase.verifyEqual(l.intersec,inters);
      % These fail!!!  See issue #74.
      testCase.verifyEqual(l(1).intersec,inters(1,:));
      testCase.verifyEqual(l(2).intersec,inters(2,:));
      testCase.verifyEqual(intersec(l(1)),inters(1,:));
      testCase.verifyEqual(intersec(l(2)),inters(2,:));
    end

    function test_braid_on_loop_action(testCase)
      % An empty braid (was issue #50).
      l0 = braidlab.loop(3);
      l = braidlab.braid([],3)*l0;
      testCase.verifyEqual(l,l0);

      l0 = braidlab.loop(5);
      l = braidlab.braid([],3)*l0;
      testCase.verifyEqual(l,l0);

      % Trying to act with a braid with more strings than the loop.
      testCase.verifyError(@() braidlab.braid([],7)*l0, ...
                           'BRAIDLAB:braid:mtimes:badgen')

      % Trying to act with a braid on unsupported object.
      testCase.verifyError(@() braidlab.braid([],7)*3, ...
                           'BRAIDLAB:braid:mtimes:badobject')
    end

    function test_loopcoords(testCase)
      % Test loop coordinates using various types.
      % This is a method for braid, but essentially uses loops.
      b = braidlab.braid([1 -2 3]);

      l = loopcoords(b);
      testCase.verifyEqual(l.coords,int64([1 -2 1 -2 -2 2]));
      l = loopcoords(b,[],'double');
      testCase.verifyEqual(l.coords,[1 -2 1 -2 -2 2]);
      l = loopcoords(b,[],'int32');
      testCase.verifyEqual(l.coords,int32([1 -2 1 -2 -2 2]));
      l = loopcoords(b,[],'vpi');
      testCase.verifyEqual(l.coords,vpi([1 -2 1 -2 -2 2]));

      l = loopcoords(b,'left');
      testCase.verifyEqual(l.coords,int64([-1 2 -3 0 0 0]));
      l = loopcoords(b,'dehornoy');
      testCase.verifyEqual(l.coords,int64([1 -2 3 0 0 0]));

      % Make a braid that will overflow int64.
      b = braidlab.braid(repmat([1 -2],[1 50]));
      testCase.verifyWarning(@() b.istrivial, ...
                           'BRAIDLAB:braid:loopcoords:overflow')
      testCase.verifyWarning(@() b == b, ...
                           'BRAIDLAB:braid:loopcoords:overflow')
    end

    function test_loop_length_overflow(testCase)
      % Test that manual iteration of loop coordinates and computation of
      % entropy handles integer overflow well.

      mybraid = testCase.b;

      expEntropy = entropy(mybraid);
      l = loopcoords(mybraid);

      tol = 1e-2; % Let's be generous.

      loopEntropy = @(N)(log( double(minlength(mybraid^N*l)) ) ...
                         - log( double(minlength(l)) ) ) / N;

      % This test case is just to ensure that the tolerance set is
      % reasonable.
      Niter = 5;
      err = ['Manual and built-in computations of entropy do not match' ...
             ' at (small) Niter=%d.'];
      testCase.verifyEqual(loopEntropy(Niter), expEntropy, 'AbsTol', tol, ...
                           sprintf(err, Niter));

      % This is the actual overflow test.
      Niter = 100;
      testCase.verifyError(@()loopEntropy(Niter),...
                           'BRAIDLAB:braid:sumg:overflow')
    end
  end
end
