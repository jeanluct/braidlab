function R = modrank(A,p)
% modrank: compute the rank of an integer array, modulo p
% usage: R = modrank(A,p)
%
% Returns the rank of the matrix A under
% modulo arithmetic, mod p.
% 
% Because all operations are performed using
% integer arithmetic, the computed rank will
% be exact.
%
% Arguments: (input)
%  A - A must be a 2-d array of integer
%      elements, or any vpi array.
%
%  p - any scalar integer or vpi number
%      Required: p > 1
%
%      If p > sqrt(2^53-1), then computations
%      will be done in a vpi form, which will
%      be somewhat slower than otherwise.
% 
% Arguments: (output)
%  R - an integer that denotes the rank of A
%
%        0 <= R <= min(size(A))
%
% Example: 
%  A = magic(5)
% A =
%    17    24     1     8    15
%    23     5     7    14    16
%     4     6    13    20    22
%    10    12    19    21     3
%    11    18    25     2     9
%
% modrank(A,2)
% ans =
%      4
%
% modrank(A,5)
% ans =
%      2
%
% modrank(A,29)
% ans =
%      5
%
%  See also: rank, mod, rem
%  
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 3/3/09

if (nargin~=2)
  error('Exactly two arguments required for modrank')
end

if (numel(p) ~= 1) || (p <= 1)
  error('p must be scalar numeric or scalar vpi, p > 1')
end

% an empty matrix must have rank 0
if isempty(A) || isempty(p) || (p == 1)
  R = 0;
  return
end

% get the shape of A
sa = size(A);
if length(sa) > 2
  error('A may not be more than a 2 dimensional array')
end
nr = sa(1);
nc = sa(2);

if (~isnumeric(A) && ~isa(A,'vpi')) || (isnumeric(A) && all((A(:)~=round(A(:)))))
  error('A must be an integer numeric array or a vpi array')
end

% if A has more rows than columns, best to transpose.
% this will not change the rank.
if (nr > nc)
  A = A.';
  [nr,nc] = deal(nc,nr);
end

% p mst be limited to sqrt(2^53 - 1), or else we must
% convert to vpi arithmetic
if p > sqrt(2^53-1)
  A = vpi(A);
end

% take the mod first, just in case
A = mod(A,p);

% do the work here. this will just be gaussian
% elimination, with column and row pivoting in
% case of zero pivots
i = 1;
R = nr; % in case we drop through the while loop
flag = true;
while flag && (i<=nr)
  % choose a pivot element
  [ipiv,jpiv] = find(A(i:nr,i:nc),1,'first');
  if isempty(ipiv)
    % the rank has been revealed if no
    % non-zeros remain for pivoting
    R = i-1;
    break
  end
  if i > 1
    ipiv = ipiv + i-1;
    jpiv = jpiv + i-1;
  end

  % swap rows
  if ipiv ~= i
    A([ipiv,i],:) = A([i,ipiv],:);
  end
  % and columns
  if jpiv ~= i
    A(:,[jpiv,i],:) = A(:,[i,jpiv]);
  end
  
  % kill off the remaining elements in the i'th column
  % if i == nr, then we are done, since A(i,i) must be
  % non-zero since we just did a pivot op.
  if i < nr
    % the pivot element
    piv = A(i,i);
    
    % which elements of A below the pivot are non-zero?
    k = i + find(A((i+1):nr,i));
    if ~isempty(k)
      for m = 1:length(k)
        A(k(m),(i+1):nc) = mod(piv*A(k(m),(i+1):nc) - A(k(m),i)*A(i,(i+1):nc),p);
        A(k(m),i) = 0;
      end
    end
  end
  
  % increment i to keep working
  i = i + 1;
end


