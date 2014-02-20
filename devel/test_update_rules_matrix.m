Ntest = 1000;

rng('default')

for i = 1:Ntest
  b = braid('random',5,10);
  l = loop(randi(100,1,2*b.n-2)-50);

  [l2,pn] = recsigns(b,l);

  M = update_rules_matrix(b,pn,size(l.coords,2));

  if any((M*l.coords.').' - l2.coords)
    error('Not equal: %s',num2str((M*l.coords.').' - l2.coords))
  end
end
