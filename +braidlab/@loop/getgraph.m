function [A, C] = getgraph(L)
%GETGRAPH  Get graph representation of the loop.
%   [A, C] = GETGRAPH(L) returns adjacency (A) and incidence/connectivity (C)
%   matrices of a graph obtained by subdividing the loop into segments.
%   Vertices are placed on the loop above and below punctures.
%
%   This is a method for the LOOP class.
%   See also LOOP.

% <LICENSE
%   Copyright (c) 2013, 2014 Jean-Luc Thiffeault, Michael Allshouse
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

% This function is heavily based on loop/plot.m function.

error('BRAIDLAB:loop:getgraph','getgraph not implemented');

if ~isscalar(L)
  error('BRAIDLAB:loop:getgraph:onlyscalar', ...
        'Can only obtain graph of a single loop, not an array of loops.');
end

%% Get the coordinates of the loop, convert to crossing numbers.
% Convert to double, since some scaling is done.
n = L.n;

% Get the b coordinates.
b_coord = double(L.b);

% Convert Dynnikov coding to intersection numbers.
[mu,nu] = L.intersec;
mu = double(mu); nu = double(nu);

% Extend the coordinates to include the punctures at either end.
% This effectively introduces two extra nu-lines outside the end punctures,
% that never have any crossings on them
b_coord = [-nu(1)/2 b_coord nu(end)/2];

% Convert to older P,M,N notation
% intersections above punctures
M_coord = [nu(1)/2 mu(2*(1:(n-2))-1) nu(n-1)/2];
% intersections below punctures
N_coord = [nu(1)/2 mu(2*(1:(n-2))) nu(n-1)/2]; 

%% GRAPH INDEXING
%
% Each vertex is indexed by a pair (P,V) where P corresponds to 
% the puncture the vertex is associated to, P = 1, ..., n
% V is the order of the vertex above (V > 0) or below (V < 0) the puncture.
% For each P,
%    max(V) == M_coord(P)
%    min(V) == -N_coord(P)

%% Identify connections of vertices that are above/below same puncture.

% 'left' semicircles are C-shaped
% 'right' semicircles are D-shaped

% Cycle through each puncture.  
for p = 1:n
    
  % Determine number of semicircles are at the present loop  
  if p == n
    nl = M_coord(n); % this is equal to N_coord(n) ?
  else
    nl = b_coord(p);
  end
  
  % Draw this number of semicircles taking into account the direction
  % (left/right) around the puncture.
  for sc = 1:abs(nl)
    joinpoints( [p, -sign(nl)*sc],[p, sign(nl)*sc], ...
                puncture_position, pgap, options );
  end
end

%%  Draw segments above the puncture line (M_coord).
for p = 1:n-1

  % How many right-semicircles (b>0) around this puncture?
  if p == 1
    nr = 0;
  else
    nr = max(b_coord(p),0);
  end
  
  % segments that span two neighboring punctures
  tojoin = M_coord(p)-nr;
  if tojoin > 0
    % How many left-semicircles (b<0) around the next puncture?
    if p < n-1
      nl = -min(b_coord(p+1),0);
    else
      nl = 0;
    end
    % We can't joint to these left-facing loops from the left.
    tojoinup = M_coord(p+1)-nl;
    tojoindown = max(tojoin-tojoinup,0);
    % The lines that join downwards.
    for s = 1:tojoindown
      % idx_mine and _next are indices of vertices of the current (mine)
      % and following (next) puncture that will be connected
      % idx_ > 0 -- vertex is above puncture
      % idx_ < 0 -- vertex is below puncture
      idx_mine = nr + s; % index of the vertex 
      idx_next = -(nl-s+tojoindown+1);
      
      joinpoints( [p,idx_mine], [p+1,idx_next], ...
                  puncture_position, pgap, options );
      
    end                                 
    % The lines that join upwards (on the same side).
    for s = tojoindown+1:tojoin
      % idx_mine and _next are indices of vertices of the current (mine)
      % and following (next) puncture that will be connected
      % idx_ > 0 -- vertex is above puncture
      % idx_ < 0 -- vertex is below puncture
      idx_mine = nr+s;
      idx_next = nl+s - (tojoin-tojoinup);
      joinpoints( [p,idx_mine], [p+1,idx_next], ...
                  puncture_position, pgap, options );
    end
  end
end

%% Draw segments below the puncture line (N_coord)

