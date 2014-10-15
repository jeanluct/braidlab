function INT = minus(INT1,INT2)
% vpi/minus: Subtracts two vpi objects, or one vpi and a constant
% usage: INT = INT1 - INT2;
% 
% arguments:
%  INT,INT1,INT2 - vpi objects or scalars
%
%
%  See also: uminus, plus
%  
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 1/19/09


% negate the second term, then add
INT = INT1 + uminus(INT2);


