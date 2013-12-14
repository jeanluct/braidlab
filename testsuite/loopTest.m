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
      testCase.l2 = loop([1 -1 2 3; 2 3 -1 2]);  % two loops
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
      [a,b] = l.ab;
      testCase.verifyEqual(a,[1 -1]);
      testCase.verifyEqual(b,[2 3]);
      % Create the same loop by specifying a,b.
      testCase.verifyEqual(l.a,braidlab.loop([1 -1],[2 3]).a);
      testCase.verifyEqual(l.b,braidlab.loop([1 -1],[2 3]).b);

      % A row-list of loops.
      l = testCase.l2;
      [c1,c2] = l.coords;
      testCase.verifyEqual(c1,[1 -1 2 3]);
      testCase.verifyEqual(c2,[2 3 -1 2]);

      % The basis of loops used to build loop coordinates.
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
    end

    function test_loop_length_overflow(testCase)
      % Test that manual iteration of loop coordinates and computation of
      % entropy handles integer overflow well.

      mybraid = testCase.b;

      expEntropy = entropy(mybraid);
      l = loopcoords(mybraid);

      tol = 1e-2; % Let's be generous.

      loopEntropy = @(N)log(minlength(mybraid^N*l)/minlength(l)) / N;

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
