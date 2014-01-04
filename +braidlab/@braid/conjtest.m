function [varargout] = conjtest(b1,b2)
%CONJTEST   Conjugacy test for braids.
%   ISCONJ = CONJTEST(B1,B2) returns true if B1 and B2 are conjugate
%   braids, that is, if there exists a braid C such that
%
%     B1 = C B2 C^-1
%
%   [ISCONJ,C] = CONJTEST(B1,B2) also returns the conjugating braid C.
%
%   See also CFBRAID.

% <LICENSE
%   Copyright (c) 2013, 2014 Jean-Luc Thiffeault
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

[isconj,C] = conjtest(braidlab.cfbraid(b1),braidlab.cfbraid(b2));

varargout{1} = isconj;
if nargout > 1
  varargout{2} = braidlab.braid(C);
end
