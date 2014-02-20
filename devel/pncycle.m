function [varargout] = pncycle(b,maxit)

% Check if pos/neg operators in loopsigma eventually reach a limit cycle.

import braidlab.*

if nargin < 1, b = compact(braid('psi',9)); end

if nargin < 2, maxit = 200; end

l = loop(b.n,'vpi');

% Number of consecutive full periods we require to declare convergence.
nconvreq = 5;

nconv = 0;
pnl = [];

for i = 1:maxit
  [l,pn] = recsigns(b,l);
  pnl = [pnl ; pn];
  if nconv == 0
    % Check if we appear to have reached a limit cycle.
    for p = 1:i-1
      if all(pnl(end,:) == pnl(end-p,:))
        period = p;
        nconv = 1;
        break;
      end
    end
  else
    % Are we still in the same limit cycle?
    if all(pnl(end,:) == pnl(end-period,:))
      nconv = nconv + 1;
      if ~mod(nconv,period)
        debugmsg(sprintf('Converged for %d period(s)...\n',nconv/period),1)
      end
      if nconv >= nconvreq*period
        fprintf('Converged after %d iterations with period %d.\n',i,period)
        break
      end
    else
      warning('False convergence after %d time(s)!\n',nconv)
      nconv = 0;
    end
  end
end

if i == maxit
  varargout{1} = [];
else
  imagesc(pnl.')
  colormap bone
  xlabel('iteration')
  ylabel('pos / neg')

  % Just output the cycle.
  varargout{1} = pnl(end-period+1:end,:);
end

if nargout > 1, varargout{2} = i; end
