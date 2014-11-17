function INT = factorial(N)
% computes the factorial of any large integer as a vpi
% usage: INT = factorial(N);
%
% Note that if N is a double, the built-in function
% factorial(N) will only be an exact integer for
% N <= 18. When N is a vpi number, there is essentially
% no limit on N, although for very large N, the number
% factorial(500) has over 1100 digits.
%
% arguments: (input)
%  N - any scalar, non-negative numeric integer.
%
%      Remember that the factorial N will
%      require a loop, so even for N on the order
%      of 1000, factorial(N) is a pretty big number.
%      For this reason, N is limited to 2^25. Even
%      so, I'd advise that that number is WAY too big
%      to compute here, as factorial(2^25) will have
%      hundreds of millions of digits.
%
%      For numbers larger than a few thousand or tens
%      of thousands, I'd strongly suggest working in
%      logs, where the gammaln function will be most
%      handy. Remember that gamma(n+1) = factorial(n).
%
% arguments: (output)
%  INT - a vpi number that represents the digits
%      of factorial(N) to full precision.
%
% Example:
%  factorial(vpi(100))
%  ans = 
%    9332621544394415268169923885626670049071596826438162146859296389521759
%    9993229915608941463976156518286253697920827223758251185210916864000000
%    000000000000000000

% error checks for N
N = double(N);
if any(N(:) < 0) || any(N(:) > (2^25))
  error('N must be non-negative integer, < 2^25')
end

% initialize INT as 1
INT = repmat(vpi(1),size(N));
two53 = 2^53;
Fact = vpi(1);

% unique will sort the elements of double(N)
% as well as tell us where they came from.
[Nuniq,I,J] = unique(N);
k = max(1,0:Nuniq(1));
nk = length(k);
for j = 1:length(Nuniq)
  Fprod = 1;
  for i = 1:nk
    Fprod = Fprod*k(i);
    if (i == nk) || ((Fprod*k(i+1))>=two53)
      Fact = Fact*Fprod;
      Fprod = 1;
    end
  end
  
  % stuff the value of Fact into the appropriate
  % elements of INT.
  INT(J == j) = Fact;
  
  % look to the next factorial on the
  % list to compute.
  if j < length(Nuniq)
    k = (Nuniq(j)+1):Nuniq(j+1);
    nk = length(k);
  end
end



