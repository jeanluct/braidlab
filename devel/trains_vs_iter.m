% Compare computation of entropy between BH (trains) and iterative (iter).

import braidlab.*

rng(1)

forcepA = false;
testred = false;
warndiscr = true;
nmax = 10;%20;
kmax = nmax+10;%+30;
nrep = 10;

if forcepA
  kmin = n+1;
else
  kmin = 1;
end

t_iter = zeros(nmax,kmax);
t_trains = zeros(nmax,kmax);
entr_iter = zeros(nmax,kmax);
entr_trains = zeros(nmax,kmax);
entr_diff = zeros(nmax,kmax);

warning('off','BRAIDLAB:braid:entropy:noconv')
warning('off','BRAIDLAB:braid:entropy:reducible')

for n = 3:nmax
  disp(n)
  for k = kmin:kmax
    for r = 1:nrep
      if forcepA
	TN = 'reducible';
	while ~strcmp(TN,'pseudo-Anosov')
	  b = braid('random',n,k);
	  [TN,~] = tntype(b);
	end
      else
	b = braid('random',n,k);
	[TN,~] = tntype(b);
      end

      tic
      entr_iter(n,k) = entropy(b);
      t_iter(n,k) = t_iter(n,k) + toc;

      tic
      try
	entr_trains(n,k) = entropy(b,'trains');
      catch err
	if strcmp(err.identifier,'BRAIDLAB:braid:tntype_helper:notdecr')
	  entr_trains(n,k) = NaN;
	else
	  rethrow(err);
	end
      end
      t_trains(n,k) = t_trains(n,k) + min(toc,1);

      if strcmp(TN,'reducible'), entr_trains(n,k) = NaN; end

      if ~isnan(entr_trains(n,k))
	discr = abs(entr_trains(n,k) - entr_iter(n,k));
      else
	discr = -1;
      end
      entr_diff(n,k) = max(entr_diff(n,k),discr);

      if discr > 1e-3 & warndiscr
	warning('Large discrepancy (%f) for braid %s.\n',...
		discr,num2str(b.word));
      end
    end
  end
end

t_diff = t_iter - t_trains;

figure(1)
imagesc(t_diff)
axis xy
colorbar
xlabel('k')
ylabel('n')
r = [1 0 0]; w = [.9 .9 .9]; b = [0 0 1];
% colormap of size 64-by-3, ranging from red -> white -> blue
mid = round(-64*min(min(t_diff))/(max(max(t_diff)) - min(min(t_diff))));
c1 = zeros(mid,3); c2 = zeros(64-mid,3);
for i = 1:3
  c1(:,i) = linspace(r(i), w(i), mid);
  c2(:,i) = linspace(w(i), b(i), 64-mid);
end
c = [c1(1:end-1,:);c2];
caxis([min(min(t_diff)) max(max(t_diff))]), colormap(c), colorbar

figure(2)
imagesc(log10(abs(entr_diff)))
axis xy
title('log_{10} |entr_{diff}|')
xlabel('k')
ylabel('n')
caxis([-8 max(max(log10(abs(entr_diff))))]), colorbar

figure(3)
subplot(2,1,1)
imagesc(entr_iter)
text(1,nmax-1,'entr_{iter}')
axis xy
colorbar
ylabel('n')
subplot(2,1,2)
imagesc(entr_trains)
text(1,nmax-1,'entr_{trains}')
axis xy
colorbar
xlabel('k')
ylabel('n')
