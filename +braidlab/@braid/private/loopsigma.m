function up = loopsigma(ii,u)
%LOOPSIGMA   Act on a loop with a braid group generator sigma.
%   UP = LOOPSIGMA(II,U) acts on the loop U (encoded in Dynnikov coordinates)
%   with the braid generator sigma_II, and returns the new loop UP.  II can be
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
      bp(:,1) = sumG( a(:,1) , pos(b(:,1)) );
      ap(:,1) = sumG( -b(:,1) , pos(bp(:,1)) );
     case n-1
      bp(:,n-2) = sumG( a(:,n-2) , neg(b(:,n-2)) );
      ap(:,n-2) = sumG( -b(:,n-2) , neg(bp(:,n-2)) );
     otherwise
      c = sumG( a(:,i-1), -a(:,i), -pos(b(:,i)), neg(b(:,i-1)) );
      ap(:,i-1) = sumG( a(:,i-1), -pos(b(:,i-1)), -pos(sumG(pos(b(:,i)),  c) ) );
      bp(:,i-1) = sumG( b(:,i), neg(c) );
      ap(:,i) = sumG( a(:,i), -neg(b(:,i)), -neg( sumG(neg(b(:,i-1)), -c)) );
      bp(:,i) = sumG( b(:,i-1), -neg(c) );
    end
  elseif ii(j) < 0
    switch(i)
     case 1
      bp(:,1) = sumG(-a(:,1), pos(b(:,1)) );
      ap(:,1) = sumG(b(:,1), -pos(bp(:,1)) );
     case n-1
      bp(:,n-2) = sumG(-a(:,n-2), neg(b(:,n-2)) );
      ap(:,n-2) = sumG(b(:,n-2), - neg(bp(:,n-2)) );
     otherwise
      d = sumG(a(:,i-1), -a(:,i), pos(b(:,i)), -neg(b(:,i-1)));
      ap(:,i-1) = sumG(a(:,i-1), pos(b(:,i-1)), pos(sumG(pos(b(:,i)),- d)) );
      bp(:,i-1) = sumG(b(:,i), -pos(d));
      ap(:,i) = sumG(a(:,i), neg(b(:,i)), neg(sumG(neg(b(:,i-1)), d)) );
      bp(:,i) = sumG(b(:,i-1), pos(d) );
    end
  end
  a = ap; b = bp;
end
up = [ap bp];

end

function out = sumG( varargin )
% SUMG(...)
%
% Guarded integer sum. Test that operation does not enter overflow.
%
% In matlab, there is no "overflow", but there is "cropping"
% E.g.
%
% maxint + 1 = maxint
% (maxint + 2) - 3 = maxint - 3
% maxint + (2 - 3) = maxint - 1

if length(varargin ) == 1 % single argument returns input value
    out = varargin{1};
elseif length(varargin) > 2 % more than two arguments recurse binomially
    % consider sorting to improve results,
    % e.g., ( 1 - 1 ) + maxint    will not overflow
    %       ( 1 + maxing) - 1     will overflow
    out = sumG( varargin{1:floor(end/2)}, sumG(varargin{floor(end/2)+1:end}) );
    
else % two arguments are added
    
    a1 = varargin{1}; a2 = varargin{2};
    
    out = a1 + a2; % regular input
    
    % we will perform the check only on integers
    if isinteger(out)
        % for integers, we have an upper and a lower boundary
        if ~( out > intmin(class(out)) && out < intmax(class(out)) )
            error('BRAIDLAB:braid:loopsigma:sumG','Summation of %d and %d has overflowed.', a1, a2)
        end
    end    
end
end
