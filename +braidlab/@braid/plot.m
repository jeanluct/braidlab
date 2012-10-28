function plot(b)
%PLOT   Plot a braid diagram.
%   PLOT(B) plots a braid diagram corresponding to the braid B.
%
%   This is a method for the BRAID class.
%   See also BRAID.

% TODO: specify some of these settings as function arguments.
% Allow a different orientation: 'LR', 'TB' (default), 'BT'.
% Allow color, line width.
baseX = 0; baseY = 0;
gapX = 100; gapY = 100;
cutf = .4;
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

for k = 1:b.length
  gen = abs(b.word(k));
  posX = baseX + gapX*(gen-1);
  posY = baseY + gapY*(k-1);
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
