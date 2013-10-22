function D = trailingdigit(INT,n)
% vpi/trailingdigit: Extract the lowest order digits of a vpi object
% usage: D = trailingdigit(INT1)
% usage: D = trailingdigit(INT1,n)
% 
%
% arguments: (input)
%  INT - A scalar vpi number
% 
%  n   - (OPTIONAL) scalar, integer, positive, numeric
%        Denotes the number of leading digits
%        to be stripped off of INT. There is no
%        maximum value for n, except the number
%        of digits in INT.
%
%        DEFAULT: n = 1
%
%
% arguments: (output)
%  D   - A double precision vector, contains
%        the trailing (lowest order) digit(s) of INT
%
%
% Example:
%  INT = vpi(17)^17
%  ans =
%      827240261886336764177
%
%  leadingdigit(INT,3)
%  ans =
%      1     7     7
%
%
%  See also: leadingdigit, quotient, mod, rem
%  
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 1/23/09

% default for n
if (nargin<2) || isempty(n)
  n = 1;
end

% ensure that INT is a vpi
INT = vpi(INT);

% a scalar?
if numel(INT) == 1
  NINT = order(INT)+1;
  
  % n cannot be too large
  n = min(n,NINT);
  
  D = fliplr(INT.digits(1:n));
elseif isempty(INT)
  % empty propagates to empty
  D = [];
else
  % an array will result in a cell
  D = cell(size(INT));
  for i = 1:numel(INT)
    D{i} = trailingdigit(INT(i),n);
  end
end




