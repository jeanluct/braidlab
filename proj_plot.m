%projr33
projr50

n = size(A,3);

%A = closure(A,'mindist');

t = 1:size(A,1);
X = squeeze(A(:,1,:));
Y = squeeze(A(:,2,:));

for i = 1:size(X,2)
  plot3(X(:,i),Y(:,i),t)
  hold all
end
hold off

Dist = zeros(length(t),n,n);

for i = 1:n
  for j = 1:n
    if i ~= j
      dX = X(:,i) - X(:,j);
      dY = Y(:,i) - Y(:,j);
      Dist(:,i,j) = hypot(dX,dY);
    else
      Dist(:,i,j) = NaN;
    end
  end
end

mindist = zeros(length(t),1);
for i = 1:length(t)
  mindist(i) = min(min(Dist(i,:,:)));
end

proj = linspace(0,pi,6);
proj = proj + .01*rand(size(proj));
Ac = closure(A,'mindist');
%cb0 = cfbraid(braid(Ac,.0012321));
for i = 1:length(proj)
  b = braid(Ac,proj(i));
%  conjtest(cb0,cfbraid(b))
%  entropy(b,1e-10,1000)
  entropy(b)
end

return

b = braid(A);
tntype(b)
entropy(b)
entropy(b,'trains')

%b2 = braid(A,pi/4);
b2 = braid(A,.6);
tntype(b2)
entropy(b2)
entropy(b2,'trains')
