function F = subfactorial(N)
% subfactorial: The subfactorial of an integer (or integers) N, known as !N
% usage: F = subfactorial(N)
%
% One of the uses of the subfactorial function is
% for the number of derangements of a set of size N,
% i.e., the number of permutations that leave no
% element fixed in place.
%
% http://en.wikipedia.org/wiki/Subfactorial
% http://www.research.att.com/~njas/sequences/index.html?q=derangements&language=english&go=Search
%
% F = factorial(N)*sum(-1^k/factorial(k)),
%
% where the sum above goes from 0 to N.
% subfactorial is vectorized, in the sense
% that the computation is done efficiently
% for vector arguments N.
%
% Arguments:
%  N - any non-negative integer scalar or vector.
%      (Don't forget that the subfactorial
%      function gets huge amaingly fast,
%      almost as quickly as does the factorial 
%      function.) So while there is no upper
%      limit imposed on the size of N, there is
%      a practical limit.
%
%  F - a vpi array of the same size and shape
%      as N, such that F(i) = subfactorial(N(i))
%
% Example:
%  N = [0 1 2 3 4 5 10 15 30]';
%  [N,subfactorial(N)]
% ans =
%     0                                  1
%     1                                  0
%     2                                  1
%     3                                  2
%     4                                  9
%     5                                 44
%    10                            1334961
%    15                       481066515734
%    30   97581073836835777732377428235481
%
% See also: factorial, factorial, nchoosek
%
% Author: John D'Errico
% e-mail: woodchips@rochester.rr.com
% Release: 1.0
% Release date: 6/30/09

% if it was vpi, just convert to a double.
if isa(N,'vpi')
  N = double(N);
end

% pre-allocate F
Nsize = size(N);
N = N(:);
F = repmat(vpi(0),Nsize);

% verify that N is non-negative, integer
if any(N < 0) || any(N ~= round(N))
  error('VPI:SUBFACTORIAL:invalidargument','N must be non-negative, integer')
end

% sort the input, so we can do the vectorized
% computation using a recurrence.
[N,Ntags,Ntags] = unique(N);

k = (N == 0);
if any(k)
  F(k) = 1;
end
k = (N == 1);
if any(k)
  F(k) = 0;
end

% if 
L = find(N > 1,1,'first');
if ~isempty(L)
  anm2 = vpi(1);
  anm1 = anm2;
  
  for n = 2:N(end)
    an = n*anm1 + (n-1)*anm2;
    
    if n == N(L)
      F(n == N) = (n-1)*anm2;
      
      if L < numel(N)
        L = L + 1;
      end
    end
    
    anm2 = anm1;
    anm1 = an;
  end
  
end

% recover the original order of N
F = reshape(F(Ntags),Nsize);
