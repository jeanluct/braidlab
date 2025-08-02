function E = ftbe(B,varargin)
%FTBE   Finite Time Braiding Exponent of a databraid.
%   E = FTBE(B) computes the Finite Time Braiding Exponent of a
%   databraid B.  The FTBE is defined for data braids without relying on
%   iteration of the braid on a given loop. Intuitively, its relation to
%   braid entropy is analogous to that of Finite Time Lyapunov Exponents
%   to entropy in a periodic flow.
%
%   The Finite Time Braiding Exponent is computed as
%
%      E = (1/T) * log(|B.l|/|l|)
%
%   where l is a generating set for the fundamental group, B.l denotes
%   action of the braid on l, log is the natural logarithm, and T is the
%   difference between crossing times of the first generator and the
%   last generator in B.
%
%   E = FTBE(B,'Parameter',VALUE,...) is the same as above except it
%   allows modification of the basic formula by specifying name-value
%   pairs as follows.
%
%   * Method - [ {'proj'} | 'nonproj' ] - The algorithm for computing
%     the length of the loop after action of the braid.
%
%     'proj' uses projectivized coordinates which makes it more suitable
%     for very large braids, at the possible (small) expense in
%     numerical accuracy.  (See braid.entropy for details.)
%
%     'nonproj' uses non-projectivized coordinates which may make it
%     slow or unusable for very long braids, but its numerical precision
%     should be dictated only by precision of evaluation of natural
%     logarithm.  (See braid.complexity for details.)
%
%   * Length - The loop length function [ {'intaxis'} | 'minlength' |
%     'l2norm' ]  See documentation of loop.intaxis, loop.minlength,
%     loop.l2norm for details.
%
%   * T - [ real ] - Uses a custom value for length of interval over
%     which FTBE is computed.  The default is the difference between
%     first and last crossing time in the braid which might
%     underestimate the time if the first generator appeared late, or if
%     the last crossing did not appear at the end of the physical braid.
%
%   * Base - [ positive real ] - Use a custom base of
%     logarithm instead of natural logarithm.
%
%   This is a method for the DATABRAID class
%   See also BRAID.COMPLEXITY and BRAID.ENTROPY

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   https://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2025  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
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

% flag validation
import braidlab.util.validateflag

parser = inputParser;

parser.addRequired('B', @(x)isa(x,'braidlab.databraid') );

parser.addParameter('method', 'proj', @ischar );
parser.addParameter('T', nan, @(n)isnumeric(n) );
parser.addParameter('base', nan, @(n)( isnumeric(n) && (n > ...
                                                  0) ) );
parser.addParameter('length','intaxis',@ischar);

parser.parse( B, varargin{:} );

params = parser.Results;

% determine type of algorithm
params.method = validateflag(params.method, {'proj','entropy'}, ...
                             {'nonproj', 'complexity'});

% determine loop length function used
params.length = validateflag(params.length, 'intaxis', ...
                             'minlength','l2norm');

% determine length of interval
if isnan(params.T)
  params.T = max(B.tcross) - min(B.tcross);
end

% pick computation method
switch params.method
  case 'proj', % projectivized uses entropy
    stretch = entropy(braid(B),'onestep','length',params.length);
  case 'nonproj', % non-projectivized uses complexity
    stretch = complexity(braid(B),'length',params.length);
end

% change base if needed
if ~isnan(params.base)
  stretch = stretch/reallog( params.base );
end

% compute FTBE by dividing stretch by physical time length
E = stretch / params.T;
