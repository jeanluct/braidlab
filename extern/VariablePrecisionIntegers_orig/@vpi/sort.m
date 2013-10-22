function [Ns,tags] = sort(N,dim,sdir)
% SORT: Sorts a vpi array in ascending or descending order.
%
%   For vectors, SORT(X) sorts the elements of X in ascending order.
%   For matrices, SORT(X) sorts each column of X in ascending order.
%   For N-D arrays, SORT(X) sorts the along the first non-singleton
%   dimension of X.
%
%   Ns = SORT(N,DIM,SDIR)
%
%   SORT has two optional parameters:
%   DIM selects a dimension along which to sort.
%   SDIR selects the direction of the sort
%      'ascend' results in ascending order
%      'descend' results in descending order
%
%   The result is in Ns which has the same shape and type as X.
%
%   [Ns,tags] = SORT(X,DIM,MODE) also returns an index matrix tags.
%
%   If Ns is a vector, then Ns = N(tags).  
%   When N is an array, the elements in the specified dimension will
%   be sorted, and tags will indicate the sort order as with a vector.
%
%   When more than one element has the same value, the order of the
%   elements are preserved in the sorted result and the indexes of
%   equal elements will be ascending in any index matrix.
%
%   The sorting methodology used is a merge sort:
%   http://en.wikipedia.org/wiki/Merge_sort
%
% Example:
%  See the help for the built-in sort
%
%  See also:
%
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 3/5/09


if (nargin < 1) || (nargin > 3)
  error('Sort expects 1, 2, or 3 arguments')
end

% propagate empty
if isempty(N)
  Ns = [];
  tags = [];
  return
end

% check for sort direction, or default
if (nargin<3) || isempty(sdir)
  sdir = 'ascend';
end
if ~ischar(sdir)
  error('Sort order must be either ''ascend'' or ''descend'' if supplied')
end
sdir = lower(sdir);
if ~ismember(sdir,{'ascend','descend'})
  error('Sort order must be either ''ascend'' or ''descend'' if supplied')
end

% default dimension to sort on
if (nargin<2) || isempty(dim)
  dim = find(size(N) > 1,1,'first');
  if isempty(dim)
    dim = 1;
  end
end
if ~isnumeric(dim) || (dim <= 0) || (dim > length(size(N))) || (dim~=round(dim))
  error('Dimension must be numeric, integer, positive, <= length(size(N))')
end

% sort over the dimension dim. Do so by
% a permutation, then a vector sort in
% a loop and an inverse permute.
P = 1:length(size(N));
P([1,dim]) = [dim,1];

N = permute(N,P);
sizeN = size(N);
s1 = sizeN(1);
Ns = reshape(N,s1,[]);
tags = zeros(size(Ns));
for j = 1:size(Ns,2)
  if strcmp(sdir,'ascend')
    [Ns(:,j),tags(:,j)] = sortvecA(Ns(:,j));
  else
    [Ns(:,j),tags(:,j)] = sortvecD(Ns(:,j));
  end
end

% do the inverse permutation
Ns = ipermute(reshape(Ns,sizeN),P);
tags = ipermute(reshape(tags,sizeN),P);

% ====================
% end mainline
% ====================

function [Vs,tags] = sortvecA(V)
% sorts a single vector in ascending order
% The sorting scheme chosen is a basic merge sort.
n = length(V);
% special case on the length. otherwise, recurse
if n == 1
  % 1 is simple
  Vs = V;
  tags = 1;
elseif n == 2
  if V(1) <= V(2)
    Vs = V;
    tags = [1 2];
  else
    Vs = V([2 1]);
    tags = [2 1];
  end
else
  % at least 3
  n1 = floor(n/2);
  [Vs1,tags1] = sortvecA(V(1:n1));
  [Vs2,tags2] = sortvecA(V((n1+1):n));
  % shift the tags for the upper half
  tags2 = tags2 + n1;
  n2 = n - n1;
  
  % merge the two sorted subarrays
  i1 = 1;
  i2 = 1;
  k = 1;
  tags = zeros(n,1);
  while (i1<=n1) & (i2<=n2)
    if Vs1(i1) <= Vs2(i2)
      tags(k) = tags1(i1);
      i1 = i1 + 1;
      if (i1 > n1) && (k < n)
        tags((k+1):n) = tags2(i2:end);
        i2 = n2 + 1;
      end
    else
      tags(k) = tags2(i2);
      i2 = i2 + 1;
      if (i2 > n2) && (k < n)
        tags((k+1):n) = tags1(i1:end);
        i1 = n1 + 1;
      end
    end
    k = k + 1;
  end
  
  Vs = V(tags);
end

% ====================

function [Vs,tags] = sortvecD(V)
% sorts a single vector in descending order
% The sorting scheme chosen is a basic merge sort.
n = length(V);
% special case on the length. otherwise, recurse
if n == 1
  % 1 is simple
  Vs = V;
  tags = 1;
elseif n == 2
  if V(1) >= V(2)
    Vs = V;
    tags = [1 2];
  else
    Vs = V([2 1]);
    tags = [2 1];
  end
else
  % at least 3
  n1 = floor(n/2);
  [Vs1,tags1] = sortvecD(V(1:n1));
  [Vs2,tags2] = sortvecD(V((n1+1):n));
  % shift the tags for the upper half
  tags2 = tags2 + n1;
  n2 = n - n1;
  
  % merge the two sorted subarrays
  i1 = 1;
  i2 = 1;
  k = 1;
  tags = zeros(n,1);
  while (i1<=n1) & (i2<=n2)
    if Vs1(i1) >= Vs2(i2)
      tags(k) = tags1(i1);
      i1 = i1 + 1;
      if (i1 > n1) && (k < n)
        tags((k+1):n) = tags2(i2:end);
        i2 = n2 + 1;
      end
    else
      tags(k) = tags2(i2);
      i2 = i2 + 1;
      if (i2 > n2) && (k < n)
        tags((k+1):n) = tags1(i1:end);
        i1 = n1 + 1;
      end
    end
    k = k + 1;
  end
  
  Vs = V(tags);
end




