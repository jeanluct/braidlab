function INT = uminus(INT)
% vpi/uminus: Negates an vpi object
% usage: INT = -INT;
% 
% arguments:
%  INT - an vpi object
%
%
%  See also: minus, uplus
%  
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 1/19/09


% an array?
if numel(INT)==1
  % just change the sign bit
  INT.sign = - INT.sign;
else
  % multiple elements
  for i = 1:numel(INT)
    INT(i).sign = - INT(i).sign;
  end
end





