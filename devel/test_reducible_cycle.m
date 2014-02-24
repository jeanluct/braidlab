m = 2;
b = braid('hk',m,m+1);
n = b.n;

close all

acc = 1e-4;

if ~(tntype(b) == 'reducible'), error('Not reducible.'); end

[M,period] = b.cyclemat('plot',[],10);
M = full(M);

if true
  % Get rid of "redundant" Dynnikov coordinates, a_(n-1) and b_(n-1):
  ii = 1:n-2; ii = [ii ii+n-2+1];
  M = M(ii,ii);
end

[V,D] = eig(M);

%if max(max(abs(M - V*D*inv(V)))) > acc
%  error('Bad diagonalization.')
%end

% Find eigenvectors with integer entries.
isloop = [];
for i = 1:size(M,1)
  ev = V(:,i);

  % Make entries real if imaginary part is small.
  ireal = find(abs(imag(ev)) < acc);
  if length(ireal) ~= size(M,1), continue; end
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
  V(:,i) = ev;
end

Vloop = unique(V(:,isloop).','rows').';

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
