function out = sumg( varargin )
%SUMG   Guarded integer sum.
%   Test that sum operation does not enter overflow.
%   In matlab, there is no "overflow", but there is "cropping"
%
%   e.g.
%
%   maxint + 1 = maxint
%   (maxint + 2) - 3 = maxint - 3
%   maxint + (2 - 3) = maxint - 1

if length(varargin) == 1 % single argument returns input value
  out = varargin{1};
elseif length(varargin) > 2
  % More than two arguments recurse binomially;
  % consider sorting to improve results,
  % e.g., ( 1 - 1 ) + maxint    will not overflow
  %       ( 1 + maxing) - 1     will overflow
  out = sumg( varargin{1:floor(end/2)}, sumg(varargin{floor(end/2)+1:end}) );
else % two arguments are added
  a1 = varargin{1}; a2 = varargin{2};
  out = a1 + a2; % regular input

  % We will perform the check only on integers
  if isinteger(out) % Note that VPI type fails this check, which is ok.
    % For integers, we have an upper and a lower boundary.
    if ~( out > intmin(class(out)) && out < intmax(class(out)) )
      error('BRAIDLAB:braid:sumg:overflow',...
	    'Summation of %d and %d has overflowed.', a1, a2)
    end
  end    
end
