b = braid('psi',15);
pn = cycle(b);

pl = polynomialcycle(b,pn);

rl = [];

for i = 1:size(pl,1)
  r = roots(pl(i,:)).';
  [~,i] = sort(abs(r),'descend');
  rl = [rl ; r(i)];
end

rldiff = abs(rl  - repmat(rl(1,:),[size(rl,1) 1]));
noteq = [];
for i = 1:size(rldiff,1)
  noteq = [noteq find(rldiff(i,:) > 1e-12)];
end
noteq= unique(noteq);
fprintf('Differing roots have magnitude\n%s\n',num2str(abs(rl(1,noteq))))