for p = 1:n-1

  % How many right-semicircles (b>0) around this puncture?
  if p == 1
    nr = 0;
  else
    nr = max(b_coord(p),0);
  end
  
  % segments that span two different punctures
  tojoin = N_coord(p)-nr;
  if tojoin > 0
    % How many left-semicircles (b<0) around the next puncture?
    if p < n-1
      nl = -min(b_coord(p+1),0);
    else
      nl = 0;
    end
    % We can't joint to these left-facing loops from the left.
    tojoindown = N_coord(p+1)-nl;
    tojoinup = max(tojoin-tojoindown,0);
    % The lines that join upwards.
    for s = 1:tojoinup
      % idx_mine and _next are indices of vertices of the current (mine)
      % and following (next) puncture that will be connected
      % idx_ > 0 -- vertex is above puncture
      % idx_ < 0 -- vertex is below puncture
      idx_mine = -(nr+s);
      idx_next = (nl-s+tojoinup+1);
      joinpoints( [p,idx_mine], [p+1,idx_next], ...
                  puncture_position, pgap, options );
    end
    % The lines that join downwards (on the same side).
    for s = tojoinup+1:tojoin
      % idx_mine and _next are indices of vertices of the current (mine)
      % and following (next) puncture that will be connected
      % idx_ > 0 -- vertex is above puncture
      % idx_ < 0 -- vertex is below puncture
      idx_mine = -(nr+s);
      idx_next = -(nl+s - (tojoin-tojoindown));
      joinpoints( [p,idx_mine], [p+1,idx_next], ...
                  puncture_position, pgap, options );
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
  axis([ax(1)-sc ax(2)+sc ax(3)-sc ax(4)+sc])
end

end

function joinpoints( mine, next, positions, gaps, options )
%% joinpoints( mine, next, positions, gaps, options )
%
% Function that plots segments of loops - either straight lines or semicircles
%
% *** Inputs: ***
% mine and next are pairs (puncture index, vertex index) defining
%    vertices that the function joins using a line.
%
% -- Function will return an error if puncture indices are not the same
%    or consecutive ascending: k, k+1
% -- Vertex indices are integers, excluding 0: positive indices are
%    interpreted as above the puncture, negative as below
% -- when mine(1) == next(1), semicircles are drawn. In this case
%    it has to hold vertex numbers are the same as well, but with
%    opposite signs. Semicircles are drawn in positive orientation,
%    so mine(2) < next(2) will result in D-shaped line, whereas 
%    mine(2) > next(2) will result in a C-shaped line.
% 
%
% positions - n x 2 matrix of puncture positions 
% gaps      - 1 x n vector of gaps between loop lines at each puncture
% options   - options data for line plotting
%
% *** Warning: *** This function is for internal use, error
% checking is not bullet proof.
  

  dp = next(1) - mine(1); % index distance between punctures
  assert( dp == 1 || dp == 0, 'BRAIDLAB:loop:plot:joinpoints',...
         'Requests one or two consecutive punctures');
  
  assert( mine(2)~=0 && next(2)~=0, 'BRAIDLAB:loop:plot:joinpoints',...
          'Vertex indices must be nonzero') ;
  
  if dp == 0
    %% Draw semicircles
    
    assert( abs(mine(2)) == abs(next(2)) && ...
            sign(mine(2)) ~= sign(next(2)),...
            'BRAIDLAB:loop:plot:joinpoints',...
            ['For semicircles, vertex indices must be equal value, ' ...
             'opposite sign']);
    
    order = abs(mine(2));      % order of the loop from the puncture
    rad = order*gaps(mine(1)); % semi circle radius    
    cirsign = sign(next(2)-mine(2)); % 1 == D shaped, -1 == C shaped
    
    loop_curve_x = cirsign*linspace(0,rad,50);
    loop_curve_y_top = sqrt(rad^2 - loop_curve_x.^2);
    loop_curve_y_bottom = -sqrt(rad^2 - loop_curve_x(end:-1:1).^2);
    plot(positions(mine(1),1) + [loop_curve_x loop_curve_x(end:-1:1)], ...
         positions(mine(1),2) + [loop_curve_y_top loop_curve_y_bottom], ...
         options.LineColor,'LineWidth',options.LineWidth, ...
         'LineStyle',options.LineStyle)
    
  else
    %% Draw straight lines
    y1 = mine(2)*gaps(mine(1))+positions(mine(1),2);
    y2 = next(2)*gaps(next(1))+positions(next(1),2);
    plot([positions(mine(1),1) positions(next(1),1)],[y1 y2], ...
         options.LineColor, 'LineWidth',options.LineWidth, ...
         'LineStyle',options.LineStyle)
  end

end


