function [varargout] = tntype(b)
%TNTYPE   Thurston-Nielsen type of a braid.
%   T = TNTYPE(B) returns the Thurston-Nielsen type of a braid B.  The braid
%   is regarded as labeling an isotopy class on the punctured disk.  The
%   type T can take the values 'finite-order', 'reducible', or
%   'pseudo-Anosov', following the Thurston-Nielsen classification theorem.
%
%   [T,ENTR] = TNTYPE(B) also returns the entropy ENTR of the braid.
%
%   TNTYPE uses Toby Hall's implementation of the Bestvina-Handel algorithm.
%
%   This is a method for the BRAID class.
%   See also BRAID, BRAID.ENTROPY.

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   http://bitbucket.org/jeanluc/braidlab/
%
%   Copyright (C) 2013--2014  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
%                             Marko Budisic         <marko@math.wisc.edu>
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
  [TN,entr] = tntype_helper(b.word,b.n);
else
  TN = 'finite-order';
  entr = 0;
end

if any(strcmpi(TN,{'reducible1','reducible2'}))
  varargout{1} = 'reducible';
else
  varargout{1} = TN;
end

% Optionally also return entropy, since we get it for free as well.
if nargout > 1, varargout{2} = entr; end
