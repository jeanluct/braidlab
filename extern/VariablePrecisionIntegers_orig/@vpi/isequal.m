function tf = isequal(INT1,INT2)
% vpi/isequal: test to see if two vpi numbers are identical as a structure
% usage: tf = isequal(INT1,INT2);
% 
% arguments:
%  INT1,INT2 - vpi objects. One of them may be
%        a numerical variable
%
%  tf  - returns a boolean, true or false.
%        tf == true if INT was an even number
%
%
% Example:
%  isequal(vpi(12),vpi(13))
%  ans = 
%     0
%
%  isequal(vpi(1),2)
%  ans = 
%     0
%
%  isequal(vpi(17),17)
%  ans = 
%     1
%
%
%  See also: iszero, isunit
%  
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 1/22/09

% a simple test.
tf = isequal(struct(vpi(INT1)),struct(vpi(INT2)));



