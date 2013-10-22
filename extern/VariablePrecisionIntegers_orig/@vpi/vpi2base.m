function B = vpi2base(INT,base)
% vpi/vpi2base: Converts a vpi number to an arbitrary base (highest order "digit" first)
% usage: B = vpi2base(INT,base)
% 
% arguments: (input)
%  INT - a vpi scalar. Sign will be ignored.
%
%  base - numeric positive Integer, defines the
%      number base to be converted to.
%
%      It is required that 2 <= base <= 2^53-1
%
% 
% arguments: (output)
%  B - Numeric vector with the "digits" of the
%      converted number.
%      
%
% Example:
%  int = vpi(17)^5 + 17 + 1
%  ans =
%      1419875
%
%  vpi2base(int,17)
%  ans =
%       1     0     0     0     1     1
%
% Example:
%  int = vpi(17)^17
%  ans =
%      827240261886336764177
%  
%  B = vpi2base(int,1000)
%  B =
%      827   240   261   886   336   764   177
%
%
%  See also: bin2vpi, dec2bin, bin2dec
%  
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 1/23/09

% error check
if nargin~=2
  error('vpi2base requires two arguments always')
end
if isempty(base) || ~isnumeric(base) || (length(base)>1) || ...
    (base < 2) || (base~=round(base)) || (base >= 2^53)
  error('base must be supplied, as a scalar numeric integer, 2 <= base <= 2^53')
end

if isempty(INT)
  % propagate empty
  B = [];
elseif numel(INT) > 1
  % an array
  B = zeros(numel(INT),1);
  for i = 1:numel(INT)
    Bi = vpi2base(INT(i),base);
    nb = length(Bi);
    nB = size(B,2);
    if nb > nB
      B = [zeros(numel(INT),nb - nB),B];
    elseif nb < nB
      Bi = [zeros(1,nB - nb),Bi];
    end
    B(i,:) = Bi;
  end
  return
end

% ensure that INT is a vpi
INT = vpi(INT);

% make the sign positive.
INT.sign = 1;

% how big is the number? how many digits?
N = order(INT)+1;

% special case for 0
if iszero(INT)
  % zero is zero, in any base.
  B = 0;
  return
end

% N = ceil(log10(INT))
% so, if we want to know the value
% of log2(INT), we can get an upper
% bound on the number of "digits"
% we will expect from this:
Nbase = ceil(N*log(10)/log(base));

% Preallocate B
B = repmat(0,1,Nbase);

% was base one of these powers of 10?
bind = find(base == [10 100 1000 10000 100000 1000000]);
if ~isempty(bind)
  % The base was a reasonable power
  % of 10, an easy problem to solve,
  % since vpi uses a base 10 storage
  % format.
  cdigits = char(INT.digits+48);
  
  ind = 1:bind;
  ind(ind>N) = [];
  i = 1;
  while ~isempty(ind)
    % grab bind digits
    B(i) = base2dec(fliplr(cdigits(ind)),10);
    
    i = i + 1;
    ind = ind + bind;
    ind(ind>N) = [];
  end
  
  % flip the order of the digits
  B = fliplr(B);
  
  % truncate any spurious leading digits
  ind = find(B,1,'first');
  B(1:(ind-1)) = [];

  return
end

% if we drop to here, we need to do
% it the hard way

L = 1;
while ~iszero(INT)
  % quotient will both divide INT by twom
  % as well as give us the remainder term
  % to yield m binary bits at the bottom end.
  [INT,R] = quotient(INT,base);
  
  % and stuff those bits into B
  B(L) = double(R);
  
  % increment L as we move up in bit order
  L = L + 1;
end
B = fliplr(B);

% toss any leading zero "digits" from B
k = find(B~=0,1,'first');
if ~isempty(k) && (k > 1)
  B(1:(k-1)) = [];
end

% =================================
%  end mainline
% =================================



