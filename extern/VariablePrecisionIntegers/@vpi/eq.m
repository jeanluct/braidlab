function B = eq(INT1,INT2)
% vpi/eq: test for equality between a pair of vpi objects
% usage: B = (INT1 == INT2)
% usage: B = eq(INT1,INT2)
% 
% arguments: (input)
%  INT1,INT2 - vpi objects or scalar integer numeric values
%
% arguments: (output)
%  B  - logical variable, true when the two inputs
%            represent the same value.
% 
% Example:
%  INT1 = vpi(456);
%  INT1 == 1
%  ans =
%     0
%
%  INT1 == INT1
%  ans =
%     1
%
%
%  See also: ge, gt, lt, le
%  
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 1/19/09


if nargin~=2
  error('== is a dyadic operator, exactly 2 arguments are required')
end

numel1 = numel(INT1);
numel2 = numel(INT2);

if (numel1 == 1) && (numel2 == 1)

  % ensure that both are vpi objects
  INT1 = vpi(INT1);
  INT2 = vpi(INT2);
  
  % check the sign bits first
  B = (INT1.sign==INT2.sign) && isequal(INT1.digits,INT2.digits);
elseif (numel1 == 1) && (numel2 > 1)
  % INT1 was a scalar but not INT2.
  % Scalar expansion on INT1
  B = true(size(INT2));
  for i = 1:numel2
    B(i) = (INT1 == INT2(i));
  end
elseif (numel1 > 1) && (numel2 == 1)
  % INT1 was a scalar but not INT2.
  % Scalar expansion on INT1
  B = true(size(INT1));
  for i = 1:numel1
    B(i) = (INT1(i) == INT2);
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
    B(i) = (INT1(i) == INT2(i));
  end
end





