function B = isfinite(INT)
% vpi/isfinite: test for inf or nan elements in a vpi
% usage: B = isfinite(INT)
% 
% arguments: (input)
%  INT - vpi object or scalar integer numeric values
%
% arguments: (output)
%  B  - logical variable, true when an element is +inf or -inf
% 
% Example:
%  INT = vpi([inf 1 -inf NaN]);
%  ans =
%     0  1  0  0
%
%  See also: isnan, isinf
%  
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 2/16/2011


if nargin~=1
  error('VPI:ISFINITE:monadicoperator','== is a monadic operator, exactly 1 argument is required')
end

% just apply isnan to the proper field
if isempty(INT)
  % empty propagates
  B = [];
elseif numel(INT) == 1
  % scalar
  B = isfinite(INT.digits(1));
else
  B = reshape(cellfun(@(D) any(isfinite(D)),{INT.digits}),size(INT));
end









