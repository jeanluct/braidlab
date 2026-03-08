function varargout = plot(L,varargin)
%PLOT   Plot a loop.
%   PLOT(L) plots a representative of the equivalence class
%   defined by the loop L.
%
%   H = PLOT(L) returns a column vector of handles to the plotted loop
%   components.  Each handle is a patch object representing one connected
%   component of the loop. Coordinates can be accessed via GET(H(i),'XData')
%   and GET(H(i),'YData').
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
%   PunctureGap        Scalar multiplier for spacing between loop lines
%                      at punctures. Overrides automatic calculation.
%   PunctureGapVector  Per-puncture gap sizes (n×1 vector). Overrides
%                      PunctureGap if both specified.
%   PunctureRadius     Explicit puncture radius for display. Independent
%                      from loop spacing control.
%   BasePointColor     The color of the basepoint puncture, if any.
%   Components         [true/false] Plot connected components in
%                      different colors.  LineColor and LineStyle are ignored.
%   FillLoop           [true/false] Fill the interior of loop components.
%                      Default: false.
%   FillColor          Color for filling loop interiors. Can be RGB triplet
%                      or color character. Default: auto-generated lighter
%                      version of edge color (50% blend with white).
%   FillAlpha          Transparency for filled loops (0 to 1, where 0 is
%                      fully transparent and 1 is opaque). Default: 0.3.
%
%   Examples:
%     L = loop([1 0 0 0]);
%     plot(L);                              % Basic plot
%     h = plot(L,'LineColor','r');          % Red loop, return handle
%     plot(L,'PunctureGap',0.15);           % Custom spacing
%     plot(L,'PunctureRadius',0.05);        % Small punctures
%     plot(L,'FillLoop',true);              % Filled loop (auto color)
%     plot(L,'FillLoop',true,...            % Custom fill color
%       'FillColor',[1 1 0],'FillAlpha',0.5);
%     xdata = get(h(1),'XData');            % Extract coordinates
%
%   This is a method for the LOOP class.
%   See also LOOP, LOOP.LOOP.

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   https://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2026  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
%                            Marko Budisic          <mbudisic@gmail.com>
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
%   along with Braidlab.  If not, see <https://www.gnu.org/licenses/>.
% LICENSE>


parser = inputParser;

%% Specify parameters

% First argument is always a loop
parser.addRequired('L', @(x)isa(x,'braidlab.loop') )

% Function that checks for valid color inputs
iscolor = @(a) (ischar(a) && isscalar(a)) || ...
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
parser.addParameter('PunctureGap', [], ...
  @(x) isempty(x) || (isnumeric(x) && isscalar(x) && x > 0));
parser.addParameter('PunctureGapVector', [], ...
  @(x) isempty(x) || (isnumeric(x) && isvector(x) && all(x > 0)));
parser.addParameter('PunctureRadius', [], ...
  @(x) isempty(x) || (isnumeric(x) && isscalar(x) && x > 0));

% Fill options
parser.addParameter('FillLoop', false, @islogical);
parser.addParameter('FillColor', [], ...
  @(x) isempty(x) || iscolor(x));
parser.addParameter('FillAlpha', 0.3, ...
  @(x) isnumeric(x) && isscalar(x) && x >= 0 && x <= 1);

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
  keytohash = @(PV)graph_keytohash(PV,M_coord,T_sum);

  % compute components of the vertices
  [~,Lp] = L.getgraph;
  [components,Nc] = laplaceToComponents(Lp);

  % assign a unique color to each component
  if Nc > 1
    compcolors = hsv(Nc);
  else
    compcolors = options.LineColor;
  end
else
  components = [];
  keytohash = [];
  Nc = 1;
  compcolors = options.LineColor;
end

%% Set position of punctures
% Check to make sure the number of coordinate pairs matches the number of
% punctures in the loop coordinate

% The default position of the punctures are the integers along the x-axis
if isempty(options.PuncturePositions)
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

