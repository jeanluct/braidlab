function [A, Lp] = getgraph(L)
%GETGRAPH  Get graph representation of the loop.
%   [A,Lp] = GETGRAPH(L) returns (nonsymmetric) adjacency matrix (A) 
%   of a graph obtained by subdividing the loop into segments.
%   Vertices are placed on the loop above and below punctures.
%   
%   A is a sparse, nonsymmetric matrix of 0s and 1s, where edges are
%   directed from lower puncture index to higher for neighbor-edges,
%   and by hairpin direction for edges that loop around a puncture.
%   
%   Lp - Laplacian matrix of symmetrized A, i.e.,
%        Lp = diag(sum(A+A.')) - (A+A.')
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

%error('BRAIDLAB:loop:getgraph','getgraph not implemented');

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
% Globals are used to speed up computation in local hash functions
global M_coord;
M_coord = [nu(1)/2 mu(2*(1:(n-2))-1) nu(n-1)/2];
% intersections below punctures
global N_coord;
N_coord = [nu(1)/2 mu(2*(1:(n-2))) nu(n-1)/2]; 

% cumulative sum of intersections, i.e., intersections at punctures
% 1, then 1+2, then 1+2+3, ...
global T_sum;
T_sum = cumsum( M_coord + N_coord );

%% GRAPH INDEXING
%
% Each vertex is indexed by a pair (P,V) where P corresponds to 
% the puncture the vertex is associated to, P = 1, ..., n
% V is the order of the vertex above (V > 0) or below (V < 0) the puncture.
% For each P,
%    max(V) == M_coord(P)
%    min(V) == -N_coord(P)

% number of vertices is the index of the last vertex:
assert(keytohashL( [n, -N_coord(n)] ) == T_sum(end), ...
       'BRAIDLAB:loop:getgraph:hasherror',...
       'Number of vertices and max linear index do not match' );
nV = T_sum(end);

global froms;
global tos;
global edgecount;

edgecount = 0;
froms = zeros(1,2*nV);
tos = zeros(1,2*nV);


%% Identify hairpins -- connections of vertices that are above/below same
%% puncture.

% 'left' hairpins are C-shaped
% 'right' hairpins are D-shaped

% Cycle through each puncture.  
for p = 1:n
    
  % Determine number of hairpins are at the present loop  
  if p == n
    nl = M_coord(n); % this is equal to N_coord(n) ?
  else
    nl = b_coord(p);
  end
  
  % Join vertices connected by hairpins, starting from
  % the inner most hairpin around the puncture and going out.
  for sc = 1:abs(nl)
    joinpoints( [p, -sign(nl)*sc],[p, sign(nl)*sc] );
  end
end

%%  Identify segments above the line of punctures.
for p = 1:n-1

  % How many right-hairpins (b>0) around this puncture?
  if p == 1
    nr = 0;
  else
    nr = max(b_coord(p),0);
  end
  
  % segments that span two neighboring punctures
  tojoin = M_coord(p)-nr;
  if tojoin > 0
    % How many left-hairpins (b<0) around the next puncture?
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
      
      joinpoints( [p,idx_mine], [p+1,idx_next]);
      
    end                                 
    % The lines that join upwards (on the same side).
    for s = tojoindown+1:tojoin
      % idx_mine and _next are indices of vertices of the current (mine)
      % and following (next) puncture that will be connected
      % idx_ > 0 -- vertex is above puncture
      % idx_ < 0 -- vertex is below puncture
      idx_mine = nr+s;
      idx_next = nl+s - (tojoin-tojoinup);
      joinpoints( [p,idx_mine], [p+1,idx_next]);
    end
  end
end

%% Draw segments below the puncture line (N_coord)

for p = 1:n-1

  % How many right-hairpins (b>0) around this puncture?
  if p == 1
    nr = 0;
  else
    nr = max(b_coord(p),0);
  end
  
  % segments that span two different punctures
  tojoin = N_coord(p)-nr;
  if tojoin > 0
    % How many left-hairpins (b<0) around the next puncture?
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
      joinpoints( [p,idx_mine], [p+1,idx_next]);
    end
    % The lines that join downwards (on the same side).
    for s = tojoinup+1:tojoin
      % idx_mine and _next are indices of vertices of the current (mine)
      % and following (next) puncture that will be connected
      % idx_ > 0 -- vertex is above puncture
      % idx_ < 0 -- vertex is below puncture
      idx_mine = -(nr+s);
      idx_next = -(nl+s - (tojoin-tojoindown));
      joinpoints( [p,idx_mine], [p+1,idx_next]);
    end
  end
end

froms = froms(1:edgecount);
tos = tos(1:edgecount);

A = sparse( froms, tos, 1, nV, nV, length(froms) );
Lp = diag(sum(A+A.')) - (A+A.');

end

function joinpoints( mine, next )
%% joinpoints( mine, next )
%  
% Function that modifies the graph structure by adding segments of
% loops.
%
% *** Inputs: ***
% mine and next are pairs (puncture index, vertex index) defining
%    vertices that the function joins.
%
% -- Function will return an error if puncture indices are not the same
%    or consecutive ascending: k, k+1
% -- Vertex indices are integers, excluding 0: positive indices are
%    interpreted as above the puncture, negative as below
% -- when mine(1) == next(1), hairpins are added. In this case
%    it has to hold vertex numbers are the same as well, but with
%    opposite signs. Hairpins are added in positive orientation,
%    so mine(2) < next(2) will result in D-shaped line, whereas 
%    mine(2) > next(2) will result in a C-shaped line.
% 
% *** Warning: *** This function is for internal use, error
% checking is not bullet proof.
  

  dp = next(1) - mine(1); % index distance between punctures
  assert( dp == 1 || dp == 0, 'BRAIDLAB:loop:getgraph:joinpoints',...
         'Requests one or two consecutive punctures');
  
  assert( mine(2)~=0 && next(2)~=0, 'BRAIDLAB:loop:getgraph:joinpoints',...
          'Vertex indices must be nonzero') ;

  mine_h = keytohashL( mine );
  next_h = keytohashL( next );
  
  assert( all( hashtokeyL(mine_h) == mine ), ...
          'BRAIDLAB:loop:getgraph:hasherror',...
          'Key inversion failed');
  
  assert( all( hashtokeyL(next_h) == next ), ...
          'BRAIDLAB:loop:getgraph:hasherror',...
          'Key inversion failed');
  
  fprintf('%s -> %d passed\n', mat2str(mine), mine_h);
  fprintf('%s -> %d passed\n', mat2str(next), next_h);
  
  global froms;
  global tos;
  global edgecount;
  
  edgecount = edgecount + 1;
  froms(edgecount) = keytohashL(mine);
  tos(edgecount) = keytohashL(next);
  
end

function I = keytohashL( PV )
%% I = keytohashL( PV )
%
% Returns a linear index from a pair (puncture index, vertex index)
%
  global M_coord;
  global T_sum;   % cumulative sum over P of |M| + |N|
  
  P = PV(1);
  V = PV(2);

  if P == 1
    I = 0 + abs(V);
  else
    I = T_sum(P-1) + abs(V);
  end
  
  if V < 0
    I = I + abs(M_coord(P));
  end
  
end

function PV = hashtokeyL( I )
%% PV = hashtokeyL( I )
%
%  Returns a pair (P,V) - puncture index, vertex index (see above)
%  from the linear index I
  global M_coord;
  global N_coord;
  global T_sum;  
  
  P = max( [find( T_sum < I, 1, 'last'), 0] ) + 1;
  
  if P > 1
    T = T_sum(P-1);
  else
    T = 0;
  end
  if I - T > M_coord(P)
    V = -( I - T - M_coord(P) );
  else
    V = I - T;    
  end
  
  PV = [P,V];
  
end


