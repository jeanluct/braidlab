rng('default')

n = 5;
k = 5;
Nreal = 100;
maxit = 0;
maxperiod = 0;

global BRAIDLAB_debuglvl
BRAIDLAB_debuglvl = 1;

for r = 1:Nreal
  b = braid('random',n,k);
  fprintf('b = %s:\t',char(b))
  [pn,it] = lacycle(b);
  if isempty(pn)
    error('Failed to converge after %d iterations: %s\n',char(b),it);
  end
  maxit = max(maxit,it);
  maxperiod = max(size(pn,1),maxperiod);
end

fprintf('Maximum iterations: %d\n',maxit)

BRAIDLAB_debuglvl = 0;
