function tf = iszero(INT)
% vpi/iszero: test to see if a vpi object is zero
% usage: tf = iszero(INT);
% 
% arguments:
%  INT - a vpi object
%
%  tf  - returns a boolean, true or false.
%        tf == true if INT was zero
%
%
% Example:
%  iszero(vpi(12))
%  ans = 
%     0
%
%  iszero(vpi(0))
%  ans = 
%     1
%
%
%  See also: isunit
%  
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 1/19/09

if numel(INT) == 1
  % scalar input
  % a simple test.
  tf = ~any(INT.digits);
elseif isempty(INT)
  % empty propagates
  tf = [];
else
  % an array of vpi numbers
  tf = true(size(INT));
  for i = 1:numel(INT)
    tf(i) = ~any(INT(i).digits);
  end
end


