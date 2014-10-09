function C = conv(A,B)
% CONV Convolution and polynomial multiplication.
%    C = CONV(A, B) convolves vectors A and B.  The resulting
%    vector is length LENGTH(A)+LENGTH(B)-1.
%    If A and B are vectors of polynomial coefficients, convolving
%    them is equivalent to multiplying the two polynomials.
% 
%    Class support for inputs A,B: 
%       float: vpi, double, single, or any other integer form.
% 
%    See also deconv, conv2, convn, filter
%
% Author: John D'Errico
% e-mail: woodchips@rochester.rr.com
% Release: 1.0
% Release date: 6/14/09

na = numel(A);
nb = numel(B);

if (na == 0) || (nb == 0)
  % propagate empty
  C = [];
elseif ~isvector(A) || ~isvector(B)
  error('VPI:CONV:nonvectors','One of A or B was not a vector or scalar')
elseif (na == 1) || (nb == 1)
  % just a scalar multiplication here
  C = A*B;
else
  % both A and B MUST be vectors. preallocate the
  % result as a vector. The orientation of the
  % vector will depend on the shape of B.
  C = repmat(vpi(0),size(B));
  % extend C to be the correct length.
  C(na + nb - 1) = 0;
  
  % just do the convolution as a loop.
  ind = 0:(nb-1);
  for i = 1:na
    j = i + ind;
    C(j) = C(j) + A(i)*B;
  end
  
end


