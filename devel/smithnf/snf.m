function [U,S,V] = snf(A);
%SNF   Smith normal form of an integer matrix.
%   [U,S,V] = SNF(A) for an integer matrix A returns integer matrices U, S,
%   and V with the properties that
%
%    - A = U*S*V';
%    - S is diagonal and nonnegative;
%    - S(i,i) divides S(i+1,i+1) for all i (here 0 divides 0 by convention);
%    - det U = +-1, and det V = +-1.
%
%   S = SNF(A) just returns diag(S).
%
%   This function is in some ways analogous to SVD.

% John Gilbert, 415-812-4487, December 1993
% gilbert@parc.xerox.com
% Xerox Palo Alto Research Center

% Modified by Jean-Luc Thiffeault for braidlab to work with VPI (Variable
% Precision Integers).

if round(A) ~= A
  error('BRAIDLAB:braid:snf:badarg','Requires integer input.');
end

% This looks much like an SVD algorithm that first bidiagonalizes
% A by Givens rotations and then chases zeros, except for
% the construction of the 2 by 2 elementary transformation.

[m,n] = size(A);
S = A;
typ = str2func(class(A));
U = typ(eye(m));
V = typ(eye(n));

% Bidiagonalize S with elementary Hermite transforms.

for j = 1:min(m,n)
  % Zero column j below the diagonal.
  for i = j+1:m
    if S(i,j) ~= 0
      % Construct an elementary Hermite transformation E
      % to zero S(i,j) by combining rows i and j.
      E = ehermite(S(j,j),S(i,j));
      % Apply the transform to S and U.
      S([j i],:) = E * S([j i],:);
      U(:,[j i]) = U(:,[j i]) * inv2(E);
    end
  end
  % Zero row j after the superdiagonal.
  for i = j+2:n
    if S(j,i) ~= 0
      % Construct an elementary Hermite transformation E
      % to zero S(j,i) by combining columns j+1 and i.
      E = ehermite(S(j,j+1),S(j,i));
      % Apply the transform to S and V.
      S(:,[j+1 i]) = S(:,[j+1 i]) * E';
      V(:,[j+1 i]) = V(:,[j+1 i]) * inv2(E);
    end
  end
end

% Now S is upper bidiagonal.
% Chase the superdiagonal nonzeros away.

D = diag(S,1);
while any(D ~= 0)
  b = min(find(D ~= 0));
  % Start chasing bulge at first nonzero superdiagonal element.

  % To guarantee reduction in S(b,b), first make S(b,b) positive
  % and make S(b,b+1) nonnegative and less than S(b,b).

  if S(b,b) < 0
    S(b,:) = -S(b,:);
    U(:,b) = -U(:,b);
  end

  if S(b,b) ~= 0
    q = floor(S(b,b+1)/S(b,b));
    E = [1 0 ; -q 1];

    S(:,[b b+1]) = S(:,[b b+1]) * E';
    V(:,[b b+1]) = V(:,[b b+1]) * inv2(E);
  end

  if S(b,b+1) ~= 0

    % Zero the first nonzero superdiagonal element
    % using columns b and b+1, to start the bulge at S(b+1,b).
    E = ehermite(S(b,b),S(b,b+1));
    S(:,[b b+1]) = S(:,[b b+1]) * E';
    V(:,[b b+1]) = V(:,[b b+1]) * inv2(E);
    for j = 1:min(m,n)
      if j+1 <= m
        % Zero S(j+1,j) using rows j and j+1.
        E = ehermite(S(j,j),S(j+1,j));
        S([j j+1],:) = E * S([j j+1],:);
        U(:,[j j+1]) = U(:,[j j+1]) * inv2(E);
      end
      if j+2 <= n
        % Zero S(j,j+2) using columns j+1 and j+2.
        E = ehermite(S(j,j+1),S(j,j+2));
        S(:,[j+1 j+2]) = S(:,[j+1 j+2]) * E';
        V(:,[j+1 j+2]) = V(:,[j+1 j+2]) * inv2(E);
      end
    end
  end
  D = diag(S,1);
end

% Now S is diagonal. Make it nonnegative.

for j = 1:min(m,n)
  if S(j,j) < 0
    S(j,:) = -S(j,:);
    U(:,j) = -U(:,j);
  end
end

% Squeeze factors to lower right to enforce divisibility condition.

for i = 1 : min(m,n)
  for j = i+1 : min(m,n)
    % Replace S(i,i), S(j,j) by their gcd and lcm respectively.
    a = S(i,i);
    b = S(j,j);
    [g,c,d] = gcd(a,b);
    if g ~= 0
      E = [ 1 d ; -b/g a*c/g];
      F = [ c 1 ; -b*d/g a/g];
      S([i j],[i j]) = E * S([i j],[i j]) * F';
      U(:,[i j]) = U(:,[i j]) * inv2(E);
      V(:,[i j]) = V(:,[i j]) * inv2(F);
    end
  end
end

U = round(U);
V = round(V);

if nargout <= 1
  U = diag(S);
end

end

%=========================================================================
function E = ehermite(a,b);

% Elementary Hermite tranformation.
%
% For integers a and b, E = ehermite(a,b) returns
% an integer matrix with determinant 1 such that E * [a;b] = [g;0],
% where g is the gcd of a and b.
% E = ehermite(a,b)
%
% This function is in some ways analogous to GIVENS.

% John Gilbert, 415-812-4487, December 1993
% gilbert@parc.xerox.com
% Xerox Palo Alto Research Center

[g,c,d] = gcd(a,b);
if g ~= 0
  E = [c d ; -b/g a/g];
else
  E = [1 0 ; 0 1];
end

end

%=========================================================================
function Ei = inv2(E)

detE = E(1,1)*E(2,2) - E(1,2)*E(2,1);

if abs(detE) ~= 1
  error('BRAIDLAB:braid:snf:detnotone','Determinant should be one.')
end

Ei = detE*[E(2,2) -E(1,2); -E(2,1) E(1,1)];

end
