function B = le(INT1,INT2)
% vpi/le: test for inequality (<=) between a pair of vpi objects
% usage: B = (INT1 <= INT2)
% usage: B = le(INT1,INT2)
% 
% arguments: (input)
%  INT1,INT2 - vpi objects or scalar integer numeric values
%
% arguments: (output)
%  result  - logical variable, true when INT1 <= INT2
% 
% Example:
%  INT1 = vpi(456);
%  INT1 <= INT1
%  ans =
%     1
%
%  INT1 < 400
%  ans =
%     0
%
%  INT1 < 500
%  ans =
%     1
%
%
%  See also: gt, lt, ge
%  
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 1/19/09

if (nargin ~= 2)
  error('a test for inequality must be between a pair of values')
end

numel1 = numel(INT1);
numel2 = numel(INT2);

if (numel1 == 1) && (numel2 == 1)

  % ensure that both are vpi objects
  INT1 = vpi(INT1);
  INT2 = vpi(INT2);
  
  % check the sign bits first
  if sign(INT1) < sign(INT2)
    B = true;
  elseif sign(INT1) > sign(INT2)
    B = false;
  elseif sign(INT1) >= 0
    % both numbers had the same signs
    % and both were non-negative. Compare
    % the relative magnitudes
    B = comparemagnitudes(-INT2,-INT1);
  else
    % both numbers had the same signs
    % and both were negative. Compare the
    % relative magnitudes
    B = comparemagnitudes(INT1,INT2);
  end
  
elseif (numel1 == 1) && (numel2 > 1)
  % INT1 was a scalar but not INT2.
  % Scalar expansion on INT1
  B = true(size(INT2));
  for i = 1:numel2
    B(i) = (INT1 <= INT2(i));
  end
elseif (numel1 > 1) && (numel2 == 1)
  % INT1 was a scalar but not INT2.
  % Scalar expansion on INT1
  B = true(size(INT1));
  for i = 1:numel1
    B(i) = (INT1(i) <= INT2);
  end
elseif isempty(INT1) || isempty(INT2)
  % empty propagates
  B = vpi([]);
  return
else
  % two non-scalar, non-empty arrays. Are they
  % compatible in size for cp,arison?
  S1 = size(INT1);
  S2 = size(INT2);
  
  if ~isequal(S1,S2)
    error('INT1 and INT2 are not compatible in size for relational comparison')
  end
  
  B = true(size(INT2));
  for i = 1:numel2
    B(i) = (INT1(i) <= INT2(i));
  end
end




