function plot(b,varargin)
%PLOT   Plot a braid diagram.
%   PLOT(B) plots a braid diagram corresponding to the braid B.
%
%   PLOT(B,...) gives the line specification as for Matlab's PLOT command.
%   The default is PLOT(B,'k','LineWidth',2).
%
%   PLOT(B,{CLSPEC1,CLSPEC2,...,CLSPECN}) plots each string of B with a
%   color and line specified by CLSPECx.  There must be exactly B.N
%   character strings in the cell.  Use CLSPECx=[] for default linespec.
%
%   Example: PLOT(B,{'r--','b:','k'}) for a three-string braid B plots the
%   first string dashed-red, the second dotted-blue, and the third solid
%   black.
%
%   Use {CLSPEC1} for multiple options for a string.
%
%   Example: PLOT(B,{{'r--','LineWidth',3},'b:','k'}) for a three-string
%   braid B plots the first string with a thick line.
%
%   This is a method for the BRAID class.
%   See also BRAID, PLOT.

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   http://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2015  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
%                            Marko Budisic         <marko@math.wisc.edu>
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

if ~isscalar(b)
  error('BRAIDLAB:braid:plot:noarray', ...
        'Can only plot scalar braid, not array of braids.');
end

% TODO:
% Specify style (rounded, line...)

baseX = 0; baseY = 0;
gapX = 100; gapY = 150;
cutf = .35;
npts = 40;
lw = 2;
defls = {'k-','LineWidth',lw};

if nargin > 1
  if iscell(varargin{1})
    if length(varargin{1}) < b.n
      error('BRAIDLAB:braid:plot:badlinespec', ...
            'Not enough colorspec/linespec for %g strings.',b.n)
    end
    for i = 1:b.n
      if isempty(varargin{1}{i})
        % Use default spec for [] or {}.
        lat{i} = defls;
      elseif iscell(varargin{1}{i})
        % varargin{i} is a cell, e.g. {'g:','LineWidth',1}
        lat{i} = varargin{1}{i};
      elseif ischar(varargin{1}{i})
        % varargin{i} is a string, e.g. 'r--'
        % Wrap in cell, use default linewidth.
        lat{i} = {varargin{1}{i},'LineWidth',lw};
      else
        error('BRAIDLAB:braid:plot:badlinespec','Bad linespec.')
      end
    end
  else
    % Only one set of linespecs.  Apply to all strings.
    for i = 1:b.n
      lat{i} = {varargin{1:end}};
    end
  end
else
  % Default linespec.
  for i = 1:b.n
    lat{i} = defls;
  end
end

if ishold
  holdstate = true;
else
  holdstate = false;
  cla
end

% Convention: plot over-under (default) vs under-over.
% Set using braidlab.prop('GenPlotOverUnder',[ {true} | false ]).
if braidlab.prop('GenPlotOverUnder') == false
  b.word = -b.word;
end

% Convention: plot braids bottom-to-top by default ('bt').
% Set using braidlab.prop('BraidPlotDir',VALUE).
switch lower(braidlab.prop('braidplotdir'))
 case 'bt'
  plt = @plot;
 case 'lr'
  plt = @(x,y,varargin) plot(y,-x,varargin{:});
 case 'rl'
  plt = @(x,y,varargin) plot(-y,-x,varargin{:});
 case 'tb'
  plt = @(x,y,varargin) plot(x,-y,varargin{:});
 otherwise
  error('BRAIDLAB:braid:plot:badbraidplotdir', ...
        'Unknown value for BraidPlotDir.  See ''help braidlab.prop.''')
end

% Plot an empty braid word (exciting!).
if isempty(b.word)
  for k = 1:b.n
    posX = baseX + (k-1)*gapX; posY = baseY;
    plt([posX posX],[posY posY+gapY],lat{k}{:})
    hold on
  end
  if ~holdstate
    hold off
    axis equal
    axis off
  end
  return
end

% Define the shape function to plot generators.
% The shape function should satisfy shapefun(0)=0, shapefun(1)=1.
shapefun = @(x) asin(2*x-1)/pi + 1/2;
%shapefun = @(x) x;  % straight line segments
f = @(x) gapY * shapefun(x/gapX);
xx = linspace(0,gapX,npts);
% The 'over' line.
bline{1} = f(xx);
% The 'under' line.
bline{2} = f(xx);
bline{2}(cutf*gapX < xx & xx < (1-cutf)*gapX) = NaN;
% Pad xx with an extra point at the beginning and end, to create a bit of
% overlap.
xx = [0 xx gapX];
bline{1} = [-gapY/2/npts bline{1} gapY+gapY/2/npts];
bline{2} = [-gapY/2/npts bline{2} gapY+gapY/2/npts];

% Keep track of permutation, for coloring purposes.
p = 1:b.n;

for i = 1:b.n, strX{i} = []; strY{i} = []; end

% Fill line data
for k = 1:b.length
  gen = abs(b.word(k));

  p([gen gen+1]) = p([gen+1 gen]);   % update permutation

  posX = double(baseX + gapX*(gen-1));
  posY = double(baseY + gapY*(k-1));

  sgn = (sign(b.word(k))+1)/2 + 1;
  % The 'over' line.
  strX{p(gen+1)} = [strX{p(gen+1)} posX+xx];
  strY{p(gen+1)} = [strY{p(gen+1)} posY+bline{3-sgn}];
  % The 'under' line with a gap.
  strX{p(gen)} = [strX{p(gen)} posX+gapX-xx];
  strY{p(gen)} = [strY{p(gen)} posY+bline{sgn}];

  % The remaining vertical lines.
  for l = 1:b.n
    if l ~= gen && l ~= gen+1
      posX = baseX + gapX*(l-1);
      strX{p(l)} = [strX{p(l)} posX posX];
      strY{p(l)} = [strY{p(l)} posY posY+gapY];
    end
  end
end

% Plot the strings continuously, to avoid ugly break when using dashes.
for l = 1:b.n
  plt(strX{l},strY{l},lat{l}{:})
  hold on
end

if ~holdstate
  hold off
  axis equal
  axis off
  % Add a gap around the edges, to avoid clipping the figure.
  axis tight
  ax = axis;
  sc = .1*max(abs(ax(1)),abs(ax(2)));
  axis([ax(1)-sc ax(2)+sc ax(3) ax(4)])
end
