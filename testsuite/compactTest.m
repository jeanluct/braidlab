classdef compactTest < matlab.unittest.TestCase
      
  methods (Test)
    function test_compact_id(testCase)
      % Verify that compacting the trivial braid returns the trivial braid.
      id = braidlab.braid([],5);
      testCase.verifyTrue(isempty(id.compact.word));

      % Verify that compacting gives the trivial braid in simple cases.
      id = braidlab.braid([1 -2 2 -1]);
      testCase.verifyTrue(isempty(id.compact.word));

      id = braidlab.braid([1 2 1 -2 -1 -2],5);
      testCase.verifyTrue(isempty(id.compact.word));
    end

    function test_compact_random(testCase)
      % Verify that compacting doesn't change the braid.
      rng('default')
      n = 10; % how many strings
      k = 30; % how many generators
      for i = 1:100
	b = braidlab.braid('random',n,k); bc = compact(b);
	testCase.verifyTrue(b == bc,...
			    'Braids not equal after compacting.');
      end
    end
  end
end
