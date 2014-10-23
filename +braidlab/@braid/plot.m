function plot(b)
%PLOT   Plot a braid diagram.
%   PLOT(B) plots a braid diagram corresponding to the braid B.
%
%   This is a method for the BRAID class.
%   See also BRAID.

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   http://bitbucket.org/jeanluc/braidlab/
%
%   Copyright (C) 2013--2014  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
%                             Marko Budisic         <marko@math.wisc.edu>
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

% TODO: specify some of these settings as function arguments.
% Allow a different orientation: 'LR', 'TB' (default), 'BT'.
% Allow color, line width.
% Specify style (rounded, line...)
baseX = 0; baseY = 0;
gapX = 100; gapY = 150;
cutf = .35;
uselines = false; % If true, use straight line segments.
npts = 40;
lat = {'LineWidth',2};

if ~isscalar(b)
  error('BRAIDLAB:braid:plot',['Can only plot scalar braid, not array of' ...
                    ' braids.']);
end

if ishold
  holdstate = true;
else
  holdstate = false;
  cla
end

% Plot an empty braid word (exciting!).
if isempty(b.word)
  for k = 1:b.n
    posX = baseX + (k-1)*gapX; posY = baseY;
    plot([posX posX],[posY posY+gapY],lat{:})
    hold on
  end
  if ~holdstate
    hold off
    axis equal
    axis off
  end
  return
end

if ~uselines
  f = @(x) gapY/pi * asin(2*x/gapX - 1) + gapY/2;
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
end

for k = 1:b.length
  gen = abs(b.word(k));
  posX = double(baseX + gapX*(gen-1));
  posY = double(baseY + gapY*(k-1));
  if ~uselines
    sgn = (sign(b.word(k))+1)/2 + 1;
    % Draw the 'over' line.
    plot(posX+xx,posY+bline{3-sgn},lat{:})
    hold on
    % Draw the 'under' line with a gap.
    plot(posX+gapX-xx,posY+bline{sgn},lat{:})
  else % use straight line segments graphics command.
    if sign(b.word(k)) == 1
      % Draw the 'over' line.
      plot([posX posX+gapX],[posY posY+gapY],lat{:})
      hold on
      % Draw the 'under' line with a gap.
      plot([posX+gapX posX+gapX-cutf*gapX],[posY posY+cutf*gapY],lat{:})
      plot([posX+gapX-(1-cutf)*gapX posX],[posY+(1-cutf)*gapY posY+gapY],lat{:})
    else
      % Draw the 'over' line.
      plot([posX+gapX posX],[posY posY+gapY],lat{:})
      % Draw the 'under' line with a gap.
      plot([posX posX+cutf*gapX],[posY posY+cutf*gapY],lat{:})
      plot([posX+(1-cutf)*gapX posX+gapX],[posY+(1-cutf)*gapY posY+gapY],lat{:})
    end
  end
  % Plot the remaining vertical lines.
  for l = 1:b.n
    if l ~= gen && l ~= gen+1
      posX = baseX + gapX*(l-1);
      plot([posX posX],[posY posY+gapY],lat{:})
    end
  end
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