% Set the gap size based on user parameters or auto-calculate
if ~isempty(options.PunctureGapVector)
  % User specified per-puncture gaps
  pgap = options.PunctureGapVector(:);
  assert(length(pgap) == n,'BRAIDLAB:loop:plot:badgapvec', ...
         'PunctureGapVector must have length n (number of punctures).');
elseif ~isempty(options.PunctureGap)
  % User specified scalar gap multiplier
  pgap = options.PunctureGap*ones(n,1);
else
  % Auto-calculate (backward compatible)
  pgap = min(space_between_loop_lines)/2+zeros(n,1);
end

%% Set the radius of the puncture
% Visual puncture radius (for drawing only)
% Can be set independently from loop spacing via PunctureRadius parameter

if ~isempty(options.PunctureRadius)
  % User specified explicit radius
  prad = options.PunctureRadius;
elseif ~isempty(options.PunctureSize)
  % User specified PunctureSize (legacy parameter)
  prad = options.PunctureSize;
else
  % Auto-calculate based on loop spacing (backward compatible)
  prad = .15*min(space_between_loop_lines);
  if isinf(prad)
    prad = .05;
  end
end

% Warn if puncture radius conflicts with loop spacing
if prad > min(space_between_loop_lines)
  warning('BRAIDLAB:loop:plot:badrad', ...
          ['Puncture radius is too large.  For this loop the value ' ...
           'can''t exceed %f.'],min(space_between_loop_lines));
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

%% Compute loop geometry
geom = computeLoopGeometry(L,puncture_position,pgap,components,keytohash);

%% Order segments by component
ordered_comps = orderSegmentsByComponent(geom);

%% Draw each component as a continuous closed curve
handles = gobjects(length(ordered_comps),1);
for c = 1:length(ordered_comps)
  seg_list = ordered_comps{c};
  
  if isempty(seg_list)
    continue;
  end
  
  % Concatenate coordinates from all segments in this component
  % Need to properly join segments - check if endpoints match
  xdata = geom(seg_list(1)).xdata;
  ydata = geom(seg_list(1)).ydata;
  
  for k = 2:length(seg_list)
    idx = seg_list(k);
    seg_x = geom(idx).xdata;
    seg_y = geom(idx).ydata;
    
    % Check if this segment's start matches our current end
    current_end_x = xdata(end);
    current_end_y = ydata(end);
    seg_start_x = seg_x(1);
    seg_start_y = seg_y(1);
    seg_end_x = seg_x(end);
    seg_end_y = seg_y(end);
    
    % Tolerance for floating point comparison
    tol = 1e-10;
    
    if abs(current_end_x - seg_start_x) < tol && ...
       abs(current_end_y - seg_start_y) < tol
      % Start matches end, append normally (skip first point to avoid duplicate)
      xdata = [xdata seg_x(2:end)]; %#ok<AGROW>
      ydata = [ydata seg_y(2:end)]; %#ok<AGROW>
    elseif abs(current_end_x - seg_end_x) < tol && ...
           abs(current_end_y - seg_end_y) < tol
      % End matches end, reverse and append (skip first point)
      xdata = [xdata seg_x(end-1:-1:1)]; %#ok<AGROW>
      ydata = [ydata seg_y(end-1:-1:1)]; %#ok<AGROW>
    else
      % Endpoints don't match - this shouldn't happen in a valid loop
      % Just append anyway for debugging
      xdata = [xdata seg_x]; %#ok<AGROW>
      ydata = [ydata seg_y]; %#ok<AGROW>
    end
  end
  
  % Determine edge color for this component
  if options.Components
    comp_id = geom(seg_list(1)).component;
    if comp_id > 0 && comp_id <= size(compcolors,1)
      edgecolor = compcolors(comp_id,:);
    else
      edgecolor = options.LineColor;
    end
  else
    edgecolor = options.LineColor;
  end
  
  % Determine fill color and alpha
  if options.FillLoop
    if ~isempty(options.FillColor)
      % User specified fill color
      facecolor = options.FillColor;
    else
      % Auto-generate lighter version of edge color
      % Convert character color to RGB if needed
      if ischar(edgecolor)
        % Get RGB from character color using a temporary line object
        h_temp = line(NaN,NaN,'Color',edgecolor);
        edgecolor_rgb = get(h_temp,'Color');
        delete(h_temp);
      else
        edgecolor_rgb = edgecolor;
      end
      % Lighten by blending with white (better than multiplication)
      facecolor = edgecolor_rgb*0.5 + [1 1 1]*0.5;
    end
    facealpha = options.FillAlpha;
  else
    facecolor = 'none';
    facealpha = 1;
  end
  
  % Plot this component using patch
  handles(c) = patch('XData',xdata,'YData',ydata, ...
                     'EdgeColor',edgecolor,'LineWidth',options.LineWidth, ...
                     'LineStyle',options.LineStyle, ...
                     'FaceColor',facecolor,'FaceAlpha',facealpha);
