function Asum = sum(A,dim)
% vpi/Asum: sum of a vpi array
% usage: Asum = sum(A,dim);
% 
% Arguments:
%  A - a vpi object array
%
%  dim - (optional) dimension of A to sum over
%      DEFAULT: dim is the first non-singleton
%      dimension of A.
%
% Arguments: (output)
%  Asum - the sum vpi object array
% 
% Example:
%  A = vpi(-3:2:25);
%  sum(A)
%
%  ans =
%      165
%
%  See also: prod, cumsum
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 2/26/09

if (nargin<1) || (nargin>2)
  error('sum takes one or two arguments')
end

if numel(A) == 1
  % the sum of a scalar is a no-op
  Asum = A;
else
  % a vector or array
  
  % default for dim?
  if (nargin==1) || isempty(dim)
    dim = find(size(A)>1,1,'first');
    if isempty(dim)
      dim = 1;
    end
  end
  
  % sum over the dimension dim. Do so by
  % a permutation, then a sum and an
  % inverse permute.
  P = 1:length(size(A));
  P([1,dim]) = [dim,1];
  
  A = permute(A,P);
  Asum = A;
  NAsum = size(A);
  N1 = NAsum(1);
  NAsum(1) = 1;
  Asum = repmat(vpi(0),NAsum);
  for j = 1:prod(NAsum(2:end))
    for i = 1:N1
      k = i + (j-1)*N1;
      Asum(j) = Asum(j) + A(k);
    end
  end
  
  % do the inverse permutation
  Asum = ipermute(Asum,P);
  
end










