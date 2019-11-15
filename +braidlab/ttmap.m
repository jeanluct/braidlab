function ttmap(t,varargin)
%TTMAP   Print a train track map obtained by braid.train.
%   TTMAP(T) displays the train-track map in structure T in a human-redable
%   form.  T can be either a braid or a structure returned by braid.train.
%
%   TTMAP(T,'Parameter',VALUE,...) takes additional parameter-value pairs
%   (defaults in braces):
%
%   * Peripheral - Include peripheral edges [ {true} | false ]
%
%   * Inverses - Display images of inverse edges [ true | {false} ]
%
%   * BoldMain - Use boldface for letters corresponding to main edges
%   [ true | {false} ]
%
%   * BoldPeripheral - Use boldface for numbers corresponding to peripheral
%   edges [ true | {false} ]
%
%   See also BRAID, BRAID.BRAID, BRAID.TRAIN.

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

%% Process inputs
import braidlab.util.validateflag

parser = inputParser;

% First argument is a structure returned by braidlab.train, or a braid.
parser.addRequired('t', @(x) ...
                   (isa(x,'struct') && ...
                    isfield(x,'ttmap') && ...
                    isfield(x,'braid')) ...
                   || ...
                   (isa(x,'braidlab.braid')));
parser.addParameter('inverses', false, @(x) islogical(x));
parser.addParameter('peripheral', true, @(x) islogical(x));
parser.addParameter('boldmain', false, @(x) islogical(x));
parser.addParameter('boldperipheral', false, @(x) islogical(x));

parser.parse(t,varargin{:});
params = parser.Results;

if params.boldmain
  printmain = @(varargin) ...
      fprintf(['<strong>' varargin{1} '</strong>'],varargin{2});
else
  printmain = @(varargin) fprintf(varargin{:});
end

if params.boldperipheral
  printperi = @(varargin) ...
      fprintf(['<strong>' varargin{1} '</strong>'],varargin{2});
else
  printperi = @(varargin) fprintf(varargin{:});
end

if isa(t,'braidlab.braid') t = train(t); end

n = t.braid.n;
tt = t.ttmap;

if length(tt)-n > 26
  error('BRAIDLAB:ttmap:toomanyedges', ...
        'Can''t display more than 26 main edges, sorry.')
end

alphalo = 'abcdefghijklmnopqrstuvwxyz';
alphaup = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

if params.peripheral
  letlist = 1:length(tt);
else
  letlist = n+1:length(tt);
end

fprintf('\n');

for i = letlist
  if i <= n
    printperi('%2d',i)
  else
    printmain('%2s',alphalo(i-n))
  end
  fprintf(' ->');
  for j = 1:length(tt{i})
    g = tt{i}(j);
    if g > 0
      if g <= n
        if params.peripheral, printperi(' %d',g); end
      else
        printmain(' %s',alphalo(g-n))
      end
    else
      if abs(g) <= n
        if params.peripheral, printperi(' %d',g); end
      else
        printmain(' %s',alphaup(abs(g)-n))
      end
    end
  end
  fprintf('\n');
  if params.inverses && i > n
    printmain('%2s',alphaup(i-n))
    fprintf(' ->');
    for j = length(tt{i}):-1:1
      g = tt{i}(j);
      if g > 0
        if g <= n
          if params.peripheral, printperi(' %d',-g); end
        else
          printmain(' %s',alphaup(g-n))
        end
      else
        if abs(g) <= n
          if params.peripheral, printperi(' %d',-g); end
        else
          printmain(' %s',alphalo(abs(g)-n))
        end
      end
    end
    fprintf('\n');
  end
end
