function INT = vpi(N)
% vpi: Creator function for a variable precision integer
% usage: M = vpi
% usage: M = vpi(N)    % N is a numeric variable
% usage: M = vpi(n)    % n is a character representation of an integer
%
%
% Arguments:
%  N - A numeric (integer) variable, to be converted into a
%      variable precision integer. When used in this mode,
%      N must be no larger than 2^53-1.
%
%      A very long integer can be entered as a character string.
%
%      If N is not supplied, then the result is a variable
%      precision zero.
%
%
% Examples of use:
%  INT = vpi  -->  creates a zero variable.
%
%  INT = vpi([]) --> creates an empty vpi variable
%
%  INT = vpi(1357902468)
%            -->  Converts the scalar integer 1357902468
%                 into a variable precision number.
%
%  INT = vpi('1234567890098765432100123456789')
%            -->
%
%
%  See also: double, single
%  
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 1/19/09


% How was vpi called? There are 2 options.

% create the number
if (nargin == 0)
  % this mode creates a zero variable, as a constant == 0
  N = 0;
elseif isa(N,'vpi')
  % It is already a vpi variable. A no-op.
  INT = N;
  return
elseif ~ischar(N) && ~isnumeric(N)
  error('N must be a integer numeric variable or a character string of digits')
elseif nargin>1
  error('vpi cannot have more than one input argument')
end

% We have a value. Is it a scalar integer? Or is it a
% character string of decimal digits?
if isempty(N)
  % create an empty vpi number
  INT.sign = 1;
  INT.digits = 0;
  INT(1) = [];
  
elseif ischar(N)
  % it was a character string. convert
  % it to large integer form.
  
  % strip out any leading blanks or trailing blanks
  bind = find(N ~= ' ');
  N = N(min(bind):max(bind));
  
  % just return vpi(0).
  if isempty(N)
    N = '0';
  end
  
  % was there a minus sign in front?
  if N(1) == '-';
    INT.sign = -1;
    N(1) = [];
  else
    INT.sign = 1;
  end
  % or a decimal point at the very end?
  if N(end) == '.'
    N(end) = [];
  end
  
  switch lower(N)
    case 'inf'
      INT.digits = inf;
      N = '';
    case 'nan'
      INT.digits = nan;
      N = '';
    otherwise
      INT.digits = [];
  end
  
  % are there any other characters here than a valid digit?
  if ~all(ismember(N,'0123456789'))
    error('If character supplied, then must be a valid decimal integer')
  end
  
  % convert the digits to numeric digits
  % flip them, since I store the digits
  % in reversed order, with the units digit
  % first.
  INT.digits = double(fliplr(N))-48;
  
  % strip off any leading zeros in the number
  k = find(INT.digits,1,'last');
  if isempty(k)
    k = 1;
  end
  if k < length(INT.digits)
    INT.digits = INT.digits(1:k);
  end
  
  % check for a mismatch of sign when the result is zero
  if isequal(INT.digits,0)
    INT.sign = 1;
  end
  
elseif (isnumeric(N) || isa(N,'logical')) && (numel(N)>1)
  % A numeric vector or array
  
  % initialize
  INT.sign = 1;
  INT.digits = 0;
  
  % replicate
  INT = repmat(INT,size(N));
  
  % and stuff the coefficients
  for i = 1:numel(N)
    INT(i) = vpi(N(i));
  end
  
elseif N == 0
  % special case for zero
  INT.sign = 1;
  INT.digits = 0;
  
else
  % A numeric scalar
  
  if ~isfinite(N)
    if isnan(N)
      INT.sign = 1;
      INT.digits = nan;
    else
      % must be /-inf
      INT.sign = sign(N);
      INT.digits = inf;
    end
    
  elseif isa(N,'double') && (abs(N)>=(2^53))
    error('If N is a double, it may be no larger than 2^53 - 1')
    
  else
    % set the sign bit
    INT.sign = 1;
    if N<0
      INT.sign = -1;
      N = abs(double(N));
    end
    
    % is N a true float or an integer float?
    if (rem(N,1) ~= 0)
      warning('VPI:float','Converted a real float to a vpi integer form')
      N = fix(N);
    end
    
    % recover the individual digits
    INT.digits = zeros(1,16);
    i = 1;
    while N~=0
      U = rem(N,10);
      INT.digits(i) = U;
      N = (N-U)/10;
      i = i + 1;
    end
    
    % do we need to trim of any trailing zeros?
    % actually, these are leading zeros due to the
    % reversed storage order of the digits.
    k = find(INT.digits,1,'last');
    if isempty(k)
      INT.digits = 0;
    elseif k < length(INT.digits)
      % trim
      INT.digits = INT.digits(1:k);
    end
    
  end
end

% set the class for this variable as a vpi
INT = class(INT,'vpi');
  
% make sure that the appropriate vpi method is
% used whenever one of the arguments is a vpi
% and any numeric type as the other argument.
superiorto('double','single','int8','uint8','int16', ...
  'uint16','int32','uint32','int64','uint64','logical')




