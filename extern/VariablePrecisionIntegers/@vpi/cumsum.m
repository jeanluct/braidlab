function Asum = cumsum(A,dim)
% vpi/cumsum: cumulative sum of a vpi array
% usage: Asum = cumsum(A,dim)
% 
% Arguments:
%  A - a vpi object array
%
%  dim - (optional) dimension of A to sum over
%      DEFAULT: dim is the first non-singleton
%      dimension of A.
%
% Arguments: (output)
%  Asum - the cumulative sum vpi object array
% 
% Example:
%  A = vpi(-3:2:25);
%  double(cumsum(A))
%
%  ans =
%    -3  -4  -3  0  5  12  21  32  45  60  77  96 117 140 165
%
%  See also: prod, sum, cumprod
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 3/3/09

if (nargin<1) || (nargin>2)
  error('cumsum takes one or two arguments')
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
  NAsum = size(A);
  N1 = NAsum(1);
  Asum = reshape(A,N1,[]);
  for j = 1:size(Asum,2)
    for i = 2:N1
      k = i + (j-1)*N1;
      Asum(i,j) = Asum(i-1,j) + Asum(i,j);
    end
  end
  
  % do the inverse permutation
  Asum = ipermute(reshape(Asum,NAsum),P);
  
end










