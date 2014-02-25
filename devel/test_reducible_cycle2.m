m = 3;
b = braid('hk',m,m+1);
n = b.n;

close all

if ~(tntype(b) == 'reducible'), error('Not reducible.'); end

% System of reducing curves from Hall and Yurttas (2009), p. 1563.
aa = zeros(1,n-2);
aa(1:m) = (1:m)+1; aa(m+1:n-2) = 2*m+1-(m+1:n-2);
lred = loop(-aa,ones(1,n-2));
if b*lred ~= lred, error('Wrong reducing curve.'); end
figure, plot(lred)

[M,period] = b.cyclemat([],10);
M = full(M);

% Get rid of "boundary" Dynnikov coordinates, a_(n-1) and b_(n-1).
% If we don't do this there is a second curve around the others.
ii = [(1:n-2) (1:n-2)+n-2+1];
M = M(ii,ii);

% Check that reducing curve is invariant.
if any(M*lred.coords' - lred.coords')
  error('Reducing curve not invatiant under linear action.')
end

A = M - eye(size(M));
[U,D,V] = snf(A);

if any(any(A - U*D*V')), error('Bad Smith form.'); end

D = diag(D);
r = length(find(D ~= 0));

P = round(inv(U));
Q = round(inv(V))';

Q = Q(:,r+1:end);

switch m
 case {1,2}
  Q' - lred.coords
 case 3
  Q*[-2 -2 -1 -1]' - lred.coords'
end
