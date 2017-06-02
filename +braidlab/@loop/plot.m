function plot(L, varargin)
%PLOT   Plot a loop.
%   PLOT(L) plots a representative of the equivalence class
%   defined by the loop L.
%
%   PLOT(L,'PropName',VALUE,...) can be used to set property PropName to
%   VALUE.  Valid properties are
%
%   LineColor          The line color used to draw the loop.
%   LineStyle          The line style used to draw the loop.
%   LineWidth          The line width used to draw the loop.
%   PunctureColor      The color of the punctures.
%   PunctureEdgeColor  The color of the boundary of the punctures.
%   PunctureEdgeWidth  The width of the boundary of the punctures.
%   PunctureSize       The size of the punctures.
%   PuncturePositions  A vector of positions for the punctures, one
%                      coordinate pair per row.  The default is to have
%                      the punctures at integer values on the X-axis.
%   BasePointColor     The color of the basepoint puncture, if any.
%   Components         [true/false] Plot connected components in
%                      different colors.  LineColor and LineStyle are ignored.
%
%   This is a method for the LOOP class.
%   See also LOOP, LOOP.LOOP.

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


parser = inputParser;

%% Specify parameters

% First argument is always a loop
parser.addRequired('L', @(x)isa(x,'braidlab.loop') )

% Function that checks for valid color inputs
iscolor = @(a) (ischar(a) && numel(a)==1) || ...
          (all(isfinite(a) & a >= 0) && ...
           numel(a) >= 3 && numel(a) <= 4);


% List of option names that can be used
parser.addParameter('LineStyle', '-', @ischar);
parser.addParameter('LineWidth', 2, @isfinite);
parser.addParameter('LineColor', 'b', iscolor);
parser.addParameter('PunctureColor', 'r', iscolor);
parser.addParameter('BasePointColor', 'g', iscolor);
parser.addParameter('PunctureEdgeColor', 'k', iscolor);
parser.addParameter('PunctureEdgeWidth', 1, @isnumeric);
parser.addParameter('PunctureSize', [], @isfinite);
parser.addParameter('PuncturePositions', [], @isnumeric);

% With 'Components' option, LineColor and LineStyle set automatically
parser.addParameter('Components', false, @islogical);

parser.parse( L, varargin{:} );
options = parser.Results;

assert( size(L.coords,1) == 1, ...
        'BRAIDLAB:loop:plot:multiloop',...
        ['Argument cannot be a loop vector. ' ...
         'Use plot(L(k)) to plot the k-th loop.'] );

%%% Process options

%%
% Extract loop properties useful for plotting
%
% n - number of punctures
% b_coord - b coordinates
% M_coord, N_coord - "above", "below" intersection numbers
[n, b_coord, M_coord, N_coord] = getcoords( L );

%% Compute components and assign colors to them
% If components are plotted separately, compute them and assign
% unique colors
if options.Components
  % cumulative sum of intersections, i.e., intersections at punctures
  % 1, then 1+2, then 1+2+3, ...
  T_sum = cumsum( M_coord + N_coord );

  % initialize hash functions - conversion of puncture-intersection coordinates
  % to linear index of vertices used in adjacency matrix
  keytohash = @(PV)graph_keytohash(PV, M_coord, T_sum);

  % compute components of the vertices
  [~,Lp] = L.getgraph;
  [components, Nc] = laplaceToComponents(Lp);

  % assign a unique color to each component
  if Nc > 1
    compcolors = hsv(Nc);
  else
    compcolors = options.LineColor;
  end
end

%% Set position of punctures
% Check to make sure the number of coordinate pairs matches the number of
% punctures in the loop coordinate

% The default position of the punctures are the integers along the x-axis
if isempty(options.PuncturePositions);
  options.PuncturePositions = [(1:n)' 0*(1:n)'];
end

assert( n == size(options.PuncturePositions,1), ...
        'BRAIDLAB:loop:plot:badlen',...
        ['Number of puncture positions should match number of ' ...
         'punctures.'] );
assert( 2 == size(options.PuncturePositions,2), ...
        'BRAIDLAB:loop:plot:badposformat',...
        'Each puncture position should be a row of 2 elements.' );

% sort the punctures based on the x coordinate
puncture_position = sortrows(options.PuncturePositions);

% Calculate the distance between punctures
d =  hypot(diff(puncture_position(:,1)),diff(puncture_position(:,2)));

%% Set the distance between the puncture and the lines forming the loop

% Calculate the distance between the lines making up the loop.  This is
% based on the number of times the loop passes above or below a given
% puncture and the distance to the two nearest punctures.

