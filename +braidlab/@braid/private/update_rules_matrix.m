function M = update_rules_matrix(b,opSign,N)

% Helper function for method braid.linact.

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   http://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2016  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
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


% Maximum generator index for this loop size.  Do not use b.n, in case braid
% has fewer punctures than loop, which is allowed.
n = N/2 + 2;

M = speye(N,N);

% Starting 1-indexed location.
a0 = 0; b0 = N/2;

% Return sign of x (note different def'n than in loopsigma.m).
pos = @(x) x > 0; neg = @(x) x < 0;

maxopSign = 5;
opSign = reshape(opSign,[length(b) maxopSign]);

for j = 1:length(b)
  i = abs(b.word(j));
  T = speye(N,N);
  if b.word(j) > 0
    switch(i)
     case 1
      % opSign(j,1) = sign(b(1));
      % opSign(j,2) = sign(bp(1));

      % ap(1) = -b(1) + pos(a(1) + pos(b(1)));
      T(a0+1,b0+1) = -1 + pos(opSign(j,1))*pos(opSign(j,2)); %#ok<*SPRIX>
      T(a0+1,a0+1) = pos(opSign(j,2));
      % bp(1) = a(1) + pos(b(1));
      T(b0+1,a0+1) = 1;
      T(b0+1,b0+1) = pos(opSign(j,1));

     case n-1
      % opSign(j,1) = sign(b(n-2));
      % opSign(j,2) = sign(bp(n-2));

      % ap(n-2) = -b(n-2) + neg(a(n-2) + neg(b(n-2)));
      T(a0+n-2,b0+n-2) = -1 + neg(opSign(j,1))*neg(opSign(j,2));
      T(a0+n-2,a0+n-2) = neg(opSign(j,2));
      % bp(n-2) = a(n-2) + neg(b(n-2));
      T(b0+n-2,a0+n-2) = 1;
      T(b0+n-2,b0+n-2) = neg(opSign(j,1));

     otherwise
      % opSign(j,1) = sign(b(i));
      % opSign(j,2) = sign(b(i-1));
      % opSign(j,3) = sign(c);
      % opSign(j,4) = sign(pos(b(i)) + c);
      % opSign(j,5) = sign(neg(b(i-1)) - c);

      %c = a(i-1) - a(i) - pos(b(i)) + neg(b(i-1));
      c = opSign(j,3);
      % ap(i-1) = a(i-1) - pos(b(i-1)) - pos(pos(b(i)) + c);
      T(a0+i-1,a0+i-1) = 1 - pos(opSign(j,4)) * (1);
      T(a0+i-1,b0+i-1) = -pos(opSign(j,2)) - pos(opSign(j,4)) * (neg(opSign(j,2)));
      T(a0+i-1,a0+i)   = -pos(opSign(j,4)) * (-1);
      % bp(i-1) = b(i) + neg(c);
      T(b0+i-1,b0+i) = 1 + neg(c) * (-pos(opSign(j,1)));
      T(b0+i-1,a0+i-1) = neg(c) * (1);
      T(b0+i-1,a0+i)   = neg(c) * (-1);
      T(b0+i-1,b0+i-1) = neg(c) * (neg(opSign(j,2)));
      % ap(i) = a(i) - neg(b(i)) - neg(neg(b(i-1)) - c);
      T(a0+i,a0+i)   = 1 + neg(opSign(j,5)) * (-1);
      T(a0+i,b0+i)   = -neg(opSign(j,1)) + neg(opSign(j,5)) * (-pos(opSign(j,1)));
      T(a0+i,a0+i-1) = neg(opSign(j,5)) * (1);
      % bp(i) = b(i-1) - neg(c);
      T(b0+i,b0+i-1) = 1 - neg(c) * (neg(opSign(j,2)));
      T(b0+i,a0+i-1) = -neg(c) * (1);
      T(b0+i,a0+i)   = -neg(c) * (-1);
      T(b0+i,b0+i)   = -neg(c) * (-pos(opSign(j,1)));
    end
  elseif b.word(j) < 0
    switch(i)
     case 1
      % opSign(j,1) = sign(b(1));
      % opSign(j,2) = sign(bp(1));

      % ap(1) = b(1) - pos(-a(1) + pos(b(1)));
      T(a0+1,b0+1) = 1 - pos(opSign(j,2)) * (pos(opSign(j,1)));
      T(a0+1,a0+1) = -pos(opSign(j,2)) * (-1);
      % bp(1) = -a(1) + pos(b(1));
      T(b0+1,a0+1) = -1;
      T(b0+1,b0+1) = pos(opSign(j,1));

     case n-1
      % opSign(j,1) = sign(b(n-2));
      % opSign(j,2) = sign(bp(n-2));

      % ap(n-2) = b(n-2) - neg(-a(n-2) + neg(b(n-2)));
      T(a0+n-2,b0+n-2) = 1 - neg(opSign(j,2)) * (neg(opSign(j,1)));
      T(a0+n-2,a0+n-2) = -neg(opSign(j,2)) * (-1);
      % bp(n-2) = -a(n-2) + neg(b(n-2));
      T(b0+n-2,a0+n-2) = -1;
      T(b0+n-2,b0+n-2) = neg(opSign(j,1));

     otherwise
      % opSign(j,1) = sign(b(i));
      % opSign(j,2) = sign(b(i-1));
      % opSign(j,3) = sign(pos(b(i)) - d);
      % opSign(j,4) = sign(d);
      % opSign(j,5) = sign(neg(b(i-1)) + d);

      %d = a(i-1) - a(i) + pos(b(i)) - neg(b(i-1));
      d = opSign(j,4);
      % ap(i-1) = a(i-1) + pos(b(i-1)) + pos(pos(b(i)) - d);
      T(a0+i-1,a0+i-1) = 1 + pos(opSign(j,3)) * -(1);
      T(a0+i-1,b0+i-1) = pos(opSign(j,2)) + pos(opSign(j,3)) * -(-neg(opSign(j,2)));
      T(a0+i-1,a0+i)   = pos(opSign(j,3)) * -(-1);
      % bp(i-1) = b(i) - pos(d);
      T(b0+i-1,b0+i)   = 1 - pos(d) * (pos(opSign(j,1)));
      T(b0+i-1,a0+i-1) = -pos(d) * (1);
      T(b0+i-1,a0+i)   = -pos(d) * (-1);
      T(b0+i-1,b0+i-1) = -pos(d) * (-neg(opSign(j,2)));
      % ap(i) = a(i) + neg(b(i)) + neg(neg(b(i-1)) + d);
      T(a0+i,a0+i)   = 1 + neg(opSign(j,5)) * (-1);
      T(a0+i,b0+i)   = neg(opSign(j,1)) + neg(opSign(j,5)) * (pos(opSign(j,1)));
      T(a0+i,a0+i-1) = neg(opSign(j,5)) * (1);
      % bp(i) = b(i-1) + pos(d);
      T(b0+i,b0+i-1) = 1 + pos(d) * (-neg(opSign(j,2)));
      T(b0+i,a0+i-1) = pos(d) * (1);
      T(b0+i,a0+i)   = pos(d) * (-1);
      T(b0+i,b0+i)   = pos(d) * (pos(opSign(j,1)));
    end
  end
  M = T*M;
end
