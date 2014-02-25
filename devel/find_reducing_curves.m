function [linv,Q] = find_reducing_curves(b,m)

import braidlab.*

if nargin < 1, b = 'hy'; end

hally = false;

if ischar(b)
  switch lower(b)
   case {'hy','hallyurttas','hall-yurttas','hally'}
    hally = true;
    if nargin < 2, m = 3; end
    b = braid('hk',m,m+1);
    n = b.n;

    % System of reducing curves from Hall and Yurttas (2009), p. 1563.
    aa = zeros(1,n-2);
    aa(1:m) = (1:m)+1; aa(m+1:n-2) = 2*m+1-(m+1:n-2);
    lred = loop(-aa,ones(1,n-2));
    if b*lred ~= lred, error('Wrong reducing curve.'); end
    figure, plot(lred)

   otherwise
    error('Unknown flag.')
  end
end

n = b.n;

tn = tntype(b);

[M,period] = b.cyclemat;
M = full(M);

% Get rid of "boundary" Dynnikov coordinates, a_(n-1) and b_(n-1).
% If we don't do this there is a second curve around the others.
ii = [(1:n-2) (1:n-2)+n-2+1];
M = M(ii,ii);

if hally
  % Check that reducing curve is invariant.
  if any(M*lred.coords' - lred.coords')
    error('Reducing curve not invatiant under linear action.')
  end
end

A = M - eye(size(M));
[U,D,V] = snf(A);  % Smith form of A.

if any(any(A - U*D*V')), error('Bad Smith form.'); end

D = diag(D);
r = length(find(D ~= 0));

Q = round(inv(V))';
Q = Q(:,r+1:end);

% Now cycle over linear combinations of the columns of Q.

mm = size(Q,2);
if mm == 0, linv = []; return; end

N = 3;  % Go from -N to N in each component.
%nwords = (2*N+1)^mm;

Z = -N*ones(mm,1); Z(end) = -N-1;

linv = [];

while 1
  incr = false;
  % Do not change the first generator (leave at 1).
  for w = mm:-1:1
    if Z(w) < N
      incr = true;
      % Increment the generator.
      Z(w) = Z(w)+1;
      break
    else
      % Otherwise reset generator at that position, and let the
      % loop move on to the next position.
      Z(w) = -N;
    end
  end

  % If nothing was changed, we're done.
  if ~incr, break; end

  %(A*Q*Z)'  % This is zero

  l = loop(Q*Z);
  if b*l == l
    if ~all(l.coords == 0) && ~nested(l)
      linv = [linv ; l];
    end
  end

  %if w == 2, disp(num2str(Z')); end
end
