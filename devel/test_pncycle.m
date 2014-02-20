rng('default')

n = 5;
k = 5;
Nreal = 100;
maxit = 0;
maxperiod = 0;

for r = 1:Nreal
  b = braid('random',n,k);
  fprintf('b = %s: ',char(b))
  [pn,it] = pncycle(b);
  if isempty(pn)
    error('Failed to converge after %d iterations: %s\n',char(b),it);
  end
  maxit = max(maxit,it);
  maxperiod = max(size(pn,1),maxperiod);
end

fprintf('Maximum iterations: %d\n',maxit)
