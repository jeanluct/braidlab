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

if exist('loopsigma_helper') == 3
  % If MEX file is available, use that.
  up = loopsigma_helper(ii,u);
  return
end

n = size(u,2)/2 + 2;
a = u(:,1:n-2); b = u(:,(n-1):end);
ap = a; bp = b;
pos = @(x)max(x,0); neg = @(x)min(x,0);
for j = 1:length(ii)
  i = abs(ii(j));
  if ii(j) > 0
    switch(i)
     case 1
      bp(:,1) = a(:,1) + pos(b(:,1));
      ap(:,1) = -b(:,1) + pos(bp(:,1));
     case n-1
      bp(:,n-2) = a(:,n-2) + neg(b(:,n-2));
      ap(:,n-2) = -b(:,n-2) + neg(bp(:,n-2));
     otherwise
      c = a(:,i-1) - a(:,i) - pos(b(:,i)) + neg(b(:,i-1));
      ap(:,i-1) = a(:,i-1) - pos(b(:,i-1)) - pos(pos(b(:,i)) + c);
      bp(:,i-1) = b(:,i) + neg(c);
      ap(:,i) = a(:,i) - neg(b(:,i)) - neg(neg(b(:,i-1)) - c);
      bp(:,i) = b(:,i-1) - neg(c);
    end
  elseif ii(j) < 0
    switch(i)
     case 1
      bp(:,1) = -a(:,1) + pos(b(:,1));
      ap(:,1) = b(:,1) - pos(bp(:,1));
     case n-1
      bp(:,n-2) = -a(:,n-2) + neg(b(:,n-2));
      ap(:,n-2) = b(:,n-2) - neg(bp(:,n-2));
     otherwise
      d = a(:,i-1) - a(:,i) + pos(b(:,i)) - neg(b(:,i-1));
      ap(:,i-1) = a(:,i-1) + pos(b(:,i-1)) + pos(pos(b(:,i)) - d);
      bp(:,i-1) = b(:,i) - pos(d);
      ap(:,i) = a(:,i) + neg(b(:,i)) + neg(neg(b(:,i-1)) + d);
      bp(:,i) = b(:,i-1) + pos(d);
    end
  end
  a = ap; b = bp;
end
up = [ap bp];
