% Simple test to understand component assignment
addpath(genpath('../..'));
import braidlab.*

L = loop([3 2 1 0 -1 -2]);

fprintf('Testing loop: %s\n',mat2str(L.coords));
fprintf('Number of punctures: %d\n\n',L.totaln);

% Call plot with Components option to trigger component computation
figure(100); clf; hold on;

% Set up axes
xlim([0 6]); ylim([-2 2]);
axis equal;

% Plot manually to see what segments we get
n = L.totaln;
[n_coord,b_coord,M_coord,N_coord] = getcoords(L);

fprintf('=== PLOT COORDINATES ===\n');
fprintf('n: %d\n',n_coord);
fprintf('b_coord: %s\n',mat2str(b_coord));
fprintf('M_coord: %s\n',mat2str(M_coord));
fprintf('N_coord: %s\n\n',mat2str(N_coord));

% Count expected segments
num_semicircles = sum(b_coord ~= 0);
num_above = sum(M_coord ~= 0);
num_below = sum(N_coord ~= 0);

fprintf('Expected segments:\n');
fprintf('  Semicircles: %d\n',num_semicircles);
fprintf('  Above: %d\n',num_above);
fprintf('  Below: %d\n',num_below);
fprintf('  TOTAL: %d\n\n',num_semicircles + num_above + num_below);

% Now manually create geometries and assign components using the actual
% plot.m logic - just inspect what comes out of computeLoopGeometry
%
% We can't call laplaceToComponents directly, so let's just trace through
% what plot.m does and look at the results

% Actually, let's just call plot and catch any errors
try
  fprintf('=== CALLING PLOT ===\n');
  figure(101); clf;
  h = plot(L,'Components',true);
  
  fprintf('Plot returned %d handles\n',length(h));
  
  for i = 1:length(h)
    xd = get(h(i),'XData');
    yd = get(h(i),'YData');
    fprintf('  Component %d: %d points, closed=%d\n', ...
            i,length(xd), ...
            (abs(xd(1)-xd(end)) < 1e-6 && abs(yd(1)-yd(end)) < 1e-6));
    
    if abs(xd(1)-xd(end)) > 1e-6 || abs(yd(1)-yd(end)) > 1e-6
      fprintf('    START: (%.4f, %.4f)\n',xd(1),yd(1));
      fprintf('    END:   (%.4f, %.4f)\n',xd(end),yd(end));
      fprintf('    GAP:   %.6f\n',sqrt((xd(1)-xd(end))^2 + (yd(1)-yd(end))^2));
    end
  end
  
catch ME
  fprintf('ERROR: %s\n',ME.message);
  fprintf('  at %s:%d\n',ME.stack(1).file,ME.stack(1).line);
end

fprintf('\n=== ANALYSIS ===\n');
fprintf('The issue: Component 2 is not closing properly\n');
fprintf('Expected: 13 total segments distributed across 2 components\n');
fprintf('But the orderSegmentsByComponent function fails to traverse all segments\n\n');

fprintf('Next step: Add debug output to orderSegmentsByComponent to see\n');
fprintf('which segments are being visited and which are being skipped.\n');

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
