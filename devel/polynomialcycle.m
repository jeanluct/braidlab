function pl = polynomialcycle(b,pnl)

pl = [];

for i = 1:size(pnl,1)
  M = linact(b,pnl(i,:));
  pl = [pl ; charpoly(M)];
end
