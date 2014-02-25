function checksnf(A,U,S,V)

if any(any(A - U*S*V'))
  error('Bad Smith form: not equal to A.')
end

if any(any(eye(size(U)) - U*round(inv(U))))
  error('Bad Smith form: inv(U) not integer.')
end

if any(any(eye(size(V)) - V*round(inv(V))))
  error('Bad Smith form: inv(V) not integer.')
end

if abs(round(det(U))) ~= 1
  error('Bad Smith form: det(U) not +/-1.')
end

if abs(round(det(V))) ~= 1
  error('Bad Smith form: det(V) not +/-1.')
end

S2 = S(1:min(size(S)),1:min(size(S)));
if any(any(S2 ~= diag(diag(S))))
  error('Bad Smith form: S not diagonal.')
end

d = diag(S);
ii = find(d == 0);
nmr = length(d);
if ~isempty(ii)
  if any(diff(ii) ~= 1)
    error('Bad smith form: zeros not contiguous.')
  end
  if ii(end) ~= length(d)
    error('Bad smith form: zeros not at the end.')
  end
  nmr = ii(1)-1;
end

for i = 1:nmr-1
  if mod(d(i+1),d(i))
    error('Bad Smith form: S(%d,%d) does not divide S(%d,%d).',i,i,i+1,i+1)
  end
end
