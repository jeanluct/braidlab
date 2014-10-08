function test_cycle

import braidlab.*

rng('default')

n = 10;
k = 10;
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
    try
      verify_cycle(b,M,period,it,@double);
    catch err
      if (strcmp(err.identifier,'BRAIDLAB:test_cycle:wrong2'))
        fprintf('retrying with VPI...')
        verify_cycle(b,M,period,it,@vpi);
        fprintf(' ok.\n')
      else
        BRAIDLAB_debuglvl = BRAIDLAB_debuglvl_save;
        rethrow(err)
      end
    end
  end
end

fprintf('Max iterations: %d     Max period: %d\n',maxit,maxperiod)

BRAIDLAB_debuglvl = BRAIDLAB_debuglvl_save;

%=================================================================
function verify_cycle(b,M,period,it,typ)

l = braidlab.loop(b.n,typ);

% Make sure we've converged to the periodic cycle.
l = b^it*l;
[l1,M2] = b^period*l;

if any(M ~= M2)
  error('BRAIDLAB:test_cycle:wrong1','Something went wrong (1).')
end

l2 = braidlab.loop(typ(M2*l.coords.'));

if l1 ~= l2
  error('BRAIDLAB:test_cycle:wrong2','Something went wrong (2).')
end
