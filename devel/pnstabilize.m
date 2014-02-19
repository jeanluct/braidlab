% Check if pos/neg operators in loopsigma eventually stabilize.

b = compact(braid('psi',9));

l = loop(b.n,'vpi');

% Number of consecutive periods we require to declare convergence.
nconvreq = 5;

nconv = 0;
pnl = [];

for i = 1:200
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
        fprintf('Converged for %d period(s)...\n',nconv/period)
      end
      if nconv >= nconvreq*period
        fprintf('Converged after %d iterations with period %d.\n',i,period)
        break
      end
    else
      fprintf('** False convergence after %d time(s)!\n',nconv)
      nconv = 0;
    end
  end
end

imagesc(pnl.')
colormap bone
xlabel('iteration')
ylabel('pos / neg')
