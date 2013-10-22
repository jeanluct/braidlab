function B = isnan(INT)
% vpi/isnan: test for nan elements in a vpi
% usage: B = isnan(INT)
% 
% arguments: (input)
%  INT - vpi object or scalar integer numeric values
%
% arguments: (output)
%  B  - logical variable, true when an element is a NaN
% 
% Example:
%  INT = vpi([NaN 1]);
%  ans =
%     1  0
%
%  See also: isinf, isfinite
%  
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 2/16/2011


if nargin~=1
  error('VPI:ISNAN:monadicoperator','== is a monadic operator, exactly 1 argument is required')
end

% just apply isnan to the proper field
if isempty(INT)
  % empty propagates
  B = [];
elseif numel(INT) == 1
  % scalar
  B = isnan(INT.digits(1));
else
  B = reshape(cellfun(@(D) any(isnan(D)),{INT.digits}),size(INT));
end


