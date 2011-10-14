% Number of strands.
n = 5;
% Word length to optimise.
nw = 4;
% Number of repetitions of the braid to check.
nrep = 2;

% For n = 5, nw = 4:
% 
%                       Burau entr  edges in TT
%
% 1  3 -2 -4		1.479388    5
% 1 -3 -2  4		0.862555    6          not Burau sharp (1.087)

N = n-1;

% Initial braid:  (1 -N-1 -N -N ...)
sig = -N*ones(1,nw);
sig(1) = 1; sig(end) = -N-1;

nwords = (2*N)^(nw-1)

good = 0;
bad = 0;

goodones = [];

while 1
  incr = false;
  % Do not change the first generator (leave at 1).
  for w = nw:-1:2
    if sig(w) < N
      incr = true;
      % Increment the generator.
      sig(w) = sig(w)+1;
      if sig(w) == 0, sig(w) = sig(w)+1; end
      break
    else
      % Otherwise reset generator at that position, and let the
      % loop move on to the next position.
      sig(w) = -N;
    end
  end

  % If nothing was changed, we're done.
  if ~incr, break; end

  fprintf('%s  ',num2str(sig))
  isbad = false;
  for k = 1:n-1
    fprintf(' l%d=',k)
    b = zeros(1,n-2);
    if k > 1, b(k-1) = -1; end
    if k < n-1, b(k) = 1; end
    u = loop([zeros(1,n-2) b]);
    l0 = length(u)/2;
    for i = 1:nrep
      for j = 1:length(sig)
	u = braid(sig(j),n)*u;
	l = length(u)/2;
	fprintf('%3d ',l-l0)
	if l-l0 < 0
	  fprintf(' ...bad')
	  bad = bad + 1;
	  isbad = true;
	  break
	end
	l0 = l;
      end
      if isbad, break; end
    end
    if isbad, break; end
  end
  if ~isbad
    good = good + 1;
    goodones = [goodones; sig];
  end
  fprintf('\n')
end

fprintf('\ngood=%d  bad=%d  total=%d\n',...
	good,bad,good+bad)
fprintf('\n\nThe best ones (pA candidates):\n\n')

pAcand = [];
for i = 1:size(goodones,1)
  entr = log(max(abs(eig(burau(braid(goodones(i,:)))))));
  gens = unique(sort(abs(goodones(i,:))));
  if length(gens) == n-1
    ispAcand = all(gens == 1:n-1);
  else
    ispAcand = false;
  end
  if entr > 1e-4 & ispAcand
    pAcand = [pAcand; [goodones(i,:) entr]];
  end
end

pAcand = sortrows(pAcand,nw+1);

for i = 1:size(pAcand,1)
  disp([num2str(pAcand(i,1:nw)) '  ' num2str(pAcand(i,nw+1))])
end
