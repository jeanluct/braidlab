function display(INT)
% vpi/display: Display a vpi object, calls disp
%
%
%  See also: disp
%  
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 1/19/09

name = inputname(1);
if ~isempty(name)
  display([name,' ='])
else
  display('ans =')
end
disp(INT)




