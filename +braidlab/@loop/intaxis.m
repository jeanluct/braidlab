function l = intaxis(obj)
%INTAXIS   The number of intersections of a loop with the real axis.
%   I = INTAXIS(L) computes the minimum number of intersections of a
%   loop L with the real axis.
%
%   This is a method for the LOOP class.
%   See also LOOP, LOOP.MINLENGTH, LOOP.INTERSEC.

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

if ~isscalar(obj)
  l = zeros(length(obj),1);
  for k = 1:length(obj)
    l(k) = intaxis(obj(k));
  end
else
  [a,b] = obj.ab;

  % The number of intersections before/after the first and last punctures.
  % See Hall & Yurttas (2009).
  cumb = [zeros(size(b,1),1) cumsum(b,2)];
  b0 = -max(abs(a) + max(b,0) + cumb(:,1:end-1),[],2);
  bn1 = -b0 - sum(b,2);

  % The number of intersections with the real axis.
  l = sum(abs(b),2) + sum(abs(a(:,2:end)-a(:,1:end-1)),2) ...
      + abs(a(:,1)) + abs(a(:,end)) + abs(b0) + abs(bn1);
end
