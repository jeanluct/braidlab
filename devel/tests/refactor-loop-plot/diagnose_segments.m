% Detailed diagnostic for segment ordering issue
addpath(genpath('../..'));
import braidlab.*

% The problematic loop
L = loop([3 2 1 0 -1 -2]);

fprintf('=== LOOP ANALYSIS ===\n');
fprintf('Dynnikov coords: %s\n',mat2str(L.coords));
fprintf('Number of punctures: %d\n',L.totaln);
fprintf('a-coords: %s\n',mat2str(L.a));
fprintf('b-coords: %s\n\n',mat2str(L.b));

% Get the graph to understand component structure
[adjmat,vertexComponent] = L.getgraph();

fprintf('=== GRAPH ANALYSIS ===\n');
fprintf('Number of vertices in graph: %d\n',length(vertexComponent));
vertexComponent_full = full(vertexComponent);
unique_comps = unique(vertexComponent_full);
fprintf('Unique components from getgraph: %s\n',mat2str(unique_comps));
fprintf('Component distribution:\n');
for i = 1:length(unique_comps)
  c = unique_comps(i);
  num_verts = sum(vertexComponent_full == c);
  fprintf('  Component %d: %d vertices\n',c,num_verts);
end
fprintf('\n');

% Get the original plot's component assignment
% Call computeLoopGeometry from our refactored code
eval(sprintf('cd %s','../..'));  % Change to braidlab root
import braidlab.*

% Use default plot parameters
n = L.totaln;
positions = [(1:n)' zeros(n,1)];
gaps = 0.2 * ones(1,n);

% Now manually extract segment generation logic to understand structure
[n_coord,b_coord,M_coord,N_coord] = getcoords(L);

fprintf('=== COORDINATES FOR PLOTTING ===\n');
fprintf('Number of punctures (from getcoords): %d\n',n_coord);
fprintf('b_coord (padded): %s\n',mat2str(b_coord));
fprintf('M_coord: %s\n',mat2str(M_coord));
fprintf('N_coord: %s\n\n',mat2str(N_coord));

% Count segments
num_semicircles = sum(b_coord ~= 0);
num_above = sum(M_coord ~= 0);
num_below = sum(N_coord ~= 0);
total_segs = num_semicircles + num_above + num_below;

fprintf('=== SEGMENT COUNTS ===\n');
fprintf('Semicircles: %d\n',num_semicircles);
fprintf('Above segments: %d\n',num_above);
fprintf('Below segments: %d\n',num_below);
fprintf('Total segments: %d\n\n',total_segs);

% Now let's actually call our refactored geometry computation
fprintf('=== CALLING computeLoopGeometry ===\n');

% We need to call the internal function - let's just run plot and catch the output
try
  figure(100); clf;
  h = plot(L,'Components',true);
  fprintf('Plot succeeded!\n');
  fprintf('Number of handles returned: %d\n',length(h));
  
  for i = 1:length(h)
    xd = get(h(i),'XData');
    yd = get(h(i),'YData');
    fprintf('  Handle %d: %d points, closed=%d\n', ...
            i,length(xd), ...
            (abs(xd(1)-xd(end)) < 1e-6 && abs(yd(1)-yd(end)) < 1e-6));
  end
catch ME
  fprintf('Plot failed: %s\n',ME.message);
end

% Helper function (from original plot.m - padded version)
function [n,b_coord,M_coord,N_coord] = getcoords(L)
  n = L.totaln;
  b_coord = double(L.b);
  [mu,nu] = L.intersec;
  mu = double(mu); nu = double(nu);
  b_coord = [-nu(1)/2 b_coord nu(end)/2];
  M_coord = [nu(1)/2 mu(2*(1:(n-2))-1) nu(n-1)/2];
  N_coord = [nu(1)/2 mu(2*(1:(n-2))) nu(n-1)/2];
end
