function [varargout] = conjtest(b1,b2)
%CONJTEST   Conjugacy test for braids.
%   ISCONJ = CONJTEST(B1,B2) returns true if B1 and B2 are conjugate
%   braids, that is, if there exists a braid C such that
%
%     B1 = C B2 C^-1
%
%   [ISCONJ,C] = CONJTEST(B1,B2) also returns the conjugating braid C.
%
%   B1 and B2 must be CFBRAID objects.
%
%   See also CFBRAID.

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   http://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2019  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
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

if nargout > 2
  error('BRAIDLAB:cfbraid:conjtest:nargout','Too many output arguments.');
end

if ~isa(b1,'braidlab.cfbraid') || ~isa(b2,'braidlab.cfbraid')
  error('BRAIDLAB:cfbraid:conjtest:badargs', ...
        'Function takes two CFBRAIDS as arguments.');
end

if b1.n ~= b2.n
  varargout{1} = false;
  if nargout > 1, varargout{2} = []; end
  return
end

if istrivial(b1)
  if istrivial(b2)
    varargout{1} = true;
    if nargout > 1
      varargout{2} = braidlab.cfbraid;
      varargout{2}.n = b1.n;
    end
  else
    varargout{1} = false;
    if nargout > 1, varargout{2} = []; end
  end
  return
end

% TODO: The braids are already in canonical form, but that's recomputed in
% the helper. Rewrite so the helper function accepts a struct.

[isconj,C] = conjtest_helper(b1.braid.word,b2.braid.word,b1.n);

varargout{1} = isconj;
if nargout > 1
  c = braidlab.cfbraid;
  c.delta = C.delta;
  c.factors = C.factors;
  c.n = b1.n;
  varargout{2} = c;
end
