function R = rem(a,b)
% vpi/rem: remainder upon integer division of vpi objects
% usage: R = rem(a,b);
% 
% Uses quotient for the computation, and is consistent
% with double/rem when the signs of the arguments vary.
%  
% By convention:
% REM(a,0) is undefined
% REM(a,a), for a~=0, is 0.
% REM(a,b), for a~=b and b~=0, has the same sign as a.
% 
%
% arguments: (input)
%  numerator,denominator - vpi scalars, or any scalar numeric integers
%
% arguments: (output)
%  R - a vpi object such that a = n*b + R, for
%      integer n such that n = fix(a/b).
%
%      R has the property that it will be smaller 
%      in absolute magnitude than b. R will have the
%      same sign as does a.
%
% Example:
%  
%
%  See also: quotient, mod, rdivide
%  
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 1/19/09


% test for b == 0
if any(b(:) == 0)
  error('b cannot be zero. Remainder is undefined.')
end

% All the work is done by quotient.
% Toss Q in the bit bucket.
[R,R] = quotient(a,b);





