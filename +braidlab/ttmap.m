function ttmap(t,varargin)
%TTMAP   Print a train track map obtained by braid.train.
%   TTMAP(T) displays the train-track map in structure T in a human-redable
%   form.
%
%   TTMAP(T,'Parameter',VALUE,...) takes additional parameter-value pairs
%   (defaults in braces).
%
%   * Inverses - Display images of inverse edges [ true | {false} ]
%
%   * Peripheral - Include peripheral edges [ {true} | false ]
%
%   See also BRAID, BRAID.BRAID, BRAID.TRAIN.

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   http://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2018  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
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

parser.addRequired('t', @(x)isa(x,'struct') ...
                   && isfield(x,'ttmap') && isfield(x,'braid'));
parser.addParameter('inverses', false, @(x)islogical(x));
parser.addParameter('peripheral', true, @(x)islogical(x));

parser.parse(t, varargin{:});
params = parser.Results;

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
    fprintf('%2d',i)
  else
    fprintf('%2s',alphalo(i-n))
  end
  fprintf(' ->');
  for j = 1:length(tt{i})
    g = tt{i}(j);
    if g > 0
      if g <= n
        if params.peripheral, fprintf(' %d',g); end
      else
        fprintf(' %s',alphalo(g-n))
      end
    else
      if abs(g) <= n
        if params.peripheral, fprintf(' %d',g); end
      else
        fprintf(' %s',alphaup(abs(g)-n))
      end
    end
  end
  fprintf('\n');
  if params.inverses && i > n
    fprintf('%2s',alphaup(i-n))
    fprintf(' ->');
    for j = length(tt{i}):-1:1
      g = tt{i}(j);
      if g > 0
        if g <= n
          if params.peripheral, fprintf(' %d',-g); end
        else
          fprintf(' %s',alphaup(g-n))
        end
      else
        if abs(g) <= n
          if params.peripheral, fprintf(' %d',-g); end
        else
          fprintf(' %s',alphalo(abs(g)-n))
        end
      end
    end
    fprintf('\n');
  end
end
