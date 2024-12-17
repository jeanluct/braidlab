function PV = graph_hashtokey( I, M, T )
%% PV = hashtokey( I, M, T )
%
% Returns the key - a pair (puncture index, vertex index) from a
% linear index.
%
% PV - pair [puncture index, vertex index]
%
% M - vector of intersection number for coordinate lines above
%     punctures
%
% T - cumulative sum (1, 1+2, 1+2+3, ...) over P intersection
%     numbers for coordinate lines at punctures
%
% A more detailed explanation
% LOOP GRAPH INDEXING
%
% The loop graph represents loops using a graph in which vertices
% are intersections of loops with Dynnikov coordinate lines
% above and below punctures.
%
% Each vertex is indexed by a pair (P,V) where P corresponds to
% the puncture the vertex is associated to, P = 1, ..., n
% V is the order of the vertex above (V > 0) or below (V < 0) the puncture.
% For each P,
%    max(V) == M(P)
%    min(V) == -N(P)
%
% Where M and N are intersection numbers with, respectively, lines
% above and below punctures.
%
% This function is the inverse of loop/private/keytohash.
%
%   This is a method for the LOOP class.
%   See also LOOP.

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   http://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2024  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
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
%   along with Braidlab.  If not, see <http://www.gnu.org/licenses/>.
% LICENSE>


  P = max( [find( T < I, 1, 'last'), 0] ) + 1;

  if P > 1
    Td = T(P-1);
  else
    Td = 0;
  end
  if I - Td > M(P)
    V = -( I - Td - M(P) );
  else
    V = I - Td;
  end

  PV = [P,V];

end
