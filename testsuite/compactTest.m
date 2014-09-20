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

classdef compactTest < matlab.unittest.TestCase

  methods (Test)
    function test_compact_id(testCase)
      % Verify that compacting the trivial braid returns the trivial braid.
      id = braidlab.braid([],5);
      testCase.verifyTrue(isempty(id.compact.word));
      
      % Verify that compacting the trivial braid constructed from a
      % trajectory returns the trivial braid.
      id = braidlab.braid(cat(3, [0,0], [1,1]),5);
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
