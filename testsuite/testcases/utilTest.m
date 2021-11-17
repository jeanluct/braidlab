% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   http://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2021  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
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

classdef utilTest < matlab.unittest.TestCase

  properties
  end


  methods (Test)
    function test_validateflag(testCase)

      import braidlab.util.validateflag;

      % partial matching
      testCase.verifyMatches(validateflag('int', ...
                                          'intaxis', ...
                                          'minlength',...
                                          {'trains','train-tracks','bh'} ...
                                          ),...
                             'intaxis');

      % case matching
      testCase.verifyMatches(validateflag('INT', ...
                                          'intaxis', ...
                                          'minlength',...
                                          {'trains','train-tracks','bh'} ...
                                          ),...
                             'intaxis');

      % matching alternate name
      testCase.verifyMatches(validateflag('bh', ...
                                          'intaxis', ...
                                          'minlength',...
                                          {'trains','train-tracks','bh'} ...
                                          ),...
                             'trains');

      % unmatched string
      testCase.verifyError(@()validateflag('int'),...
                           'BRAIDLAB:validateflag:flaginvalid')


    end
  end
end
