function INT = abs(INT)
% vpi/abs: absolute value of a vpi object
% usage: INT = abs(INT);
% 
% arguments:
%  INT - an vpi object
%
% Example:
%  abs(vpi(-5))
%  ans = 
%     5
%
%  See also: sign
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 1/19/09

% an array?
if numel(INT)==1
  % just set the sign bit
  INT.sign = 1;
else
  % multiple elements
  for i = 1:numel(INT)
    INT(i).sign = 1;
  end
end


