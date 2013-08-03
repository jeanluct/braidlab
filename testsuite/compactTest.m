classdef compactTest < matlab.unittest.TestCase
      
  methods (Test)
    function test_compact_id(testCase)
      id = braidlab.braid([],5);
      testCase.verifyEqual(id,id.compact);

      id = braidlab.braid([1 2 1 -2 -1 -2],5);
      testCase.verifyEqual(id,id.compact);
    end

    function test_compact_random(testCase)
      rng('default')
      n = 10; % how many strings
      k = 30; % how many generators
      for i = 1:1000
	b = braidlab.braid('random',n,k); bc = compact(b);
	testCase.verifyTrue(b == bc,...
			    'Braids not equal after compacting.');
      end
    end
  end
end
