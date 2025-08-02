function b = convert_to_braid(obj)

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   https://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2025  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
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
%   along with Braidlab.  If not, see <https://www.gnu.org/licenses/>.
% LICENSE>

n = obj.nann;
idxn = find(abs(obj.word) == n);
if isempty(idxn)
  w = obj.word;
else
  % Sigma_n = n n n-1 n-2 ... 1 -2 -3 ... -n -n
  Sn = [n n:-1:2 1 -(2:n) -n];
  Sni = [n n:-1:2 -1 -(2:n) -n];
  if obj.word(idxn(1)) > 0
    w = [obj.word(1:idxn(1)-1) Sn];
  else
    w = [obj.word(1:idxn(1)-1) Sni];
  end
  for i = 2:length(idxn)
    w = [w obj.word(idxn(i-1)+1:idxn(i)-1)]; %#ok<AGROW>
    if obj.word(idxn(i)) > 0
      w = [w Sn]; %#ok<AGROW>
    else
      w = [w Sni]; %#ok<AGROW>
    end
  end
  w = [w obj.word(idxn(end)+1:end)];
end

b = braidlab.braid(w,obj.n);
