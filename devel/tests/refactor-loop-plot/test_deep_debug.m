% Deep debug - understand the segment structure
addpath(genpath('.'));
import braidlab.*

L = loop([3 2 1 0 -1 -2]);

% We need to access the geometry computation directly
% Let's replicate the key parts to see what's happening

[n,b_coord,M_coord,N_coord] = getLoopCoords(L);

fprintf('Loop properties:\n');
fprintf('  n (punctures): %d\n', n);
fprintf('  b_coord: %s\n', mat2str(b_coord));
fprintf('  M_coord: %s\n', mat2str(M_coord));
fprintf('  N_coord: %s\n', mat2str(N_coord));
fprintf('\n');

% Helper function to extract coordinates
function [n,b_coord,M_coord,N_coord] = getLoopCoords(L)
  n = L.totaln;
  b_coord = double(L.b);
  [mu,nu] = L.intersec;
  mu = double(mu); nu = double(nu);
  b_coord = [-nu(1)/2 b_coord nu(end)/2];
  M_coord = [nu(1)/2 mu(2*(1:(n-2))-1) nu(n-1)/2];
  N_coord = [nu(1)/2 mu(2*(1:(n-2))) nu(n-1)/2];
end
