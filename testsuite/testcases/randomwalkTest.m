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

      b = braidlab.braid(braidlab.closure(XY,'pure'));
      testCase.verifyEqual(b,braidlab.braid([1 -3 -2 3 1 2 3 1 2 1 3 2]));
      testCase.verifyTrue(b.ispure);
    end
  end

end
