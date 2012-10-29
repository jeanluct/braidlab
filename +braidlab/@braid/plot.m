function plot(b)
%PLOT   Plot a braid diagram.
%   PLOT(B) plots a braid diagram corresponding to the braid B.
%
%   This is a method for the BRAID class.
%   See also BRAID.

% TODO: specify some of these settings as function arguments.
% Allow a different orientation: 'LR', 'TB' (default), 'BT'.
% Allow color, line width.
% Specify style (rounded, line...)
baseX = 0; baseY = 0;
gapX = 100; gapY = 150;
cutf = .35;
uselines = false;
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
  clf reset
  hold on
end

if ~uselines
  f = @(x) gapY/pi * asin(2*x/gapX - 1) + gapY/2;
  xx = linspace(0,gapX,npts);
  % The 'over' line.
  bline{1} = f(xx);
  % The 'under' line.
  bline{2} = f(xx);
  igap = find(cutf*gapX < xx & xx < (1-cutf)*gapX);
  bline{2}(igap) = NaN;
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
    % Draw the 'under' line with a gap.
    plot(posX+gapX-xx,posY+bline{sgn},lat{:})
  else % use the 'line' graphics command.
    if sign(b.word(k)) == 1
      % Draw the 'over' line.
      line([posX posX+gapX],[posY posY+gapY],lat{:})
      % Draw the 'under' line with a gap.
      line([posX+gapX posX+gapX-cutf*gapX],[posY posY+cutf*gapY],lat{:})
      line([posX+gapX-(1-cutf)*gapX posX],[posY+(1-cutf)*gapY posY+gapY],lat{:})
    else
      % Draw the 'over' line.
      line([posX+gapX posX],[posY posY+gapY],lat{:})
      % Draw the 'under' line with a gap.
      line([posX posX+cutf*gapX],[posY posY+cutf*gapY],lat{:})
      line([posX+(1-cutf)*gapX posX+gapX],[posY+(1-cutf)*gapY posY+gapY],lat{:})
    end
  end
  % Plot the remaining vertical lines.
  for l = 1:b.n
    if l ~= gen & l ~= gen+1
      posX = baseX + gapX*(l-1);
      line([posX posX],[posY posY+gapY],lat{:})
    end
  end
end

if ~holdstate
  hold off
  axis equal
  axis off
end
