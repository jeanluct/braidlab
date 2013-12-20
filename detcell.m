function d = detcell(a)

% Compute the determinant using the cofactor expansion.
%
% Inefficient, but avoids division.

n  = size(a,2);
m = cell(n-1);

if n == 1, d = a{1,1}; return; end
if n == 2, d = a{1,1}*a{2,2} - a{1,2}*a{2,1}; return; end

d = 0;

for k = 1:n
  for i = 2:n
    h = 1;
    for j = 1:n
      if j == k, continue; end
      m{i-1,h} = a{i,j};
      h = h + 1;
    end
  end
  % sum (+/-) cofactor * minor matrix.
  d = d + (-1)^(k+1) * a{1,k} * det2(m);
end
