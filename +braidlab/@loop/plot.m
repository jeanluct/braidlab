function plot(varargin)
%PLOT   Plot a loop.
%   PLOT(L) plots a representative of the equivalence class
%   defined by the loop L.
%
%   PLOT(L,'PROPNAME',VALUE,...) can be used to set property PROPNAME to
%   VALUE.  Valid properties are
%
%   LineColor          The line color used to draw the loop.
%   LineStyle          The line style used to draw the loop.
%   LineWidth          The line width used to draw the loop.
%   PunctureColor      The color of the punctures.
%   PunctureEdgeColor  The color of the boundary of the punctures.
%   PunctureSize       The size of the punctures.
%   PuncturePositions  A vector of positions for the punctures, one
%                      coordinate pair per row.  The default is to have
%                      the punctures at integer values on the X-axis.
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

%% List of option names that can be used

optionNames = [
    'LineColor        '
    'LineStyle        '
    'LineWidth        '
    'PunctureColor    '
    'PunctureEdgeColor'
    'PunctureSize     '
    'PuncturePositions'
    ];

names = lower(optionNames);
m = size(names,1);

%% Creation of the options structure

options = [];

for j = 1:m
  options.(deblank(optionNames(j,:))) = [];
end

%% Check that the number of input arguments is valid

% Must be of the form L then option name then option value

if rem(nargin,2) ~= 1
  error('BRAIDLAB:loop:plot:oddarg', ...
        'Number of inputs must be odd.');
end

%% Assigning input options

L = varargin{1};

if ~isscalar(L)
  error('BRAIDLAB:loop:plot:onlyscalar', ...
        'Can only plot scalar loop, not array of loops.');
end

argin_index = 2; % The first argument needs to be the loop, so the 
                   % second index will be the first property name
                   
val = 0; % We do not expect the next argument to be a value

while argin_index <= nargin
  arg = varargin{argin_index};

  if ~val
    if ~ischar(arg)
      error('BRAIDLAB:loop:plot:notaprop', ...
            'Argument %d should be a string.',argin_index);
    end

    lowArg = lower(arg);
    j = strmatch(lowArg,names);
    if isempty(j)                       % if no matches
      error('BRAIDLAB:loop:plot:invalidpropname', ...
            'Invalid property ''%s''.',arg);
    elseif length(j) > 1                % if more than one match
      % Check for any exact matches (in case any names are subsets of others)
      k = strmatch(lowArg,names,'exact');
      if length(k) == 1
        j = k;
      else
        matches = deblank(optionNames(j(1),:));
        for k = j(2:length(j))'
          matches = [matches ', ' deblank(optionNames(k,:))]; %#ok<AGROW>
        end
        error('BRAIDLAB:loop:plot:ambiguouspropname', ...
              'Property %s is ambiguous; matches %s.',arg,matches);
      end
    end
    val = 1;                      % we expect a value next

  else
    options.(deblank(optionNames(j,:))) = arg;
    val = 0;

  end
  argin_index = argin_index + 1;
end

if isempty(options.LineColor);  options.LineColor = 'b'; end
if isempty(options.LineStyle);  options.LineStyle = '-'; end
if isempty(options.LineWidth);  options.LineWidth = 2; end
if isempty(options.PunctureColor); options.PunctureColor = 'r'; end
if isempty(options.PunctureEdgeColor); options.PunctureEdgeColor = 'k'; end


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

%% Set the position of the punctures

% The default position of the punctures are the integers along the x-axis

if isempty(options.PuncturePositions);
  options.PuncturePositions = [(1:n)' 0*(1:n)'];
end

% sort the punctures based on the x coordinate
puncture_position = sortrows(options.PuncturePositions);

% Check to make sure the number of coordinate pairs matches the number of
% punctures in the loop coordinate
if n ~= length(puncture_position)
  error('BRAIDLAB:loop:plot:badlen','Bad number of puncture positions.')
end

if 2 ~= size(puncture_position,2)
  error('BRAIDLAB:loop:plot:badposformat', ...
        'The input position format is incorrect.')
end

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

if isempty(options.PunctureSize);
  options.PunctureSize = .15*min(space_between_loop_lines);
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

