function D = leadingdigit(INT,n)
% vpi/leadingdigit: Extract the highest order digits of a vpi object
% usage: D = leadingdigit(INT1)
% usage: D = leadingdigit(INT1,n)
% 
%
% arguments: (input)
%  INT - A vpi number
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
%        the leading digit(s) of INT
%
%
% Example:
%  INT = vpi(17)^17
%  ans =
%      827240261886336764177
%
%  leadingdigit(INT,2)
%  ans =
%      8     2
%
%
%  See also: trailingdigit, quotient, mod, rem
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
  
  % n can not be too large
  n = min(n,NINT);
  
  D = INT.digits(NINT + (0:-1:(-n+1)));
  
elseif isempty(INT)
  % empty propagates to empty
  D = [];
else
  % an array will result in a cell
  D = cell(size(INT));
  for i = 1:numel(INT)
    D{i} = leadingdigit(INT(i),n);
  end
end





