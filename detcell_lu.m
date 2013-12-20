function d = detcell_lu(a)

% This is no good since it requires division to be defined.

n = size(a,1);

for k = 1:n-1
  for i = k+1:n
    a{i,k} = a{i,k} / a{k,k};
    for j = k+1:n
      a{i,j} = a{i,j} - a{i,k}*a{k,j};
    end
  end
end

d = a{1,1};
for k = 2:n, d = d*a{k,k}; end
