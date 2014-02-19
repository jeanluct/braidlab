function [varargout] = loopsigma(ii,u)
%LOOPSIGMA   Act on a loop with a braid group generator sigma.
%   UP = LOOPSIGMA(J,U) acts on the loop U (encoded in Dynnikov coordinates)
%   with the braid generator sigma_J, and returns the new loop UP.  J can be
%   a positive or negative integer (inverse generator), and can be specified
%   as a vector, in which case all the generators are applied to the loop
%   sequentially from left to right.
%
%   U is specified as a row vector, or rows of row vectors containing
%   several loops.

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

if isempty(ii)
  up = u;
  return
end

% If MEX file is available, use that.
if exist('loopsigma_helper') == 3 && nargout < 2
  if isa(u,'double') || isa(u,'single') || isa(u,'int32') || isa(u,'int64')
    varargout{1} = loopsigma_helper(ii,u);
    return
  end
end

n = size(u,2)/2 + 2;
a = u(:,1:n-2); b = u(:,(n-1):end);
ap = a; bp = b;

pos = @(x)max(x,0); neg = @(x)min(x,0);

% If nargout > 1, record the state of pos/neg operators.
recposneg = false;
if nargout > 1, recposneg = true; end
if recposneg
  pn = zeros(size(u,1),length(ii),4);
end

for j = 1:length(ii)
  i = abs(ii(j));
  if ii(j) > 0
    switch(i)
     case 1
      bp(:,1) = sumg( a(:,1) , pos(b(:,1)) );
      ap(:,1) = sumg( -b(:,1) , pos(bp(:,1)) );
      if recposneg
        pn(:,j,1) = sign(b(:,1));
        pn(:,j,2) = sign(bp(:,1));
      end
     case n-1
      bp(:,n-2) = sumg( a(:,n-2) , neg(b(:,n-2)) );
      ap(:,n-2) = sumg( -b(:,n-2) , neg(bp(:,n-2)) );
      if recposneg
        pn(:,j,1) = sign(b(:,n-2));
        pn(:,j,2) = sign(bp(:,n-2));
      end
     otherwise
      c = sumg( a(:,i-1), -a(:,i), -pos(b(:,i)), neg(b(:,i-1)) );
      ap(:,i-1) = sumg( a(:,i-1), -pos(b(:,i-1)), -pos(sumg(pos(b(:,i)), c)) );
      bp(:,i-1) = sumg( b(:,i), neg(c) );
      ap(:,i) = sumg( a(:,i), -neg(b(:,i)), -neg(sumg(neg(b(:,i-1)), -c)) );
      bp(:,i) = sumg( b(:,i-1), -neg(c) );
      if recposneg
        pn(:,j,1) = sign(b(:,i));
        pn(:,j,2) = sign(b(:,i-1));
        pn(:,j,3) = sign(c);
        pn(:,j,4) = sign( neg(b(:,i-1)) - c );
      end
    end
  elseif ii(j) < 0
    switch(i)
     case 1
      bp(:,1) = sumg(-a(:,1), pos(b(:,1)) );
      ap(:,1) = sumg(b(:,1), -pos(bp(:,1)) );
      if recposneg
        pn(:,j,1) = sign(b(:,1));
        pn(:,j,2) = sign(bp(:,1));
      end
     case n-1
      bp(:,n-2) = sumg(-a(:,n-2), neg(b(:,n-2)) );
      ap(:,n-2) = sumg(b(:,n-2), - neg(bp(:,n-2)) );
      if recposneg
        pn(:,j,1) = sign(b(:,n-2));
        pn(:,j,2) = sign(bp(:,n-2));
      end
     otherwise
      d = sumg(a(:,i-1), -a(:,i), pos(b(:,i)), -neg(b(:,i-1)));
      ap(:,i-1) = sumg(a(:,i-1), pos(b(:,i-1)), pos(sumg(pos(b(:,i)),- d)) );
      bp(:,i-1) = sumg(b(:,i), -pos(d));
      ap(:,i) = sumg(a(:,i), neg(b(:,i)), neg(sumg(neg(b(:,i-1)), d)) );
      bp(:,i) = sumg(b(:,i-1), pos(d) );
      if recposneg
        pn(:,j,1) = sign(b(:,i));
        pn(:,j,2) = sign(b(:,i-1));
        pn(:,j,3) = sign(pos(b(:,i)) - d);
        pn(:,j,4) = sign(d);
      end
    end
  end
  a = ap; b = bp;
end
varargout{1} = [ap bp];

if nargout > 1
  pn = reshape(pn,[size(u,1) 4*length(ii)]);
  varargout{2} = pn;
end