space_between_loop_lines = zeros(size(d));
for i = 1:n-1
  space_between_loop_lines(i) = min(d(i)/M_coord(i),d(i)/N_coord(i))*.7;
end

% Set the gap size to half the minimum distance between lines
pgap = min(space_between_loop_lines)/2+zeros(n,1);

%% Set the radius of the puncture
% TODO: Keep punctures same size (need special gap near x-axis).
% set the default puncture radius if no property value was input
if isempty(options.PunctureSize)
  options.PunctureSize = .15*min(space_between_loop_lines);
  if isinf(options.PunctureSize)
    options.PunctureSize = .05;
  end
end

prad = options.PunctureSize;
% check to make sure puncture radius is not so large that it hits the loop

if prad > min(space_between_loop_lines)
  warning('BRAIDLAB:loop:plot:badrad', ...
          ['Puncture radius is too large.  For this loop the value ' ...
           'can''t exceed %f.'],min(space_between_loop_lines))
  prad = .15*min(space_between_loop_lines);
end

%% Identify hold state of the current figure
% this state will be reestablished after loop is plotted

if ishold
  holdstate = true;
else
  holdstate = false;
  % This makes sure to start the axes afresh.
  % Try "imagesc([1 1]), plot(loop)" without the cla to see the problem.
  % See also issue #43.
  cla
  hold on
end

%%  Draw punctures.

if prad > 0
  puncture_boundary_x = linspace(-prad,prad,100);
  puncture_boundary_y_top = sqrt(prad^2 - puncture_boundary_x.^2);
  puncture_boundary_y_bottom = -sqrt(prad^2 - puncture_boundary_x(end:-1:1).^2);

  for p = 1:n
    if p == L.basepoint
      pc = options.BasePointColor;
    else
      pc = options.PunctureColor;
    end
    patch(puncture_position(p,1) + ...
          [puncture_boundary_x puncture_boundary_x(end:-1:1)], ...
          puncture_position(p,2) + ...
          [puncture_boundary_y_top puncture_boundary_y_bottom], ...
          pc,'EdgeColor',options.PunctureEdgeColor, ...
          'LineWidth',options.PunctureEdgeWidth)
  end
end

%% Draw semicircles
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
    if options.Components
      mycomp = components( keytohash([p, -sign(nl)*sc]) );
      mycolor = compcolors(mycomp,:);
      options.LineColor = mycolor;
    end

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

      if options.Components
        mycomp = components( keytohash([p,idx_mine]) );
        mycolor = compcolors(mycomp,:);
        options.LineColor = mycolor;
      end

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

      if options.Components
        mycomp = components( keytohash([p,idx_mine]) );
        mycolor = compcolors(mycomp,:);
        options.LineColor = mycolor;
      end

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

      if options.Components
        mycomp = components( keytohash([p,idx_mine]) );
        mycolor = compcolors(mycomp,:);
        options.LineColor = mycolor;
      end

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

      if options.Components
        mycomp = components( keytohash([p,idx_mine]) );
        mycolor = compcolors(mycomp,:);
        options.LineColor = mycolor;
      end

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

function [n, b_coord, M_coord, N_coord] = getcoords( L )
%% getcoords( L )
%
% Extract loop properties useful for plotting
%
% n - number of punctures
% b_coord - b coordinates
% M_coord - "above" intersections
% N_coord - "below" intersections

n = L.totaln;

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
  if options.Components
    plot(positions(mine(1),1) + [loop_curve_x loop_curve_x(end:-1:1)], ...
         positions(mine(1),2) + [loop_curve_y_top loop_curve_y_bottom], ...
         'Color', options.LineColor,'LineWidth',options.LineWidth, ...
         'LineStyle',options.LineStyle)
  else
    plot(positions(mine(1),1) + [loop_curve_x loop_curve_x(end:-1:1)], ...
         positions(mine(1),2) + [loop_curve_y_top loop_curve_y_bottom], ...
         options.LineColor,'LineWidth',options.LineWidth, ...
         'LineStyle',options.LineStyle)
  end

else
  %% Draw straight lines
  y1 = mine(2)*gaps(mine(1))+positions(mine(1),2);
  y2 = next(2)*gaps(next(1))+positions(next(1),2);
  if options.Components
    plot([positions(mine(1),1) positions(next(1),1)],[y1 y2], ...
         'Color',options.LineColor, 'LineWidth',options.LineWidth, ...
         'LineStyle',options.LineStyle)
  else
    plot([positions(mine(1),1) positions(next(1),1)],[y1 y2], ...
         options.LineColor, 'LineWidth',options.LineWidth, ...
         'LineStyle',options.LineStyle)
  end
end
