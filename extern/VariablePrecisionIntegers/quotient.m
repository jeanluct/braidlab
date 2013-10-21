function [Q,R] = quotient(numerator,denominator)
% quotient: divides two integers, computing a quotient and remainder
% usage: [Q,R] = quotient(numerator,denominator);
% 
% quotient is used by the rdivide and rem functions.
% When numerator and/or demonimator represent negative
% numbers, then the quotient and remainders will be
% consistent with the signs that / and rem would return.
%
% Specifically, when numerator and denominator have
% signs as given below, then Q and R will behave as
% given by this table:
%
%  num, den, Q,   R
%  >0   >0   >0   >0
%  >0   <0   <0   >0
%  <0   >0   <0   <0
%  <0   <0   >0   <0
%  
% Quotient supports vector or array inputs, although
% the vpi version does not do so at this time.
%
% arguments: (input)
%  numerator,denominator - integer scalar numeric variables
%
% arguments: (output)
%  Q,R - integers such that numerator = Q*denominator + R
%        R has the property that it will be smaller
%        in magnitude than numerator.
%
% Example:
%
%
%  See also: vpi/quotient, rem, mod, rdivide
%  
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 2/25/09

if nargin ~= 2
  error('Both a numerator and denominator must be supplied')
end

maxint = 2^53 - 1;
% can we represent numerator as a double?
if any(abs(numerator(:))>maxint) || any(abs(denominator(:))>maxint)
  error('Numbers too large, exact computation impossible. Convert to vpi form first')
end

% is the denominator zero?
if denominator == 0
  error('Divide by zero')
end

% use matlab's divide operator.
Q = fix(numerator./denominator);
R = numerator - Q.*denominator;



