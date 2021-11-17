function [vertexComponent, Nc] = laplaceToComponents( Lp )
%% [vertexComponent, Nc] = laplaceToComponents( Lp )
%
% Compute connected components in a graph using graph Laplacian.
%
% Number of components is the dimension of the kernel of the
% Laplacian.  Zero-eigenvectors are constant on components of the
% graph. The components can be identify solely from signs of
% eigenvectors, as the positive and negative values of the
% eigenvectors will partition the graph into two, along component
% boundaries. For different eigenvectors partitions will be different,
% so we can take mutual intersections of such partitions to recover
% all components.
%
% Numerically, this is done by treating + and - signs as binary
% digits and the list of + and - corresponding to each vertex gives
% a binary representation of the component to which the vertex belongs.
%
% *** Inputs: ***
% Lp - graph Laplacian (square, real, symmetric, sparse matrix)
%
% *** Outputs: ***
%
% vertexComponent - each element corresponds to a vertex in the graph
% and elements store component numbers
%
% Nc - number of components; dimension of the kernel of the laplacian
% is the number of components
%
%
%   This is a method for the LOOP class.
%   See also LOOP.

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   http://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2021  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
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

opts.issym = true; opts.isreal=true;
[vc,ev] = eigs(Lp,size(Lp,1)/2,'SA');
ev = diag(ev);

% signs of eigenvectors on nodal domains form
% binary coordinates for the components
comp = double(vc(:,ev < 1e-12) > 0);

% convert binary coordinates to decimal
Nc = size(comp, 2);
colors = int32( comp * 2.^(0:(Nc-1)).' );

% since theoretical max of the binary coordinates
% goes 2^Nc, re-label the colors, as only
% Nc out of 2^Nc numbers are used
ucolors = unique(colors);
vertexComponent = NaN(size(colors));
for c = 1:Nc
  vertexComponent( colors == ucolors(c) ) = c;
end

assert( ~any(isnan(vertexComponent)), 'Some component was not assigned');
assert(numel(ucolors) == Nc, 'Number of components and zero eigenvalues does not match')

end
