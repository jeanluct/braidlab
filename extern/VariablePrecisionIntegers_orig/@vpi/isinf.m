function B = isinf(INT)
% vpi/isinf: test for infinite elements in a vpi
% usage: B = isinf(INT)
% 
% arguments: (input)
%  INT - vpi object or scalar integer numeric values
%
% arguments: (output)
%  B  - logical variable, true when an element is +inf or -inf
% 
% Example:
%  INT = vpi([inf 1 -inf]);
%  ans =
%     1  0  1
%
%  See also: isnan, isfinite
%  
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 2/16/2011


if nargin~=1
  error('VPI:ISINF:monadicoperator','== is a monadic operator, exactly 1 argument is required')
end

% just apply isnan to the proper field
if isempty(INT)
  % empty propagates
  B = [];
elseif numel(INT) == 1
  % scalar
  B = isinf(INT.digits(1));
else
  B = reshape(cellfun(@(D) any(isinf(D)),{INT.digits}),size(INT));
end





