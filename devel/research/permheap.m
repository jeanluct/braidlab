function [varargout] = permheap(P,c)
%PERMHEAP   Heap's algorithm for generating permutations by interchanges.
%   [P,C] = PERMHEAP(P,C) returns a new permutation given a permutation P.
%   C is a bookeeping vector which should be first initialized to ones(1,N),
%   where N is the order of the permutation.  The function uses Heap's
%   algorithm, which interchanges entries of P at each call until all
%   permutations have been produced.
%
%   [P,C,NOTDONE] = PERMHEAP(P,C) sets NOTDONE to false after all
%   permutations have been cycled over.
%
%   [P,C] = PERMHEAP(N) initializes P to 1:N and C to ones(1,N).
%
%   A typical use of PERMHEAP is as follows, which lists all permutations
%   of N integers:
%
%   [P,C] = permheap(N); notdone = true;
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
%   that PERMHEAP would normally return them.
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
    %   (Use MEX file for this?  Probably not worth it for the rest of the
    %   file, since the function call overhead probably makes this
    %   impractical for truly large problems.)
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
      j = c(i);
    else
      j = 1;
    end
    % Swap content of P(i) and P(j).
    temp = P(j); P(j) = P(i); P(i) = temp;
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