end

% Return handles if requested
if nargout > 0
  varargout{1} = handles;
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

end  % plot

% ============================================================================
function geom = computeLoopGeometry(L,puncture_position,pgap,components, ...
                                    keytohash)
%COMPUTELOOPGEOMETRY  Compute geometric segments for loop visualization.
%   GEOM = COMPUTELOOPGEOMETRY(L,PUNCTURE_POSITION,PGAP,COMPONENTS,KEYTOHASH)
%   computes all geometric segments (semicircles and line segments) needed
%   to visualize the loop L.
%
%   Inputs:
%     L                 - Loop object
%     puncture_position - n x 2 matrix of puncture positions
%     pgap              - n x 1 vector of gaps at each puncture
%     components        - Component assignment vector (empty if not using)
%     keytohash         - Function handle for vertex hashing (empty if not using)
%
%   Output:
%     geom - Structure array with one element per segment, fields:
%       .type      - 'semicircle' or 'line'
%       .puncture  - [p1 p2] puncture indices (p1==p2 for semicircles)
%       .vertex    - [v1 v2] vertex indices (signed)
%       .component - Component ID (0 if not using components)
%       .xdata     - x-coordinates of segment
%       .ydata     - y-coordinates of segment

[n,b_coord,M_coord,N_coord] = getcoords(L);

% Initialize segment storage
segments = {};
segcount = 0;

% Determine if we are tracking components
use_components = ~isempty(components);

% Draw semicircles around each puncture
for p = 1:n
  % Determine number of semicircles at the present puncture
  if p == n
    nl = M_coord(n);
  else
    nl = b_coord(p);
  end

  % Draw this number of semicircles taking into account the direction
  for sc = 1:abs(nl)
    segcount = segcount + 1;
    segments{segcount}.type = 'semicircle';
    segments{segcount}.puncture = [p p];
    segments{segcount}.vertex = [p,-sign(nl)*sc; p,sign(nl)*sc];
    
    if use_components
      segments{segcount}.component = components(keytohash([p,-sign(nl)*sc]));
    else
      segments{segcount}.component = 0;
    end
    
    [segments{segcount}.xdata,segments{segcount}.ydata] = ...
      computeSemicircle([p,-sign(nl)*sc],[p,sign(nl)*sc], ...
                        puncture_position,pgap);
  end
end

% Draw segments above the puncture line (M_coord)
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
    % We can't join to these left-facing loops from the left.
    tojoinup = M_coord(p+1)-nl;
    tojoindown = max(tojoin-tojoinup,0);
    % The lines that join downwards.
    for s = 1:tojoindown
      idx_mine = nr + s;
      idx_next = -(nl-s+tojoindown+1);
      
      segcount = segcount + 1;
      segments{segcount}.type = 'line';
      segments{segcount}.puncture = [p p+1];
      segments{segcount}.vertex = [p,idx_mine; p+1,idx_next];
      
      if use_components
        segments{segcount}.component = components(keytohash([p,idx_mine]));
      else
        segments{segcount}.component = 0;
      end
      
      [segments{segcount}.xdata,segments{segcount}.ydata] = ...
        computeLine([p,idx_mine],[p+1,idx_next],puncture_position,pgap);
    end
    % The lines that join upwards (on the same side).
    for s = tojoindown+1:tojoin
      idx_mine = nr+s;
      idx_next = nl+s - (tojoin-tojoinup);
      
      segcount = segcount + 1;
      segments{segcount}.type = 'line';
      segments{segcount}.puncture = [p p+1];
      segments{segcount}.vertex = [p,idx_mine; p+1,idx_next];
      
      if use_components
        segments{segcount}.component = components(keytohash([p,idx_mine]));
      else
        segments{segcount}.component = 0;
      end
      
      [segments{segcount}.xdata,segments{segcount}.ydata] = ...
        computeLine([p,idx_mine],[p+1,idx_next],puncture_position,pgap);
    end
  end
