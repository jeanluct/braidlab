function [varargout] = permheap(P,c)
%PERMHEAP   Heap's algorithm for generating permutations by interchanges.
%   [P,C] = PERMHEAP(P,C) returns a new permutation given a permutation P.
%   C is initialized to ones(1,N), where N is the order of the permutation.
%   The function uses Heap's algorithm, which interchanges entries of P each
%   time until all permutations have been produced.  C is a bookeeping
%   vector.
%
%   [P,C,NOTDONE] = PERMHEAP(P,C) sets NOTDONE to false after all
%   permutations have been cycled over.
%
%   [P,C] = PERMHEAP(N) initializes P to 1:N and C to ones(1,N).
%
%   A typical use of PERMHEAP is as follows, which lists all permutations
%   of N integers:
%
%   P = 1:N; C = ones(1,N); notdone = true;
%   while notdone
%     disp(P)
%     [P,C,notdone] = permheap(P,C);
%   end
%
%   PERMHEAP does not pre-generate the permutations, so memory is not
%   wasted in storing a large number (N!) of permutations.
%
%   If memory is not an issue, PP = PERMHEAP(N) returns an array PP of
%   dimension N! by N giving all the permutations at once, in the same order
%   that PERMHEAP would normally list them.
%
%   Reference: R. Segdewick, "Permutation Generation Methods," Computing
%   Surveys 9 (1977), 137-164.

if nargin < 2
  if nargout == 2
    % Just initialize P and C.
    varargout{1} = 1:P;
    varargout{2} = ones(1,P);
    return
  else
    % Return the entire list at once.
    n = P;
    N = factorial(n);
    [p,c] = permheap(n);
    varargout{1} = zeros(N,n);
    for i = 1:N
      varargout{1}(i,:) = p;
      [p,c] = permheap(p,c);
    end
    return
  end
end

for i = 1:length(P)
  if c(i) < i
    if mod(i,2) == 0
      i2 = c(i);
    else
      i2 = 1;
    end
    temp = P(i2);
    P(i2) = P(i);
    P(i) = temp;
    c(i) = c(i) + 1;
    varargout{1} = P;
    if nargout > 1, varargout{2} = c; end
    if nargout > 2, varargout{3} = true; end
    return
  else
    c(i) = 1;
  end
end

varargout{1} = P;
if nargout > 1, varargout{2} = c; end
if nargout > 2, varargout{3} = false; end

% ====================================================
