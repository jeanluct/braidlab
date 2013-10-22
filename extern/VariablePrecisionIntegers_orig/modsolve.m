function x = modsolve(A,rhs,p)
% modsolve: solves the modular system of equations such that: mod(A*x - rhs,p) = 0
% usage: x = modsolve(A,rhs,p) % Solve the modular system
% usage: x = modsolve(A,[],p)  % Compute the modular inverse of A
%
% arguments: (input)
%  A   - (nxn) square matrix, composed of integers
%
%  rhs - (nxp) vector or array of right hand sides
%        If rhs is empty, then the modular inverse
%        of A will be returned in x.
%
%  p   - scalar, integer. Denotes the modular base
%        used in the computations. p MUST be a prime
%        number, p >= 2
%
% arguments: (output)
%  x   - contains the solution to the modular problem
%        mod(A*x - rhs,p) = 0
%
%        IF rhs was empty, then x contains the
%        inverse of A, i.e., the solution to
%        mod(A*x - eye(n),p) = 0
%
%        IF A is singular, modulo p, then x will be
%        returned with all NaN elements, and a warning
%        will be generated.
%
% Example:
%  A = mod(magic(3),7)
% %  A =
% %      1     1     6
% %      3     5     0
% %      4     2     2
%
% % Compute the inverse, modulo 7
% Ainv = modsolve(A,[],7)
% % Ainv =
% %       6     6     3
% %       2     5     1
% %       0     4     4
%
% % Verify that this is a valid inverse
% mod(A*Ainv,7)
% % ans =
% %      1     0     0
% %      0     1     0
% %      0     0     1
%
% % ===================================
% Example:
% % Solve for a given right hand side, modulo 11
% A = mod(magic(5),11);
% rhs = [6 7 9 3 0]';
%
% x = modsolve(A,rhs,11)
% % x =
% %      6
% %     10
% %      8
% %      7
% %     10
%
% % Verification step
% mod(A*x - rhs,11)
% % ans =
% %      0
% %      0
% %      0
% %      0
% %      0
%
% % ===================================
% Example: 
% % A is a singular matrix, modulo 5
%  A = mod(magic(3),5)
% % A =
% %      3     1     1
% %      3     0     2
% %      4     4     2
%
% % Attempt to compute the inverse, modulo 5
% x = modsolve(A,[],5)
% % Warning: A is a singular matrix (modulo p)
% % In modsolve at 135
% % x =
% %     NaN   NaN   NaN
% %     NaN   NaN   NaN
% %     NaN   NaN   NaN
%
%
% See also: mod, rem, inv, linsolve, slash
%
% Author: John D'Errico
% e-mail: woodchips@rochester.rr.com
% Release: 1.0
% Release date: 11/7/09

% error checks
if (nargin ~= 3)
  error('MODSOLVE:improperarguments','Three arguments are required')
end

if ~(isnumeric(A) || islogical(A) || isa(A,'vpi'))
  error('MODSOLVE:improperA','A must be numeric or logical')
end

sizeA = size(A);
if (any(rem(A(:),1) ~= 0)) || (numel(sizeA)>2) || (sizeA(1) ~= sizeA(2))
  error('MODSOLVE:improperA','A must be a numeric or logical square, integer array')
end
n = sizeA(1);

% if rhs is empty, then we compute the inverse of A
if isempty(rhs)
  rhs = eye(n,n);
elseif (size(rhs,1) ~= n)
  error('MODSOLVE:improperrhs','rhs does not conform in size with A')
elseif any(rem(rhs(:),1) ~= 0)
  error('MODSOLVE:improperrhs','rhs must be an integer vector or array')
end

% how many right hand sides are there to solve for?
nrhs = size(rhs,2);

% p must be integer and prime
if (numel(p) ~= 1) || (rem(p,1) ~= 0) || (p <= 1) || ~isprime(p)
  error('MODSOLVE:improperp','p must be scalar, integer, and prime')
end

% ensure that all of A and rhs are reduced modulo p
A = mod(A,p);
rhs = mod(rhs,p);

% do the forward Gaussian elimination step.
% Use row pivoting, but not column pivoting.
% column pivots are unnecessary, as numerical
% problems cannot exist in modular arithmetic.
%
% Note that these computations could be special
% cased for p = 2. This would just use xor. I'm
% not sure it is really worth the effort though.
for i = 1:(n-1)
  % choose a row to swap, in case the ith row
  % of A has a zero pivot element
  if A(i,i) == 0
    % a zero pivot element, so we must do a
    % row swap
    k = i + find(A((i+1):end,i),1,'first');
    
    if isempty(k)
      % oops. singular A
      warning('MODSOLVE:singularitydetected','A is a singular matrix (modulo p)')
      x = nan(n,nrhs);
      return
    end
    
    % do the swap
    A([i k],:) = A([k i],:);
    rhs([i k],:) = rhs([k i],:);
    
  end
  
  % at this point, we are assured that A(i,i)
  % is non-zero, so it has a multiplicative
  % inverse, modulo p.
  Apiv = A(i,i);
  Apivinv = minv(Apiv,p);
  
  % multiply the ith row by the inverse of Apiv
  A(i,i) = 1;
  A(i,(i+1):end) = mod(A(i,(i+1):end)*Apivinv,p);
  rhs(i,:) = mod(rhs(i,:)*Apivinv,p);
  
  % Kill off the rows below the pivot in this column
  % that are non-zero.
  k = i + find(A((i+1):end,i));
  rhs(k,:) = mod(rhs(k,:) - A(k,i)*rhs(i,:),p);
  A(k,i:end) = mod(A(k,i:end) - A(k,i)*A(i,i:end),p);
  
end
% when we drop down to this point, A is now upper
% triangular, with unit diagonal elements, down to the
% last element, which need not be so so far. Make it so.
if A(n,n) == 0
  % oops. singular A
  warning('MODSOLVE:singularitydetected','A is a singular matrix (modulo p)')
  x = nan(n,nrhs);
  return
elseif A(n,n) ~= 1
  % if it was 1, then we could skip this
  rhs(n,:) = mod(rhs(n,:)*minv(A(n,n),p),p);
  A(n,n) = 1;
end

% Do a backsolve to get x. Preallocate
% x to have the same class as p.
if isa(p,'vpi')
  x = repmat(vpi(0),n,nrhs);
else
  x = zeros(n,nrhs,class(p));
end

x(n,:) = rhs(n,:);
for i = (n-1):-1:1
  x(i,:) = mod(rhs(i,:) - A(i,(i+1):end)*x((i+1):end,:),p);
end


