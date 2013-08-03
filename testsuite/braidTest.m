classdef braidTest < matlab.unittest.TestCase

  properties
    b1
    b2
    b3
    id
    pure
  end

  %methods (TestClassSetup)
  %  function addbraidFolderToPath(testCase)
  %    testCase.addTeardown(@path, addpath(fullfile(pwd,'..')));
  %  end
  %end

  methods (TestMethodSetup)
    function createBraid(testCase)
      import braidlab.*
      testCase.b1 = braid([1 -2 3 5],7);
      testCase.b2 = braid([1 2 4 6],7);
      testCase.b3 = braid([1 -2 3 5 2 1 2 -1 -2 -1],7);
      testCase.id = braid([],7);
      testCase.pure = braid([1 -2 1 -2 1 -2]);
    end
  end

  methods (Test)
    function test_braid_constructor(testCase)
      b = testCase.b1;
      testCase.verifyEqual(b.word,int32([1 -2 3 5]));
      testCase.verifyEqual(b.n,7);

      b = braidlab.braid('halftwist',5);
      testCase.verifyEqual(b.word,int32([4 3 2 1 4 3 2 4 3 4]));

      rng(1);
      b = braidlab.braid('random',5,7);
      testCase.verifyEqual(b,braidlab.braid([-2 2 -3 -2 -3 -1 -4]));

      b = braidlab.braid('HironakaKin',3,1);
      testCase.verifyEqual(b,braidlab.braid([1 2 3 3 2 1 1 2 3 4]));
    end

    function test_braid_from_randomwalk(testCase)
      rng(1);
      b = braidlab.braid(braidlab.randomwalk(4,2,1));
      testCase.verifyEqual(b,braidlab.braid([1 -3 -2 3 1 2 3 1 2]));

      b = braidlab.braid(braidlab.randomwalk(4,2,1),pi/4);
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
  end
end
