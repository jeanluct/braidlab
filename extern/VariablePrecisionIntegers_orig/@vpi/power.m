function INT = power(INT1,k)
% vpi/power: raises a vpi object to a positive integer (numeric) power
% usage: INT = INT1.^k;
% usage: INT = power(INT1,k);
%
% arguments: (input)
%  INT1 - a vpi scalar integer or integer numeric
%        variable
%
%  k   - positive integer scalar, k must be no
%        larger than 2^53
%
% arguments: (output)
%  INT  - a vpi scalar integer, representing the
%        power operation, INT1^k
%
% Example:
%
%
%  See also: mpower
%
%
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 2.0
%  Release date: 3/3/09

% is k a vpi object? Any power of any number other
% than 0 or +/- 1
if isa(k,'vpi')
  k = double(k);
end

% is k too large to work with?
if any(k(:) > (2^53-1))
  error('the exponent must not be larger than 2^53')
end

% INT1? Make sure it is a vpi number.
INT1 = vpi(INT1);

% There are several possibilities to worry about
if (numel(INT1) == 1) && (numel(k) == 1)
  % a pair of scalars to work with

  % special cases, is INT1 0, 1 or -1?
  if INT1 == 0
    % 0^k == 0, except 0^0 = NaN
    if k ~= 0
      INT = vpi(0);
    else
      INT = NaN;
    end
    return
  elseif INT1 == 1
    % 1^k == 1
    INT = vpi(1);
    return
  elseif INT1 == -1
    % (-1)^k
    if rem(k,2) == 0
      INT = vpi(1);
    else
      INT = vpi(-1);
    end
    return
  end

  % other special cases, is INT1 a pure power of 10?
  ispow10 = (INT1.sign > 0) && (sum(INT1.digits) == 1);
  if ispow10
    % exactly one digit can be non-zero,
    % and it must be 1. Which digit was it?
    L = find(INT1.digits)-1;

    % initialize INT as a unit vpi
    INT = vpi(1);

    % the final power of 10 is just
    L = L*k;

    % so stuff the proper digits into INT
    INT.digits = [zeros(1,L),1];

    return
  end

  % other special cases - was k zero or one?
  if k == 0
    % anything to the zero power is 1, except for 0^0
    % which is undefined. Since I don't do nans here,
    % bounce out.
    INT = vpi(INT1);
    if all(INT.digits==0)
      error('0^0 is undefined == NaN for doubles, but a vpi can''t be a NaN')
    end

    INT = vpi(1);
    return
  elseif k == 1
    % anything to the 1 power is itself.
    INT = vpi(INT1);
    return

  elseif k == 2
    % simple powers are easy to do as a multiply
    INT = vpi(INT1);
    INT = INT*INT;
    return

  elseif k == 3
    % simple powers are easy to do as a multiply
    INT = vpi(INT1);
    INT = INT*INT*INT;
    return

  elseif k == 4
    % simple powers are easy to do as a multiply
    INT = vpi(INT1);
    INT = INT*INT;
    INT = INT*INT;
    return

  elseif k == 8
    % simple powers are easy to do as a multiply
    INT = vpi(INT1);
    INT = INT*INT;
    INT = INT*INT;
    INT = INT*INT;
    return

  end

  % convert k to binary
  kbin = fliplr(dec2bin(k) == '1');

  % make sure that INT is a vpi
  if kbin(1)
    INT = vpi(INT1);
  else
    INT = vpi(1);
  end

  % if we get to this point, then k was at least 2
  % we use the binary expansion of k to form the
  % desired power as efficiently as possible,
  % repeatedly squaring INT1 on each pass.
  for i = 2:length(kbin)
    if i > 2
      INT2 = INT2*INT2;
    else
      INT2 = INT1*INT1;
    end

    % do we need to multiply this power
    % of INT1 into the result?
    if kbin(i)
      INT = INT*INT2;
    end
  end
  
elseif isempty(INT1) || isempty(k)
  % empty propagates to empty
  INT = [];
  return
elseif (numel(INT1) == 1) && (numel(k) > 1)
  % A scalar raised to an array power as
  % an elementwise operation. Do scalar
  % expansion for INT1.
  INT = repmat(vpi(0),size(k));
  for i = 1:numel(k)
    INT(i) = INT1.^k(i);
  end
elseif (numel(INT1) > 1) && (numel(k) == 1)
  % A vpi array raised to a scalar power as
  % an elementwise operation. Do scalar
  % expansion for k.
  INT = INT1;
  for i = 1:numel(INT1)
    INT(i) = INT1(i).^k;
  end
elseif (numel(INT1) > 1) && (numel(k) > 1)
  % A vpi array raised to an array power as
  % an elementwise operation.

  % first verify the arrays conform in size
  S1 = size(INT1);
  Sk = size(k);
  if ~isequal(S1,Sk)
    error('INT1 and k do not conform in size for elementwise power op')
  end

  INT = INT1;
  for i = 1:numel(k)
    INT(i) = INT1(i).^k(i);
  end

end





