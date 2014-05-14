function Aprod = prod(A,dim)
% vpi/prod: prod of a vpi array
% usage: Aprod = prod(A,dim);
% 
% Arguments:
%  A - a vpi object array
%
%  dim - (optional) dimension of A to sum over
%      DEFAULT: dim is the first non-singleton
%      dimension of A.
%
% Arguments: (output)
%  Aprod - the product vpi object array
% 
% Example:
%  A = vpi(-3:2:25);
%  prod(A)
%
% ans =
%     23717560741875
%
%  See also: length, numel, size, repmat, sum
% 
%  Author: John D'Errico
%  e-mail: woodchips@rochester.rr.com
%  Release: 1.0
%  Release date: 2/26/09

if (nargin<1) || (nargin>2)
  error('prod takes one or two arguments')
end

if numel(A) == 1
  % the product of a scalar is a no-op
  Aprod = A;
else
  % a vector or array
  
  % default for dim?
  if (nargin==1) || isempty(dim)
    dim = find(size(A)>1,1,'first');
    if isempty(dim)
      dim = 1;
    end
  end
  
  % product over the dimension dim. Do so by
  % a permutation, then a product and an
  % inverse permute.
  P = 1:length(size(A));
  P([1,dim]) = [dim,1];
  
  A = permute(A,P);
  Aprod = A;
  NAprod = size(A);
  N1 = NAprod(1);
  NAprod(1) = 1;
  Aprod = repmat(vpi(1),NAprod);
  for j = 1:prod(NAprod(2:end))
    for i = 1:N1
      k = i + (j-1)*N1;
      Aprod(j) = Aprod(j).*A(k);
    end
  end
  
  % do the inverse permutation
  Aprod = ipermute(Aprod,P);
  
end







