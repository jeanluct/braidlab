function T = train(b)
%TRAIN   Train track of a braid.
%   T = TRAIN(B) returns a structure T with the train track information for
%   a braid B.  The braid is regarded as labeling an isotopy class on the
%   punctured disk.
%
%   The returned structure T contains the following fields:
%
%   T.braid: the braid itself.
%
%   T.tntype: Thurston type of the isotopy class.  This take the values
%   'finite-order', 'reducible', or 'pseudo-Anosov', following the
%   Thurston-Nielsen classification theorem.
%
%   T.entropy: entropy of the braid.
%
%   T.ttmap: train track map, stored as a cell array of vectors.  For
%   example, edge 2 mapped to the edge sequence [-3 1 2] corresponds to
%   T.ttmap{2} = [-3 1 2].
%
%   T.transmat: transition matrix for the train track map.
%
%   TRAIN uses Toby Hall's implementation of the Bestvina-Handel algorithm.
%
%   References:
%
%   M. Bestvina and M. Handel, "Train-Tracks for surface homeomorphisms,"
%   Topology 34 (1995), 109-140.
%
%   T. Hall, "Train: A C++ program for computing train tracks of surface
%   homeomorphisms," http://www.liv.ac.uk/~tobyhall/T_Hall.html
%
%   W. P. Thurston, "On the geometry and dynamics of diffeomorphisms of
%   surfaces," Bull. Am. Math. Soc. 19 (1988), 417-431.
%
%   This is a method for the BRAID class.
%   See also BRAID, BRAID.ENTROPY.

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   http://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2018  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
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

if b.n >= 3
  T = train_helper(b.word,b.n);
else
  T.tntype = 'finite-order';
  T.entropy = 0;
end

% There are two types of reducibility.  From trains/graph.h:
%
%    Reducible1 means transition matrix reducible
%    Reducible2 have efficient fibred surface
%
% More info on this in trains frontend's "help gates":
%
%    If the graph map held in memory has been found to represent a
%    pseudo-Anosov isotopy class, or a reducible class for which
%    reducibility has been detected because there is an efficient fibred
%    surface with a vertex at which not all of the gates are connected by
%    infinitesimal edges, then this command will display lists of gates and
%    infinitesimal edges at each vertex. The gates are listed in cyclic
%    (anticlockwise) order around the vertex.
%
% For now, treat these as identical and just set the field to 'reducible'.
if any(strcmpi(T.tntype,{'reducible1','reducible2'}))
  T.tntype = 'reducible';
end

T.braid = b;

% Preferred order.
T = orderfields(T,{'braid','tntype','entropy','transmat','ttmap'});
