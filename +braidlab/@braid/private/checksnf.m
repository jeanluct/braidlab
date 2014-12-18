function checksnf(A,U,S,V)
%CHECKSNF   Check output of snf (Smith Normal Form).

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   http://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2015  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
%                            Marko Budisic         <marko@math.wisc.edu>
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

if any(any(A - U*S*V' ~= 0))
  error('BRAIDLAB:braid:checksnf:badsnf', ...
        'Bad Smith form: not equal to A.')
end

if ~strcmp(class(A),'vpi') %#ok<STISA>
  if any(any(eye(size(U)) - U*round(inv(U)) ~= 0))
    error('BRAIDLAB:braid:checksnf:badsnf', ...
          'Bad Smith form: inv(U) not integer.')
  end

  if any(any(eye(size(V)) - V*round(inv(V)) ~= 0))
    error('BRAIDLAB:braid:checksnf:badsnf', ...
          'Bad Smith form: inv(V) not integer.')
  end

  if abs(round(det(U))) ~= 1
    error('BRAIDLAB:braid:checksnf:badsnf', ...
          'Bad Smith form: det(U) not +/-1.')
  end

  if abs(round(det(V))) ~= 1
    error('BRAIDLAB:braid:checksnf:badsnf', ...
          'Bad Smith form: det(V) not +/-1.')
  end
end

S2 = S(1:min(size(S)),1:min(size(S)));
if any(any(S2 ~= diag(diag(S))))
  error('BRAIDLAB:braid:checksnf:badsnf', ...
        'Bad Smith form: S not diagonal.')
end

d = diag(S);
ii = find(d == 0);
nmr = length(d);
if ~isempty(ii)
  if any(diff(ii) ~= 1)
    error('BRAIDLAB:braid:checksnf:badsnf', ...
          'Bad smith form: zeros not contiguous.')
  end
  if ii(end) ~= length(d)
    error('BRAIDLAB:braid:checksnf:badsnf', ...
          'Bad smith form: zeros not at the end.')
  end
  nmr = ii(1)-1;
end

for i = 1:nmr-1
  if mod(d(i+1),d(i)) ~= 0
    error('BRAIDLAB:braid:checksnf:badsnf', ...
          'Bad Smith form: S(%d,%d) does not divide S(%d,%d).',i,i,i+1,i+1)
  end
end
