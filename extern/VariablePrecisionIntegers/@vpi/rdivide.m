function Q = rdivide(numerator,denominator)
% vpi/rdivide: Integer division for two vpi objects
% usage: Q = numerator./denominator
% usage: Q = rdivide(numerator,denominator)
% 
%
% arguments: (input)
%  numerator,denominator - vpi scalars, or any
%      scalar numeric integers
%
%
% arguments: (output)
%  Q - a vpi that represents the integer part of the
%      quotient of numerator./denominator
%
%
% Example:
%  m = vpi('112233445566778899001');
%  m./12345
%  ans =
%     
%
%  See also: quotient, rem, mod, mrdivide, times, mtimes
%  
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 1/19/09

if (nargin~=2)
  error('rdivide must have both a numerator and a denominator')
end

nn = numel(numerator);
nd = numel(denominator);

% which case is it?
if (nn == 1) && (nd == 1)
  % scalars
  
  % just use quotient for all the heavy lifting
  Q = quotient(numerator,denominator);
elseif (nn == 0) || (nd == 0)
  % propagate empty
  Q = [];
elseif (nn == 1)  
  % scalar expansion of the numerator
  Q = vpi(nd);
  for i = 1:nd
    Q(i) = quotient(numerator,denominator(i));
  end
elseif (nd == 1)
  % scalar expansion of the denominator
  Q = vpi(nn);
  for i = 1:nn
    Q(i) = quotient(numerator(i),denominator);
  end
else
  % both are arrays. do they conform?
  sn = size(numerator);
  sd = size(denominator);
  if ~isequal(sn,sd)
    error('numerator and denominator do not conform in shape or size for this operation')
  end
  Q = vpi(nn);
  for i = 1:nn
    Q(i) = quotient(numerator(i),denominator(i));
  end
end







