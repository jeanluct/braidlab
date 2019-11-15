function [varargout] = prop(varargin)
%PROP   Get and set global properties for braidlab.
%   PROP('PropertyName',VALUE,...) assigns VALUE to a braidlab property.
%   This property is global to braidlab classes and functions.
%
%   PROP('PropertyName') returns the current value of the property.
%
%   PROP('Reset') resets all the properties to their default values.
%
%   PROP with no argument returns a struct with all the properties and their
%   current values.
%
%   Valid properties and values are (defaults in braces):
%
%   * GenRotDir [{1} | -1]- The direction of rotation of braid group
%   generators.  This is the direction of rotation when strings are
%   exchanged by a generator.  A value of 1 corresponds to clockwise, -1 to
%   counterclockwise.
%
%   * GenLoopActDir [{'lr'} | 'rl'] - The direction of application of
%   generators acting on a loop.  The default is a left-to-right ('lr'),
%   that is for generators s1 and s2 and a loop l, ([s1 s2])*l = s2(s1(l)).
%   This is also called a right group action.  The other option is
%   right-to-left ('rl'), called a left group action.
%
%   * GenPlotOverUnder [{true} | false] - Whether to plot a positive
%   generator as over/under or under/over.  This only affects braid.plot.
%
%   * BraidPlotDir [{'bt'} | 'tb' | 'lr' | 'rl'] - The direction that
%   braid.plot displays braids.  Here 'btlr' mean bottom, top, left, right.
%   The default is bottom-to-top ('bt'), but popular conventions also
%   include 'tb' and 'lr'.
%
%   * BraidAbsTol [{1e-10}] - The absolute tolerance used to determine
%   coincident coordinates when constructing a braid from data.  Set this to
%   a conservative estimate of typical errors in your dataset.
%
%   * LoopCoordsBasePoint ['left' | {'right'} | 'dehornoy'] - The position
%   of the basepoint when defining the loop coordinates of a braid using
%   braid.loopcoords.  The option 'dehornoy' sets the basepoint to 'left'
%   and also sets 'GenRotDir' to -1.  See braid.loopcoords.
%
%   See also BRAID, BRAID.BRAID, BRAID.LOOPCOORDS, BRAID.MTIMES, LOOP.

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   http://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2019  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
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

% TODO: also allow PROP(STRUCT) to set arguments.

% The persistent struct that contains the properties.
persistent pr

% Default values.
if isempty(pr), pr = prdef; end

if nargin == 0
  varargout{1} = pr;
end

% One argument means query mode.
if nargin == 1
  flag = lower(varargin{1});
  switch flag
   case {'default','reset'}
    pr = prdef;
    varargout{1} = pr;
   case {'genrotdir'}
    varargout{1} = pr.GenRotDir;
   case {'genloopactdir'}
    varargout{1} = pr.GenLoopActDir;
   case {'genplotoverunder'}
    varargout{1} = pr.GenPlotOverUnder;
   case {'braidplotdir'}
    varargout{1} = pr.BraidPlotDir;
   case {'braidabstol'}
    varargout{1} = pr.BraidAbsTol;
   case {'loopcoordsbasepoint'}
    varargout{1} = pr.LoopCoordsBasePoint;
   otherwise
    error('BRAIDLAB:prop:badarg','Unknown string argument.')
  end
  return
end

parser = inputParser;
parser.addParameter('genrotdir', [], @(x) x == 1 || x == -1);
parser.addParameter('genloopactdir', [],  @(s) ischar(s) && ...
                   any(strcmpi(s,{'lr','rl'})));
parser.addParameter('genplotoverunder', [], @(x) x == true || x == false);
parser.addParameter('braidplotdir', [], @(s) ischar(s) && ...
                   any(strcmpi(s,{'bt','tb','lr','rl'})));
parser.addParameter('braidabstol', [], @(x) x >= 0);
parser.addParameter('loopcoordsbasepoint', [], @(s) ischar(s) && ...
                   any(strcmpi(s,{'left','right','dehornoy'})));

parser.parse(varargin{:});
params = parser.Results;

% Do not overwrite arguments that weren't specified (no default values).
if ~isempty(params.genrotdir)
  pr.GenRotDir = params.genrotdir;
end
if ~isempty(params.genloopactdir)
  pr.GenLoopActDir = params.genloopactdir;
end
if ~isempty(params.genplotoverunder)
  pr.GenPlotOverUnder = params.genplotoverunder;
end
if ~isempty(params.braidplotdir)
  pr.BraidPlotDir = params.braidplotdir;
end
if ~isempty(params.braidabstol)
  pr.BraidAbsTol = params.braidabstol;
end
if ~isempty(params.loopcoordsbasepoint)
  if strcmpi(params.loopcoordsbasepoint,'dehornoy')
    pr.LoopCoordsBasePoint = 'left';
    if ~isempty(params.genrotdir)
      if params.genrotdir ~= -1
        error('BRAIDLAB:prop:badgenrotdir', ...
              'Property ''dehornoy'' is incompatible with GenRotDir=1.');
      end
    end
    pr.GenRotDir = -1;
  else
    pr.LoopCoordsBasePoint = params.loopcoordsbasepoint;
  end
end

if nargout > 0
  varargout{1} = pr;
end

%======================================================================
function pr = prdef

% Default values.
pr.GenRotDir = 1;
pr.GenLoopActDir = 'lr';
pr.GenPlotOverUnder = true;
pr.BraidPlotDir = 'bt';
pr.BraidAbsTol = 1e-10;
pr.LoopCoordsBasePoint = 'right';
