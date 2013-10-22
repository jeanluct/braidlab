function Q = mrdivide(numerator,denominator)
% vpi/mrdivide: Integer division for two vpi objects
% usage: Q = numerator/denominator
% usage: Q = mrdivide(numerator,denominator)
% 
%
% arguments: (input)
%  numerator,denominator - vpi scalars, or any
%      scalar numeric integers
%
%
% arguments: (output)
%  Q - a vpi that represents the integer part of the
%      quotient of numerator/denominator
%
%
% Example:
%  m = vpi('112233445566778899001');
%  m/12345
%  ans =
%     9091409118410603
%
%
%  See also: quotient, rem, mod, rdivide, times, mtimes
%  
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 1/19/09

if (nargin~=2)
  error('mrdivide must have both a numerator and a denominator')
end

nn = numel(numerator);
nd = numel(denominator);

if (nn == 1) && (nd == 1)
  % just use quotient for all the heavy lifting
  Q = quotient(numerator,denominator);
elseif (nn > 1) && (nd == 1)
  % denominator is a scalar. Do scalar expansion here.
  Q = vpi(numerator);
  for i = 1:nn
    Q(i) = quotient(numerator(i),denominator);
  end
else
  % no other modes are supported
  error('Sorry, matrix divide is not supported for this shape input arguments')
end


