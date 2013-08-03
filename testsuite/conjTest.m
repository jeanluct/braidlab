% Verify independence on projection line.
% Braids should be conjugate.
classdef conjTest < matlab.unittest.TestCase

  properties
    gen1
    gen2
    gen1c
    gen2c
  end

  methods (TestMethodSetup)
    function createBraids(testCase)
      load testdata
      XY = XY(1:length(ti),:,:);
      % Close the braid.
      XY = braidlab.closure(XY);

      % Because of the added noise, braid can vary by trivial gens, so
      % set the seed.
      rng(1);
      testCase.gen1 = testCase.verifyWarningFree(@() braidlab.braid(XY), ...
			'BRAIDLAB:braid:color_braiding:coincident');
      testCase.gen1c = testCase.gen1.compact;
      testCase.gen2 = testCase.verifyWarning(@() braidlab.braid(XY,-pi/4), ...
			'BRAIDLAB:braid:color_braiding:coincident');
      testCase.gen2c = testCase.gen2.compact;
    end
  end
      
  methods (Test)
    function test_length(testCase)
      testCase.verifyEqual(testCase.gen1.length,894);
      testCase.verifyEqual(testCase.gen1c.length,14);
      if testCase.gen2.length < 400
	keyboard
      end
      testCase.verifyEqual(testCase.gen2.length,400);
      testCase.verifyEqual(testCase.gen2c.length,12);
    end

    function test_compact(testCase)
      testCase.verifyTrue(testCase.gen1 == testCase.gen1c,...
			  'Something went wrong when compacting gen1.');
      testCase.verifyTrue(testCase.gen2 == testCase.gen2c,...
			  'Something went wrong when compacting gen2.');
    end

    function test_conj(testCase)
      [conj,C] = conjtest(testCase.gen1c,testCase.gen2c);
      testCase.verifyTrue(conj,'Braids are not conjugate.');
      testCase.verifyEqual(C,braidlab.braid([-3 -2 -3 -1 -2 -3 1 2 1 2]));
    end
  end
end