end

% Draw segments below the puncture line (N_coord)
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
    % We can't join to these left-facing loops from the left.
    tojoindown = N_coord(p+1)-nl;
    tojoinup = max(tojoin-tojoindown,0);
    % The lines that join upwards.
    for s = 1:tojoinup
      idx_mine = -(nr+s);
      idx_next = (nl-s+tojoinup+1);
      
      segcount = segcount + 1;
      segments{segcount}.type = 'line';
      segments{segcount}.puncture = [p p+1];
      segments{segcount}.vertex = [p,idx_mine; p+1,idx_next];
      
      if use_components
        segments{segcount}.component = components(keytohash([p,idx_mine]));
      else
        segments{segcount}.component = 0;
      end
      
      [segments{segcount}.xdata,segments{segcount}.ydata] = ...
        computeLine([p,idx_mine],[p+1,idx_next],puncture_position,pgap);
    end
    % The lines that join downwards (on the same side).
    for s = tojoinup+1:tojoin
      idx_mine = -(nr+s);
      idx_next = -(nl+s - (tojoin-tojoindown));
      
      segcount = segcount + 1;
      segments{segcount}.type = 'line';
      segments{segcount}.puncture = [p p+1];
      segments{segcount}.vertex = [p,idx_mine; p+1,idx_next];
      
      if use_components
        segments{segcount}.component = components(keytohash([p,idx_mine]));
      else
        segments{segcount}.component = 0;
      end
      
      [segments{segcount}.xdata,segments{segcount}.ydata] = ...
        computeLine([p,idx_mine],[p+1,idx_next],puncture_position,pgap);
    end
  end
end

% Convert cell array to structure array
geom = [segments{:}];

end  % computeLoopGeometry

% ============================================================================
function ordered = orderSegmentsByComponent(geom)
%ORDERSEGMENTSBYCOMPONENT  Order segments into continuous loop paths.
%   ORDERED = ORDERSEGMENTSBYCOMPONENT(GEOM) takes an array of unordered
%   segments and discovers connected components, ordering each component's
%   segments to form a continuous closed path.
%
%   Note: The geom.component field (which comes from vertex components)
%   is IGNORED. This function finds segment components from scratch using
%   graph connectivity.
%
%   Input:
%     geom - Structure array of segments (from computeLoopGeometry)
%
%   Output:
%     ordered - Cell array where ordered{k} contains the ordered segment
%               indices for component k

if isempty(geom)
  ordered = {};
  return;
end

num_segs = length(geom);

% Build global vertex-to-segment adjacency map
% Key: vertex string 'p_v', Value: list of segment indices
vertex_to_segs = containers.Map('KeyType','char','ValueType','any');

for s = 1:num_segs
  v1 = geom(s).vertex(1,:);
  v2 = geom(s).vertex(2,:);
  
  key1 = sprintf('%d_%d',v1(1),v1(2));
  key2 = sprintf('%d_%d',v2(1),v2(2));
  
  % Add segment to vertex adjacency lists
  if ~isKey(vertex_to_segs,key1)
    vertex_to_segs(key1) = [];
  end
  if ~isKey(vertex_to_segs,key2)
    vertex_to_segs(key2) = [];
  end
  
  vertex_to_segs(key1) = [vertex_to_segs(key1) s];
  vertex_to_segs(key2) = [vertex_to_segs(key2) s];
end

% Find connected components using DFS
visited = false(num_segs,1);
ordered = {};

