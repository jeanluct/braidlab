function b = mpower(a,k)
% vpi/power: raises a vpi object to a positive integer (numeric) power
% usage: b = a^k;
% usage: b = mpower(a,k);
% 
% arguments: (input)
%  a - a vpi scalar integer
%
%  k - positive integer scalar,
%      k may be no larger than 2^53 - 1
%
% arguments: (output)
%  b - a vpi scalar integer, representing the
%      power operation, INT1^k
%
% Example:
%  A = vpi(magic(3));
% double(A^3)
% ans =
%        1197        1029        1149
%        1077        1125        1173
%        1101        1221        1053
%
%  See also: power
%  
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 2.0
%  Release date: 3/3/09

na = numel(a);
nk = numel(k);

if (na == 0) || (nk == 0)
  % propagate empty
  b = [];
elseif (na == 1) && (nk == 1)
  % scalar ops, use power
  b = a.^k;
elseif (na > 1) && (nk == 1) && (k > 0) && ...
    (length(size(a)) == 2) && (k <= (2^53 - 1))
  % we can raise a square matrix to a positive
  % integer power
  if (diff(size(a)) ~= 0)
    error('Not supported: raising a non-square matrix to an integer power')
  end
  
  if isnumeric(k)
    kbin = dec2bin(k) - 48;
  else
    kbin = vpi2bin(k) - 48;
  end
  kbin = fliplr(kbin);
  
  % what size square matrix is a?
  n = size(a,1);
  if kbin(1)
    b = a;
  else
    b = vpi(eye(n));
  end
  a2 = a;
  for i = 2:length(kbin)
    % repeatedly square a
    a2 = a2*a2;
    
    % do we multiply this term in?
    if kbin(i)
      b = b*a2;
    end
  end  
else
  % not supported
  error('Not supported: raising a scalar or matrix to a non-scalar power')
end


