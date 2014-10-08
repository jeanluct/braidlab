function Aprod = cumprod(A,dim)
% vpi/cumprod: cumulative product of a vpi array
% usage: Aprod = cumprod(A,dim);
% 
% Arguments:
%  A - a vpi object array
%
%  dim - (optional) dimension of A to prod over
%      DEFAULT: dim is the first non-singleton
%      dimension of A.
%
% Arguments: (output)
%  Aprod - the product vpi object array
% 
% Example:
%  A = vpi(-3:2:12);
%  double(cumprod(A))
%
% ans =
%    -3  3  3  9  45  315  2835  31185
%
%  See also: cumsum, prod, sum
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
  % a permutation, then a prod and an
  % inverse permute.
  P = 1:length(size(A));
  P([1,dim]) = [dim,1];
  
  A = permute(A,P);
  NAprod = size(A);
  N1 = NAprod(1);
  Aprod = reshape(A,N1,[]);
  for j = 1:size(Aprod,2)
    for i = 2:N1
      k = i + (j-1)*N1;
      Aprod(i,j) = Aprod(i-1,j).*Aprod(i,j);
    end
  end
  
  % do the inverse permutation
  Aprod = ipermute(reshape(Aprod,NAprod),P);
  
end








