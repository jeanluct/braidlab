% Check if pos/neg operators in loopsigma eventually stabilize.

b = compact(braid('psi',9));

l = loop(b.n);

nconv = 0;
pnl = [];

for i = 1:200
  [l,pn] = recsigns(b,l);
  pnl = [pnl ; pn];
  if i > 1
    if all(pnl(end,:) == pnl(end-1,:))
      nconv = nconv + 1;
      if nconv >= 5
	fprintf('converged after %d iterations.\n',i)
	break
      end
    else
      nconv = 0;
    end
  end
end

imagesc(pnl.')
colormap bone
xlabel('iteration')
ylabel('pos / neg')
