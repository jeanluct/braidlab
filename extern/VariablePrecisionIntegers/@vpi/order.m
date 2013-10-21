function ord = order(INT)
% vpi/order: power of 10 associated with the highest order digit of a vpi object
% usage: ord = order(INT);
% 
% This result will always be one less than the number of
% decimal digits in the VPI number.
%
% arguments: (input)
%  INT - a vpi object
%
% arguments: (input)
%  ord - scalar numeric integer
%       the power of 10 associated with the highest
%       order decimal digit of INT. If INT is zero, then
%       ord will be zero.
%
% Example:
%  order(vpi(1234567))
%  ans = 
%     6
%
%  See also: sign
%  
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 1/19/09

if numel(INT) == 1
  % Use find here rather than just taking the
  % length of the digits field, in case of any
  % high order zeros. find with the 'last'
  % option will be fast anyway, especially
  % since we only need to find one element.
  ord = find(INT.digits,1,'last');
  if isempty(ord)
    % the number was zero.
    ord = 0;
  else
    % one less than the index
    ord = ord - 1;
  end
elseif isempty(INT)
  % empty propagates
  ord = [];
else
  % this is an array. Just loop.
  ord = zeros(size(INT));
  for i = 1:numel(INT)
    ord(i) = order(INT(i));
  end
end



