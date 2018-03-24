% Test program to check when the internal algorithm for entropy overflows.

% See issue #138.

import braidlab.*

global BRAIDLAB_debuglvl BRAIDLAB_braid_nomex
BRAIDLAB_debuglvl = 1;
BRAIDLAB_braid_nomex = false;
%BRAIDLAB_braid_nomex = true;

% A simple pA braid and its entropy.
b0 = braid([1 -2]);
entr0 = entropy(b0);

% Estimate max number of repetitions before we overflow.
Nrepmax = ceil(log(realmax)/entr0);

for divNrepmax = [10 5 3 2]
  % Number of repetitions of basic braid: inch our way towards Nrepmax.
  rep = ceil(Nrepmax/divNrepmax);
  fprintf('b0^%d\thas entropy %.3e',rep,entropy(b0^rep));
  fprintf(' (exact=%.3e)\n',rep*entr0)
end

% Direct method: compute generator-by-generator, 
% Do the last case above.
% (This is much slower!  Use larger "chunks" to make it faster.)
b = b0^rep;
l = loop(b.n); l = loop(l.coords/minlength(l));  % normalized initial loop
loglen = 0;
for i = 1:length(b)
  l1 = braid(b.word(i),b.n)*l;
  len = minlength(l1);
  loglen = loglen + log(len); % keep track of log-growth
  l = loop(l1.coords/len);    % keep loop coordinates normalized to avoid
                              % overflow.
end
fprintf('\nentropy from per-generator computation=%.3e\n',loglen)

% Yet another way: use complexity, but with arbitrary precision.
l = loop(b.n,@vpi);
l1 = b*l;
% The minlength function doesn't seem to work well with VPI, so use L^1
% norm of entries instead.
fprintf('\nentropy using Variable Precision Integers (VPI)=%.3e\n', ...
        log(sum(abs(double(l1.coords)))) - log(sum(abs(double(l.coords)))))
