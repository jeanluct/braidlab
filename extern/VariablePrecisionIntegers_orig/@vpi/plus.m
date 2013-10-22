function INT = plus(INT1,INT2)
% vpi/plus: Adds two vpi objects, or adds a numeric var to an vpi
% usage: INT = INT1 + INT2;
%
% arguments: (input)
%  INT1,INT2 - vpi scalars or any valid numeric integers
%       INT1 and INT2 may be positive, negative, or zero.
%
% arguments: (output)
%  INT - a vpi number representing the sum:
%       INT = INT1 + INT2
%
% Example:
%  m = vpi('11111111');
%  m+900
%  ans =
%     11112011
%
%  m = vpi('5454545123456789123')
%  m+m
%  ans =
%     10909090246913578246
%
%
%  See also: minus, uplus
%
%
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 1/19/09

if nargin~=2
  error('Plus is a dyadic operator, exactly 2 arguments')
end

numel1 = numel(INT1);
numel2 = numel(INT2);

if (numel1 == 1) && (numel2 == 1)
  % a pair of scalars

  % make sure both INT1 and INT2 are vpi objects
  if ~isa(INT1,'vpi')
    % Is INT1 a real number, or a floating point integer?
    if rem(INT1,1) ~= 0
      % INT1 is a true float
      warning('VPI:PLUS:fix','Addition of a vpi with a non-integer variable, fixed to an integer')
      INT1 = vpi(fix(INT1));
    else
      INT1 = vpi(INT1);
    end
  end
  if ~isa(INT2,'vpi')
    % Is INT2 a real number, or a floating point integer?
    if rem(INT2,1) ~= 0
      % INT2 is a true float
      warning('VPI:PLUS:fix','Addition of a vpi with a non-integer variable, fixed to an integer')
      INT2 = vpi(fix(INT2));
    else
      INT2 = vpi(INT2);
    end
  end
  
  % both are vpi numbers. Make them the same
  % number of digits.
  n1 = length(INT1.digits);
  n2 = length(INT2.digits);
  if n1>n2
    % append zeros to INT2
    INT2.digits(n1) = 0;
  elseif n2>n1
    % append zeros to INT1
    INT1.digits(n2) = 0;
  end
  
  % do the addition
  INT = INT1;
  INT.digits = INT1.sign*INT1.digits + INT2.sign*INT2.digits;

  % if the most significant digit was negative, then flip the signs
  % on all of the digits.
  mostsigdigit = find(INT.digits,1,'last');
  if isempty(mostsigdigit)
    % the result was zero
    finalsign = 1;
  elseif INT.digits(mostsigdigit) > 0
    % the result was apparently positive
    finalsign = 1;
  else
    % a negative result
    finalsign = -1;
    INT.digits = -INT.digits;
  end
  INT.sign = finalsign;
  
  % Are any carries necessary?
  K = find((INT.digits<0) | (INT.digits>9));
  % Were there any digits that need a carry?
  % The following while loop will be most efficient
  % for the most common case, where relatively
  % few digits require a carry, but it will also
  % be almost as efficient as a for loop for the
  % pathological case of 1 + 99999...99999, where
  % each carry generates a new carry.
  while ~isempty(K)
    % there was at least one carry to be done
    olddigits = INT.digits(K);
    
    % mod will insure the new digit
    % lies in [0,9].
    newdigits = mod(INT.digits(K),10);
    
    % stuff into place
    INT.digits(K) = newdigits;
    
    % this will be an integer result:
    carry = (olddigits - newdigits)/10;
    
    % will it force us to add another digit
    % to INT?
    if K(end) == numel(INT.digits)
      % do so
      INT.digits(end+1) = 0;
    end
    
    % add in the carried digits. There may
    % be a few new carries created by this
    % operation. The while loop will catch
    % them.
    INT.digits(K+1) = INT.digits(K+1) + carry;
    
    % update the list of digits that possibly
    % are in need of a carry
    K = K + 1;
    % if K is now empty here, we are done.
    K = K((INT.digits(K)<0) | (INT.digits(K)>9));
    
  end

  % were there trailing (high end) zero digits? if so,
  % then trim them off of the result.
  lastdigitindex = find(INT.digits,1,'last');
  if isempty(lastdigitindex)
    INT.digits = 0;
    INT.sign = 1;
  elseif lastdigitindex < length(INT.digits)
    INT.digits = INT.digits(1:lastdigitindex);
  end
elseif (numel1 == 1) && (numel2 > 1)
  % INT1 was a scalar but not INT2.
  % Scalar expansion on INT1
  INT = vpi(INT2);
  for i = 1:numel2
    INT(i) = INT1 + INT2(i);
  end
elseif (numel1 > 1) && (numel2 == 1)
  % INT1 was a scalar but not INT2.
  % Scalar expansion on INT1
  INT = vpi(INT1);
  for i = 1:numel1
    INT(i) = INT1(i) + INT2;
  end
elseif isempty(INT1) || isempty(INT2)
  % empty propagates
  INT = vpi([]);
  return
else
  % two non-scalar, non-empty arrays. Are they
  % compatible in size for addition?
  S1 = size(INT1);
  S2 = size(INT2);
  
  if ~isequal(S1,S2)
    error('INT1 and INT2 are not compatible in size for addition')
  end
  
  INT = vpi(INT1);
  for i = 1:numel2
    INT(i) = INT1(i) + INT2(i);
  end
end