while any(~visited)
  % Start new component from first unvisited segment
  seed_idx = find(~visited,1);
  
  % Traverse this component using DFS
  component_segs = traverseComponent(geom,seed_idx,vertex_to_segs);
  
  % Mark as visited
  visited(component_segs) = true;
  
  % Add to output
  ordered{end+1} = component_segs(:)';  % Row vector
end

% Helper function: traverse connected component starting from seed
function path = traverseComponent(geom,seed,vertex_to_segs)
  % Build path by following segment connections
  num_segs = length(geom);
  
  % Start from seed segment
  path = seed;
  used = false(num_segs,1);
  used(seed) = true;
  
  % Track current endpoint (end of last segment added)
  v_current = geom(seed).vertex(2,:);
  
  % Follow connections until we return to start or run out
  while true
    key_current = sprintf('%d_%d',v_current(1),v_current(2));
    
    if ~isKey(vertex_to_segs,key_current)
      % Dead end (shouldn't happen for closed loop)
      break;
    end
    
    % Get all segments touching this vertex
    candidates = vertex_to_segs(key_current);
    
    % Find first unused candidate
    next_seg = 0;
    for k = 1:length(candidates)
      if ~used(candidates(k))
        next_seg = candidates(k);
        break;
      end
    end
    
    if next_seg == 0
      % No unused segments - we've closed the loop
      break;
    end
    
    % Add to path
    path(end+1) = next_seg;
    used(next_seg) = true;
    
    % Move to other endpoint of this segment
    if isequal(geom(next_seg).vertex(1,:),v_current)
      % Entered via vertex 1, exit via vertex 2
      v_current = geom(next_seg).vertex(2,:);
    else
      % Entered via vertex 2, exit via vertex 1
      v_current = geom(next_seg).vertex(1,:);
    end
  end
end  % traverseComponent

end  % orderSegmentsByComponent


% ============================================================================
function [xdata,ydata] = computeSemicircle(mine,next,positions,gaps)
%COMPUTESEMICIRCLE  Compute coordinates for a semicircular segment.
%   [XDATA,YDATA] = COMPUTESEMICIRCLE(MINE,NEXT,POSITIONS,GAPS)
%   computes the x and y coordinates for a semicircular loop segment.
%
%   Inputs:
%     mine, next - [puncture, vertex] pairs (both same puncture)
%     positions  - n x 2 matrix of puncture positions
%     gaps       - n x 1 vector of gaps at each puncture
%
%   Outputs:
%     xdata, ydata - Coordinate vectors for the semicircle

order = abs(mine(2));
rad = order*gaps(mine(1));
cirsign = sign(next(2)-mine(2));

loop_curve_x = cirsign*linspace(0,rad,50);
loop_curve_y_top = sqrt(rad^2 - loop_curve_x.^2);
loop_curve_y_bottom = -sqrt(rad^2 - loop_curve_x(end:-1:1).^2);

xdata = positions(mine(1),1) + [loop_curve_x loop_curve_x(end:-1:1)];
ydata = positions(mine(1),2) + [loop_curve_y_top loop_curve_y_bottom];

end  % computeSemicircle

% ============================================================================
function [xdata,ydata] = computeLine(mine,next,positions,gaps)
%COMPUTELINE  Compute coordinates for a straight line segment.
%   [XDATA,YDATA] = COMPUTELINE(MINE,NEXT,POSITIONS,GAPS)
%   computes the x and y coordinates for a straight line loop segment.
%
%   Inputs:
%     mine, next - [puncture, vertex] pairs (consecutive punctures)
%     positions  - n x 2 matrix of puncture positions
%     gaps       - n x 1 vector of gaps at each puncture
%
%   Outputs:
%     xdata, ydata - Coordinate vectors for the line segment

y1 = mine(2)*gaps(mine(1))+positions(mine(1),2);
y2 = next(2)*gaps(next(1))+positions(next(1),2);

xdata = [positions(mine(1),1) positions(next(1),1)];
ydata = [y1 y2];

end  % computeLine

% ============================================================================
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

end  % getcoords