puncture_boundary_x = linspace(-prad,prad,100);
puncture_boundary_y_top = sqrt(prad^2 - puncture_boundary_x.^2);
puncture_boundary_y_bottom = -sqrt(prad^2 - puncture_boundary_x(end:-1:1).^2);
  
for p = 1:n
  patch(puncture_position(p,1) + ...
        [puncture_boundary_x puncture_boundary_x(end:-1:1)], ...
        puncture_position(p,2) + ...
        [puncture_boundary_y_top puncture_boundary_y_bottom], ...
        options.PunctureColor,'EdgeColor',options.PunctureEdgeColor)
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
    rad = sc*pgap(p); % semi circle radius
    loop_curve_x = sign(nl)*linspace(0,rad,50);
    loop_curve_y_top = sqrt(rad^2 - loop_curve_x.^2);
    loop_curve_y_bottom = -sqrt(rad^2 - loop_curve_x(end:-1:1).^2);
    plot(puncture_position(p,1) + [loop_curve_x loop_curve_x(end:-1:1)], ...
         puncture_position(p,2) + [loop_curve_y_top loop_curve_y_bottom], ...
         options.LineColor,'LineWidth',options.LineWidth, ...
         'LineStyle',options.LineStyle)
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
      y1 = idx_mine*pgap(p) + puncture_position(p,2);
      y2 = idx_next*pgap(p+1) + puncture_position(p+1,2);
      plot([puncture_position(p,1) puncture_position(p+1,1)],[y1 y2], ...
           options.LineColor, ...
           'LineWidth',options.LineWidth,'LineStyle',options.LineStyle)
    end
    % The lines that join upwards (on the same side).
    for s = tojoindown+1:tojoin
      % idx_mine and _next are indices of vertices of the current (mine)
      % and following (next) puncture that will be connected
      % idx_ > 0 -- vertex is above puncture
      % idx_ < 0 -- vertex is below puncture
      idx_mine = nr+s;
      idx_next = nl+s - (tojoin-tojoinup);
      y1 = idx_mine*pgap(p)+puncture_position(p,2);
      y2 = idx_next*pgap(p+1)+puncture_position(p+1,2);
      %if y2 <= gap*nl; y2 = -gap*(nl+3-s); end
      plot([puncture_position(p,1) puncture_position(p+1,1)],[y1 y2], ...
           options.LineColor, ...
           'LineWidth',options.LineWidth,'LineStyle',options.LineStyle)
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
      y1 = idx_mine*pgap(p)+puncture_position(p,2);
      y2 = idx_next*pgap(p+1)+puncture_position(p+1,2);
      plot([puncture_position(p,1) puncture_position(p+1,1)],[y1 y2], ...
           options.LineColor, ...
           'LineWidth',options.LineWidth,'LineStyle',options.LineStyle)
    end
    % The lines that join downwards (on the same side).
    for s = tojoinup+1:tojoin
      % idx_mine and _next are indices of vertices of the current (mine)
      % and following (next) puncture that will be connected
      % idx_ > 0 -- vertex is above puncture
      % idx_ < 0 -- vertex is below puncture
      idx_mine = -(nr+s);
      idx_next = -(nl+s - (tojoin-tojoindown));
      y1 = idx_mine*pgap(p)+puncture_position(p,2);
      y2 = idx_next*pgap(p+1)+puncture_position(p+1,2);
      plot([puncture_position(p,1) puncture_position(p+1,1)],[y1 y2], ...
           options.LineColor, ...
           'LineWidth',options.LineWidth,'LineStyle',options.LineStyle)
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
%

% puncture indices
  p_m = mine(1);
  p_n = next(1);
  
  dp = next(1) - mine(1); % index distance between punctures
  
  assert( dp == 1 || dp == 0, ['Loop plotting function ' ...
                      'should be used only for one or for consecutive ' ...
                      'punctures.'] );
  if dp == 0
    %% Draw semicircles
    
    error('Not implemented');
    
  else
    %% Draw lines
    
    y1 = idx_mine*gaps(mine(1))+positions(mine(1),2);
    y2 = idx_next*gaps(next(1))+positions(next(1),2);
    plot([gaps(mine(1),1) positions(next(1),1)],[y1 y2], ...
         options.LineColor, 'LineWidth',options.LineWidth, ...
         'LineStyle',options.LineStyle)
  
  end

end


