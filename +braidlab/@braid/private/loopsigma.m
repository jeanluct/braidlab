function up = loopsigma(ii,u)
%LOOPSIGMA   Act on a loop with a braid group generator sigma.
%   UP = LOOPSIGMA(J,U) acts on the loop U (encoded in Dynnikov coordinates)
%   with the braid generator sigma_J, and returns the new loop UP.  J can be
%   a positive or negative integer (inverse generator), and can be specified
%   as a vector, in which case all the generators are applied to the loop
%   sequentially from left to right.
%
%   U is specified as a row vector, or rows of row vectors containing
%   several loops.

if isempty(ii)
  up = u;
  return
end

if isa(u,'double') && exist('loopsigma_helper') == 3
  % If MEX file is available, use that.
  % Only works on double precision numbers.
  up = loopsigma_helper(ii,u);
  return
end

n = size(u,2)/2 + 2;
a = u(:,1:n-2); b = u(:,(n-1):end);
ap = a; bp = b;

% The pure function defs don't work for vpi, since it doesn't overlad min/max.
%pos = @(x)max(x,0); neg = @(x)min(x,0);
function x = pos(x), x(find(x < 0)) = 0; end
function x = neg(x), x(find(x > 0)) = 0; end

for j = 1:length(ii)
  i = abs(ii(j));
  if ii(j) > 0
    switch(i)
     case 1
      bp(:,1) = sumg( a(:,1) , pos(b(:,1)) );
      ap(:,1) = sumg( -b(:,1) , pos(bp(:,1)) );
     case n-1
      bp(:,n-2) = sumg( a(:,n-2) , neg(b(:,n-2)) );
      ap(:,n-2) = sumg( -b(:,n-2) , neg(bp(:,n-2)) );
     otherwise
      c = sumg( a(:,i-1), -a(:,i), -pos(b(:,i)), neg(b(:,i-1)) );
      ap(:,i-1) = sumg( a(:,i-1), -pos(b(:,i-1)), -pos(sumg(pos(b(:,i)), c) ) );
      bp(:,i-1) = sumg( b(:,i), neg(c) );
      ap(:,i) = sumg( a(:,i), -neg(b(:,i)), -neg( sumg(neg(b(:,i-1)), -c)) );
      bp(:,i) = sumg( b(:,i-1), -neg(c) );
    end
  elseif ii(j) < 0
    switch(i)
     case 1
      bp(:,1) = sumg(-a(:,1), pos(b(:,1)) );
      ap(:,1) = sumg(b(:,1), -pos(bp(:,1)) );
     case n-1
      bp(:,n-2) = sumg(-a(:,n-2), neg(b(:,n-2)) );
      ap(:,n-2) = sumg(b(:,n-2), - neg(bp(:,n-2)) );
     otherwise
      d = sumg(a(:,i-1), -a(:,i), pos(b(:,i)), -neg(b(:,i-1)));
      ap(:,i-1) = sumg(a(:,i-1), pos(b(:,i-1)), pos(sumg(pos(b(:,i)),- d)) );
      bp(:,i-1) = sumg(b(:,i), -pos(d));
      ap(:,i) = sumg(a(:,i), neg(b(:,i)), neg(sumg(neg(b(:,i-1)), d)) );
      bp(:,i) = sumg(b(:,i-1), pos(d) );
    end
  end
  a = ap; b = bp;
end
up = [ap bp];

end
