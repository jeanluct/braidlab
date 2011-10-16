function tight

import braidlab.*

% Number of strands.
n = 4;
% Word length to optimise.
nw = 4;

%istight(monster)

printbraids = false;

N = n-1;

% Initial braid:  (1 -N-1 -N -N ...)
sig = -N*ones(1,nw);
sig(1) = 1; sig(end) = -N-1;

nwords = (2*N)^(nw-1);

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

  % Check if all generators are present.
  gens = unique(sort(abs(sig)));
  if length(gens) ~= n-1, continue; end

  if printbraids, fprintf('%s  ',num2str(sig)); end
  if istight(sig,n)
    good = good + 1;
    goodones = [goodones; sig];
  else
    if printbraids, fprintf(' ...bad'); end
    bad = bad + 1;
  end
  if printbraids, fprintf('\n'); end
end

fprintf('\ngood=%d  bad=%d  total=%d\n',...
	good,bad,good+bad)
fprintf('\n\nThe best ones (pA candidates):\n\n')

warning('off','BRAIDLAD:braid:entropy:noconv');

pAcand = [];
for i = 1:size(goodones,1)
  entr = entropy(braid(goodones(i,:)));
  if entr > 1e-4
    entrbnd = log(max(abs(eig(burau(braid(goodones(i,:)),'abs')))));
    entrbur = log(max(abs(eig(burau(braid(goodones(i,:)))))));
    pAcand = [pAcand; [goodones(i,:) entr entrbnd entrbur]];
  end
end

pAcand = sortrows(pAcand,nw+1);
colstr = sprintf(['%-' num2str(length(num2str(pAcand(1,1:nw)))) 's'],'braid');
fprintf('%s \tentr         entr(abs)    entr(Burau)\n',colstr)
for i = [1 (find(diff(pAcand(:,nw+1)) > 1e-3)+1)']
  fprintf('%s \t',num2str(pAcand(i,1:nw)))
  fprintf('%7.4f      %7.4f      %7.4f\n', ...
	  pAcand(i,nw+1),pAcand(i,nw+2),pAcand(i,nw+3))
end

% =====================================================================
function ee = istight(sig,n)

import braidlab.*

if nargin < 2
  n = max(abs(sig))+1;
end

a = braid(sig,n);

% Compute entropy (not too accurately, to save time).
entr = a.entropy(1e-3,10);
entrabs = log(max(abs(eig(burau(a,'abs')))));

% Return true if the entropy is equal to the monoid bound.
ee = abs(entr-entrabs) < 5e-3;

% =====================================================================
function ee = istightold(sig,n,nrep)

% The old way: look at all loops between adjacent pairs.

import braidlab.*

% Number of repetitions of the braid to check.
if nargin < 3
  nrep = 2;
end

ee = true;
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
	ee = false;
	return
      end
      l0 = l;
    end
  end
end
