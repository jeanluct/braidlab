m = 2;
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

acc = 1e-7;

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

[V,D] = eig(M);
D = diag(D);

% Keep only eigenvectors with eigenvalue one.
iones = find(abs(D-1) < acc);
Vones = V(:,iones);

% Find complex vectors.
icomp = [];
for i = 1:size(Vones,2)
  ev = Vones(:,i);
  if any(find(abs(imag(ev)) > acc)), icomp = [icomp i]; end
end
% Try to keep only the real combination.  What's the best way?

% Find eigenvectors with integer entries.
isloop = [];
for i = 1:size(Vones,2)
  ev = Vones(:,i);

  % Make entries real if imaginary part is small.
  ireal = find(abs(imag(ev)) < acc);
  %if length(ireal) ~= size(M,1), continue; end
  ev(ireal) = real(ev(ireal));

  % Make entries real if imaginary part is small.
  izero = find(abs(ev) < acc);
  ev(izero) = 0;

  % Normalize by smallest nonzero entry, such that the entry is positive.
  innz = find(abs(ev) > acc);
  minev = min(abs(ev(innz)));
  ev = ev / (sign(ev(innz(1)))*minev);

  iint = (abs(ev - round(ev)) < acc);
  if all(iint)
    isloop = [isloop i];
    ev = round(ev);
  end
  Vones(:,i) = ev;
end

Vloop = unique(Vones(:,isloop).','rows').';

for i = 1:size(Vloop,2)
  for s = [-1 1]
    l = loop(s*Vloop(:,i));
    l2 = b*l;
    fprintf('In: %s\t',char(l))
    fprintf('Out: %s',char(l2))
    if l == l2
      figure
      fprintf(' ...matches!')
      plot(l)
    end
    fprintf('\n')
  end
end
