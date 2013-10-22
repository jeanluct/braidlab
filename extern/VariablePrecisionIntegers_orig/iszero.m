function tf = iszero(INT)
% vpi/iszero: test to see if a numeric object is zero
% usage: tf = iszero(INT);
% 
% arguments:
%  INT - a general numeric object
%
%  tf  - returns a boolean, true or false.
%        tf == true if INT was zero
%
%
% Example:
%  iszero(-3:3)
%  ans = 
%     0 0 0 1 0 0 0
%
%  See also: isunit
%  
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 1/19/09

% this code is trivial, since we can efficiently
% use the numerical test for zero. This numeric
% version of iszero is only provided so that
% iszero(0) will return a valid result just as
% does iszero(vpi(0)).
tf = INT == 0;

