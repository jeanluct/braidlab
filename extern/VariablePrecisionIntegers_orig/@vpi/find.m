function [I,J,V] = find(X,K,direction)
% vpi/FIND: Find indices of nonzero elements.
%
%    I = FIND(X) returns the linear indices corresponding to 
%    the nonzero entries of the array X.  X may be a logical expression. 
%    Use IND2SUB(SIZE(X),I) to calculate multiple subscripts from 
%    the linear indices I.
%  
%    I = FIND(X,K) returns at most the first K indices corresponding to 
%    the nonzero entries of the array X.  K must be a positive integer, 
%    but can be of any numeric type.
% 
%    I = FIND(X,K,'first') is the same as I = FIND(X,K).
% 
%    I = FIND(X,K,'last') returns at most the last K indices corresponding 
%    to the nonzero entries of the array X.
% 
%    [I,J] = FIND(X,...) returns the row and column indices instead of
%    linear indices into X. If X is an N-dimensional array where N > 2,
%    then J is a linear index over the N-1 trailing dimensions of X.
% 
%    [I,J,V] = FIND(X,...) also returns a vector V containing the values
%    that correspond to the row and column indices I and J.
%
% Example:
%
% See also: ind2sub, non-zeros, relop
% 
%   Author: John D'Errico
%   e-mail: woodchips@rochester.rr.com
%   Release: 1.0
%   Release date: 3/3/09

if (nargin<3) || isempty(direction)
  direction = 'first';
elseif ~ischar(direction) || ~ismember(lower(direction),{'first','last'})
  error('Invalid search option. Must be ''first'' or ''last''')
end
direction = lower(direction);

if (nargin<2)
  K = inf;
end

if nargin < 1
  error('find must have at least one argument')
end
nx = numel(X);

if (numel(K) ~= 1) || (K < 1)
  error('K must be a positive scalar integer')
end

% propagate empty
if isempty(X)
  I = [];
  J = [];
  V = [];
  return
else
  % preallocate some space
  if isinf(K)
    I = zeros(nx,1);
  else
    I = zeros(K,1);
  end
end

% where do we start to look?
switch direction
  case 'first'
    inc = 1;
    ind = 1;
  case 'last'
    ind = numel(X);
    inc = -1;
end

% do the search
count = 0;
keepsearching = true;
while keepsearching
  % check the current element
  if X(ind) ~= 0
    count = count + 1;
    I(count) = ind;
  end
  
  % are we done, or keep up the search?
  if count < K
    ind = ind + inc;
    if (ind <= 0) || (ind > nx)
      keepsearching = false;
    end
  else
    % we have found as many elements as we need
    keepsearching = false;
  end
end

% drop the part of I that we preallocated
% too big
if count < length(I)
  I((count+1):end) = [];
end

% if we started at the end and worked
% backwards, the elements will be stored
% in the reverse order.
if strcmp(direction,'last')
  I = flipud(I);
end

% do we need to return the values too?
if nargout > 2
  V = X(I);
end

% do we need to return the indices as subscripts?
if nargout > 1
  % yes. Use this scheme instead of ind2sub
  % in case the array had 3 or more dimensions
  nrows = size(X,1);
  J = 1 + floor((I-1)/nrows);
  I = I - (J-1)*nrows;
end



  
  
  