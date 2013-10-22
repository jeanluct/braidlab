function tf = isunit(INT)
% vpi/isunit: test to see if a vpi object is +1 or -1
% usage: tf = isunit(INT);
% 
% arguments:
%  INT - a vpi object
%
%  tf  - returns a boolean, true or false.
%        tf == true if INT was zero
%
%
% Example:
%  isunit(vpi(12))
%  ans = 
%     0
%
%  isunit(vpi(1))
%  ans = 
%     1
%
%
%  See also: iszero
%  
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 1/19/09

if nargin == 0
  error('No input argument supplied')
end

if numel(INT) == 1
  % scalar input
  % a simple test.
  tf = ((order(INT) == 0) && (INT.digits(1) == 1));
elseif isempty(INT)
  % propagate empty
  tf = [];
else
  % must be an array
  tf = true(size(INT));
  for i = 1:numel(INT)
    tf(i) = isunit(INT(i));
  end
end


