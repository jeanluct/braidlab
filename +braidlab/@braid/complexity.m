function [c,bE] = complexity(b, varargin)
%COMPLEXITY   Dynnikov-Wiest geometric complexity of a braid.
%   C = COMPLEXITY(B) returns the Dynnikov-Wiest complexity of a braid:
%
%     C(B) = log|B.E| - log|E|
%
%   where E is a canonical curve diagram, and |L| gives the number of
%   intersections of the curve diagram L with the real axis.
%
%   C = COMPLEXITY(B,'Parameter',Value,...) takes additional parameter-value
%   pairs that modify algorithm behavior (defaults in braces).
%
%   * Length - Choice of loop length |L| [ {'intaxis'} | 'minlength' |
%   'l2norm' ] See documentation of loop.intaxis, loop.minlength,
%   loop.l2norm for details.
%
%   * Base - base of logarithm used [ {e} | number > 1 ] Chooses a
%   different base for the logarithms used in computations.
%
%   C = COMPLEXITY(B,'DW') matches original Dynnikov-Wiest
%   definition. Shortcut for 'LengthType'='intaxis', 'Base'=2
%
%   [C,BE] = COMPLEXITY(...)
%   Additionally returns loop b.E
%
%   References:
%
%   I. A. Dynnikov and B. Wiest, "On the Complexity of Braids,"
%   Journal of the European Mathematical Society 9 (2007), 801-840.
%
%   This is a method for the BRAID class.
%   See also BRAID, BRAID.LOOPCOORDS, LOOP.MINLENGTH, LOOP.INTAXIS.

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   http://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2017  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
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

% flag validation
import braidlab.util.validateflag

%% parse input arguments
parser = inputParser;
parser.FunctionName='complexity';
parser.addRequired('b', @(x)isa(x,'braidlab.braid') );
parser.addOptional('dwflag', '',...
                   @(s)ischar(s) && strcmpi(s,'dw') );
parser.addParameter('base', nan,...
                   @(n)isnumeric(n) && n > 1);
parser.addParameter('length','intaxis',@ischar);

parser.parse(b, varargin{:} );
params = parser.Results;


b = params.b;

% set DW defaults
if ~isempty( params.dwflag )
  params.length = 'intaxis';
  params.base = 2;
else
  params.length = validateflag(params.length, 'intaxis','minlength', ...
                               'l2norm');
end

%% Apply braid to the fundamental loop

% Canonical set of loops, with extra boundary puncture (n+1).
E = braidlab.loop(b.n,'bp');

bE = b*E;

% determine lengths
switch params.length
  case 'intaxis'
    % Subtract b.n-1 to remove extra crossings due to boundary (n+1)
    % puncture: (n-1) arcs going to it never cross the horizontal so
    % they should be accounted for.
    lengthBefore = intaxis(E)-b.n+1;
    lengthAfter = intaxis(bE)-b.n+1;
  case 'minlength'
    lengthBefore = minlength(E);
    lengthAfter = minlength(bE);
  case 'l2norm'
    lengthBefore = l2norm(E);
    lengthAfter = l2norm(bE);
end

% reallog throws error for non-positive inputs
c = reallog( lengthAfter ) - reallog( lengthBefore );

% change base if needed
if ~isnan(params.base)
  c = c/reallog( params.base );
end

end
