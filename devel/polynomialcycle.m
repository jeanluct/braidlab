function pl = polynomialcycle(b,pnl)

pl = [];

for i = 1:size(pnl,1)
  M = update_rules_matrix(b,pnl(i,:));
  pl = [pl ; charpoly(M)];
end
