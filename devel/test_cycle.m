rng('default')

n = 5;
k = 5;
Nreal = 100;
maxit = 0;
maxperiod = 0;

global BRAIDLAB_debuglvl
if exist('BRAIDLAB_debuglvl','var')
  BRAIDLAB_debuglvl_save = BRAIDLAB_debuglvl;
else
  BRAIDLAB_debuglvl_save = 0;
end
BRAIDLAB_debuglvl = 1;

for r = 1:Nreal
  b = braid('random',n,k);
  fprintf('b = %s:\t',char(b))
  [M,period,it] = cycle(b);
  maxit = max(maxit,it);
  maxperiod = max(period,maxperiod);

  % Doublecheck effective linear action.
  if true
    l = loop(b.n);
    % Make sure we've converged to the periodic cycle.
    l = b^it*l;
    [l1,M2] = b^period*l;
    if any(M ~= M2)
      BRAIDLAB_debuglvl = BRAIDLAB_debuglvl_save;
      error('Something went wrong (1).')
    end
    l2 = loop(M2*l.coords.');
    if l1 ~= l2
      BRAIDLAB_debuglvl = BRAIDLAB_debuglvl_save;
      error('Something went wrong (2).')
    end
  end
end

fprintf('Max iterations: %d     Max period: %d\n',maxit,maxperiod)

BRAIDLAB_debuglvl = BRAIDLAB_debuglvl_save;
