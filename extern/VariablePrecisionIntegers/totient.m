function phi = totient(N)
% vpi/totient: the number of positive integers less than N that are coprime to N
% usage: phi = totient(N)
%
% Euler's totient function, as defined by
%
% http://en.wikipedia.org/wiki/Euler's_totient_function
%
% phi is the number of positive integers that are
% both less than N and coprime (relatively prime)
% to N.
%
% http://en.wikipedia.org/wiki/Coprime
%
% Totient requires the factors of N, so if N is
% very large, this might take a while.
%
%
% Example:
%  When N is a prime, N will be coprime
%  to all of the N-1 positive numbers less
%  than N.
%
%  totient(17)
% ans =
%     16
%
% Example:
%  totient(36)
% ans =
%     12
%
%  Show this to be correct, since the numbers
%  less than 36 that are coprime to 36 are
%  easily generated.
%
%  cp = [];
%  for i = 1:35
%    if gcd(i,36) == 1
%      cp = [cp,i];
%    end
%  end
%
%  cp
% cp =
%    1  5  7 11 13 17 19 23 25 29 31 35
%
% Of course, there are 12 such numbers in
% the list.
%
%  length(cp)
% ans =
%     12
%
% Example:
%  P = vpi('16867914157');
%  totient(P)
% ans =
%     16744790560
%
%
%  See also: factor, gcd
%
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 2/14/09

if (nargin~=1) || (isnumeric(N) && any(N(:)~=round(N(:))))
  error('Totient requires exactly one integer argument.')
end

% in case of an array or vector
nn = numel(N);
phi = N;
for i = 1:nn
  Ni = N(i);
  
  % 
  if Ni <= 1
    phi(i) = 0;
    continue
  end
  
  % get the factors of Ni
  F = factor(Ni);
  
  % if there was only one factor, but Ni is predicted
  % to be composite
  if (length(F) == 1) && ~isprime(Ni)
    error('factor failed to find the factors of a composite number Ni')
  end
  
  % only one factor?
  if length(F) == 1
    % only one factor. N was prime
    phi(i) = F - 1;
  else
    % at least two factors in the list
    if isnumeric(F)
      % all of the factors were small numbers
      % count the multiplicities.
      [uF,I,J] = unique(F);
      countF = accumarray(J(:),1);
    else
      % vpi numbers, so unique will not be happy.
      % do it the brute force way. The list of
      % factors cannot be too long. (must write
      % unique for vpi one day.)
      nf = length(F);
      uF = repmat(vpi(0),nf,1);
      countF = zeros(nf,1);
      
      % k is the number of distinct factors found
      k = 0;
      while ~isempty(F)
        % grab the k'th distinct factor
        k = k + 1;
        % it is just the first element in F
        uF(k) = F(1);
        h = (uF(k) == F);
        % and count how many times it appeared
        countF(k) = sum(h);
        % drop all the replicates of that factor
        F(h) = [];
      end
      
      % clean up the pre-allocants
      countF = countF(1:k);
      uF = uF(1:k);
    end % if isnumeric(F)
    
    % build the totient function from the
    % distinct factors and their multiplicities.
    % I can probably do this in a vectorized form
    % but the cost is trivial without doing so.
    phi(i) = 1;
    for j = 1:length(uF)
      fac = uF(j);
      
      if countF(j) == 1
        phi(i) = phi(i)*(fac - 1);
      else
        phi(i) = phi(i)*(fac - 1)*fac^(countF(j)-1);
      end
    end
  end % if length(F) == 1
end % for i = 1:nn

% ==============
% end mainline
% ==============
