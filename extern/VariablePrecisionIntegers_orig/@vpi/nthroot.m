function [Root,excess] = nthroot(K,n)
% vpi/nthroot: Integer part of the n'th root of the vpi number K
% usage: Root = nthroot(K,n)
%
%
% arguments: (input)
%  K - a vpi scalar (positive) integer
%      K must be non-negative for even roots,
%      or an error will result.
%
%  n - scalar, positive integer
%      n <= 2^53 - 1
% 
%
% arguments: (output)
%  Root - The largest magnitude non-negative vpi
%      integer such that abs(Root^n) <= abs(K)
%
%  excess - a non-negative vpi number that gives
%      the amount by which Root^2 misses the mark.
%      Thus, we have
%
%      excess = (N - Root^n)
%
%
% Example:
%  K = vpi(2)^10000;
%  [R,excess] = nthroot(K,81);
% R =
%    14594761271001143604743871845333000639
%
% See that R^2 <= K <= (R+1)^2
%
%  R^81 <= K
%  ans =
%       1
%
%  K <= (R+1)^81
%  ans =
%       1
%
%  K - (R^81 + excess)
%  ans =
%      0
%
%
% Example:
%  K = vpi(2)^600 - 1;
%  R = nthroot(K,3)
% R =
%   1606938044258990275541962092341162602522202993782792835301375
%
% This difference should be exactly 1.
%  vpi(2)^200 - R
%  ans =
%      1
%
%  See also: sqrt, modroot, power, log, exp
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 2/13/09

if nargin ~= 2
  error('nthroot must have two arguments')
end

if (numel(K) == 1) && (numel(n) == 1)
  % n and K are both scalars
  
  % make sure that n is a double
  n = double(n);
  
  % n?
  if (n < 1)
    error('n must be a positive integer')
  end
  
  % even roots will not work on negative numbers
  if (K < 0)
    if ((isnumeric(n) && (mod(n,2) == 0)) && (isa(n,'vpi') && iseven(n)))
      error('Cannot take the nthroot of negative arguments for even n')
    end
    K = abs(K);
    Ksign = -1;
  else
    Ksign = 1;
  end
  
  % is K small enough to do it exactly?
  if K <= (2^53 - 1)
    % small
    Root = vpi(fix(nthroot(double(K),n)));
  elseif isnumeric(K)
    Root = fix(nthroot(K,n));
  else
    % just too big
    
    % get a good, fast approximation to the nthroot
    Rlog = log10(K)/n;
    Root = vpi(1);
    Root.digits = [zeros(1,floor(Rlog)),1];
    Root = Root*fix(10^(mod(Rlog,1)+14))/1e14;
    
    % Try an iterative improvement step(s).
    flag = true;
    nstall = 0;
    if Root <= 500
      % for very small Roots (and therefore
      % very high fractional exponents since
      % we ended up in this branch) the
      % iterative scheme is poor. But in this
      % case, the initial estimate will be
      % superb anyway.
      while (K < (Root^n))
        Root = Root - 1;
      end
      while ((Root+1)^n <= K)
        root = root + 1;
      end
      
      flag = false;
    end
    while flag
      % Simple iteration using
      % K = (x0 + delta)^n + error
      % K = x0^n + n*x0^(n-1)*delta + n*(n-1)/2*x0^(n-2)*delta^2 + ... + delta^n + error
      % K/x0^(n-1) + (n-1)*x0 = n*x0 + n*delta + n*(n-1)/2*delta^2/x0 + ... + delta0/x0^(n-1) + error/x0^(n-1)
      % x0 + delta = (K/x0^(n-1) + (n-1)*x0)/n - (n-1)/2*delta^2/x0 + ...
      %
      % The first part of this expansion
      % reduces to the standard averaging
      % scheme used for sqrt when n = 2.
      newRoot1 = ((n-1)*Root + K/(Root^(n-1)))/n;
      delta = Root - newRoot1;
      if abs(3*delta) > Root
        % a potential problem here
        if (K > (Root^n)) && ((Root+1)^n > K)
          break
        end
      end
      
      Root = newRoot1;
      if delta == 0
        % the last two iterates were the same.
        % quit now.
        break
      elseif abs(delta) < 3
        % the scheme may be stalled,
        nstall = nstall + 1;
        if nstall > 1
          % it looks like we may have stalled,
          % but we must be close, so do this
          % the hard way.
          while (K < (Root^n))
            Root = Root - 1;
          end
          while ((Root+1)^n <= K)
            root = root + 1;
          end
          break
        end
      end % if delta == 0
    end % while flag
  end
  
  % was K negative?
  if Ksign < 0
    Root = -Root;
  end
  
  % did we need to compute the remainder?
  if nargout > 1
    excess = Ksign.*K - Root.^n;
  end
  
elseif isempty(K) || isempty(n)
  % propagate the empty
  Root = [];
  excess = [];
elseif (numel(K) > 1) && (numel(n) == 1)
  % n was a scalar, but not K. scalar expansion
  Root = vpi(K);
  for i = 1:numel(K)
    Root(i) = nthroot(K(i),n);
  end
  
  % only bother t do this if there is a reason
  if nargout > 1
    excess = K - Root.^n;
  end
  
elseif (numel(K) == 1) && (numel(n) > 1)
  % K was a scalar, but not n. scalar expansion
  Root = repmat(vpi(K),size(n));
  for i = 1:numel(n)
    Root(i) = nthroot(K,n(i));
  end
  
  % only bother t do this if there is a reason
  if nargout > 1
    excess = K - Root.^n;
  end

elseif (numel(K) > 1) && (numel(n) > 1)
  % both K and n are arrays.
  % check to see if they conform.
  sk = size(K);
  sn = size(n);
  if ~isequal(sk,sn)
    error('K and n do not conform in size')
  end
  
  Root = vpi(K);
  for i = 1:numel(K)
    Root(i) = nthroot(K(i),n(i));
  end
  
  % only bother t do this if there is a reason
  if nargout > 1
    excess = K - Root.^n;
  end
end

  

  


