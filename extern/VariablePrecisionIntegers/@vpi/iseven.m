function tf = iseven(INT)
% vpi/iseven: test to see if a vpi object represents an even number
% usage: tf = iseven(INT);
% 
% arguments:
%  INT - a vpi object
%
%  tf  - returns a boolean, true or false.
%        tf == true if INT was an even number
%
%
% Example:
%  iseven(vpi(12))
%  ans = 
%     1
%
%  iseven(vpi(1))
%  ans = 
%     0
%
%
%  See also: iszero, isunit
%  
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 1/22/09

% an array?
if numel(INT)==1
  % a simple test.
  tf = rem(INT.digits(1),2) == 0;
else
  % multiple elements
  tf = true(size(INT));
  for i = 1:numel(INT)
    tf(i) = iseven(INT(i));
  end
end


