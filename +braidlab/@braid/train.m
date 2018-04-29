function [varargout] = train(b)
%TRAIN   Train track of a braid.
%   T = TRAIN(B) returns a structure T with the train track information for
%   a braid B.  The braid is regarded as labeling an isotopy class on the
%   punctured disk.
%
%   The returned structure T contains the following fields:
%
%   T.tntype: the Thurston type of the isotopy class.  This take the values
%   'finite-order', 'reducible', or 'pseudo-Anosov', following the
%   Thurston-Nielsen classification theorem.
%
%   T.entropy: the entropy of the braid.
%
%   T.ttmap: the train track map.
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

varargout{1} = T;

if any(strcmpi(T.tntype,{'reducible1','reducible2'}))
  varargout{1}.tntype = 'reducible';
end
